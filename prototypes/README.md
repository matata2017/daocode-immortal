# Prototypes Index

This directory contains throwaway prototypes for validating game concepts before full implementation.

## What is a Prototype?

A prototype is a **quick, disposable implementation** designed to test a specific hypothesis. It's not production code - it's meant to be discarded after validation.

## Prototypes

| Name | Purpose | Status | Location |
|------|---------|--------|----------|
| Core Loop | Validate "答题→修为→境界→BOSS面试" | Ready to test | [core-loop/](core-loop/) |

---

## Core Loop Prototype

**Hypothesis**: 答题获得修为、境界提升、挑战BOSS面试的循环能让玩家感到成长感、挑战感和学习价值。

**What it tests**:
- 答题流程（选择题）
- 修为计算和显示
- 境界突破触发
- BOSS面试对话（Mock）

**How to run**:
1. 在 Godot 4.6.1 中打开 `prototypes/core-loop/project.godot`
2. 按 F5 运行
3. 完成 5 道题目，体验修为增长和境界提升

**Success criteria**:
- 答题流程顺畅无卡顿
- 修为变化直观有激励感
- 境界提升有仪式感
- 有"再玩一次"的冲动

---

## Prototype Guidelines

1. **Fast**: 1-2 days to build
2. **Focused**: Test ONE hypothesis
3. **Disposable**: Delete after validation
4. **No polish**: Skip UI/UX polish
5. **Mock external deps**: No real API calls

---

## After Validation

- **PASS**: Proceed to Sprint 1 implementation
- **FAIL**: Iterate on GDD design, re-prototype
- **Partial**: Note improvements needed for Sprint planning