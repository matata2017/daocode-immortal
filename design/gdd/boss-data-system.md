# BOSS数据系统 (Boss Data System)

> **Status**: Designed
> **Author**: User + Claude Code
> **Last Updated**: 2026-03-30
> **Implements Pillar**: Challenge、沉浸修仙、实用至上

## Overview

**BOSS数据系统**定义了修仙界各大门派的面试官 BOSS 的数据结构，包括名称、背景故事、外观设定、面试风格、题目池配置、以及 MiniMax AI 驱动的 Prompt 模板。

MVP 包含 **2 个 BOSS**：
1. **外包厂面试官**（小 BOSS）— 外包公司 HR，风格年轻务实，面试流程简单，难度较低
2. **大厂面试官**（大 BOSS）— 大厂技术专家，风格仙风道骨，面试深度高、难度较高

玩家达到对应境界后可以解锁并挑战 BOSS，BOSS 会根据玩家回答动态追问、给予提示或或讲解答案。最终生成面试报告。

**为什么需要这个系统**：BOSS 是"渡劫"体验的核心。没有 BOSS，面试只是冷冰冰的问答，没有 BOSS，玩家感受不到"修仙渡劫"的紧张感和仪式感。BOSS 也是"成长可见"的里程碑——击败 BOSS 是境界突破的证明，也是代表玩家真正达到了大厂面试的水平。

## Player Fantasy

**你正坐在面试官面前，感受紧张、刺激、期待被认可。**

BOSS 战是游戏的高光时刻——不是普通答题，而是一场"渡劫"。你需要准备好，否则就无法通过。

### 玩家体验场景

**场景 1：挑战小 BOSS（外包厂面试官）**
玩家达到金丹期，解锁"外包厂面试官"。进入面试场景，一位年轻的 HR 坐在你对面，穿着休闲装，态度轻松。

"你好呀，听说你在修炼集合框架？来聊聊 ArrayList 和 HashMap 吧~"

玩家开始答题。小 BOSS 会追问，但不会太刁钻。回答正确时，她会说"不错，继续！"。回答错误时，她会说"别紧张，这道题在工作中经常遇到，我给你讲讲..."

最终，小 BOSS 点点头："还可以，有兴趣来我们公司试试！" 玩家获得面试报告，包含建议和成就感。

**场景 2：挑战大 BOSS（大厂面试官）**
玩家达到元婴期，解锁"大厂面试官"。进入面试场景，一位仙风道骨的技术专家长老。白发、长袍，目光锐利。

"年轻人，你的修行之路还很长。"

他提出的问题深且广，从底层原理到架构设计，从并发模型到性能优化。每个问题都需要深思熟虑。

玩家回答后，大 BOSS 会深入追问："为什么这样设计？有什么替代方案？生产环境会怎样？"

最终，大 BOSS 点头："功力尚可，但还需历练。" 或摇头："修行不够，继续努力。"

### 支撑的游戏支柱

| 支柱 | 如何体现 |
|------|----------|
| **沉浸修仙** | BOSS 有修仙风格的名称、外观、对话风格 |
| **实用至上** | BOSS 代表真实面试场景，问题来自真实面试 |
| **Challenge** | BOSS 战是高压力挑战，需要充分准备 |
| **成长可见** | 击败 BOSS 是重要的成长里程碑 |

## Detailed Design

### Core Rules

#### BOSS 数据结构

```gdscript
# boss_data.gd
class_name BossData
extends Resource

enum BossId {
    OUTSOURCE_HR,    # 外包厂HR（小BOSS）
    TECH_GIANT,      # 大厂长老（大BOSS）
    UNICORN,         # 独角兽CTO（DLC）
    STARTUP,         # 创业公司CTO（DLC）
}

enum BossDifficulty {
    EASY,      # 简单模式： 韱门宽松
    NORMAL,    # 普通模式: 标准体验
    HARD,      # 困难模式: 高压面试
}

@export var id: BossId
@export var name: String                      # 显示名称
@export var title: String                     # 称号："外包厂面试官"
@export var description: String               # 背景故事（2-3段）
@export var portrait_path: String             # 立绘路径
@export var theme_color: Color                # 主题色
@export var personality: String               # 性格描述（用于 AI Prompt）
@export var speaking_style: String            # 说话风格（用于 AI Prompt）
@export var unlock_realm: RealmId             # 解锁境界
@export var difficulty_config: Dictionary     # 难度配置 {BossDifficulty: config}
@export var rewards: RewardConfig             # 奖励配置
@export var fail_penalty_percent: int         # 失败惩罚百分比
```

#### BOSS 配置表（MVP）

| ID | 名称 | 称号 | 性格 | 说话风格 | 主题色 | 解锁境界 | 失败惩罚 |
|----|------|------|------|----------|--------|----------|----------|
| OUTSOURCE_HR | 外包厂HR | 外包厂面试官 | 年轻务实、轻松友好 | 口语化、鼓励型 | #4CAF50 | 金丹期 | 5% |
| TECH_GIANT | 大厂长老 | 大厂面试官 | 仙风道骨、严谨深入 | 文言风、追问型 | #1E88E5 | 元婴期 | 10% |

### States and Transitions

```
┌─────────────────┐
│  BOSS 已解锁      │  玩家达到解锁境界
└────────┬────────┘
         │ 玩家选择挑战
         ↓
┌─────────────────┐
│  BOSS 面试进行中  │  正在答题/追问
└────────┬────────┘
         │ 面试结束
         ↓
┌─────────────────┐
│  BOSS 面试结算    │  通过/失败
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
    ↓         ↓
┌────────┐ ┌────────┐
│  通过    │ │  失败   │
└────────┘ └────────┘
```

### 难度档配置

| BOSS | EASY | NORMAL | HARD |
|------|------|--------|------|
| 外包厂HR | 题目: 10道 easy<br>时间: 无限<br>追问: 15% | 题目: 10道 easy+medium<br>时间: 20分钟<br>追问: 30% | 不提供 |
| 大厂长老 | 不提供 | 题目: 15道 medium<br>时间: 30分钟<br>追问: 60% | 题目: 15道 medium+hard<br>时间: 25分钟<br>追问: 80% |

### 通过条件
| BOSS | EASY | NORMAL | HARD |
|------|------|--------|------|
| 外包厂HR | 6/10 | 6/10 | - |
| 大厂长老 | - | 10/15 | 11/15 |

### Interactions with Other Systems
| 系统 | 数据流向 | 接口 |
|------|----------|------|
| **境界数据系统** | 境界→BOSS | `get_boss_unlock_realm(boss_id)` |
| **题库数据系统** | BOSS→题目 | `get_questions_for_boss(difficulty, topics)` |
| **回答分析系统** | BOSS→AI | `get_boss_prompt(boss_id, context)` |
| **面试报告系统** | BOSS→报告 | `generate_interview_report(results)` |
| **存档系统** | BOSS↔存档 | `save/load_boss_progress()` |

## Formulas

### BOSS 解锁检查

```
can_challenge(player, boss_id) =
    player.realm_id >= get_boss(boss_id).unlock_realm

# 返回：Boolean
# 示例：玩家是金丹期，大厂长老需要元婴期
# can_challenge(TECH_GIANT) = GOLDEN_CORE >= NASCENT_SOUL = false
```

### 面试得分计算

```
interview_score(session) =
    COUNT(questions WHERE answered_correctly)

# 返回：Integer [0, total_questions]
# 示例：10道题答对 6道 → score = 6
```

### 通过判定

```
interview_passed(score, boss_id, difficulty) =
    score >= get_passing_score(boss_id, difficulty)

# 返回：Boolean
# 示例：外包厂HR NORMAL模式，通过需要 6分
# passed = 6 >= 6 = true
```

### 失败惩罚计算

```
fail_penalty(player, boss_id) =
    player.cultivation × get_boss(boss_id).fail_penalty_percent / 100

# 返回：Integer
# 示例：玩家有 2000 修为，挑战大厂长老失败（惩罚 10%）
# penalty = 2000 × 0.10 = 200
# player.cultivation = max(0, 2000 - 200) = 1800
```

### 追问概率调整

```
adjusted_follow_up_chance(base_chance, difficulty) =
    CASE difficulty:
        EASY:  base_chance × 0.5
        NORMAL: base_chance × 1.0
        HARD:  base_chance × 1.5

# 返回：Float [0, 1]
# 示例：大厂长老基础追问概率 60%
# HARD模式: 0.60 × 1.5 = 0.90 (90%)
```

## Edge Cases

| 边缘情况 | 处理方式 | 影响范围 |
|----------|----------|----------|
| **玩家境界不足尝试挑战** | BOSS 卡片显示锁定，点击提示"需达到 XX 境界" | UI 系统 |
| **BOSS 题目池为空** | 显示"该 BOSS 正在准备中，敬请期待" | 面试系统 |
| **面试中途退出** | 视为失败，扣除修炼值 | 面试系统 |
| **AI 服务不可用** | 回退到预设对话模板，面试继续 | AI 集成 |
| **玩家修为不足以支付失败惩罚** | 修为归零，不会变负 | 修为计算 |
| **同一 BOSS 多次失败** | 每次都扣修炼值，无累计惩罚 | 存档系统 |
| **BOSS 战时切换难度** | 需重新开始，当前进度作废 | UI 系统 |
| **存档损坏导致 BOSS 进度丢失** | 重置为未挑战状态，不影响境界 | 存档系统 |

## Dependencies

### 上游依赖（无）

BOSS 数据系统是基础数据层，**无上游依赖**。

### 下游依赖（被依赖）

| 系统 | 依赖类型 | 接口契约 |
|------|----------|----------|
| **BOSS 面试系统** | 硬依赖 | `get_boss(boss_id) → BossData` |
| **回答分析系统** | 硬依赖 | `get_boss_prompt_template(boss_id) → String` |
| **境界数据系统** | 软依赖 | BOSS 解锁条件检查 |
| **面试报告系统** | 软依赖 | BOSS 信息用于报告 |
| **存档系统** | 硬依赖 | `save/load_boss_progress()` |

### 数据流向图

```
┌─────────────────┐
│   BOSS数据系统    │
└────────┬────────┘
         │
    ┌────┴────┬────────────┬────────────┐
    │         │            │            │
    ↓         ↓            ↓            ↓
┌───────┐ ┌──────────┐ ┌────────┐ ┌────────┐
│BOSS面试│ │回答分析│ │面试报告│ │存档系统│
└───────┘ └──────────┘ └────────┘ └────────┘
```

## Tuning Knobs

| Knob | 类型 | 默认值 | 范围 | 影响范围 |
|------|------|--------|------|----------|
| `default_difficulty` | BossDifficulty | NORMAL | EASY/NORMAL/HARD | 新玩家默认难度档 |
| `fail_penalty_cap_percent` | int | 15 | 0-50 | 失败惩罚上限百分比 |
| `follow_up_chance_modifier` | float | 1.0 | 0.5-2.0 | 全局追问概率调整 |
| `hint_trigger_count` | int | 2 | 1-5 | 错误几次后给提示 |
| `time_bonus_per_question_seconds` | int | 60 | 30-120 | 每题基础时间 |
| `boss_cooldown_hours` | int | 0 | 0-48 | BOSS 战冷却时间（0=无限制） |

### 调参指南

- **失败惩罚**：若发现玩家反复挑战 BOSS 刷奖励，可提高惩罚上限
- **追问概率**：若 BOSS 面试太简单，可提高全局追问概率
- **冷却时间**：若需要控制 BOSS 战频率，可设置冷却时间
- **提示触发**：若想增加挑战性，可提高触发提示所需的错误次数

## Acceptance Criteria

### 功能验收

| # | 验收条件 | 优先级 | 测试方法 |
|---|----------|--------|----------|
| AC-01 | 金丹期玩家可挑战外包厂HR | P0 | 手动测试 |
| AC-02 | 元婴期玩家可挑战大厂长老 | P0 | 手动测试 |
| AC-03 | 境界不足的 BOSS 显示锁定状态 | P1 | 手动测试 |
| AC-04 | 可选择难度档（适用时） | P1 | 手动测试 |
| AC-05 | 面试通过后显示祝贺动画 | P1 | 手动测试 |
| AC-06 | 面试失败后扣除修炼值 | P1 | 单元测试 |
| AC-07 | AI 面试官能正确追问和给提示 | P1 | 集成测试 |
| AC-08 | 面试结束生成报告 | P1 | 手动测试 |
| AC-09 | BOSS 立绘正确加载显示 | P1 | 资源检查 |
| AC-10 | 存档正确保存 BOSS 挑战记录 | P0 | 集成测试 |

### 数据完整性验收

| # | 验收条件 | 测试方法 |
|---|----------|----------|
| AC-11 | 每个 BOSS 有完整的配置数据 | 数据库查询 |
| AC-12 | 每个 BOSS 有对应的 AI Prompt 模板 | 资源检查 |
| AC-13 | BOSS 主题色与 UI 一致 | 视觉测试 |
| AC-14 | BOSS 解锁境界与境界系统配置一致 | 数据一致性检查 |

### 性能验收

| # | 验收条件 | 目标值 |
|---|----------|--------|
| AC-15 | BOSS 数据加载时间 | < 50ms |
| AC-16 | BOSS 面试场景切换时间 | < 500ms |
| AC-17 | AI 追问响应时间 | < 3s |

## Open Questions

| # | 问题 | 状态 | 决策/负责人 | 目标日期 |
|---|------|------|-------------|----------|
| OQ-01 | 是否需要 BOSS 战回放功能？ | 待讨论 | 游戏设计师 | Alpha 前 |
| OQ-02 | 困难模式是否需要解锁条件？ | 待讨论 | 游戏设计师 | MVP 后 |
| OQ-03 | BOSS 是否有每日/每周挑战次数限制？ | 待讨论 | 产品团队 | MVP 后 |
| OQ-04 | 是否支持跳过 BOSS 直接"飞升"？ | 待确认 | 游戏设计师 | 开发前 |
| OQ-05 | BOSS 的 AI Prompt 如何与 Prompt 管理系统对接？ | 待设计 | AI 工程师 | Alpha 前 |

---

## 附录：BOSS 背景故事（MVP）

### 外包厂HR
> 某外包公司的人力资源专员，日常负责筛选合适的技术人才。
>
> 风格年轻化，务实、友好。面试问题以实用性为主，不会刻意刁难候选人。
>
> 口头禅："我们公司虽然外包，但技术氛围不错，来了就是自己人。"
>
> **性格设定**： 鼓励型、耐心、不会追问到底层原理
> **适合人群**： 初级工程师、转行人员/准备跳槽者

### 大厂长老
> 某知名大厂的技术面试官，技术造诣深厚。在行业摸爬滚打多年，见多识广。
>
> 仙风道骨。严谨深入。面试问题从底层原理到架构设计。层层递进。
>
> 口头禅："年轻人，你的修行之路还很漫长。"
>
> **性格设定**. 追问型、严谨、注重思考深度
> **适合人群**. 中高级工程师/架构师/技术专家