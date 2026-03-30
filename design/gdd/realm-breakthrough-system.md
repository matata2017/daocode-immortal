# 境界突破系统 (Realm Breakthrough System)

> **Status**: Designed
> **Author**: User + Claude Code
> **Last Updated**: 2026-03-30
> **Implements Pillar**: 成长可见, 沉浸修仙

## Overview

**境界突破系统**负责管理玩家境界提升的完整流程，包括突破条件检查、突破考试触发、成功/失败处理、境界更新。

境界系统是游戏的核心成长线练，境界提升需要通过突破考试验证，确保玩家真正掌握知识点。

**为什么需要这个系统**: 没有境界突破系统，修为只是一个数值，没有"晋升"的仪式感。系统化的突破流程让每次境界提升都有里程碑意义，增强成就感和持续游玩动力。

## Player Fantasy

玩家期望体验：

**1. 晋升的期待感**
- "我终于要突破了！"的兴奋时刻
- 查看修为进度条，知道距离下一境界还有多远
- 境界图标/名称变化带来成就感

**2. 挑战的紧张感**
- 突破考试有通过门槛，不是"躺赢"
- 考试失败有代价，需要重新准备
- 每次突破都是努力的成果

**3. 成长的可见性**
- 境界列表清晰展示所有境界和当前进度
- 已解锁/未解锁状态一目了然
- 境界特权（新题目/新场景）解锁有期待

## Detailed Design

### Core Rules

#### 境界列表

| 境界 | 修为阈值 | 突破考试 | 解锁内容 |
|------|----------|----------|----------|
| 练气期 | 0 | 无 | 基础题目 |
| 筑基期 | 100 | 5题60% | 进阶题目 |
| 金丹期 | 500 | 8题65% | 挑战题目 + BOSS面试 |
| 元婴期 | 1500 | 10题70% | 高级BOSS |
| 化神期 | 4000 | 12题75% | 传说BOSS |
| 渡劫期 | 10000 | 15题80% | 全部内容 |

#### 突破流程

```
1. 检查突破条件
   IF cultivation >= threshold AND cooldown == 0:
     允许突破

2. 触发突破考试
   - 调用突破考试系统
   - 进入考试场景

3. 等待考试结果
   - 接收考试通过/失败

4. 处理结果
   IF success:
     - 更新境界
     - 播放成功动画
     - 解锁新内容
   ELSE:
     - 设置冷却时间
     - 扣除10%修为
     - 返回修炼
```

#### 境界特权

| 境界 | 解锁题目 | 解锁BOSS | 其他特权 |
|------|----------|----------|----------|
| 练气期 | 基础100题 | 无 | 无 |
| 筑基期 | +50题 | 外包厂HR | 心魔场景 |
| 金丹期 | +50题 | 大厂长老 | BOSS面试 |
| 元婴期 | +50题 | 技术专家 | 高级心魔 |
| 化神期 | +30题 | 架构师 | 传说心魔 |
| 渡劫期 | +20题 | 仙人 | 全部特权 |

### States and Transitions

```
┌─────────────────┐
│   练气期         │  初始境界
└────────┬────────┘
         │ 修为>=100
         ↓
┌─────────────────┐
│   可突破筑基    │  显示突破按钮
└────────┬────────┘
         │ 点击突破
         ↓
┌─────────────────┐
│   突破考试中     │  考试系统处理
└────────┬────────┘
         │ 考试结果
         ↓
    ┌────┴────┐
    ↓         ↓
┌────────┐  ┌────────┐
│ 突破成功│  │ 突破失败│
└────┬────┘  └────┬────┘
    │            │
    ↓            ↓
┌──────────────┐  ┌──────────────┐
│ 境界→筑基    │  │ 冷却+重试    │
│ 解锁新内容   │  │ 扣除修为     │
└──────────────┘  └──────────────┘
```

### Interactions with Other Systems

| 系统 | 数据流向 | 接口 |
|------|----------|------|
| **境界数据系统** | 读取 | `get_realm_data(realm_id)` |
| **修为计算系统** | 读取 | `get_cultivation()` |
| **突破考试系统** | 写入 | `start_breakthrough_exam()` |
| **存档系统** | 写入 | `update_realm()`, `save_breakthrough_record()` |
| **音频系统** | 写入 | `play_bgm("breakthrough")` |

## Formulas

### 突破条件检查
```
can_breakthrough = (
    current_cultivation >= threshold AND
    current_realm == expected_previous_realm AND
    cooldown_remaining <= 0
)
```

### 突破成功处理
```
on_breakthrough_success():
    save_data.realm_id = next_realm_id
    save_data.cultivation = current_cultivation  // 不扣除
    save_data.unlocked_content = get_unlocks_for_realm(next_realm_id)
    emit signal("realm_changed", next_realm_id)
```

### 突破失败处理
```
on_breakthrough_failed():
    save_data.cultivation = max(0, current_cultivation × 0.9)
    save_data.cooldown_end = current_time + cooldown_duration
    emit signal("breakthrough_failed", current_realm_id)
```

## Edge Cases

| 边缘情况 | 处理方式 |
|----------|----------|
| **已达最高境界** | 提示"已达到最高境界" |
| **突破考试系统不可用** | 显示错误，禁用突破 |
| **存档损坏** | 使用缓存数据，尝试恢复 |
| **同时满足多个境界条件** | 按顺序检查（一次只能突破一级） |
| **突破成功但存档失败** | 先更新境界，再保存 |

## Dependencies

### 上游依赖
| 系统 | 依赖类型 | 接口 |
|------|----------|------|
| **境界数据系统** | 硬依赖 | `get_realm_data()` |
| **修为计算系统** | 硬依赖 | `get_cultivation()` |
| **突破考试系统** | 硬依赖 | `start_breakthrough_exam()` |

### 下游依赖
| 系统 | 依赖类型 | 接口 |
|------|----------|------|
| **存档系统** | 硬依赖 | `update_realm()` |
| **音频系统** | 软依赖 | 播放突破BGM |

## Tuning Knobs

| Knob | 默认值 | 范围 |
|------|--------|------|
| `cultivation_loss_on_fail` | 0.1 | 0.0-0.2 |
| `cooldown_hours` | 见境界表 | 1-24小时 |

## Acceptance Criteria

| # | 验收条件 | 测试方法 |
|---|----------|----------|
| AC-01 | 突破条件检查正确 | 单元测试 |
| AC-02 | 突破成功正确更新境界 | 集成测试 |
| AC-03 | 突破失败正确设置冷却 | 集成测试 |
| AC-04 | 已达最高境界无法再突破 | 单元测试 |
| AC-05 | 境界特权正确解锁 | 集成测试 |

## Open Questions

| # | 问题 | 状态 |
|---|------|------|
| OQ-01 | 是否支持跳过突破考试？ | 待讨论 |
| OQ-02 | 是否支持境界降级？ | 待讨论 |