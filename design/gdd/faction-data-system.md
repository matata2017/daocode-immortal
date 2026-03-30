# 门派数据系统 (Faction Data System)

> **Status**: Designed
> **Author**: User + Claude Code
> **Last Updated**: 2026-03-30
> **Implements Pillar**: 沉浸修仙、实用至上

## Overview

**门派数据系统**定义了修仙界各大编程门派的数据结构，包括门派名称、修仙背景故事、绝学领域（知识点分类）、专属题目池等。

门派对应现实中的编程语言（Java派、Go派、C++派等），每个门派拥有独特的门派背景故事、绝学领域（知识点分类）、和专属题目池。玩家选择门派后，将学习该门派的"绝学"——即该语言的核心面试知识点。

MVP 阶段只包含 **Java派**，验证"门派→题目→修仙"的完整体验。后期扩展更多门派作为 DLC。

**为什么需要这个系统**：门派是"沉浸修仙"支柱的核心体现，让刷题有归属感和叙事包装。同时门派对应真实编程语言，满足"实用至上"——学完真能用。

## Player Fantasy

**你是修仙门派的弟子，门派是你的归属和荣耀。**

选择门派不只是选择语言——是选择一个**身份**，一个**修行方向**，一个**门派大家庭**。

### 玩家体验场景

**场景 1：拜入山门**
新玩家进入游戏，看到门派选择界面。Java派介绍："吾派传承自 Sun 古宗，后为 Oracle 大能所收。擅长集合之术、并发心法，乃是当今修仙界最兴盛的门派之一。" 玩家选择后，获得"Java派弟子"称号。

**场景 2：修炼门派绝学**
Java派弟子进入"集合框架洞府"，修炼 ArrayList、HashMap 等心法。每道题都是门派传承的口诀，答对了，长老会夸奖"悟性不错"。

**场景 3：跨门派切磋（后期 DLC）**
化神期玩家可以"云游四方"，学习其他门派的绝学。Go派的并发模型、C++派的内存心法...每个门派都有独特魅力。

### 支撑的游戏支柱

| 支柱 | 如何体现 |
|------|----------|
| **沉浸修仙** | 门派名称、背景故事、长老对话都充满修仙风味 |
| **实用至上** | 门派对应真实编程语言，学完真能面试用 |
| **成长可见** | 门派进度、绝学掌握度可视化 |
| **碎片友好** | 每个门派独立，可随时切换或专注一个 |

## Detailed Design

### Core Rules

#### 门派数据结构

```gdscript
# faction_data.gd
class_name FactionData
extends Resource

enum FactionId {
    JAVA,    # Java派
    GO,      # Go派
    CPP,     # C++派 (DLC)
    PYTHON,  # Python派 (DLC)
    RUST,    # Rust派 (DLC)
}

@export var id: FactionId
@export var name: String                  # 显示名称："Java派"
@export var full_name: String             # 英文全名："Java Collection Sect"
@export var tagline: String               # 口号："一次编写，到处运行"
@export var lore: String                  # 门派背景故事（2-3段）
@export var language_icon_path: String    # 语言 Logo 图标路径
@export var banner_path: String           # 门派横幅图片路径
@export var theme_color: Color            # 主题色
@export var skill_domains: Array[SkillDomain]  # 绝学领域列表
@export var unlock_realm: RealmId         # 解锁所需境界（MVP = MORTAL）
```

#### 门派配置表（MVP）

| ID | 名称 | 全称 | 口号 | 主题色 | 解锁条件 |
|----|------|------|------|--------|----------|
| JAVA | Java派 | Java Collection Sect | 一次编写，到处运行 | #F89820 | 凡人 |
| GO | Go派 | Go Concurrency Sect | 简洁并发，高效如飞 | #00ADD8 | 凡人 |

#### 绝学领域数据结构

```gdscript
class_name SkillDomain
extends Resource

@export var id: String              # "collections"
@export var name: String            # "集合框架"
@export var description: String     # "ArrayList, HashMap, HashSet..."
@export var icon_path: String       # 领域图标
@export var topic_ids: Array[String] # 关联的题库知识点 ID
@export var question_count: int     # 题目数量（预计算）
```

#### Java派绝学领域

| 领域ID | 名称 | 描述 | 预估题目数 |
|--------|------|------|------------|
| collections | 集合框架 | ArrayList, LinkedList, HashMap, HashSet, LinkedHashMap | 50+ |
| concurrency | 并发心法 | synchronized, volatile, ThreadPool, ConcurrentHashMap | 40+ |
| jvm | JVM内功 | 内存模型, GC算法, 类加载机制, JIT | 30+ |
| spring | Spring剑法 | IoC容器, AOP原理, SpringBoot自动配置 | 40+ |

#### Go派绝学领域

| 领域ID | 名称 | 描述 | 预估题目数 |
|--------|------|------|------------|
| basics | 基础语法 | 变量声明, 切片操作, map, 结构体, 接口 | 40+ |
| concurrency | 并发模型 | goroutine, channel, select, context, sync包 | 50+ |
| runtime | Runtime心法 | GC原理, GMP调度, 内存模型 | 30+ |
| web | Web实战 | gin/echo框架, middleware, RESTful设计 | 40+ |

### States and Transitions

```
┌─────────────────┐
│  未选择门派      │  新玩家初始状态
└────────┬────────┘
         │ 选择门派
         ↓
┌─────────────────┐
│  已选择门派      │  player.faction_id != null
└────────┬────────┘
         │ 切换门派
         ↓
┌─────────────────┐
│  已切换门派      │  进度独立保留
└─────────────────┘
```

**状态转换规则**：
- 新玩家必须选择门派才能开始修炼
- 可随时切换门派，无惩罚
- 每个门派的绝学掌握度独立存储

### Interactions with Other Systems

| 系统 | 数据流向 | 接口 |
|------|----------|------|
| **题库数据系统** | 门派→题目 | `get_faction_topics(faction_id)` |
| **主菜单系统** | 门派→UI | `get_all_factions()` |
| **存档系统** | 门派↔存档 | `save/load_faction_progress()` |
| **修炼场景系统** | 门派→场景 | `get_faction_theme(faction_id)` |

## Formulas

### 绝学掌握度计算

```
domain_mastery_percent(player, domain_id) =
    (count_correct_answers(player, domain_id) / total_questions(domain_id)) × 100%

# 返回范围：[0%, 100%]
# 示例：玩家在 Java 集合框架答对 35 题，总 50 题
# 结果：35 / 50 × 100% = 70%
```

### 门派总掌握度

```
faction_mastery_percent(player, faction_id) =
    SUM(domain_mastery_percent(domain) for each domain in faction)
    / count_domains(faction)

# 返回范围：[0%, 100%]
# 示例：Java 派 4 个领域，掌握度分别为 70%, 60%, 40%, 50%
# 结果：(70 + 60 + 40 + 50) / 4 = 55%
```

### 已回答题目数

```
answered_count(player, faction_id) =
    COUNT(questions WHERE question.faction_id == faction_id AND question is answered)
```

## Edge Cases

| 边缘情况 | 处理方式 | 影响范围 |
|----------|----------|----------|
| **玩家不选门派直接开始** | 强制显示门派选择，不选无法进入修炼 | 主菜单 |
| **门派题目为空** | 显示"该门派正在建设中"，引导选其他门派 | 修炼系统 |
| **切换门派时正在答题** | 弹窗确认"当前答题进度会保存，确定切换？" | UI 系统 |
| **存档损坏导致门派进度丢失** | 重置为默认门派，显示提示 | 存档系统 |
| **DLC 门派未购买** | 显示锁定状态，点击跳转购买页面 | 商店系统 |
| **内功题目没有门派归属** | 所有门派都可访问内功题目池 | 题库系统 |
| **新门派添加后老存档兼容** | 新门派进度初始化为 0%，不影响现有进度 | 存档系统 |

## Dependencies

### 上游依赖（无）

门派数据系统是基础数据层，**无上游依赖**。

### 下游依赖（被依赖）

| 系统 | 依赖类型 | 接口契约 |
|------|----------|----------|
| **主菜单系统** | 硬依赖 | `get_all_factions() → Array[FactionData]` |
| **题库数据系统** | 硬依赖 | `get_faction_topics(faction_id) → Array[TopicId]` |
| **存档系统** | 硬依赖 | `save_faction_progress(faction_id, progress)` |
| **修炼场景系统** | 软依赖 | `get_faction_theme(faction_id) → ThemeConfig` |
| **BOSS面试系统** | 软依赖 | BOSS 可根据玩家门派调整题目方向 |

### 数据流向图

```
┌─────────────────┐
│  门派数据系统    │
└────────┬────────┘
         │
    ┌────┴────┬────────────┬────────────┐
    ↓         ↓            ↓            ↓
┌───────┐ ┌───────┐   ┌───────┐   ┌───────┐
│主菜单 │ │题库系统│   │存档系统│   │修炼场景│
└───────┘ └───────┘   └───────┘   └───────┘
```

## Tuning Knobs

| Knob | 类型 | 默认值 | 范围 | 影响范围 |
|------|------|--------|------|----------|
| `default_faction` | FactionId | JAVA | JAVA, GO | 新玩家默认门派 |
| `faction_switch_cooldown_seconds` | int | 0 | 0-86400 | 切换门派冷却时间（0=无限制） |
| `mastery_display_precision` | int | 0 | 0-2 | 掌握度小数位数 |
| `show_locked_factions` | bool | true | true/false | 是否显示未解锁的 DLC 门派 |
| `faction_icon_size` | int | 64 | 32-128 | 门派图标显示大小 |

### 调参指南

- **切换冷却**：若发现玩家频繁切换影响体验，可设置冷却时间
- **DLC 展示**：若不想刺激玩家，可隐藏未购买的 DLC 门派
- **掌握度精度**：0 表示整数显示，更简洁；2 表示精确到小数点后两位

## Acceptance Criteria

### 功能验收

| # | 验收条件 | 优先级 | 测试方法 |
|---|----------|--------|----------|
| AC-01 | 新玩家首次进入时显示门派选择界面 | P0 | 手动测试 |
| AC-02 | 玩家可选择 Java派 或 Go派 | P0 | 手动测试 |
| AC-03 | 选择门派后显示门派称号和主题色 | P0 | 手动测试 |
| AC-04 | 玩家可在设置中切换门派，无惩罚 | P1 | 手动测试 |
| AC-05 | 每个门派显示 4 个绝学领域 | P1 | 手动测试 |
| AC-06 | 点击绝学领域可进入该领域的题目列表 | P1 | 手动测试 |
| AC-07 | 绝学掌握度正确计算并显示 | P1 | 单元测试 |
| AC-08 | 门派总掌握度正确计算并显示 | P2 | 单元测试 |
| AC-09 | 内功题目对所有门派可见 | P1 | 手动测试 |
| AC-10 | 存档正确保存和加载门派进度 | P0 | 集成测试 |

### 数据完整性验收

| # | 验收条件 | 测试方法 |
|---|----------|----------|
| AC-11 | 每个门派至少有 100+ 道专属题目 | 数据库查询 |
| AC-12 | 每个绝学领域至少有 20+ 道题目 | 数据库查询 |
| AC-13 | 门派配置 JSON 可被正确解析 | 单元测试 |
| AC-14 | 门派图标资源存在且可加载 | 资源检查 |

### 性能验收

| # | 验收条件 | 目标值 |
|---|----------|--------|
| AC-15 | 门派列表加载时间 | < 100ms |
| AC-16 | 门派切换响应时间 | < 50ms |
| AC-17 | 掌握度计算时间 | < 10ms |

## Open Questions

| # | 问题 | 状态 | 决策/负责人 | 目标日期 |
|---|------|------|-------------|----------|
| OQ-01 | 门派是否有独特的修炼场景背景？ | 待讨论 | 美术团队 | Alpha 前 |
| OQ-02 | 门派选择是否影响 BOSS 面试的题目方向？ | 待讨论 | 游戏设计师 | MVP 后 |
| OQ-03 | 是否需要门派专属成就系统？ | 待讨论 | 游戏设计师 | MVP 后 |
| OQ-04 | DLC 门派定价策略？ | 待讨论 | 产品团队 | 发布前 |
| OQ-05 | 是否支持"无门派"玩家（只修内功）？ | 待确认 | 游戏设计师 | 开发前 |

---

## 附录：门派背景故事（MVP）

### Java派

> 吾派传承自上古 Sun 宗，后为 Oracle 大能所收。门中弟子以"一次编写，到处运行"为修仙信条。
>
> 绝学包括集合框架心法、并发术式、JVM 内功、Spring 剑法四大领域。其中集合框架为入门根基，JVM 内功为进阶核心。
>
> 门派驻地：万物皆对象峰

### Go派

> 吾派诞生于 Google 仙山，以"简洁并发，高效如飞"著称。门中弟子崇尚大道至简，代码如诗。
>
> 绝学包括基础语法、并发模型、Runtime 心法、Web 实战四大领域。其中并发模型为镇派之宝，goroutine 之术独步天下。
>
> 门派驻地：云原生峰
