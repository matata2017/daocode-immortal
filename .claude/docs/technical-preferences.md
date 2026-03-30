# Technical Preferences

<!-- Populated by /setup-engine. Updated as the user makes decisions throughout development. -->
<!-- All agents reference this file for project-specific standards and conventions. -->

## Engine & Language

- **Engine**: Godot 4.6.1
- **Language**: GDScript (primary), C++ via GDExtension (performance-critical)
- **Rendering**: Forward+ (PC), Mobile (移动端)
- **Physics**: Jolt Physics (Godot 4.6 默认)

## Naming Conventions

- **Classes**: PascalCase (e.g., `PlayerController`, `QuestionManager`)
- **Variables/Functions**: snake_case (e.g., `move_speed`, `get_current_question()`)
- **Signals**: snake_case past tense (e.g., `health_changed`, `question_answered`)
- **Files**: snake_case matching class (e.g., `player_controller.gd`, `question_manager.gd`)
- **Scenes**: PascalCase matching root node (e.g., `PlayerController.tscn`, `BossInterview.tscn`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `MAX_QUESTIONS`, `DEFAULT_REALM`)
- **Enums**: PascalCase for enum name, UPPER_SNAKE_CASE for values (e.g., `Realm.LOW_QI`)

## Performance Budgets

- **Target Framerate**: 60 FPS (PC) / 30 FPS (移动端低端设备)
- **Frame Budget**: 16.6ms (60 FPS) / 33.3ms (30 FPS)
- **Draw Calls**: < 100 per frame (2D UI为主)
- **Memory Ceiling**: 256MB (移动端) / 512MB (PC)
- **Texture Memory**: < 128MB

## Testing

- **Framework**: GUT (Godot Unit Testing)
- **Minimum Coverage**: 80%
- **Required Tests**:
  - 题库数据加载和解析
  - 修为计算公式
  - 境界突破逻辑
  - 心魔（错题）记录和复习
  - AI 面试官 Prompt 生成

## Forbidden Patterns

- **禁止直接调用 MiniMax API** — 必须通过后端代理，API Key 不能暴露在客户端
- **禁止在 _process() 中做重计算** — 使用缓存或信号驱动更新
- **禁止硬编码题目数据** — 题目必须从外部 JSON/Resource 加载
- **禁止阻塞主线程** — 文件 I/O 和网络请求必须异步

## Allowed Libraries / Addons

- **GUT** — 单元测试框架
- **Godot CodeEdit** — 内置代码编辑器
- **MiniMax API** — AI 面试官和美术生成（通过后端代理）
- **自定义 Resource 类型** — 题目数据结构

## Architecture Decisions Log

- **ADR-001**: 使用 GDScript 作为主要开发语言，性能关键部分用 C++ GDExtension
- **ADR-002**: 题库数据使用 JSON 格式存储，运行时加载为自定义 Resource
- **ADR-003**: AI 面试官通过后端代理调用 MiniMax API，不在客户端暴露密钥
- **ADR-004**: 使用 Godot CodeEdit 而非嵌入 WebView 编辑器，保持轻量
