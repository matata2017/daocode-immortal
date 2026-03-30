# Architecture Decision Records

This directory contains Architecture Decision Records (ADRs) for 道码修仙 (DaoCode Immortal).

## What is an ADR?

An ADR is a document that captures an important architectural decision along with its context and consequences.

## Index

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| [ADR-001](ADR-001-primary-language-choice.md) | GDScript 作为主要开发语言 | Accepted | 2026-03-30 |
| [ADR-002](ADR-002-question-bank-storage-format.md) | 题库数据存储格式 | Accepted | 2026-03-30 |
| [ADR-003](ADR-003-minimax-api-proxy.md) | MiniMax API 后端代理 | Accepted | 2026-03-30 |
| [ADR-004](ADR-004-code-editor-choice.md) | 代码编辑器选择 | Accepted | 2026-03-30 |

## Creating New ADRs

1. Copy the template from `ADR-template.md`
2. Name the file `ADR-NNN-brief-title.md`
3. Fill in Context, Decision, and Consequences
4. Add to this index

## Template

```markdown
# ADR-NNN: [Title]

> **Status**: [Proposed | Accepted | Deprecated | Superseded]
> **Date**: YYYY-MM-DD
> **Decision Makers**: [Who made this decision]

## Context

[What is the issue that we're seeing that is motivating this decision?]

## Decision

[What is the change that we're proposing and/or doing?]

## Consequences

[What becomes easier or more difficult because of this change?]

## Related

- [Links to related ADRs or design documents]
```