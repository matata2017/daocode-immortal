# 回答分析系统 (Answer Analysis System)

> **Status**: Designed
> **Author**: User + Claude Code
> **Last Updated**: 2026-03-30
> **Implements Pillar**: 实用至上

## Overview

**回答分析系统**负责分析玩家的答题答案，调用 MiniMax AI 判断答案正确性，生成反馈和追问建议。

系统接收玩家的文字/代码答案，通过 API 代理后端调用 MiniMax AI，根据 Prompt 模板生成分析结果，返回：答案判定（正确/部分正确/错误）、AI 反馈文本、追问建议、讲解内容。

**为什么需要这个系统**: 没有回答分析，玩家答题后只能看到"对/错"，无法获得深入反馈。AI 驱动的分析让每次答题都成为学习机会，提供"为什么对/错"、"如何改进"等有价值的反馈，实现"实用至上"支柱。

## Player Fantasy

玩家期望体验：

**1. 智能反馈的价值感**
- "AI 真的懂我的答案，不只是对错判定"
- 答对时：告诉"为什么对"，巩固知识
- 答错时：告诉"错在哪"、"如何改进"，真正学到东西

**2. 追问的压力与成长**
- 答对后 AI 继续追问，考验是否真正理解
- 追问让"蒙对"无处藏身，确保掌握
- 深入追问带来面试真实感

**3. 个性化体验**
- 不同 BOSS 性格对应不同反馈风格
- 外包厂HR 友好鼓励，大厂长老严肃严谨
- AI 反馈贴合角色，沉浸感强

## Detailed Design

### Core Rules

#### 答案判定类型

| 判定类型 | 条件 | 反馈策略 |
|----------|------|----------|
| **完全正确** | 答案完全匹配或 AI 判定为正确 | 正向反馈 + 可选追问 |
| **部分正确** | 答案有对有错，理解不完整 | 指出正确部分 + 补充讲解 + 追问 |
| **完全错误** | 答案完全错误或无关 | 错误反馈 + 详细讲解 + 引导提示 |

#### 开放式题目评分机制

对于没有标准答案的开放式题目（如"设计秒杀系统"），采用**多维度打分**机制：

**评分维度**：

| 维度 | 说明 | 权重 |
|------|------|------|
| **完整性** | 是否覆盖关键模块/要点 | 30% |
| **深度** | 是否考虑边界情况、异常处理 | 25% |
| **可行性** | 方案是否实际可行 | 25% |
| **规范性** | 是否遵循最佳实践 | 20% |

**分数阈值与判定**：

| 总分范围 | 等级 | 判定 | 修为奖励 |
|----------|------|------|----------|
| 35-40 | 优秀 | 完全正确 | 100% 基础值 |
| 25-34 | 良好 | 部分正确 | 70% 基础值 |
| 15-24 | 及格 | 基本正确 | 40% 基础值 |
| 0-14 | 不及格 | 错误 | 0% |

**AI Prompt 示例**：
```
你是面试官，评估候选人对"{question}"的回答。

评分维度（每项0-10分）：
1. 完整性：是否覆盖核心模块
2. 深度：是否考虑边界情况
3. 可行性：方案是否实际可行
4. 规范性：是否遵循最佳实践

玩家答案：
{player_answer}

参考要点：
{key_points}

请返回JSON格式：
{
  "scores": {"completeness": X, "depth": X, "feasibility": X, "standards": X},
  "total_score": X,
  "feedback": "具体反馈",
  "improvement_suggestions": ["建议1", "建议2"]
}
```

#### 分析流程

```
1. 接收答题数据
   - question_id
   - player_answer (文字/代码)
   - question_type (选择/代码/应用/开放)
   - boss_id

2. 判断题型分支
   IF 选择题:
     直接比对答案（无需 AI）
   IF 代码题/应用题:
     调用 AI 分析（正确/部分正确/错误）
   IF 开放式题目:
     调用 AI 多维度打分

3. 构建 AI 请求
   - 从 Prompt 管理系统获取模板
   - 填充变量：{question}, {player_answer}, {correct_answer}, {boss_style}
   - 开放式题目额外填充：{key_points}
   - 设置参数：temperature, max_tokens

4. 调用 API 代理后端
   - POST /api/v1/chat/completions
   - 等待响应（超时处理）

5. 解析 AI 响应
   - 判定结果：correct / partial / wrong（或 open_score）
   - 反馈文本：feedback_text
   - 追问建议：follow_up_question (可选)
   - 讲解内容：explanation
   - 开放式题目额外：scores, improvement_suggestions

6. 返回分析结果
   - 给调用方（BOSS 面试系统/答题修炼系统）
```

#### AI 请求参数配置

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `temperature` | 0.7 | 创造性（0-1），越高越随机 |
| `max_tokens` | 500 | 最大返回 token 数 |
| `timeout_ms` | 5000 | 请求超时时间 |

#### 缓存策略

**缓存键**: `hash(question_id + player_answer + boss_id)`

**缓存规则**:
- 相同问题+相同答案+相同BOSS → 返回缓存结果
- 缓存有效期：24小时
- 缓存命中时直接返回，不调用 AI

### States and Transitions

```
┌─────────────────┐
│   空闲状态       │  等待答题请求
└────────┬────────┘
         │ receive_answer()
         ↓
┌─────────────────┐
│   参数验证中     │  验证 question_id, player_answer
└────────┬────────┘
         │ 验证通过
         ↓
┌─────────────────┐
│   缓存查询中     │  检查是否有缓存结果
└────────┬────────┘
         │
    ┌────┴────┐
    ↓         ↓
┌───────┐  ┌───────────┐
│命中缓存│  │ 未命中缓存 │
└───┬───┘  └─────┬─────┘
    │            │
    │            ↓
    │      ┌───────────┐
    │      │ AI请求中   │
    │      └─────┬─────┘
    │            │
    │      ┌─────┴─────┐
    │      ↓           ↓
    │  ┌───────┐  ┌─────────┐
    │  │成功   │  │ 失败    │
    │  └───┬───┘  └────┬────┘
    │      │           │
    └──────┴───────────┘
           │
           ↓
    ┌───────────────┐
    │ 解析响应中     │
    └───────┬───────┘
            │
            ↓
    ┌───────────────┐
    │ 返回结果       │
    └───────────────┘
```

### Interactions with Other Systems

| 系统 | 数据流向 | 接口 |
|------|----------|------|
| **API代理后端** | 写入 | `POST /api/v1/chat/completions` |
| **Prompt管理系统** | 读取 | `get_prompt_template(type, boss_id)` |
| **题库数据系统** | 读取 | `get_question_by_id(question_id)` 获取题目和正确答案 |
| **BOSS面试系统** | 双向 | `analyze_answer()` → 返回分析结果 |
| **答题修炼系统** | 双向 | `analyze_answer()` → 返回分析结果 |
| **面试报告系统** | 写入 | `add_analysis_result()` 记录分析历史 |

## Formulas

### 选择题直接判定（无需 AI）
```
IF player_answer == correct_answer:
    verdict = "correct"
    confidence = 1.0
ELSE:
    verdict = "wrong"
    confidence = 1.0
```

### AI 判定解析
```
parse_ai_response(response_text) -> {
    verdict: "correct" | "partial" | "wrong",
    confidence: 0.0-1.0,
    feedback_text: String,
    follow_up_question: String | null,
    explanation: String
}

where:
  response_text = AI 返回的原始文本
  verdict = 从 response_text 中提取的判定结果
  confidence = AI 对判定的置信度
```

### AI Prompt 构建
```
build_analysis_prompt(question, player_answer, correct_answer, boss_style) =
    template = get_prompt_template("ANSWER_ANALYSIS", boss_id)
    prompt = template
        .replace("{question}", question)
        .replace("{player_answer}", player_answer)
        .replace("{correct_answer}", correct_answer)
        .replace("{boss_style}", boss_style)
    return prompt
```

### 请求超时处理
```
IF api_response_time > timeout_ms:
    use_fallback_response()

fallback_response = {
    verdict: "unknown",
    confidence: 0.0,
    feedback_text: "网络超时，请稍后重试",
    follow_up_question: null,
    explanation: null
}
```

### 答案相似度计算（用于部分正确判定）
```
similarity_score = levenshtein_distance(player_answer, correct_answer) / max_length

where:
  levenshtein_distance = 编辑距离
  max_length = max(len(player_answer), len(correct_answer))

IF similarity_score >= 0.8:
    verdict_hint = "可能正确"
ELIF similarity_score >= 0.5:
    verdict_hint = "部分正确"
ELSE:
    verdict_hint = "可能错误"
```

**注意**: 相似度只是给 AI 的参考，最终判定由 AI 决定。

## Edge Cases

| 边缘情况 | 处理方式 | 影响范围 |
|----------|----------|----------|
| **玩家答案为空** | 返回错误 "请输入答案"，不调用 AI | 答题流程 |
| **AI 请求超时** | 使用降级回复模板，提示"网络超时，请稍后重试" | 答题反馈 |
| **AI 返回格式错误** | 尝试解析关键词，失败则使用降级回复 | 答题反馈 |
| **API 代理后端不可用** | 使用离线降级模式，预设回复模板 | 答题反馈 |
| **缓存命中但数据损坏** | 忽略缓存，重新调用 AI | 缓存系统 |
| **玩家答案过长（>1000字）** | 截断到 1000 字，提示"答案过长已截断" | 答题流程 |
| **玩家答案含特殊字符** | 过滤危险字符，防止 Prompt 注入 | 安全性 |
| **同一问题连续多次请求** | 触发限流，返回"请求过于频繁" | API 调用 |
| **BOSS 性格未配置** | 使用通用 Prompt 模板 | Prompt 管理 |
| **题目已被删除** | 返回错误"题目不存在" | 答题流程 |
| **AI 判定置信度过低（<0.5）** | 标记为"需要人工复核"，降级处理 | 分析结果 |

## Dependencies

### 上游依赖（此系统依赖的系统）
| 系统 | 依赖类型 | 依赖内容 | 接口契约 |
|------|----------|----------|----------|
| **API代理后端** | 硬依赖 | 调用 MiniMax AI 分析答案 | `POST /api/v1/chat/completions` |
| **Prompt管理系统** | 硬依赖 | 获取答案分析 Prompt 模板 | `get_prompt_template(type, boss_id)` |
| **题库数据系统** | 硬依赖 | 获取题目和正确答案 | `get_question_by_id(question_id)` |

### 下游依赖（依赖此系统的系统）
| 系统 | 依赖类型 | 依赖内容 | 接口契约 |
|------|----------|----------|----------|
| **BOSS面试系统** | 硬依赖 | 分析玩家答题答案 | `analyze_answer(question_id, player_answer, boss_id)` |
| **答题修炼系统** | 硬依赖 | 分析修炼答题答案 | `analyze_answer(question_id, player_answer)` |
| **面试报告系统** | 软依赖 | 获取分析历史记录 | `get_analysis_history()` |

### 依赖关系图
```
题库数据系统 ─────────┐
                      │
Prompt管理系统 ────────┼──→ 回答分析系统 ──→ BOSS面试系统
                      │                      │
API代理后端 ───────────┘                      │
                                             ↓
                                      面试报告系统
```

## Tuning Knobs

| Knob | 类型 | 默认值 | 范围 | 影响范围 |
|------|------|--------|------|----------|
| `ai_temperature` | float | 0.7 | 0.0-1.0 | AI 回复的创造性/随机性 |
| `ai_max_tokens` | int | 500 | 100-2000 | AI 返回的最大 token 数 |
| `request_timeout_ms` | int | 5000 | 2000-30000 | API 请求超时时间 |
| `cache_ttl_hours` | int | 24 | 1-168 | 缓存有效期（小时） |
| `max_answer_length` | int | 1000 | 500-5000 | 玩家答案最大长度 |
| `similarity_threshold_high` | float | 0.8 | 0.6-0.95 | 高相似度阈值 |
| `similarity_threshold_low` | float | 0.5 | 0.3-0.7 | 低相似度阈值 |
| `min_confidence_threshold` | float | 0.5 | 0.3-0.8 | 最低置信度阈值 |

### 调参指南

**`ai_temperature`（AI 创造性）**
- **调低**: AI 回复更确定、一致，适合严谨场景
- **调高**: AI 回复更多样、创意，适合轻松场景
- **观察指标**: 玩家对 AI 回复多样性的反馈

**`request_timeout_ms`（请求超时）**
- **调低**: 快速失败，玩家等待短，但可能频繁超时
- **调高**: 更容忍慢响应，但玩家等待长
- **观察指标**: 超时率 vs 玩家等待体验

**`cache_ttl_hours`（缓存有效期）**
- **调低**: 缓存更新更频繁，AI 分析更实时
- **调高**: 缓存命中更高，节省 API 调用
- **观察指标**: 缓存命中率 vs API 调用量

**`min_confidence_threshold`（最低置信度）**
- **调低**: 接受更多 AI 判定，但可能不准确
- **调高**: 拒绝低置信度判定，更保守但更准确
- **观察指标**: 人工复核率 vs 判定准确率

## Acceptance Criteria

### 功能验收
| # | 验收条件 | 优先级 | 测试方法 |
|---|----------|--------|----------|
| AC-01 | 选择题直接判定正确（不调用 AI） | P0 | 单元测试 |
| AC-02 | 代码题/应用题调用 AI 分析 | P0 | 集成测试 |
| AC-03 | AI 返回结果正确解析 | P0 | 单元测试 |
| AC-04 | 缓存命中时跳过 AI 调用 | P0 | 单元测试 |
| AC-05 | 超时时使用降级回复 | P0 | 单元测试 |
| AC-06 | 空答案返回错误提示 | P0 | 单元测试 |
| AC-07 | 答案过长时截断 | P1 | 单元测试 |
| AC-08 | 特殊字符过滤生效 | P1 | 单元测试 |
| AC-09 | 同一问题连续请求触发限流 | P1 | 集成测试 |
| AC-10 | 返回结果包含判定/反馈/追问 | P0 | 单元测试 |

### 性能验收
| # | 验收条件 | 目标值 |
|---|----------|--------|
| AC-11 | 选择题判定响应时间 | < 50ms |
| AC-12 | AI 分析响应时间（缓存命中） | < 100ms |
| AC-13 | AI 分析响应时间（未命中） | < 3000ms |
| AC-14 | 缓存命中率 | > 30% |

### 集成验收
| # | 验收条件 | 优先级 | 测试方法 |
|---|----------|--------|----------|
| AC-15 | 与 API 代理后端正确交互 | P0 | 集成测试 |
| AC-16 | 与 Prompt 管理系统正确获取模板 | P0 | 集成测试 |
| AC-17 | 与题库数据系统正确获取题目 | P0 | 集成测试 |
| AC-18 | BOSS 面试系统正确接收分析结果 | P0 | 集成测试 |

### 质量验收
| # | 验收条件 | 目标值 |
|---|----------|--------|
| AC-19 | AI 判定准确率（与人工对比） | > 85% |
| AC-20 | 玩家对 AI 反馈满意度 | > 80% |

## Open Questions

| # | 问题 | 状态 | 决策/负责人 | 目标日期 |
|---|------|------|-------------|----------|
| OQ-01 | 是否支持多轮对话上下文（历史答案影响判定）？ | 待讨论 | 产品团队 | Alpha前 |
| OQ-02 | 是否支持代码运行验证（不仅仅是 AI 分析）？ | 待讨论 | 技术团队 | Beta前 |
| OQ-03 | AI 判定争议时是否支持人工复核入口？ | 待讨论 | 产品团队 | Beta前 |
| OQ-04 | 是否支持答案评分（不只是正确/错误，还有质量分）？ | 待讨论 | 游戏设计师 | Alpha前 |
| OQ-05 | 是否支持玩家反馈 AI 判定（"我认为判定错误"）？ | 待讨论 | 产品团队 | 发布后 |

---

## 附录：AI 返回格式示例

```json
{
  "verdict": "partial",
  "confidence": 0.75,
  "feedback_text": "你对 HashMap 底层结构的理解是正确的，但忽略了 JDK 1.8 的优化。在 JDK 1.8 中，当链表长度超过 8 时会转换为红黑树，提升查询效率。",
  "follow_up_question": "那你知道为什么选择 8 作为转换阈值吗？",
  "explanation": "HashMap 底层是数组+链表，JDK 1.8 优化后链表过长会转为红黑树。选择 8 是因为泊松分布的概率在 8 时已经非常小，几乎不会发生哈希冲突到这个程度。",
  "key_points": [
    "数组+链表是基础结构",
    "JDK 1.8 引入红黑树优化",
    "转换阈值是 8"
  ],
  "missing_points": [
    "未提及红黑树优化",
    "未解释转换阈值原因"
  ]
}
```

---

## 附录：降级回复模板

当 AI 不可用时，使用以下预设模板：

**正确回复**:
```
"回答正确！{question}的关键点是{key_point}。"
```

**错误回复**:
```
"回答有些问题。正确答案是{correct_answer}。建议复习一下这个知识点。"
```

**超时回复**:
```
"网络超时，无法分析你的答案。请稍后重试。"
```