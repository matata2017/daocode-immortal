# Sprint 3: Features & Polish

> **Sprint Goal**: 完成核心功能——境界突破、BOSS面试、主菜单、学习分析
> **Duration**: 2 weeks
> **Start Date**: 2026-04-28
> **End Date**: 2026-05-11

---

## Overview

Sprint 3 聚焦于 **Feature Layer** 和剩余 UI 系统，完成游戏的完整核心循环。

完成后，玩家可以体验：
- 完整的主菜单流程
- 境界突破考试
- BOSS 面试
- 学习分析面板
- 完整的核心循环：答题→修为→境界→BOSS面试

---

## Prerequisites

- [ ] Sprint 2 所有 Critical Path 任务完成
- [ ] 答题修炼系统可用
- [ ] 回答分析系统可用（或 Mock 版本）

---

## Sprint Backlog

### 🔴 Critical Path (必须完成)

| # | Task | System | GDD | Owner | Effort | Status |
|---|------|--------|-----|-------|--------|--------|
| 3.1 | 实现突破考试 | 突破考试系统 | [GDD](../../design/gdd/breakthrough-exam-system.md) | gameplay-programmer | S | 🔲 |
| 3.2 | 实现境界突破 | 境界突破系统 | [GDD](../../design/gdd/realm-breakthrough-system.md) | gameplay-programmer | M | 🔲 |
| 3.3 | 实现对话UI | 对话UI系统 | [GDD](../../design/gdd/dialogue-ui-system.md) | ui-programmer | M | 🔲 |
| 3.4 | 实现面试报告 | 面试报告系统 | [GDD](../../design/gdd/interview-report-system.md) | ui-programmer | S | 🔲 |
| 3.5 | 实现BOSS面试流程 | BOSS面试系统 | [GDD](../../design/gdd/boss-interview-system.md) | ai-programmer | L | 🔲 |
| 3.6 | 实现主菜单 | 主菜单系统 | [GDD](../../design/gdd/main-menu-system.md) | ui-programmer | M | 🔲 |

### 🟡 High Priority (应该完成)

| # | Task | System | GDD | Owner | Effort | Status |
|---|------|--------|-----|-------|--------|--------|
| 3.7 | 实现学习分析面板 | 学习分析系统 | [GDD](../../design/gdd/learning-analytics-system.md) | ui-programmer | M | 🔲 |
| 3.8 | 整合AI面试官 | 回答分析系统 | [GDD](../../design/gdd/answer-analysis-system.md) | ai-programmer | M | 🔲 |

### 🟢 Nice to Have (可以延后)

| # | Task | System | GDD | Owner | Effort | Status |
|---|------|--------|-----|-------|--------|--------|
| 3.9 | 扩展题库至100道 | 题库数据系统 | [GDD](../../design/gdd/question-bank-data-system.md) | game-designer | M | 🔲 |
| 3.10 | 添加更多BOSS | BOSS数据系统 | [GDD](../../design/gdd/boss-data-system.md) | game-designer | S | 🔲 |

---

## Definition of Done

- [ ] 代码通过 GUT 单元测试
- [ ] 相关 GDD 的 Acceptance Criteria 全部通过
- [ ] 核心循环可以端到端运行
- [ ] MVP 功能完整

---

## Sprint Deliverables

### 代码

```
src/
├── systems/
│   ├── breakthrough_exam.gd        # 突破考试
│   └── realm_breakthrough.gd       # 境界突破
├── scenes/
│   ├── main_menu.gd                # 主菜单
│   └── boss_interview.gd           # BOSS面试场景
├── ui/
│   ├── dialogue_ui.gd              # 对话UI
│   ├── interview_report.gd         # 面试报告
│   └── learning_analytics.gd       # 学习分析
└── gameplay/
    └── boss_interview_manager.gd   # BOSS面试主逻辑
```

---

## Sprint Review Checklist

- [ ] 主菜单可以正常进入游戏
- [ ] 境界突破可以触发并完成
- [ ] BOSS面试可以正常进行
- [ ] 面试报告正确生成
- [ ] 学习分析面板显示正确
- [ ] 核心循环完整：答题→修为→境界→BOSS面试
- [ ] 测试覆盖率 ≥ 80%

---

## MVP 完成标志

Sprint 3 结束后，MVP 应该可以：
1. 从主菜单开始游戏
2. 选择门派
3. 答题获得修为
4. 达到阈值后境界突破
5. 挑战BOSS面试
6. 查看学习分析

**此时可以进入 Pre-Production → Production 阶段转换**
