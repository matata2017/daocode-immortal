# ADR-001: GDScript 作为主要开发语言

> **Status**: Accepted
> **Date**: 2026-03-30
> **Decision Makers**: User + Claude Code

## Context

道码修仙是一款修仙主题的编程面试学习游戏，需要选择合适的开发语言。

### 问题

- 游戏主要功能：答题系统、UI交互、数据管理、AI面试对话
- 目标平台：PC (Windows/Mac/Linux) 和移动端 (Android/iOS)
- 团队规模：单人独立开发
- 性能需求：大部分为2D UI场景，少量代码编辑器功能可能有性能需求

### 考虑方案

| 方案 | 优点 | 缺点 |
|------|------|------|
| **GDScript** | Godot原生、语法简单、快速迭代、文档丰富 | 性能不如C++、类型系统较弱 |
| **C#** | 强类型、性能好、生态丰富 | 需要额外配置.NET、学习成本 |
| **C++ (GDExtension)** | 最高性能、完全控制 | 开发慢、编译复杂、调试困难 |
| **混合方案** | 平衡开发效率和性能 | 架构复杂度高 |

## Decision

采用**混合方案**：
- **GDScript** 作为主要开发语言（90%+代码）
- **C++ via GDExtension** 仅用于性能关键部分

### 理由

1. **快速迭代优先**：独立开发需要快速验证想法，GDScript最适合
2. **2D UI为主**：本游戏大部分是UI和数据处理，不需要极致性能
3. **预留性能空间**：如果代码编辑器等功能需要优化，可用GDExtension
4. **降低复杂度**：混合方案比纯C++简单，比纯GDScript灵活

## Consequences

### 正面

- 开发速度大幅提升（GDScript编写快、调试快）
- 资源管理和场景系统集成良好
- 移动端部署简单（GDScript无需额外编译）

### 负面

- 需要维护GDScript/C++边界（如果使用GDExtension）
- GDScript类型系统较弱，需要更多测试覆盖
- 如果需要大量GDExtension，会增加构建复杂度

### 需要遵守

- 所有公共API必须有类型注解（GDScript 4.x静态类型）
- 性能关键代码标记为 `# PERF-CRITICAL`，便于后续迁移
- GDExtension代码放在 `src/native/` 目录，独立管理

## Related

- [ADR-002: 题库数据存储格式](ADR-002-question-bank-storage-format.md)
- [ADR-004: 代码编辑器选择](ADR-004-code-editor-choice.md)