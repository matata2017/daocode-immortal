# Sprint Roadmap

> **Project**: 道码修仙 (DaoCode Immortal)
> **Last Updated**: 2026-03-30

---

## Overview

MVP 开发分为 3 个 Sprint，每个 Sprint 2 周，总计 6 周。

```
Sprint 1          Sprint 2          Sprint 3
Foundation   →    Core Loop    →    Features
(2 weeks)        (2 weeks)         (2 weeks)
    ↓                ↓                 ↓
基础设施          答题玩法          完整循环
```

---

## Sprint Timeline

| Sprint | Name | Duration | Goal | Status |
|--------|------|----------|------|--------|
| [Sprint 1](sprint-001-foundation.md) | Foundation Layer | 2026-03-30 → 2026-04-13 | 数据层、存档、场景、音频 | 🔲 Not Started |
| [Sprint 2](sprint-002-core-loop.md) | Core Loop | 2026-04-14 → 2026-04-27 | 答题修炼、修为计算、反馈UI | 🔲 Not Started |
| [Sprint 3](sprint-003-features.md) | Features | 2026-04-28 → 2026-05-11 | 境界突破、BOSS面试、主菜单 | 🔲 Not Started |

---

## System → Sprint Mapping

### Sprint 1: Foundation (10 systems)

| System | Layer | GDD |
|--------|-------|-----|
| 题库数据系统 | Data | [GDD](../../design/gdd/question-bank-data-system.md) |
| 境界数据系统 | Data | [GDD](../../design/gdd/realm-data-system.md) |
| 门派数据系统 | Data | [GDD](../../design/gdd/faction-data-system.md) |
| BOSS数据系统 | Data | [GDD](../../design/gdd/boss-data-system.md) |
| Prompt管理系统 | Data | [GDD](../../design/gdd/prompt-management-system.md) |
| 存档系统 | Persistence | [GDD](../../design/gdd/save-system.md) |
| 场景管理系统 | Core | [GDD](../../design/gdd/scene-management-system.md) |
| 音频系统 | Audio | [GDD](../../design/gdd/audio-system.md) |
| 设置系统 | Meta | [GDD](../../design/gdd/settings-system.md) |
| API代理后端 | Infrastructure | [GDD](../../design/gdd/api-proxy-backend.md) |

### Sprint 2: Core Loop (9 systems)

| System | Layer | GDD |
|--------|-------|-----|
| 修为计算系统 | Progression | [GDD](../../design/gdd/cultivation-calculation-system.md) |
| 错题记录系统 | Persistence | [GDD](../../design/gdd/wrong-question-record-system.md) |
| 回答分析系统 | AI | [GDD](../../design/gdd/answer-analysis-system.md) |
| 答题反馈系统 | UI | [GDD](../../design/gdd/answer-feedback-system.md) |
| 修炼场景系统 | UI | [GDD](../../design/gdd/practice-scene-system.md) |
| 心魔UI系统 | UI | [GDD](../../design/gdd/demon-ui-system.md) |
| 代码编辑器 | UI | [GDD](../../design/gdd/code-editor-system.md) |
| 答题修炼系统 | Gameplay | [GDD](../../design/gdd/practice-cultivation-system.md) |
| 心魔复习系统 | Gameplay | [GDD](../../design/gdd/demon-review-system.md) |

### Sprint 3: Features (7 systems)

| System | Layer | GDD |
|--------|-------|-----|
| 对话UI系统 | UI | [GDD](../../design/gdd/dialogue-ui-system.md) |
| 面试报告系统 | UI | [GDD](../../design/gdd/interview-report-system.md) |
| 主菜单系统 | UI | [GDD](../../design/gdd/main-menu-system.md) |
| 学习分析系统 | UI | [GDD](../../design/gdd/learning-analytics-system.md) |
| 突破考试系统 | Gameplay | [GDD](../../design/gdd/breakthrough-exam-system.md) |
| 境界突破系统 | Gameplay | [GDD](../../design/gdd/realm-breakthrough-system.md) |
| BOSS面试系统 | Gameplay | [GDD](../../design/gdd/boss-interview-system.md) |

---

## Milestones

| Milestone | Target Date | Criteria |
|-----------|-------------|----------|
| **M1: Foundation Complete** | 2026-04-13 | Sprint 1 DoD 满足 |
| **M2: Core Loop Playable** | 2026-04-27 | 可以答题获得修为 |
| **M3: MVP Complete** | 2026-05-11 | 核心循环完整运行 |

---

## Current Sprint

查看 [active.md](../session-state/active.md) 获取当前进度。
