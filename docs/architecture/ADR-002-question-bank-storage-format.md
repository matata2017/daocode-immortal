# ADR-002: 题库数据存储格式

> **Status**: Accepted
> **Date**: 2026-03-30
> **Decision Makers**: User + Claude Code

## Context

道码修仙需要存储300+道编程面试题目，包括多种题型（选择题、代码题、开放问答题）。

### 问题

- 题目数量：300+道，持续扩展
- 题目类型：选择题、代码题、开放问答题
- 题目属性：门派分类、难度、知识点标签、正确答案、解析
- 使用场景：运行时加载、编辑时更新

### 考虑方案

| 方案 | 优点 | 缺点 |
|------|------|------|
| **JSON文件** | 人类可读、编辑方便、Godot原生支持 | 大文件解析慢、无类型约束 |
| **SQLite数据库** | 结构化、查询快、支持索引 | 需要额外模块、部署复杂 |
| **Godot Resource** | 类型安全、编辑器集成、加载快 | 需要自定义编辑器、导入流程复杂 |
| **混合方案** | JSON作为源文件，运行时转为Resource | 需要转换流程 |

## Decision

采用**混合方案**：
- **JSON** 作为源文件格式（设计时编辑）
- **自定义 Resource** 作为运行时格式（加载后缓存）

### 理由

1. **编辑友好**：JSON可直接编辑，方便导入外部题库
2. **类型安全**：自定义Resource提供类型约束，减少运行时错误
3. **加载效率**：Resource加载后缓存，避免重复解析JSON
4. **导入流程**：首次加载时JSON→Resource转换，后续直接使用缓存

## Consequences

### 正面

- 非程序员也能编辑题库（JSON格式清晰）
- 导入外部题库简单（PDF解析→JSON流程）
- 运行时性能好（Resource缓存）
- 类型系统保护（GDScript类型注解）

### 负面

- 需要编写JSON→Resource转换代码
- Resource类型定义需要维护
- 大题库首次加载可能有延迟（可后台加载）

### 需要遵守

- JSON文件放在 `assets/data/questions/` 目录
- Resource类型定义放在 `src/data/question_resource.gd`
- 题库加载使用异步方式，不阻塞主线程
- JSON schema文档放在 `docs/data-schema/question-schema.md`

## Related

- [ADR-001: 主要开发语言](ADR-001-primary-language-choice.md)
- [题库数据系统 GDD](../design/gdd/question-bank-data-system.md)