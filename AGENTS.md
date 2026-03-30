# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

---

## Project: 道码修仙 (DaoCode Immortal)

A cultivation-themed programming interview learning game. Core loop: **答题→修为→境界→BOSS面试**

**Current Stage**: Pre-Production (26 MVP system GDDs designed, prototype ready, Sprint 1-3 planned)

---

## Technology Stack

- **Engine**: Godot 4.6.1
- **Language**: GDScript (primary), C++ via GDExtension (performance-critical only)
- **Rendering**: Forward+ (PC), Mobile (移动端)
- **Physics**: Jolt Physics (Godot 4.6 默认)
- **Testing**: GUT (Godot Unit Testing)
- **AI Services**: MiniMax API (via backend proxy only — never expose API key in client)

---

## Development Commands

### Run Prototype
```bash
# Open in Godot Editor
godot4 prototypes/core-loop/project.godot

# Or run directly
godot4 --path prototypes/core-loop
```

### Testing (GUT)
```bash
# Run all tests
godot4 --headless --path . -s addons/gut/gut_cmdln.gd

# Run specific test file
godot4 --headless --path . -s addons/gut/gut_cmdln.gd -gtest_strict=true tests/unit/test_save_system.gd
```

### Build
```bash
# Export PC build
godot4 --headless --path . --export-release "Windows Desktop" build/windows/
```

---

## Architecture Overview

### Key Architecture Decisions (see `docs/architecture/`)

1. **GDScript primary** — 90%+ code in GDScript for rapid iteration. C++ GDExtension only for performance-critical code paths (marked `# PERF-CRITICAL`)
2. **JSON data storage** — Question bank stored as JSON, loaded as custom Resources at runtime
3. **API proxy pattern** — MiniMax API calls go through cloud function proxy (Supabase/Cloudflare Workers). API key never in client code
4. **Native CodeEdit** — Use Godot's built-in CodeEdit for code questions, not embedded WebView

### System Categories (26 MVP systems)

| Layer | Systems | Dependency |
|-------|---------|------------|
| **Foundation** | 题库/境界/门派/BOSS数据, Prompt管理, 存档, 场景管理, 音频, 设置, API代理 | None |
| **Core** | 修为计算, 错题记录, 回答分析 | Foundation |
| **Presentation** | 答题反馈, 修炼场景, 对话UI, 心魔UI, 代码编辑器, 突破考试, 面试报告, 主菜单, 学习分析 | Core |
| **Feature** | 答题修炼, 境界突破, 心魔复习, BOSS面试 | All above |

See `design/gdd/systems-index.md` for full dependency map.

---

## Design Workflow

### GDD Standard (8 Required Sections)

Every system design document must include:
1. Overview — one-paragraph summary
2. Player Fantasy — intended feeling
3. Detailed Rules — unambiguous mechanics
4. Formulas — all math with variables defined
5. Edge Cases — unusual situations handled
6. Dependencies — other systems listed with interfaces
7. Tuning Knobs — configurable values with ranges
8. Acceptance Criteria — testable success conditions

### Key Skills

| Command | Purpose |
|---------|---------|
| `/design-system <name>` | Section-by-section GDD authoring |
| `/design-review` | Validate GDD against 8-section standard |
| `/map-systems` | Create/update systems index |
| `/gate-check <phase>` | Validate readiness for phase transition |
| `/prototype` | Create throwaway validation prototype |

---

## Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Classes | PascalCase | `PlayerController`, `QuestionManager` |
| Functions/Variables | snake_case | `get_current_question()`, `move_speed` |
| Signals | snake_case past tense | `question_answered`, `health_changed` |
| Files | snake_case | `player_controller.gd` |
| Constants | UPPER_SNAKE_CASE | `MAX_QUESTIONS`, `DEFAULT_REALM` |

---

## Performance Budgets

| Metric | Target |
|--------|--------|
| Framerate | 60 FPS (PC) / 30 FPS (mobile low-end) |
| Frame Budget | 16.6ms (60 FPS) |
| Draw Calls | < 100 per frame |
| Memory | 256MB (mobile) / 512MB (PC) |

---

## Forbidden Patterns

- **Never call MiniMax API directly from client** — must use backend proxy
- **Never do heavy computation in `_process()`** — use signals or caching
- **Never hardcode question data** — load from external JSON/Resource
- **Never block main thread** — file I/O and network must be async

---

## Context Management

**The file is the memory, not the conversation.** Always:

1. Update `production/session-state/active.md` after each milestone
2. Write design sections to file immediately after approval (incremental writing)
3. After compaction/crash, read `active.md` first to recover state

See `.Codex/docs/context-management.md` for full protocol.

---

## Key Files

| File | Purpose |
|------|---------|
| `design/gdd/game-concept.md` | Game vision, core fantasy, pillars |
| `design/gdd/systems-index.md` | All 26 systems, dependencies, progress |
| `design/gdd/*.md` | Individual system GDDs |
| `docs/architecture/ADR-*.md` | Architecture decision records |
| `production/sprints/sprint-*.md` | Sprint plans and task breakdown |
| `prototypes/core-loop/` | Core loop validation prototype |
| `.Codex/docs/technical-preferences.md` | Naming, performance, testing config |