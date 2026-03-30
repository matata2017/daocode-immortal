# Systems Index: 道码修仙 (DaoCode Immortal)

> **Status**: Draft
> **Created**: 2026-03-30
> **Last Updated**: 2026-03-30
> **Source Concept**: design/gdd/game-concept.md

---

## Overview

道码修仙是一款修仙主题的编程面试学习游戏，核心循环是"答题→修为→境界→BOSS面试"。

游戏需要以下类型的系统：
- **数据层**：题库、境界、BOSS、门派的数据定义和加载
- **核心玩法**：答题修炼、境界突破、心魔复习、BOSS面试四大核心系统
- **AI集成**：MiniMax API 代理、Prompt 管理、回答分析
- **表现层**：答题反馈、修炼场景、对话UI、代码编辑器
- **基础设施**：存档、场景管理、音频、设置、主菜单

---

## Systems Enumeration

| # | System Name | Category | Priority | Status | Design Doc | Depends On |
|---|-------------|----------|----------|--------|------------|------------|
| 1 | 题库数据系统 | Data | MVP | Designed | [question-bank-data-system.md](question-bank-data-system.md) | 无 |
| 2 | 境界数据系统 | Data | MVP | Designed | [realm-data-system.md](realm-data-system.md) | 无 |
| 3 | BOSS数据系统 | Data | MVP | Designed | [boss-data-system.md](boss-data-system.md) | 无 |
| 4 | 门派数据系统 | Data | MVP | Designed | [faction-data-system.md](faction-data-system.md) | 无 |
| 5 | Prompt管理系统 | Data | MVP | Designed | [prompt-management-system.md](prompt-management-system.md) | 无 |
| 6 | 存档系统 | Persistence | MVP | Designed | [save-system.md](save-system.md) | 无 |
| 7 | 场景管理系统 | Core | MVP | Designed | [scene-management-system.md](scene-management-system.md) | 无 |
| 8 | 音频系统 | Audio | MVP | Designed | [audio-system.md](audio-system.md) | 无 |
| 9 | 设置系统 | Meta | MVP | Designed | [settings-system.md](settings-system.md) | 无 |
| 10 | API代理后端 | Infrastructure | MVP | Designed | [api-proxy-backend.md](api-proxy-backend.md) | 无 |
| 11 | 修为计算系统 | Progression | MVP | Designed | [cultivation-calculation-system.md](cultivation-calculation-system.md) | 存档系统, 境界数据系统 |
| 12 | 错题记录系统 | Persistence | MVP | Designed | [wrong-question-record-system.md](wrong-question-record-system.md) | 题库数据系统, 存档系统 |
| 13 | 回答分析系统 | AI | MVP | Designed | [answer-analysis-system.md](answer-analysis-system.md) | API代理后端, Prompt管理系统 |
| 14 | 答题反馈系统 | UI | MVP | Designed | [answer-feedback-system.md](answer-feedback-system.md) | 音频系统 |
| 15 | 修炼场景系统 | UI | MVP | Designed | [practice-scene-system.md](practice-scene-system.md) | 场景管理系统, 音频系统 |
| 16 | 对话UI系统 | UI | MVP | Designed | [dialogue-ui-system.md](dialogue-ui-system.md) | 场景管理系统 |
| 17 | 心魔UI系统 | UI | MVP | Designed | [demon-ui-system.md](demon-ui-system.md) | 错题记录系统 |
| 18 | 代码编辑器 | UI | MVP | Designed | [code-editor-system.md](code-editor-system.md) | 题库数据系统 |
| 19 | 突破考试系统 | Gameplay | MVP | Designed | [breakthrough-exam-system.md](breakthrough-exam-system.md) | 题库数据系统, 答题反馈系统 |
| 20 | 面试报告系统 | UI | MVP | Designed | [interview-report-system.md](interview-report-system.md) | 回答分析系统, 存档系统 |
| 21 | 答题修炼系统 | Gameplay | MVP | Designed | [practice-cultivation-system.md](practice-cultivation-system.md) | 题库数据系统, 修为计算系统, 答题反馈系统, 修炼场景系统 |
| 22 | 境界突破系统 | Gameplay | MVP | Designed | [realm-breakthrough-system.md](realm-breakthrough-system.md) | 境界数据系统, 修为计算系统, 突破考试系统 |
| 23 | 心魔复习系统 | Gameplay | MVP | Designed | [demon-review-system.md](demon-review-system.md) | 错题记录系统, 心魔UI系统, 题库数据系统 |
| 24 | BOSS面试系统 | Gameplay | MVP | Designed | [boss-interview-system.md](boss-interview-system.md) | BOSS数据系统, 对话UI系统, 回答分析系统, 面试报告系统 |
| 25 | 主菜单系统 | UI | MVP | Designed | [main-menu-system.md](main-menu-system.md) | 场景管理系统, 门派数据系统, 存档系统, 设置系统 |
| 26 | 学习分析系统 | UI | MVP | Designed | [learning-analytics-system.md](learning-analytics-system.md) | 存档系统, 题库数据系统, 门派数据系统, 错题记录系统 |

---

## Categories

| Category | Description | Systems in This Game |
|----------|-------------|---------------------|
| **Data** | 数据定义和加载 | 题库数据, 境界数据, BOSS数据, 门派数据, Prompt管理 |
| **Core** | 基础设施系统 | 场景管理 |
| **Gameplay** | 核心玩法系统 | 答题修炼, 境界突破, 心魔复习, BOSS面试, 突破考试 |
| **Progression** | 玩家成长系统 | 修为计算 |
| **Persistence** | 存档和状态持久化 | 存档系统, 错题记录 |
| **UI** | 玩家界面 | 答题反馈, 修炼场景, 对话UI, 心魔UI, 代码编辑器, 面试报告, 主菜单, 学习分析 |
| **Audio** | 音频系统 | 音频系统 |
| **AI** | AI集成系统 | 回答分析, API代理后端 |
| **Meta** | 元系统 | 设置系统 |

---

## Priority Tiers

| Tier | Definition | Target Milestone | Design Urgency |
|------|------------|------------------|----------------|
| **MVP** | 核心循环必需系统。缺少这些无法验证"是否有用/有趣" | 4-8周 MVP | 设计优先 |
| **Vertical Slice** | 完整体验必需，但可在 MVP 后迭代 | 8-12周 | 设计次优先 |
| **Full Vision** | 完整愿景，多门派、社交等 | 3-6个月 | 后期设计 |

> **注意**：根据概念文档，所有 25 个系统都是 MVP 范围，因为核心循环依赖它们。

---

## Dependency Map

### Foundation Layer (no dependencies)

1. **题库数据系统** — 核心数据定义，被多个系统依赖
2. **境界数据系统** — 成长系统数据基础
3. **BOSS数据系统** — 面试系统数据基础
4. **门派数据系统** — 题库分类基础
5. **Prompt管理系统** — AI 面试官 Prompt 模板
6. **存档系统** — 进度持久化基础设施
7. **场景管理系统** — 场景切换基础设施
8. **音频系统** — 音效和音乐基础设施
9. **设置系统** — 用户偏好基础设施
10. **API代理后端** — MiniMax API 代理服务

### Core Layer (depends on foundation)

1. **修为计算系统** — depends on: 存档系统, 境界数据系统
2. **错题记录系统** — depends on: 题库数据系统, 存档系统
3. **回答分析系统** — depends on: API代理后端, Prompt管理系统

### Feature Layer (depends on core)

1. **答题修炼系统** — depends on: 题库数据系统, 修为计算系统, 答题反馈系统, 修炼场景系统
2. **境界突破系统** — depends on: 境界数据系统, 修为计算系统, 突破考试系统
3. **心魔复习系统** — depends on: 错题记录系统, 心魔UI系统, 题库数据系统
4. **BOSS面试系统** — depends on: BOSS数据系统, 对话UI系统, 回答分析系统, 面试报告系统

### Presentation Layer (depends on features)

1. **答题反馈系统** — depends on: 音频系统
2. **修炼场景系统** — depends on: 场景管理系统, 音频系统
3. **对话UI系统** — depends on: 场景管理系统
4. **心魔UI系统** — depends on: 错题记录系统
5. **代码编辑器** — depends on: 题库数据系统
6. **突破考试系统** — depends on: 题库数据系统, 答题反馈系统
7. **面试报告系统** — depends on: 回答分析系统, 存档系统
8. **主菜单系统** — depends on: 场景管理系统, 门派数据系统, 存档系统, 设置系统
9. **学习分析系统** — depends on: 存档系统, 题库数据系统, 门派数据系统, 错题记录系统

---

## Recommended Design Order

| Order | System | Priority | Layer | Agent(s) | Est. Effort |
|-------|--------|----------|-------|----------|-------------|
| 1 | 题库数据系统 | MVP | Foundation | game-designer, systems-designer | M |
| 2 | 境界数据系统 | MVP | Foundation | game-designer, systems-designer | S |
| 3 | 门派数据系统 | MVP | Foundation | game-designer | S |
| 4 | BOSS数据系统 | MVP | Foundation | game-designer | S |
| 5 | Prompt管理系统 | MVP | Foundation | ai-programmer, game-designer | M |
| 6 | 存档系统 | MVP | Foundation | gameplay-programmer | M |
| 7 | 场景管理系统 | MVP | Foundation | gameplay-programmer | S |
| 8 | 音频系统 | MVP | Foundation | audio-director | S |
| 9 | 设置系统 | MVP | Foundation | ui-programmer | S |
| 10 | API代理后端 | MVP | Foundation | backend-programmer | M |
| 11 | 修为计算系统 | MVP | Core | systems-designer | S |
| 12 | 错题记录系统 | MVP | Core | gameplay-programmer | S |
| 13 | 回答分析系统 | MVP | Core | ai-programmer | M |
| 14 | 答题反馈系统 | MVP | Presentation | ux-designer, audio-director | M |
| 15 | 修炼场景系统 | MVP | Presentation | ux-designer, art-director | M |
| 16 | 对话UI系统 | MVP | Presentation | ux-designer, ui-programmer | M |
| 17 | 心魔UI系统 | MVP | Presentation | ux-designer, ui-programmer | S |
| 18 | 代码编辑器 | MVP | Presentation | ui-programmer | M |
| 19 | 突破考试系统 | MVP | Presentation | game-designer | S |
| 20 | 面试报告系统 | MVP | Presentation | ux-designer | S |
| 21 | 答题修炼系统 | MVP | Feature | game-designer, gameplay-programmer | L |
| 22 | 境界突破系统 | MVP | Feature | game-designer, gameplay-programmer | M |
| 23 | 心魔复习系统 | MVP | Feature | game-designer, gameplay-programmer | M |
| 24 | BOSS面试系统 | MVP | Feature | game-designer, ai-programmer | L |
| 25 | 主菜单系统 | MVP | Presentation | ux-designer, ui-programmer | M |
| 26 | 学习分析系统 | MVP | Presentation | ux-designer, ui-programmer | M |

**Effort estimates**:
- S = 1 session (单次设计对话)
- M = 2-3 sessions
- L = 4+ sessions

---

## Circular Dependencies

**无循环依赖发现。**

所有依赖关系都是单向的，可以按照依赖顺序依次设计。

---

## High-Risk Systems

| System | Risk Type | Risk Description | Mitigation |
|--------|-----------|-----------------|------------|
| **题库数据系统** | Scope | 300+道题的数据结构和导入流程复杂 | 早期原型 PDF 导入，先验证 50 道精选题 |
| **API代理后端** | Technical | MiniMax API 集成和密钥安全 | 使用云函数（Supabase/Cloudflare）代理 |
| **回答分析系统** | Design | AI 返回解析和追问逻辑复杂 | 设计清晰的 Prompt 模板，缓存常见回答 |
| **BOSS面试系统** | Scope | AI 面试官体验依赖多个子系统 | 先完成其他系统，最后整合测试 |
| **答题反馈系统** | Design | 反馈质量直接影响游戏感 | 早期原型测试，迭代调整 |

---

| Progress Tracker

| Metric | Count |
|--------|-------|
| Total systems identified | 26 |
| Design docs started | 26 |
| Design docs reviewed | 0 |
| Design docs approved | 0 |
| MVP systems designed | 26/26 |
| Vertical Slice systems designed | 0/0 |

### Design Progress

| # | System | Status | Design Doc |
|---|--------|--------|------------|
| 1 | 题库数据系统 | ✅ Designed | [question-bank-data-system.md](question-bank-data-system.md) |
| 2 | 境界数据系统 | ✅ Designed | [realm-data-system.md](realm-data-system.md) |
| 3 | BOSS数据系统 | ✅ Designed | [boss-data-system.md](boss-data-system.md) |
| 4 | 门派数据系统 | ✅ Designed | [faction-data-system.md](faction-data-system.md) |
| 5 | Prompt管理系统 | ✅ Designed | [prompt-management-system.md](prompt-management-system.md) |
| 6 | 存档系统 | ✅ Designed | [save-system.md](save-system.md) |
| 7 | 场景管理系统 | ✅ Designed | [scene-management-system.md](scene-management-system.md) |
| 8 | API代理后端 | ✅ Designed | [api-proxy-backend.md](api-proxy-backend.md) |
| 9 | 修为计算系统 | ✅ Designed | [cultivation-calculation-system.md](cultivation-calculation-system.md) |
| 10 | 错题记录系统 | ✅ Designed | [wrong-question-record-system.md](wrong-question-record-system.md) |
| 11 | 心魔复习系统 | ✅ Designed | [demon-review-system.md](demon-review-system.md) |
| 12 | 学习分析系统 | ✅ Designed | [learning-analytics-system.md](learning-analytics-system.md) |
| 13 | 心魔UI系统 | ✅ Designed | [demon-ui-system.md](demon-ui-system.md) |
| 14 | 音频系统 | ✅ Designed | [audio-system.md](audio-system.md) |
| 15 | 设置系统 | ✅ Designed | [settings-system.md](settings-system.md) |
| 16 | 回答分析系统 | ✅ Designed | [answer-analysis-system.md](answer-analysis-system.md) |
| 17 | 答题反馈系统 | ✅ Designed | [answer-feedback-system.md](answer-feedback-system.md) |
| 18 | 突破考试系统 | ✅ Designed | [breakthrough-exam-system.md](breakthrough-exam-system.md) |
| 19 | 境界突破系统 | ✅ Designed | [realm-breakthrough-system.md](realm-breakthrough-system.md) |
| 20 | 修炼场景系统 | ✅ Designed | [practice-scene-system.md](practice-scene-system.md) |
| 21 | 答题修炼系统 | ✅ Designed | [practice-cultivation-system.md](practice-cultivation-system.md) |
| 22 | 主菜单系统 | ✅ Designed | [main-menu-system.md](main-menu-system.md) |
| 23 | 对话UI系统 | ✅ Designed | [dialogue-ui-system.md](dialogue-ui-system.md) |
| 24 | 代码编辑器 | ✅ Designed | [code-editor-system.md](code-editor-system.md) |
| 25 | 面试报告系统 | ✅ Designed | [interview-report-system.md](interview-report-system.md) |
| 26 | BOSS面试系统 | ✅ Designed | [boss-interview-system.md](boss-interview-system.md) |

---

## Next Steps

- [ ] 审核并批准此系统枚举
- [ ] 设计第一个系统：**题库数据系统**（使用 `/design-system 题库数据系统`）
- [ ] 按设计顺序依次完成各系统 GDD
- [ ] 每个完成后运行 `/design-review`
- [ ] 高风险系统早期原型（题库导入、AI 面试官）
- [ ] MVP 系统设计完成后运行 `/gate-check pre-production`
