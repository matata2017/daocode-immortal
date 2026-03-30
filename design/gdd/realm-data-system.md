# 境界数据系统 (Realm Data System)

> **Status**: Designed
> **Author**: User + Claude Code
> **Last Updated**: 2026-03-30
> **Implements Pillar**: 成长可见、沉浸修仙

## Overview

**境界数据系统**定义了玩家从"凡人程序员"到"飞升大佬"的成长阶梯。

系统包含 7 个境界等级（凡人→炼气→筑基→金丹→元婴→化神→飞升），每个境界有明确的修为阈值、解锁内容、对应能力等级。境界不仅是数值标签——它决定了玩家能挑战的题目难度、能面对的 BOSS 面试官、以及在修仙世界观中的身份地位。

玩家通过**修为计算系统**积累修为，当修为达到阈值后可尝试**境界突破**。境界数据系统提供这些阈值的定义和突破规则。

**为什么需要这个系统**：境界是"成长可见"支柱的核心体现。没有它，玩家刷题只是"做了一道题"，而不是"我变强了"。境界把抽象的学习进步变成了可感知的身份升级。

## Player Fantasy

**你是修仙小说的主角，每一次境界突破都是人生的高光时刻。**

在这个世界里，境界不只是等级数字——它是你的**身份、荣耀、和认可**。

### 玩家体验场景

**场景 1：初入仙途**
玩家刚进入游戏，看到自己"凡人"的称号。界面提示："汝乃凡人，当勤勉修炼，方可踏入仙途。" 凡人只能做简单题，玩家感受到成长的渴望。

**场景 2：炼气突破**
修为达到 100，系统提示"汝已具备炼气资格，可尝试突破"。玩家点击"突破"，进入突破试炼——连续答对 5 道简单题。成功后，角色发光，境界称号变为"炼气期弟子"，解锁中等难度题目。

**场景 3：金丹渡劫**
玩家想要突破金丹，这是一次"渡劫"。系统提示"金丹渡劫，九死一生"。突破试炼包含 10 道中等题，必须答对 8 道。失败会扣除部分修为，但可以重试。成功后，玩家感受到"我终于踏入大厂门槛"的成就感。

**场景 4：飞升时刻**
通关所有 BOSS，修为满，玩家触发"飞升"仪式——一段华丽的动画，展示角色飞升仙界。屏幕显示"恭喜飞升！汝已拿到 Offer！" 这是游戏的终极成就。

### 支撑的游戏支柱

| 支柱 | 如何体现 |
|------|----------|
| **成长可见** | 境界是最直观的成长指标，玩家随时知道自己"是什么水平" |
| **沉浸修仙** | 境界名称、突破仪式、飞升动画都充满修仙风味 |
| **实用至上** | 境界对应真实的面试能力（炼气=入门，金丹=高级） |
| **碎片友好** | 每次突破都是一个"里程碑"，给玩家明确的短期目标 |

## Detailed Design

### Core Rules

#### 境界数据结构

```gdscript
# realm_data.gd
class_name RealmData
extends Resource

enum RealmId {
    MORTAL,       # 凡人
    QI_REFINING,  # 炼气
    FOUNDATION,   # 筑基
    GOLDEN_CORE,  # 金丹
    NASCENT_SOUL, # 元婴
    SPIRIT_SEVER, # 化神
    ASCENSION     # 飞升
}

@export var id: RealmId
@export var name: String                    # 显示名称："炼气"
@export var title: String                   # 称号："炼气期弟子"
@export var description: String             # 修仙风格描述
@export var required_cultivation: int       # 突破所需修为
@export var breakthrough_trial: TrialConfig # 突破试炼配置
@export var unlocks: Array[String]          # 解锁内容标识
@export var real_world_level: String        # 对应真实能力
@export var icon_path: String               # 境界图标路径
@export var theme_color: Color              # 主题色
```

#### 境界配置表

| ID | 名称 | 称号 | 修为阈值 | 试炼要求 | 解锁内容 | 对应能力 |
|----|------|------|----------|----------|----------|----------|
| 0 | 凡人 | 凡人 | 0 | 无 | 基础题（简单） | 入门级 |
| 1 | 炼气 | 炼气期弟子 | 100 | 简单题×5，答对3 | 中等题 | 初级工程师 |
| 2 | 筑基 | 筑基期修士 | 500 | 中等题×8，答对5 | 困难题 | 中级工程师 |
| 3 | 金丹 | 金丹期真人 | 1500 | 中等题×10，答对8 | 独角兽BOSS | 高级工程师 |
| 4 | 元婴 | 元婴期老祖 | 4000 | 困难题×8，答对6 | 大厂BOSS | 资深工程师 |
| 5 | 化神 | 化神期尊者 | 10000 | 困难题×12，答对10 | 全部门派 | 架构师/专家 |
| 6 | 飞升 | 飞升仙人 | 通关BOSS | 无 | 结局动画 | 拿到Offer |

#### 突破试炼配置

```gdscript
class_name TrialConfig
extends Resource

@export var question_count: int        # 题目数量
@export var difficulty: String         # 题目难度: easy/medium/hard
@export var required_correct: int      # 需要答对数量
@export var time_limit_seconds: int    # 时间限制（0=无限制）
@export var fail_penalty_percent: int  # 失败扣除修为百分比
```

| 境界突破 | 题数 | 难度 | 需答对 | 时间限制 | 失败惩罚 |
|----------|------|------|--------|----------|----------|
| 凡人→炼气 | 5 | 简单 | 3 | 无 | 5% |
| 炼气→筑基 | 8 | 中等 | 5 | 无 | 10% |
| 筑基→金丹 | 10 | 中等 | 8 | 15分钟 | 10% |
| 金丹→元婴 | 8 | 困难 | 6 | 20分钟 | 15% |
| 元婴→化神 | 12 | 困难 | 10 | 30分钟 | 15% |
| 化神→飞升 | - | - | 通关所有BOSS | - | - |

### States and Transitions

```
┌─────────┐  修为≥100+试炼通过  ┌─────────┐
│  凡人   │ ─────────────────→ │  炼气   │
└─────────┘                     └─────────┘
     ↑                               │
     │                               │ 修为≥500+试炼通过
     │                               ↓
┌─────────┐  修为≥1500+试炼通过 ┌─────────┐
│  金丹   │ ←─────────────────  │  筑基   │
└─────────┘                     └─────────┘
     │
     │ 修为≥4000+试炼通过
     ↓
┌─────────┐  修为≥10000+试炼通过 ┌─────────┐
│  元婴   │ ─────────────────→ │  化神   │
└─────────┘                     └─────────┘
                                     │
                                     │ 通关所有BOSS
                                     ↓
                                ┌─────────┐
                                │  飞升   │
                                └─────────┘
```

**状态转换规则**：
- 只能按顺序突破，不能跳跃
- 突破失败：境界不变，扣除修为，可重试
- 突破成功：境界+1，触发突破动画

### Interactions with Other Systems

| 系统 | 数据流向 | 接口 |
|------|----------|------|
| **修为计算系统** | 境界→修为 | `get_required_cultivation(realm_id)` |
| **境界突破系统** | 境界→突破 | `get_breakthrough_trial(realm_id)` |
| **答题修炼系统** | 境界→题目 | `get_unlocked_difficulties(realm_id)` |
| **BOSS面试系统** | 境界→BOSS | `get_unlocked_bosses(realm_id)` |
| **存档系统** | 境界↔存档 | `save/load_realm_progress()` |

## Formulas

### 突破条件检查

```
can_breakthrough(player) =
    player.cultivation >= get_required_cultivation(player.realm_id + 1)
    AND player.realm_id < ASCENSION

返回：Boolean
```

### 突破失败惩罚

```
fail_penalty(player, target_realm_id) =
    player.cultivation × get_fail_penalty_percent(target_realm_id)

# 示例：玩家有 600 修为，突破筑基失败（惩罚 10%）
# penalty = 600 × 0.10 = 60
# player.cultivation = max(0, 600 - 60) = 540

# 保证修为不会变成负数
```

### 试炼通过判定

```
trial_passed(correct_count, required_correct) =
    correct_count >= required_correct

返回：Boolean
```

### 境界进度百分比

```
realm_progress_percent(player) =
    IF player.realm_id == ASCENSION:
        RETURN 100%

    current_threshold = get_required_cultivation(player.realm_id)
    next_threshold = get_required_cultivation(player.realm_id + 1)

    progress = (player.cultivation - current_threshold)
             / (next_threshold - current_threshold)
             × 100%

    RETURN clamp(progress, 0%, 100%)

# 示例：炼气期玩家，修为 300
# current_threshold = 100, next_threshold = 500
# progress = (300 - 100) / (500 - 100) × 100% = 50%
```

### 修为到下一境界剩余

```
cultivation_to_next(player) =
    IF player.realm_id == ASCENSION:
        RETURN 0

    next_threshold = get_required_cultivation(player.realm_id + 1)
    RETURN max(0, next_threshold - player.cultivation)

# 示例：炼气期玩家，修为 300，筑基需要 500
# 返回：500 - 300 = 200
```

### 境界对应的题目难度

```
get_unlocked_difficulties(realm_id) =
    CASE realm_id:
        MORTAL:       ["easy"]
        QI_REFINING:  ["easy", "medium"]
        FOUNDATION:   ["easy", "medium", "hard"]
        GOLDEN_CORE+: ["easy", "medium", "hard"]  # 全部解锁
```

## Edge Cases

| 边缘情况 | 处理方式 | 影响范围 |
|----------|----------|----------|
| **玩家修为满但未突破** | 显示"修为已满，请突破境界以继续积累" | 答题系统 |
| **飞升后继续获得修为** | 修为不再增加，显示"已飞升，修为圆满" | 修为计算 |
| **突破失败后修为不足再突破** | 可以再次尝试，但需要重新积累修为 | 境界突破 |
| **试炼中途退出** | 视为失败，扣除修为惩罚 | 境界突破 |
| **试炼题目不够** | 从题库随机补充相近难度题目 | 突破考试 |
| **玩家尝试跳过境界** | 不允许，必须按顺序突破，UI 隐藏未解锁的突破选项 | UI 系统 |
| **飞升条件满足但境界不够** | 不能飞升，需要先达到化神 | BOSS 系统 |
| **突破惩罚导致修为为负** | 修为最低为 0，不会变负 | 修为计算 |
| **网络断开导致突破记录丢失** | 本地缓存突破状态，恢复后同步 | 存档系统 |
| **修改系统时间作弊** | 服务端校验（后期），MVP 不处理 | 安全性 |

## Dependencies

### 上游依赖

**无** — 这是基础数据系统，没有上游依赖。

### 下游依赖

| 系统 | 依赖类型 | 接口需求 | 设计状态 |
|------|----------|----------|----------|
| **修为计算系统** | 硬依赖 | `get_required_cultivation(realm_id) -> int` | 未设计 |
| **境界突破系统** | 硬依赖 | `get_breakthrough_trial(realm_id) -> TrialConfig` | 未设计 |
| **答题修炼系统** | 软依赖 | `get_unlocked_difficulties(realm_id) -> Array[String]` | 未设计 |
| **BOSS面试系统** | 软依赖 | `get_unlocked_bosses(realm_id) -> Array[BossId]` | 未设计 |
| **存档系统** | 硬依赖 | 境界进度持久化 | 未设计 |
| **UI显示系统** | 软依赖 | `get_realm_display_info(realm_id) -> RealmDisplayData` | 未设计 |

### 接口契约

**契约 1：`get_required_cultivation(realm_id: int) -> int`**
- 输入：境界 ID（0-6）
- 输出：该境界所需的修为阈值
- 特殊：`realm_id = 6`（飞升）返回 `Infinity` 或特殊值

**契约 2：`get_breakthrough_trial(realm_id: int) -> TrialConfig`**
- 输入：目标境界 ID
- 输出：突破试炼配置
- 特殊：`realm_id = 6`（飞升）返回 null（无试炼，需通关 BOSS）

**契约 3：`get_realm_by_cultivation(cultivation: int) -> RealmId`**
- 输入：修为值
- 输出：对应的境界 ID
- 用途：根据修为反推当前境界

## Tuning Knobs

| 参数名 | 类型 | 默认值 | 安全范围 | 调整影响 |
|--------|------|--------|----------|----------|
| `fail_penalty_base_percent` | float | 10 | 5-20 | 突破失败扣除修为的基础百分比。太高→玩家挫败；太低→无压力 |
| `fail_penalty_increase_per_realm` | float | 2 | 0-5 | 每个境界增加的惩罚百分比。高境界失败代价更大 |
| `trial_question_count_base` | int | 5 | 3-10 | 基础试炼题数。太多→疲劳；太少→运气成分大 |
| `trial_pass_threshold_percent` | float | 60 | 50-80 | 试炼通过阈值百分比。太高→难度大；太低→无挑战 |
| `cultivation_curve_multiplier` | float | 2.5 | 2.0-4.0 | 境界修为增长倍率。控制游戏节奏 |

### 参数预设

**轻松模式**（降低难度）：
```
fail_penalty_base_percent = 5
trial_pass_threshold_percent = 50
cultivation_curve_multiplier = 2.0
```

**标准模式**（推荐）：
```
fail_penalty_base_percent = 10
trial_pass_threshold_percent = 60
cultivation_curve_multiplier = 2.5
```

**硬核模式**（增加挑战）：
```
fail_penalty_base_percent = 20
trial_pass_threshold_percent = 80
cultivation_curve_multiplier = 3.5
```

## Acceptance Criteria

### 功能验收标准

| ID | 测试场景 | 预期结果 | 优先级 |
|----|----------|----------|--------|
| **AC-01** | 查询境界配置 | 返回正确的修为阈值、称号、描述 | P0 |
| **AC-02** | 检查突破条件（修为足够） | `can_breakthrough()` 返回 true | P0 |
| **AC-03** | 检查突破条件（修为不足） | `can_breakthrough()` 返回 false | P0 |
| **AC-04** | 获取突破试炼配置 | 返回正确的题数、难度、通过条件 | P0 |
| **AC-05** | 计算境界进度百分比 | 返回 0-100% 的正确值 | P1 |
| **AC-06** | 飞升境界查询 | 返回特殊标识，无突破试炼 | P1 |
| **AC-07** | 获取解锁内容 | 返回正确的题目难度和 BOSS 列表 | P1 |
| **AC-08** | 根据修为反推境界 | 返回正确的境界 ID | P1 |
| **AC-09** | 修为满后无法继续积累 | 显示"修为已满"提示 | P2 |
| **AC-10** | 飞升后修为不再增加 | 显示"已飞升，修为圆满" | P2 |

### 数据完整性验收

| ID | 验证规则 | 检查方法 |
|----|----------|----------|
| **AC-D01** | 7 个境界全部配置完整 | 启动时校验 |
| **AC-D02** | 修为阈值严格递增 | 导入时校验 |
| **AC-D03** | 每个境界有称号和描述 | 导入时校验 |
| **AC-D04** | 试炼配置完整（题数、难度、通过条件） | 导入时校验 |
| **AC-D05** | 境界图标资源存在 | 启动时校验 |

### 验证清单（QA 使用）

```markdown
## 境界数据系统验收清单

### 基础功能
- [ ] 能查询所有 7 个境界的配置
- [ ] 能检查玩家是否满足突破条件
- [ ] 能获取突破试炼配置
- [ ] 能计算境界进度百分比
- [ ] 能根据修为反推境界

### 数据完整性
- [ ] 修为阈值严格递增（0→100→500→1500→4000→10000）
- [ ] 每个境界有称号、描述、图标
- [ ] 试炼配置完整

### 边缘情况
- [ ] 飞升境界返回特殊标识
- [ ] 修为满后无法继续积累
- [ ] 负数修为处理正确
```

## Open Questions

| # | 问题 | 状态 | 决策/负责人 | 目标日期 |
|---|------|------|-------------|----------|
| OQ-01 | 突破失败是否有每日次数限制？ | 待讨论 | 游戏设计师 | Alpha 前 |
| OQ-02 | 是否需要"渡劫丹"道具降低失败惩罚？ | 待讨论 | 游戏设计师 | MVP 后 |
| OQ-03 | 境界是否有有效期（掉级机制）？ | 待讨论 | 产品决策 | MVP 后 |
| OQ-04 | 是否支持多角色/多存档的独立境界？ | 待确认 | 技术设计师 | 开发前 |
| OQ-05 | 境界称号是否可以自定义显示？ | 待讨论 | UX 设计师 | MVP 后 |

---

## 附录：境界名称对照表

| 中文 | 英文 | 修仙含义 | 现实对应 |
|------|------|----------|----------|
| 凡人 | Mortal | 未踏入仙途 | 入门级/实习生 |
| 炼气 | Qi Refining | 吸收天地灵气 | 初级工程师 |
| 筑基 | Foundation | 奠定修炼根基 | 中级工程师 |
| 金丹 | Golden Core | 凝聚金丹，脱胎换骨 | 高级工程师 |
| 元婴 | Nascent Soul | 元婴出窍，神游太虚 | 资深工程师 |
| 化神 | Spirit Severing | 化神分身，千变万化 | 架构师/专家 |
| 飞升 | Ascension | 白日飞升，得道成仙 | 拿到 Offer |
