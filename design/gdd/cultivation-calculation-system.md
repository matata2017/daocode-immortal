# 修为计算系统 (Cultivation Calculation System)

> **Status**: Designed
> **Author**: User + Claude Code
> **Last Updated**: 2026-03-30
> **Implements Pillar**: 成长可见

## Overview

**修为计算系统**负责将玩家的答题表现转化为修为数值，是"成长可见"支柱的核心引擎。

系统根据题目难度、题目标签数量、答题正确性等因素计算每次答题的修为收益。答对获得修为（基础值 + 标签加成），答错不扣修为但记录为"心魔"。BOSS面试中答错会扣修为，增加面试压力。

**为什么需要这个系统**：没有明确的修为计算，玩家不知道"刷这道题有什么用"。系统化的计算让每道题的价值可预期——标签多的题目价值更高，配合视觉反馈（修为+X飘字）给玩家即时成就感。标签加权公式也鼓励玩家主动挑战覆盖更多知识点的题目。

## Player Fantasy

**每一道题都有明确的价值，每一分修为都是真实的进步。**

修为不是抽象的进度条——它是你可以预测、可以计算的"修炼成果"。你看到一道题目有3个标签，就知道它比只有1个标签的题目更"值钱"。你看到自己境界高了，就知道该去挑战更难的题目，因为简单题的修为会衰减。

### 玩家体验场景

**场景 1：基础修炼**
玩家做了一道简单题（1个标签），修为+12飘字。他注意到比普通简单题（10分）多了2分，意识到"标签越多，修为越多"。

**场景 2：境界提升后**
玩家从炼气突破到筑基，继续做简单题。修为+8飘字（之前是+10）。他意识到"境界高了，简单题收益降低"，于是主动切换到中等难度。

**场景 3：BOSS面试紧张感**
玩家在BOSS面试中答错一道题，看到修为-15飘字。他感到压力——BOSS面试是真的会"损失修为"的。下次他会在挑战BOSS前多复习心魔。

### 支撑的游戏支柱

| 支柱 | 如何体现 |
|------|----------|
| **成长可见** | 每道题的修为收益可预测、可计算，进步数值化 |
| **沉浸修仙** | 修为名称、飘字动画、境界突破都充满修仙风味 |
| **实用至上** | 标签加权鼓励学习覆盖更多知识点的题目 |
| **碎片友好** | 每道题独立计算，随时退出不影响收益 |

## Detailed Design

### Core Rules

#### 修为计算数据结构

```gdscript
# cultivation_calculator.gd
class_name CultivationCalculator
extends Node

# 基础修为配置
const BASE_CULTIVATION = {
    "easy": 10,    # 简单题基础修为
    "medium": 20,  # 中等题基础修为
    "hard": 30,    # 困难题基础修为
}

# 标签加成配置
const TAG_BONUS_PERCENT = 10   # 每个标签加成百分比
const MAX_TAG_BONUS_PERCENT = 50 # 标签加成上限

# BOSS扣修为配置
const BOSS_WRONG_MULTIPLIER = -1.0 # BOSS答错扣100%基础值
```

#### 修为计算主流程

```gdscript
func calculate_cultivation_gain(
    question: QuestionData,
    is_correct: bool,
    is_boss_interview: bool = false
) -> int:
    # 1. 获取基础修为
    var base = BASE_CULTIVATION[question.difficulty]

    # 2. 计算标签加成
    var tag_bonus = calculate_tag_bonus(base, question.tags.size())

    # 3. 计算最终修为变化
    var cultivation_change = base + tag_bonus

    if not is_correct:
        if is_boss_interview:
            # BOSS面试答错：扣基础值
            cultivation_change = -base
        else:
            # 普通修炼答错：不扣，返0
            cultivation_change = 0

    return cultivation_change
```

#### 标签加成计算

```gdscript
func calculate_tag_bonus(base_cultivation: int, tag_count: int) -> int:
    # 每个标签加10%，上限50%
    var bonus_percent = min(tag_count * TAG_BONUS_PERCENT, MAX_TAG_BONUS_PERCENT)
    return int(base_cultivation * bonus_percent / 100.0)
```

### States and Transitions

修为计算系统是无状态的计算服务，不维护自身状态。状态由存档系统管理。

```
┌───────────────────────────────────────────────────────────────┐
│                      修为计算流程                               │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│  输入: question, is_correct, is_boss_interview               │
│                     │                                         │
│                     ↓                                         │
│           ┌─────────────────────┐                             │
│           │  获取基础修为        │ BASE_CULTIVATION[difficulty]│
│           └─────────────┬───────┘                             │
│                         │                                     │
│                         ↓                                     │
│           ┌─────────────────────┐                             │
│           │  计算标签加成        │ min(tags×10%, 50%)         │
│           └─────────────┬───────┘                             │
│                         │                                     │
│                         ↓                                     │
│        ┌────────────────┴────────────────┐                    │
│        │           is_correct?            │                   │
│        ├──────────YES───────────NO────────┤                   │
│        │                      │            │                  │
│        │                      ↓            ↓                  │
│        │             ┌─────────────┐ ┌─────────────┐         │
│        │             │ is_boss?    │ │ return 0    │         │
│        │             ├─────YES─────┤ │ (不扣修为)  │         │
│        │             │             │ └─────────────┘         │
│        │             ↓             │                         │
│        │     return -base          │                         │
│        │     (扣基础值)            │                         │
│        │                           │                         │
│        ↓                           │                         │
│  return base + tag_bonus           │                         │
│                                                               │
│  输出: cultivation_change (整数)                              │
└───────────────────────────────────────────────────────────────┘
```

### Interactions with Other Systems

| 系统 | 数据流向 | 接口 |
|------|----------|------|
| **存档系统** | 计算器→存档 | `apply_cultivation_change(amount)` |
| **境界数据系统** | 计算器→境界 | `get_realm_by_cultivation(total_cultivation)` |
| **答题修炼系统** | 答题→计算器 | `calculate_cultivation_gain(question, is_correct)` |
| **境界突破系统** | 突破→计算器 | `apply_breakthrough_penalty(percent)` |
| **BOSS面试系统** | BOSS→计算器 | `calculate_cultivation_gain(question, is_correct, true)` |
| **题库数据系统** | 计算器←题目 | `question.difficulty, question.tags` |

#### 接口契约

**契约 1: `calculate_cultivation_gain(question, is_correct, is_boss_interview) -> int`**
- 输入: 题目数据、是否正确、是否BOSS面试
- 输出: 修为变化量（正数=增加，负数=扣除，0=无变化）
- 调用方: 答题修炼系统、BOSS面试系统

**契约 2: `apply_cultivation_change(amount: int) -> void`**
- 输入: 修为变化量
- 输出: 无（存档系统更新 cultivation 字段）
- 调用方: 修为计算系统调用存档系统
- 约束: 修为最低为0，最高为当前境界上限

**契约 3: `get_cultivation_cap(realm_id: int) -> int`**
- 输入: 当前境界ID
- 输出: 该境界的修为上限（下一境界阈值）
- 调用方: 存档系统检查修为上限
- 来源: 境界数据系统

## Formulas

### 核心公式：普通修炼修为收益

```
cultivation_gain(question, is_correct) =
    IF is_correct:
        base = BASE_CULTIVATION[question.difficulty]
        tag_bonus = base × min(tag_count × 10%, 50%)
        RETURN base + tag_bonus
    ELSE:
        RETURN 0  # 普通修炼答错不扣修为

# 变量定义:
# - BASE_CULTIVATION: {"easy": 10, "medium": 20, "hard": 30}
# - tag_count: 题目标签数量 (0-5)
# - tag_bonus: 标签加成修为值

# 示例计算:
# 1. 简单题答对，1个标签:
#    base = 10, tag_bonus = 10 × 10% = 1
#    gain = 10 + 1 = 11

# 2. 中等题答对，3个标签:
#    base = 20, tag_bonus = 20 × 30% = 6
#    gain = 20 + 6 = 26

# 3. 困难题答对，5个标签:
#    base = 30, tag_bonus = 30 × 50% = 15 (触达上限)
#    gain = 30 + 15 = 45

# 4. 任意难度答错:
#    gain = 0
```

### 核心公式：BOSS面试修为变化

```
boss_cultivation_change(question, is_correct) =
    IF is_correct:
        # 与普通修炼相同
        RETURN cultivation_gain(question, true)
    ELSE:
        # BOSS面试答错：扣除基础值
        base = BASE_CULTIVATION[question.difficulty]
        RETURN -base

# 示例计算:
# 1. BOSS面试中等题答错:
#    change = -20

# 2. BOSS面试困难题答错:
#    change = -30
```

### 核心公式：境界突破失败惩罚

```
breakthrough_fail_penalty(player, target_realm_id) =
    current_cultivation × get_fail_penalty_percent(target_realm_id)

# 从境界数据系统获取惩罚百分比:
# - 凡人→炼气: 5%
# - 炼气→筑基: 10%
# - 筑基→金丹: 10%
# - 金丹→元婴: 15%
# - 元婴→化神: 15%

# 示例:
# 玩家有600修为，突破筑基失败:
# penalty = 600 × 10% = 60
# new_cultivation = max(0, 600 - 60) = 540
```

### 核心公式：修为上下限

```
clamp_cultivation(current_cultivation, realm_id) =
    min_cultivation = 0
    max_cultivation = get_required_cultivation(realm_id + 1)  # 下一境界阈值

    # 特殊：飞升境界无上限
    IF realm_id == ASCENSION:
        max_cultivation = Infinity

    RETURN clamp(current_cultivation, min_cultivation, max_cultivation)

# 示例:
# 炼气期玩家，修为800，筑基需要500:
# max = 500
# result = clamp(800, 0, 500) = 500  # 超出部分被截断，提示突破

# 凡人玩家，修为150，炼气需要100:
# max = 100
# result = clamp(150, 0, 100) = 100  # 超出部分被截断
```

### 核心公式：门派精通度

```
update_domain_mastery(player, question, is_correct) =
    IF is_correct:
        # 答对：精通度+X%
        delta = 0.02  # 每次+2%
    ELSE:
        # 答错：精通度-X%（如果已精通）
        delta = -0.01  # 每次-1%

    current_mastery = player.faction_mastery[question.faction_id][question.domain]
    new_mastery = clamp(current_mastery + delta, 0, 1)

    RETURN new_mastery

# 精通度范围: 0.0 - 1.0 (0% - 100%)
# 每个门派有4个领域（如Java: collections, concurrency, jvm, spring）
```

### 修为收益期望值表

| 难度 | 标签数 | 基础值 | 标签加成 | 总收益 |
|------|--------|--------|----------|--------|
| 简单 | 0 | 10 | 0 | 10 |
| 简单 | 1 | 10 | 1 | 11 |
| 简单 | 3 | 10 | 3 | 13 |
| 中等 | 0 | 20 | 0 | 20 |
| 中等 | 2 | 20 | 4 | 24 |
| 中等 | 5 | 20 | 10 | 30 |
| 困难 | 0 | 30 | 0 | 30 |
| 困难 | 3 | 30 | 9 | 39 |
| 困难 | 5 | 30 | 15 | 45 |

### 境界升级所需题目数估算

| 目标境界 | 所需修为 | 平均每题收益 | 约需答对题数 |
|----------|----------|--------------|--------------|
| 炼气 | 100 | 12 (简单+1标签) | ~9题 |
| 筑基 | 500 | 24 (中等+2标签) | ~21题 |
| 金丹 | 1500 | 39 (困难+3标签) | ~38题 |
| 元婴 | 4000 | 39 | ~103题 |
| 化神 | 10000 | 39 | ~256题 |

> 注：以上为估算，实际受题目难度分布、标签数量、答错率影响

## Edge Cases

| 边缘情况 | 处理方式 | 影响范围 |
|----------|----------|----------|
| **题目标签数为0** | 标签加成 = 0%，按基础值计算 | 修为计算 |
| **题目标签超过5** | 标签加成上限50%，多余标签忽略 | 修为计算 |
| **玩家修为已达当前境界上限** | 修为不再增加，显示"修为已满，请突破境界" | 存档系统 |
| **玩家修为为0** | 修为操作返回0，不做任何扣除 | 修为计算 |
| **BOSS面试答错导致修为变负** | 修为最低为0，不会变负 | 修为计算 |
| **同一题目重复答对** | 仍获得修为（刷题就是重复） | 修为计算 |
| **领域精通度超过100%** | 上限100%，不再增加 | 领域精通度 |
| **境界突破失败后修为扣除导致领域精通度下降** | 领域精通度按比例下降，保持非负 | 领域精通度 |
| **飞升后继续答题** | 修为和精通度不再增加，显示"已飞升，修炼圆满" | 存档系统 |

## Dependencies

### 上游依赖

| 系统 | 依赖类型 | 接口需求 | 设计状态 |
|------|----------|----------|----------|
| **存档系统** | 硬依赖 | `cultivation` 字段读写、`faction_mastery` 字段读写 | 已设计 |
| **境界数据系统** | 硬依赖 | `get_required_cultivation(realm_id)`、`get_fail_penalty_percent(realm_id)` | 已设计 |
| **题库数据系统** | 硬依赖 | `question.difficulty`、`question.tags`、`question.faction_id`、`question.domain` | 已设计 |

### 下游依赖（被依赖）

| 系统 | 依赖类型 | 接口契约 | 设计状态 |
|------|----------|----------|----------|
| **答题修炼系统** | 硬依赖 | `calculate_cultivation_gain(question, is_correct)` | 未设计 |
| **境界突破系统** | 硬依赖 | `apply_breakthrough_penalty(percent)` | 未设计 |
| **BOSS面试系统** | 硬依赖 | `calculate_cultivation_gain(question, is_correct, true)` | 未设计 |
| **面试报告系统** | 软依赖 | 修为变化统计 | 未设计 |

### 接口契约详情

**契约 1: 存档系统 → 修为计算系统**

存档系统提供以下字段供修为计算系统读写：
```gdscript
# SaveData 中的相关字段
@export var cultivation: int = 0              # 总修为值
@export var faction_mastery: Dictionary       # 门派精通度 {faction_id: {domain: mastery}}
```

**契约 2: 境界数据系统 → 修为计算系统**

境界数据系统提供以下接口：
```gdscript
func get_required_cultivation(realm_id: int) -> int
# 返回该境界的修为阈值

func get_fail_penalty_percent(realm_id: int) -> int
# 返回该境界突破失败的惩罚百分比
```

**契约 3: 题库数据系统 → 修为计算系统**

题库数据系统提供以下字段供修为计算使用：
```gdscript
# QuestionData 中的相关字段
@export var difficulty: String               # "easy" / "medium" / "hard"
@export var tags: Array[String]              # 知识点标签列表
@export var faction_id: String               # 门派ID（如 "JAVA"）
@export var domain: String                   # 领域ID（如 "collections"）
```

## Tuning Knobs

| Knob | 类型 | 默认值 | 范围 | 影响范围 |
|------|------|--------|------|----------|
| `base_cultivation_easy` | int | 10 | 5-20 | 简单题基础修为 |
| `base_cultivation_medium` | int | 20 | 10-40 | 中等题基础修为 |
| `base_cultivation_hard` | int | 30 | 15-60 | 困难题基础修为 |
| `tag_bonus_percent` | int | 10 | 5-20 | 每个标签的加成百分比 |
| `max_tag_bonus_percent` | int | 50 | 30-100 | 标签加成上限百分比 |
| `boss_wrong_multiplier` | float | -1.0 | -0.5 to -2.0 | BOSS答错扣除倍率 |
| `domain_mastery_gain` | float | 0.02 | 0.01-0.05 | 答对领域精通度增益 |
| `domain_mastery_loss` | float | 0.01 | 0.005-0.02 | 答错领域精通度损失 |

### 调参指南

**调整游戏节奏（让玩家更快或更慢突破境界）**：
- 若想让玩家更快突破：提高基础修为值（如 easy 15/medium 25/hard 40）
- 若想延长游戏时长：降低基础修为值（如 easy 8/medium 15/hard 25）

**调整标签重要性**：
- 若想让多标签题目更有价值：提高 `tag_bonus_percent`（如 15%）
- 若想减少标签差距：降低 `tag_bonus_percent`（如 5%）

**调整BOSS面试压力**：
- 若想增加BOSS面试紧张感：提高 `boss_wrong_multiplier`（如 -1.5，扣150%基础值）
- 若想降低BOSS面试压力：降低 `boss_wrong_multiplier`（如 -0.5，扣50%基础值）

**调整领域精通度增长速度**：
- 若想让精通度快速提升：提高 `domain_mastery_gain`（如 0.05，答对+5%）
- 若想精通度缓慢积累：降低 `domain_mastery_gain`（如 0.01，答对+1%）

### 参数预设方案

**轻松模式**（适合新手，快速成长）：
```
base_cultivation_easy = 15
base_cultivation_medium = 30
base_cultivation_hard = 45
boss_wrong_multiplier = -0.5
domain_mastery_gain = 0.05
```

**标准模式**（推荐，平衡体验）：
```
base_cultivation_easy = 10
base_cultivation_medium = 20
base_cultivation_hard = 30
boss_wrong_multiplier = -1.0
domain_mastery_gain = 0.02
```

**硬核模式**（适合进阶玩家，慢节奏）：
```
base_cultivation_easy = 8
base_cultivation_medium = 15
base_cultivation_hard = 25
boss_wrong_multiplier = -1.5
domain_mastery_gain = 0.01
```

## Acceptance Criteria

### 功能验收

| # | 验收条件 | 优先级 | 测试方法 |
||---|----------|--------|----------|
| AC-01 | 简单题答对获得基础修为 + 标签加成 | P0 | 单元测试 |
| AC-02 | 中等题答对获得基础修为 + 标签加成 | P0 | 单元测试 |
| AC-03 | 困难题答对获得基础修为 + 标签加成 | P0 | 单元测试 |
| AC-04 | 普通修炼答错返回0（不扣修为） | P0 | 单元测试 |
| AC-05 | BOSS面试答对获得完整修为 | P0 | 单元测试 |
| AC-06 | BOSS面试答错扣除基础修为值 | P0 | 单元测试 |
| AC-07 | 标签加成上限正确（最多50%） | P1 | 单元测试 |
| AC-08 | 修为上限检查正确（不超境界阈值） | P1 | 单元测试 |
| AC-09 | 修为下限检查正确（不低于0） | P1 | 单元测试 |
| AC-10 | 境界突破失败惩罚计算正确 | P1 | 单元测试 |
| AC-11 | 领域精通度计算正确 | P2 | 单元测试 |

### 数值验证

| # | 测试场景 | 预期结果 |
|---|----------|----------|
| AC-12 | 简单题(1标签)答对 | 修为+11 |
| AC-13 | 中等题(3标签)答对 | 修为+26 |
| AC-14 | 困难题(5标签)答对 | 修为+45 |
| AC-15 | BOSS面试中等题答错 | 修为-20 |
| AC-16 | 普通修炼答错 | 修为+0 |
| AC-17 | 突破筑基失败(修为600) | 修为-60 |

### 性能验收

| # | 验收条件 | 目标值 |
|---|----------|--------|
| AC-18 | 修为计算响应时间 | < 1ms |
| AC-19 | 大批量修为计算（1000次） | < 100ms |

### 验证清单（QA 使用）

```markdown
## 修为计算系统验收清单

### 基础功能
- [ ] 不同难度题目答对获得正确修为
- [ ] 标签加成正确计算（10%/标签，上限50%）
- [ ] 普通修炼答错不扣修为
- [ ] BOSS面试答错扣基础值

### 边界条件
- [ ] 0标签题目获得基础值
- [ ] 5+标签题目触达上限
- [ ] 修为最低为0
- [ ] 修为最高为境界阈值

### 境界突破
- [ ] 突破失败惩罚正确扣除
- [ ] 惩罚百分比按境界变化
```

## Open Questions

| # | 问题 | 状态 | 决策/负责人 | 目标日期 |
|---|------|------|-------------|----------|
| OQ-01 | 标签加成公式是否需要根据门派调整？ | 待讨论 | 游戏设计师 | Alpha 前 |
| OQ-02 | 领域精通度是否影响修为收益？ | 待讨论 | 游戏设计师 | Alpha 前 |
| OQ-03 | 是否需要"连击奖励"作为后期玩法？ | 待讨论 | 游戏设计师 | Beta 前 |
| OQ-04 | BOSS面试答错是否需要显示"修为-XX"飘字？ | 待确认 | UX 设计师 | Alpha 前 |
| OQ-05 | 飞升后是否显示"修为圆满"的特殊UI？ | 待讨论 | UX 设计师 | Beta 前 |
