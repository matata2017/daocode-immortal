# Sprint 1: Foundation Layer

> **Sprint Goal**: 搭建游戏基础设施——数据层、存档系统、场景管理、音频系统
> **Duration**: 2 weeks
> **Start Date**: 2026-03-30
> **End Date**: 2026-04-13

---

## Overview

Sprint 1 聚焦于 **Foundation Layer**（基础层）系统，这些系统没有依赖，是所有其他系统的基石。

完成后，游戏将具备：
- 完整的数据定义（题库、境界、门派、BOSS）
- 存档系统（进度持久化）
- 场景管理（场景切换）
- 音频系统（BGM/SFX）
- 设置系统（用户偏好）
- API代理后端（AI面试准备）

---

## Sprint Backlog

### 🔴 Critical Path (必须完成)

| # | Task | System | GDD | Owner | Effort | Status |
|---|------|--------|-----|-------|--------|--------|
| 1.1 | 实现题目数据结构 | 题库数据系统 | [GDD](../../design/gdd/question-bank-data-system.md) | gameplay-programmer | M | 🔲 |
| 1.2 | 创建示例题库(20道) | 题库数据系统 | [GDD](../../design/gdd/question-bank-data-system.md) | game-designer | S | 🔲 |
| 1.3 | 实现境界数据定义 | 境界数据系统 | [GDD](../../design/gdd/realm-data-system.md) | gameplay-programmer | S | 🔲 |
| 1.4 | 实现门派数据定义 | 门派数据系统 | [GDD](../../design/gdd/faction-data-system.md) | gameplay-programmer | S | 🔲 |
| 1.5 | 实现存档读写 | 存档系统 | [GDD](../../design/gdd/save-system.md) | gameplay-programmer | M | 🔲 |
| 1.6 | 实现场景切换 | 场景管理系统 | [GDD](../../design/gdd/scene-management-system.md) | gameplay-programmer | S | 🔲 |
| 1.7 | 实现BGM/SFX播放 | 音频系统 | [GDD](../../design/gdd/audio-system.md) | gameplay-programmer | S | 🔲 |

### 🟡 High Priority (应该完成)

| # | Task | System | GDD | Owner | Effort | Status |
|---|------|--------|-----|-------|--------|--------|
| 1.8 | 实现设置面板UI | 设置系统 | [GDD](../../design/gdd/settings-system.md) | ui-programmer | S | 🔲 |
| 1.9 | 实现BOSS数据定义 | BOSS数据系统 | [GDD](../../design/gdd/boss-data-system.md) | gameplay-programmer | S | 🔲 |
| 1.10 | 创建Prompt模板 | Prompt管理系统 | [GDD](../../design/gdd/prompt-management-system.md) | game-designer | M | 🔲 |

### 🟢 Nice to Have (可以延后)

| # | Task | System | GDD | Owner | Effort | Status |
|---|------|--------|-----|-------|--------|--------|
| 1.11 | 部署API代理云函数 | API代理后端 | [GDD](../../design/gdd/api-proxy-backend.md) | backend-programmer | M | 🔲 |
| 1.12 | 扩展题库至50道 | 题库数据系统 | [GDD](../../design/gdd/question-bank-data-system.md) | game-designer | S | 🔲 |

---

## Definition of Done

每个任务必须满足：

- [ ] 代码通过 GUT 单元测试
- [ ] 符合 [coding-standards.md](../../.claude/docs/coding-standards.md)
- [ ] 公共 API 有类型注解和文档注释
- [ ] 相关 GDD 中的 Acceptance Criteria 全部通过
- [ ] 无 console 错误或警告

---

## Sprint Deliverables

### 代码

```
src/
├── data/
│   ├── question_data.gd          # 题目数据结构
│   ├── realm_data.gd             # 境界数据
│   ├── faction_data.gd           # 门派数据
│   └── boss_data.gd              # BOSS数据
├── systems/
│   ├── save_system.gd            # 存档系统
│   ├── scene_manager.gd          # 场景管理
│   └── audio_manager.gd          # 音频管理
├── ui/
│   └── settings_panel.gd         # 设置面板
└── services/
    └── prompt_manager.gd         # Prompt管理
```

### 数据文件

```
assets/data/
├── questions/
│   └── sample_questions.json     # 示例题库(20道)
├── realms.json                   # 境界配置
├── factions.json                 # 门派配置
├── bosses.json                   # BOSS配置
└── prompts/
    └── interview_prompts.json    # AI面试Prompt
```

### 测试

```
tests/
├── unit/
│   ├── test_question_data.gd
│   ├── test_realm_data.gd
│   ├── test_save_system.gd
│   └── test_prompt_manager.gd
└── integration/
    └── test_data_loading.gd
```

---

## Dependencies & Risks

### 外部依赖

| 依赖 | 状态 | 风险 |
|------|------|------|
| Godot 4.6.1 | ✅ 已安装 | 低 |
| GUT 测试框架 | ⚠️ 待安装 | 中 |
| MiniMax API 账号 | ⚠️ 待注册 | 中 |

### 风险

| 风险 | 影响 | 缓解措施 |
|------|------|----------|
| 题库数据结构设计不当 | 高 | 先实现20道示例题验证结构 |
| GUT 框架学习成本 | 中 | 预留1天学习时间 |
| MiniMax API 审核延迟 | 低 | Sprint 1 不强制完成API代理 |

---

## Daily Standup Template

```markdown
## [日期] Standup

### 昨天
- [完成的任务]

### 今天
- [计划的任务]

### 阻塞
- [阻塞问题]
```

---

## Sprint Review Checklist

Sprint 结束时检查：

- [ ] 所有 Critical Path 任务完成
- [ ] 测试覆盖率 ≥ 80%
- [ ] 可以成功加载题库数据
- [ ] 存档可以正常读写
- [ ] 场景可以正常切换
- [ ] 音频可以正常播放
- [ ] Sprint Retrospective 完成

---

## Notes

- 本项目为单人开发，Sprint 用于自我管理
- Effort 估算：S = 0.5-1天，M = 1-2天，L = 3-5天
- 建议每日更新任务状态
