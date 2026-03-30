# Prompt管理系统 (Prompt Management System)

> **Status**: Designed
> **Author**: User + Claude Code
> **Last Updated**: 2026-03-30
> **Implements Pillar**: 沉浸修仙、实用至上

## Overview

**Prompt管理系统**定义了 MiniMax AI 面试官的所有 Prompt 模板，包括开场白、回答分析、追问、提示、讲解、面试报告等场景。

每个模板支持变量插值（如 `{boss_name}`、 `{question}`、 `{player_answer}`).并根据 BOSS 性格动态调整风格。系统管理模板版本、 A/B 测试配置、以及调试日志。

**为什么需要这个系统**：Prompt 是 AI 面试官的"灵魂"。没有它， AI 只能返回通用回复，无法体现 BOSS 的性格差异，破坏"沉浸修仙"体验。良好的 Prompt 设计直接影响面试的趣味性和教育价值。

## Player Fantasy

**每次与 AI 面试官对话，都感觉像是在与一个真实角色交流。**
> AI 面试官不只是是一个问答机器。而是一个有性格、有风格的"人"。
>
> Prompt 管理系统让外包厂HR 说"年轻友好，大厂长老说"仙风道骨"——每种性格都有对应的语言风格和让对话更真实、更沉浸。

### 玩家体验场景

**场景 1：外包厂HR 的友好问候**
"你好呀~ 我是XX公司的HR。今天我们面试主要聊聊Java基础，放轻松~ 当成聊天就行。"
> 风格：口语化、轻松、带emoji、鼓励型

**场景 2：大厂长老的严肃开场**
"年轻人，你的修行之路还很长。吾且问你几个问题，看看你的功力如何。"
> 风格: 文言风、严谨、有威严.追问型

### 支撑的游戏支柱
| 支柱 | 如何体现 |
|------|----------|
| **沉浸修仙** | BOSS 有独特的说话风格。体现门派文化 |
| **实用至上** | AI 反馈包含真实面试建议。专业且有价值 |
| **Challenge** | 追问 Prompt 让面试更有深度和压力 |

## Detailed Design

### Core Rules

#### Prompt 模板数据结构
```gdscript
class_name PromptTemplate
extends Resource

enum PromptType {
    INTRO,           # 开场白
    FOLLOW_UP,       # 追问
    HINT,            # 提示
    EXPLANATION,     # 讲解
    ENCOURAGE,       # 鋱励（答对）
    CORRECT_FEEDBACK,# 正确反馈
    REPORT_SUMMARY, # 面试报告摘要
}

@export var id: String
@export var type: PromptType
@export var boss_id: BossId              # 适用 BOSS（null = 通用）
@export var template_text: String        # 模板文本
@export var variables: Array[String]     # 所需变量列表
@export var style_modifiers: Dictionary # 风格调整器 {formal: 0-1}
@export var version: String
@export var is_active: bool
```

#### Prompt 类型配置表

| 类型 | 用途 | 触发时机 | 变量示例 |
|------|------|----------|----------|
| INTRO | 开场白 | 面试开始 | `{boss_name}`, `{topic}` |
| FOLLOW_UP | 追问 | 答对后追问 | `{question}`, `{correct_answer}` |
| HINT | 提示 | 答错多次后 | `{question}`, `{hint_text}` |
| EXPLANATION | 讲解 | 答错时讲解 | `{question}`, `{correct_answer}`, `{explanation}` |
| ENCOURAGE | 鋱励 | 答对时 | `{player_name}`, `{topic}` |
| CORRECT_FEEDBACK | 正确反馈 | 答对时 | `{question}`, `{explanation}` |
| REPORT_SUMMARY | 报告摘要 | 面试结束 | `{score}`, `{total}`, `{strength}`, `{weakness}` |

#### BOSS 风格调整器

| BOSS | formal_level | encouragement_level | detail_level |
|------|--------------|---------------------|-------------|
| 外包厂HR | 0.3 (口语化) | 0.8 (高鼓励) | 0.5 (简略) |
| 大厂长老 | 0.9 (文言风) | 0.4 (低鼓励) | 0.8 (详细) |

### States and Transitions
```
┌─────────────────────┐
│  Prompt 模板已加载  │
└──────────┬──────────┘
           │ 请求生成 Prompt
           ↓
┌─────────────────────┐
│  Prompt 正在渲染    │  变量插值进行中
└──────────┬──────────┘
           │ 渲染完成
           ↓
┌─────────────────────┐
│  Prompt 已就绪       │  可发送给 AI
└─────────────────────┘
```

### Interactions with Other Systems
| 系统 | 数据流向 | 接口 |
|------|----------|------|
| **BOSS数据系统** | BOSS→Prompt | `get_boss_style_modifiers(boss_id)` |
| **回答分析系统** | Prompt→AI | `render_prompt(template_id, variables)` |
| **存档系统** | Prompt↔存档 | `save/load_prompt_history()` |

## Formulas

### Prompt 渲染公式
```
render_prompt(template_id, variables) =
    base_template = get_template(template_id)
    style_modifiers = get_boss_style_modifiers(current_boss_id)

    # 应用风格调整器
    rendered = apply_style_modifiers(base_template, style_modifiers)

    # 变量插值
    for each (key, value) in variables:
        rendered = rendered.replace(`{${key}}`, value)

    return rendered
```

### 风格调整公式
```
apply_style_modifiers(template, modifiers) =
    # formal_level: 调整文言程度
    IF modifiers.formal_level > 0.7:
        template = add_classical_particles(template)

    # encouragement_level: 调整鼓励语气
    IF modifiers.encouragement_level > 0.6:
        template = add_encouraging_words(template)

    # detail_level: 调整详细程度
    IF modifiers.detail_level > 0.6:
        template = add_more_explanation(template)

    return template
```

## Edge Cases
| 边缘情况 | 处理方式 | 影响范围 |
|----------|----------|----------|
| **变量值为空或null** | 使用默认值或如"未知"） | AI 集成 |
| **模板不存在** | 使用 fallback 通用模板 | AI 集成 |
| **BOSS 风格未配置** | 使用默认风格（0.5, 0.5, 0.5） | AI 集成 |
| **AI 响应对长超限** | 截断 + 添加"..." | AI 集成 |
| **变量插值失败** | 保留原始占位符 + 日志记录 | AI 集成 |
| **模板版本不兼容** | 自动迁移到最新版本 | 存档系统 |
| **同时请求多个 Prompt** | 鎟列处理，AI 集成 |
| **缓存过期** | 重新渲染 | 性能系统 |

## Dependencies
### 上游依赖（无）
Prompt 管理系统是基础数据层，**无上游依赖**。

### 下游依赖（被依赖）
| 系统 | 依赖类型 | 接口契约 |
|------|----------|----------|
| **回答分析系统** | 硬依赖 | `render_prompt(template_id, variables) → String` |
| **BOSS面试系统** | 硬依赖 | `get_prompt_templates(boss_id) → Array[PromptTemplate]` |
| **存档系统** | 软依赖 | 缓存历史 Prompt 记录 |

## Tuning Knobs
| Knob | 类型 | 默认值 | 范围 | 影响范围 |
|------|------|--------|------|----------|
| `max_response_length` | int | 500 | 100-2000 | AI 响应最大长度（字符） |
| `cache_ttl_seconds` | int | 3600 | 0-86400 | Prompt 缓存过期时间 |
| `fallback_template_enabled` | bool | true | true/false | 是否启用 fallback 模板 |
| `style_modifier_strength` | float | 1.0 | 0.5-2.0 | 风格调整器影响强度 |
| `variable_default_value` | String | "未知" | - | 变量缺失时的默认值 |

## Acceptance Criteria
### 功能验收
| # | 验收条件 | 优先级 | 测试方法 |
|---|----------|--------|----------|
| AC-01 | 每个 BOSS 有对应的 INTRO 模板 | P0 | 数据库查询 |
| AC-02 | 变量插值正确替换占位符 | P0 | 单元测试 |
| AC-03 | 风格调整器正确应用 | P1 | 单元测试 |
| AC-04 | fallback 模板在缺失时启用 | P1 | 单元测试 |
| AC-05 | 缓存正确工作 | P1 | 单元测试 |
| AC-06 | 模板版本管理正常 | P2 | 单元测试 |
| AC-07 | 日志记录缺失变量 | P2 | 韗成测试 |

### 数据完整性验收
| # | 验收条件 | 测试方法 |
|---|----------|----------|
| AC-08 | 每个模板有所需变量列表 | 数据检查 |
| AC-09 | 模板文本不包含硬编码值 | 代码检查 |
| AC-10 | BOSS 风格配置完整 | 数据检查 |

## Open Questions
| # | 问题 | 状态 | 决策/负责人 | 目标日期 |
|---|------|------|-------------|----------|
| OQ-01 | 是否支持玩家自定义 Prompt？ | 待讨论 | 产品团队 | Alpha 前 |
| OQ-02 | 如何处理 Prompt 版本回滚? | 待设计 | 后端团队 | Alpha 前 |
| OQ-03 | 是否需要 A/B 测试框架? | 待讨论 | 测试团队 | Beta 前 |
| OQ-04 | Prompt 日志保留多久? | 待讨论 | 产品团队 | 发布前 |
| OQ-05 | 如何处理敏感信息（如 API Key）？ | 待设计 | 安全团队 | 开发前 |

---

## 附录：示例 Prompt 模板

### 外包厂HR - 开场白
```
你好呀~ 我是{boss_name}的面试官{role}。今天我们主要聊聊{topic}。放轻松~ 当成聊天就行。准备好了吗~
```

### 大厂长老 - 开场白
```
年轻人，你的修行之路还很长。吾乃{boss_name}，今日特来考校你的功力。准备好了吗？%
```
### 外包厂HR - 追问
```
嗯，回答得不错~ 那能说说{follow_up_question}？%
```
### 大厂长老 - 追问
```
此题答对，但吾需追问：{follow_up_question}。汝且详述之。%
```