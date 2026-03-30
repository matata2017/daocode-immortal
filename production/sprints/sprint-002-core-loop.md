# Sprint 2: Core Loop & Presentation

> **Sprint Goal**: 实现核心玩法循环——答题修炼、修为计算、答题反馈
> **Duration**: 2 weeks
> **Start Date**: 2026-04-14
> **End Date**: 2026-04-27

---

## Overview

Sprint 2 聚焦于 **Core Layer** 和 **Presentation Layer**，实现基本的答题玩法和UI反馈。

完成后，玩家可以：
- 看到题目并作答
- 获得答题反馈（对/错/解析）
- 修为增长
- 修炼场景正常工作

---

## Prerequisites

- [ ] Sprint 1 所有 Critical Path 任务完成
- [ ] 题库数据系统可用
- [ ] 存档系统可用
- [ ] 音频系统可用

---

## Sprint Backlog

### 🔴 Critical Path (必须完成)

| # | Task | System | GDD | Owner | Effort | Status |
|---|------|--------|-----|-------|--------|--------|
| 2.1 | 实现修为计算公式 | 修为计算系统 | [GDD](../../design/gdd/cultivation-calculation-system.md) | systems-designer | S | 🔲 |
| 2.2 | 实现错题记录 | 错题记录系统 | [GDD](../../design/gdd/wrong-question-record-system.md) | gameplay-programmer | S | 🔲 |
| 2.3 | 实现答题反馈UI | 答题反馈系统 | [GDD](../../design/gdd/answer-feedback-system.md) | ui-programmer | M | 🔲 |
| 2.4 | 实现修炼场景 | 修炼场景系统 | [GDD](../../design/gdd/practice-scene-system.md) | ui-programmer | M | 🔲 |
| 2.5 | 实现答题修炼流程 | 答题修炼系统 | [GDD](../../design/gdd/practice-cultivation-system.md) | gameplay-programmer | L | 🔲 |
| 2.6 | 实现代码编辑器 | 代码编辑器 | [GDD](../../design/gdd/code-editor-system.md) | ui-programmer | M | 🔲 |

### 🟡 High Priority (应该完成)

| # | Task | System | GDD | Owner | Effort | Status |
|---|------|--------|-----|-------|--------|--------|
| 2.7 | 实现心魔UI | 心魔UI系统 | [GDD](../../design/gdd/demon-ui-system.md) | ui-programmer | S | 🔲 |
| 2.8 | 实现心魔复习流程 | 心魔复习系统 | [GDD](../../design/gdd/demon-review-system.md) | gameplay-programmer | M | 🔲 |
| 2.9 | 实现回答分析 | 回答分析系统 | [GDD](../../design/gdd/answer-analysis-system.md) | ai-programmer | M | 🔲 |

---

## Definition of Done

- [ ] 代码通过 GUT 单元测试
- [ ] 相关 GDD 的 Acceptance Criteria 全部通过
- [ ] 无 console 错误或警告
- [ ] 答题流程可以端到端运行

---

## Sprint Deliverables

### 代码

```
src/
├── systems/
│   ├── cultivation_calculator.gd    # 修为计算
│   ├── wrong_question_tracker.gd    # 错题记录
│   └── answer_analyzer.gd           # 回答分析
├── scenes/
│   └── practice_scene.gd            # 修炼场景
├── ui/
│   ├── answer_feedback.gd           # 答题反馈
│   ├── code_editor.gd               # 代码编辑器
│   └── demon_panel.gd               # 心魔面板
└── gameplay/
    └── practice_cultivation.gd      # 答题修炼主逻辑
```

### 测试

```
tests/
├── unit/
│   ├── test_cultivation_calculator.gd
│   ├── test_wrong_question_tracker.gd
│   └── test_answer_analyzer.gd
└── integration/
    └── test_practice_flow.gd
```

---

## Sprint Review Checklist

- [ ] 玩家可以答题并获得修为
- [ ] 答题反馈正确显示
- [ ] 错题被正确记录
- [ ] 心魔复习可以触发
- [ ] 测试覆盖率 ≥ 80%
