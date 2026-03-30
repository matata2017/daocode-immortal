# ADR-004: 代码编辑器选择

> **Status**: Accepted
> **Date**: 2026-03-30
> **Decision Makers**: User + Claude Code

## Context

道码修仙的代码题需要代码编辑功能，包括语法高亮、代码输入、基本编辑体验。

### 问题

- 题型：代码题（编写代码片段）
- 目标语言：主要是Java面试题
- 功能需求：语法高亮、代码输入、行号显示
- 性能需求：流畅编辑体验
- 平台：PC和移动端

### 考虑方案

| 方案 | 优点 | 缺点 |
|------|------|------|
| **Godot CodeEdit** | 内置组件、轻量、跨平台 | 功能基础、Java语法高亮需自定义 |
| **嵌入WebView + Monaco** | 功能强大、VSCode体验 | 重量大、移动端复杂、通信开销 |
| **嵌入WebView + Ace** | 轻量、语法支持好 | 仍是WebView、通信开销 |
| **自定义TextEdit** | 完全控制 | 开发量大、难以达到专业体验 |

## Decision

采用 **Godot CodeEdit** 方案：
- 使用Godot内置的CodeEdit节点
- 自定义Java语法高亮规则

### 理由

1. **轻量优先**：游戏主要场景是答题，不需要完整IDE体验
2. **跨平台一致**：CodeEdit在PC和移动端行为一致
3. **集成简单**：无需WebView通信，直接GDScript控制
4. **性能可控**：原生组件，无额外开销
5. **功能足够**：语法高亮+行号+基本编辑已满足需求

## Consequences

### 正面

- 游戏体积小（无WebView依赖）
- PC和移动端体验一致
- 与游戏UI系统无缝集成
- 性能稳定可控

### 负面

- Java语法高亮需要自定义实现
- 无代码补全（可通过TextEdit的completion实现基础补全）
- 编辑体验不如专业IDE

### 需要遵守

- 代码编辑器代码放在 `src/ui/code_editor.gd`
- 语法高亮规则放在 `assets/data/syntax/java_syntax.json`
- 如需增强功能，优先考虑Godot原生扩展而非WebView
- 性能预算：编辑器响应延迟 < 50ms

## Related

- [ADR-001: 主要开发语言](ADR-001-primary-language-choice.md)
- [代码编辑器系统 GDD](../design/gdd/code-editor-system.md)