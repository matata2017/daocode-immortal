# 存档系统 (Save System)

> **Status**: Designed
> **Author**: User + Claude Code
> **Last Updated**: 2026-03-30
> **Implements Pillar**: 成长可见、碎片友好

## Overview

**存档系统**负责持久化玩家所有进度数据，包括基础信息（门派、境界、修为）、答题记录、错题本、BOSS挑战记录、以及用户设置。

采用 **单存档 + 实时自动保存** 模式，玩家无需手动保存，所有操作即时写入本地，后期支持云同步。

**为什么需要这个系统**：存档是"成长可见"支柱的基础。没有它，玩家每次启动都要从头开始，破坏游戏体验。实时保存支持"碎片友好"，随时退出随时恢复。

## Player Fantasy

**你的修炼进度永远不会丢失。**

无论是地铁上刷了5分钟题，还是周末深度修炼2小时，所有进度都会被完整保存。下次打开游戏，你立刻回到上次的状态。

### 玩家体验场景
**场景 1：地铁上快速刷题**
玩家在地铁上刷了3道题，到站直接关闭游戏。第二天打开，这3道题的记录都在，修为也已增加。

**场景 2：挑战BOSS失败**
玩家挑战大厂长老失败，被扣除10%修为。第二天打开游戏，扣除的修为已经生效，BOSS挑战记录也保存了。

### 支撑的游戏支柱
| 支柱 | 如何体现 |
|------|----------|
| **成长可见** | 所有进度数据持久保存，随时可查 |
| **碎片友好** | 实时保存，随时退出随时恢复 |
| **沉浸修仙** | 存档数据以修仙风格命名（如"修炼记录"） |

## Detailed Design

### Core Rules

#### 存档数据结构
```gdscript
class_name SaveData
extends Resource

@export var version: int = 1                    # 存档版本
@export var created_at: String               # 创建时间 ISO8601
@export var last_played_at: String            # 最后游玩时间

# 玩家基础信息
@export var faction_id: String                # 当前门派
@export var realm_id: String                  # 当前境界
@export var cultivation: int = 0              # 修为值

# 答题记录
@export var answered_questions: Dictionary     # {question_id: {correct: bool, answered_at: String}}
@export var total_correct: int = 0             # 总答对数
@export var total_answered: int = 0            # 总答题数

# 错题记录（心魔）
@export var wrong_questions: Dictionary        # {question_id: {wrong_count: int, last_wrong_at: String, last_review_at: String}}

# BOSS 挑战记录
@export var boss_challenges: Dictionary       # {boss_id: {attempts: int, best_score: int, defeated: bool, last_attempt_at: String}}

# 境界突破记录
@export var realm_breakthroughs: Dictionary   # {realm_id: {achieved_at: String, attempts: int}}

# 门派进度
@export var faction_mastery: Dictionary       # {faction_id: {domain_mastery: Dictionary}}

# 用户设置
@export var settings: Dictionary             # {volume_master: float, notifications_enabled: bool}
```

#### 存档文件位置
```
# Windows
%APPDATA%/DaoCodeImmortal/save.json

# macOS
~/Library/Application Support/DaoCodeImmortal/save.json

# Linux
~/.local/share/DaoCodeImmortal/save.json

# Android
/data/data/[package_name]/files/save.json

# iOS
Application.persistentDataPath + "/save.json"
```

#### 自动保存触发时机
| 触发事件 | 保存内容 | 保存频率 |
|----------|----------|----------|
| 答题完成 | 答题记录、修为值 | 即时 |
| 境界突破 | 境界记录、修为值 | 即时 |
| BOSS 挑战结束 | BOSS 记录 | 即时 |
| 切换门派 | 门派ID | 即时 |
| 修改设置 | 设置数据 | 即时 |
| 退出游戏 | 客户端数据 | 即时 |

### States and Transitions
```
┌─────────────────┐
│  存档未初始化    │  新安装
└────────┬────────┘
         │ 初始化存档
         ↓
┌─────────────────┐
│  存档已加载      │  游戏运行中
└────────┬────────┘
         │ 数据变更
         ↓
┌─────────────────┐
│  存档已更新      │  自动保存中
└────────┬────────┘
         │ 保存完成
         ↓
┌─────────────────┐
│  存档已同步      │  云同步完成
└─────────────────┘
```

### Interactions with Other Systems
| 系统 | 数据流向 | 接口 |
|------|----------|------|
| **修为计算系统** | 存档→修为 | `get/set_cultivation()` |
| **错题记录系统** | 存档→错题 | `get/add_wrong_question()` |
| **境界数据系统** | 存档→境界 | `get/set_realm_id()` |
| **门派数据系统** | 存档→门派 | `get/set_faction_id()` |
| **BOSS数据系统** | 存档→BOSS进度 | `get/update_boss_challenge()` |
| **面试报告系统** | 存档→报告历史 | `add_interview_report()` |
| **设置系统** | 存档→设置 | `get/set_settings()` |

## Formulas

### 存档大小估算
```
save_size_bytes =
    base_overhead (500) +
    answered_questions * 100 +
    wrong_questions * 80 +
    boss_challenges * 60 +
    settings * 50

# 预估 300 题后:
# 500 + 300*100 + 50*80 + 5*60 + 50 = 500 + 30000 + 4000 + 300 + 50 ≈ 35KB
```

### 存档版本迁移
```
migrate_save(old_save, target_version) =
    CASE old_save.version:
        1 → target_version:  # 当前版本，无需迁移
            return old_save
        ELSE:
            return error("不支持的存档版本")
```

## Edge Cases
| 边缘情况 | 处理方式 | 影响范围 |
|----------|----------|----------|
| **存档文件损坏** | 重置为新存档，显示提示"存档损坏，已重置" | 启动流程 |
| **存档版本不兼容** | 尝试迁移，失败则重置 | 启动流程 |
| **存储空间不足** | 显示错误，禁止继续游戏 | 存档流程 |
| **云同步失败** | 本地存档继续，显示"云同步失败"图标 | UI |
| **多设备同时使用** | 后保存的覆盖先保存的 | 云同步 |
| **清除存档** | 确认后删除，显示新手引导 | 设置系统 |
| **导入旧存档** | 版本迁移后导入 | 设置系统 |

## Dependencies
### 上游依赖（无）
存档系统是基础设施层，**无上游依赖**。

### 下游依赖（被依赖）
| 系统 | 依赖类型 | 接口契约 |
|------|----------|----------|
| **修为计算系统** | 硬依赖 | `get/set_cultivation()` |
| **错题记录系统** | 硬依赖 | `get/add_wrong_question()` |
| **境界突破系统** | 硬依赖 | `get/set_realm_id()` |
| **门派数据系统** | 硬依赖 | `get/set_faction_id()` |
| **BOSS数据系统** | 硬依赖 | `get/update_boss_challenge()` |
| **面试报告系统** | 硬依赖 | `add_interview_report()` |
| **设置系统** | 硬依赖 | `get/set_settings()` |

## Tuning Knobs
| Knob | 类型 | 默认值 | 范围 | 影响范围 |
|------|------|--------|------|----------|
| `auto_save_interval_seconds` | int | 30 | 10-300 | 自动保存检查间隔 |
| `cloud_sync_interval_seconds` | int | 300 | 60-3600 | 云同步检查间隔 |
| `max_save_size_kb` | int | 100 | 50-500 | 最大存档大小限制 |
| `backup_count` | int | 3 | 1-10 | 本地备份数量 |
| `compression_enabled` | bool | true | true/false | 是否压缩存档 |

### 调参指南
- **自动保存间隔**：若发现性能问题，可增大间隔
- **云同步间隔**：若云服务压力大，可增大间隔
- **备份数量**：若需要更安全的回滚，可增加备份数量

## Acceptance Criteria
### 功能验收
| # | 验收条件 | 优先级 | 测试方法 |
|---|----------|--------|----------|
| AC-01 | 游戏启动时自动加载存档 | P0 | 单元测试 |
| AC-02 | 数据变更后自动保存 | P0 | 单元测试 |
| AC-03 | 存档损坏时重置为新存档 | P0 | 单元测试 |
| AC-04 | 云同步失败时不影响本地存档 | P1 | 集成测试 |
| AC-05 | 存档版本迁移正常工作 | P1 | 单元测试 |
| AC-06 | 清除存档需要确认 | P1 | 手动测试 |
| AC-07 | 存档大小在限制内 | P1 | 单元测试 |
| AC-08 | 多平台存档位置正确 | P1 | 手动测试 |

### 性能验收
| # | 验收条件 | 目标值 |
|---|----------|--------|
| AC-09 | 存档加载时间 | < 100ms |
| AC-10 | 存档保存时间 | < 50ms |
| AC-11 | 云同步时间 | < 2s |

## Open Questions
| # | 问题 | 状态 | 决策/负责人 | 目标日期 |
|---|------|------|-------------|----------|
| OQ-01 | 云存档使用哪个服务？ | 待确认 | 后端团队 | Alpha 前 |
| OQ-02 | 是否支持导出/导入存档？ | 待讨论 | 产品团队 | Beta 前 |
| OQ-03 | 存档是否加密？ | 待确认 | 安全团队 | Alpha 前 |
| OQ-04 | 如何处理玩家作弊修改存档？ | 待讨论 | 游戏设计师 | 发布前 |
| OQ-05 | 是否支持 Steam 云存档？ | 待确认 | 后端团队 | 发布前 |

---

## 附录：存档数据示例
```json
{
  "version": 1,
  "created_at": "2026-03-30T10:00:00Z",
  "last_played_at": "2026-03-30T15:30:00Z",
  "faction_id": "JAVA",
  "realm_id": "GOLDEN_CORE",
  "cultivation": 1500,
  "answered_questions": {
    "q_001": { "correct": true, "answered_at": "2026-03-30T10:05:00Z" },
    "q_002": { "correct": false, "answered_at": "2026-03-30T10:10:00Z" }
  },
  "total_correct": 1,
  "total_answered": 2,
  "wrong_questions": {
    "q_002": { "wrong_count": 1, "last_wrong_at": "2026-03-30T10:10:00Z" }
  },
  "boss_challenges": {
    "OUTSOURCE_HR": { "attempts": 0, "defeated": false }
  },
  "realm_breakthroughs": {
    "QI_REFINING": { "achieved_at": "2026-03-30T10:30:00Z", "attempts": 1 },
    "FOUNDATION": { "achieved_at": "2026-03-30T12:00:00Z", "attempts": 2 },
    "GOLDEN_CORE": { "achieved_at": "2026-03-30T14:00:00Z", "attempts": 1 }
  },
  "faction_mastery": {
    "JAVA": {
      "collections": 0.7,
      "concurrency": 0.4,
      "jvm": 0.3,
      "spring": 0.2
    }
  },
  "settings": {
    "volume_master": 0.8,
    "volume_music": 0.6,
    "volume_sfx": 0.8,
    "notifications_enabled": true
  }
}
```