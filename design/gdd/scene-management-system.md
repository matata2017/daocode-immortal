# 场景管理系统 (Scene Management System)

> **Status**: Designed
> **Author**: User + Claude Code
> **Last Updated**: 2026-03-30
> **Implements Pillar**: 沉浸修仙、性能

## Overview

**场景管理系统**负责游戏中所有场景的加载、卸载、切换和过渡动画，是 Godot 场景架构的核心。

系统管理 5 个主要场景：主菜单、修炼场景、BOSS 面试场景、境界突破场景、心魔场景。每个场景可携带参数（如门派 ID、BOSS ID）进行切换。支持过渡动画（淡入淡出、云雾特效）和加载进度显示。

**为什么需要这个系统**：场景管理是游戏的"空间骨架"。没有它，场景切换会混乱，过渡没有仪式感，破坏"沉浸修仙"体验。统一的场景管理也方便添加加载动画、场景预加载等优化。

## Player Fantasy

**每次场景切换都像是一次"传送"，流畅且有仪式感。**

场景过渡不是生硬的黑屏切换，而是配合修仙主题的云雾特效、淡入淡出。玩家感受到"传送洞府"、"进入面试"的仪式感。

### 玩家体验场景

**场景 1：进入修炼场景**
玩家在主菜单点击"开始修炼"，画面淡出，显示"传送中..."加载提示，然后淡入显示修炼场景（洞府背景）。

**场景 2：挑战 BOSS**
玩家点击"挑战大厂长老"，画面以云雾特效过渡，显示"传送至面试场地..."，然后显示 BOSS 面试场景。

**场景 3：返回主菜单**
玩家完成修炼，点击"返回"，场景淡出，回到主菜单。修仙氛围贯穿始终。

### 支撑的游戏支柱

| 支柱 | 如何体现 |
|------|----------|
| **沉浸修仙** | 场景过渡配合修仙主题特效 |
| **碎片友好** | 场景切换快速，无长时间加载 |

## Detailed Design

### Core Rules

#### 场景定义
```gdscript
# scene_manager.gd
extends Node

enum SceneId {
    MAIN_MENU,       # 主菜单
    CULTIVATION,     # 修炼场景
    BOSS_INTERVIEW,  # BOSS 面试
    REALM_BREAKTHROUGH, # 境界突破
    DEMON_REALM,     # 心魔场景
}

var _scenes: Dictionary = {
    SceneId.MAIN_MENU: "res://scenes/MainMenu.tscn",
    SceneId.CULTIVATION: "res://scenes/CultivationScene.tscn",
    SceneId.BOSS_INTERVIEW: "res://scenes/BossInterviewScene.tscn",
    SceneId.REALM_BREAKTHROUGH: "res://scenes/RealmBreakthroughScene.tscn",
    SceneId.DEMON_REALM: "res://scenes/DemonRealmScene.tscn",
}

var _current_scene: Node = null
var _current_scene_id: SceneId = -1
```

#### 场景切换接口
```gdscript
func change_scene(scene_id: SceneId, params: Dictionary = {}, transition: String = "fade") -> void:
    # 切换场景
    # params: 场景参数（如 {faction_id: "JAVA", boss_id: "TECH_GIANT"}）
    # transition: 过渡类型 ("fade", "cloud", "instant")
```

### States and Transitions

```
┌─────────────────┐
│  当前场景运行    │
└────────┬────────┘
         │ change_scene()
         ↓
┌─────────────────┐
│  过渡动画开始    │  淡出/云雾
└────────┬────────┘
         │ 动画完成
         ↓
┌─────────────────┐
│  卸载当前场景    │
└────────┬────────┘
         │ 卸载完成
         ↓
┌─────────────────┐
│  加载新场景      │  可显示加载进度
└────────┬────────┘
         │ 加载完成
         ↓
┌─────────────────┐
│  初始化场景参数  │  传入 params
└────────┬────────┘
         │ 初始化完成
         ↓
┌─────────────────┐
│  过渡动画结束    │  淡入
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│  新场景运行      │
└─────────────────┘
```

### 场景参数传递

| 目标场景 | 参数 | 说明 |
|----------|------|------|
| CULTIVATION | `{faction_id}` | 显示对应门派的修炼场景 |
| BOSS_INTERVIEW | `{boss_id, difficulty}` | 显示对应 BOSS 和难度 |
| REALM_BREAKTHROUGH | `{realm_id}` | 显示对应境界的突破试炼 |
| DEMON_REALM | `{question_ids}` | 显示要复习的错题 |

### 过渡动画类型

| 类型 | 效果 | 适用场景 |
|------|------|----------|
| `fade` | 黑屏淡入淡出 | 通用 |
| `cloud` | 云雾遮罩后切换 | 修炼→BOSS、突破场景 |
| `instant` | 无动画立即切换 | 调试用 |

### Interactions with Other Systems

| 系统 | 数据流向 | 接口 |
|------|----------|------|
| **主菜单系统** | 场景→菜单 | `change_scene(CULTIVATION, params)` |
| **修炼场景系统** | 场景→修炼 | `change_scene(MAIN_MENU)` |
| **对话UI系统** | 场景→BOSS面试 | `change_scene(BOSS_INTERVIEW, {boss_id})` |
| **境界突破系统** | 场景→突破 | `change_scene(REALM_BREAKTHROUGH, {realm_id})` |
| **心魔复习系统** | 场景→心魔 | `change_scene(DEMON_REALM, {question_ids})` |

## Formulas

### 场景切换时间预算
```
total_transition_time =
    fade_out_duration (0.3s) +
    scene_unload_time (0.1s) +
    scene_load_time (0.5s) +
    fade_in_duration (0.3s)

# 目标: < 1.5s
# 云雾过渡: +0.3s = < 1.8s
```

### 场景内存估算
```
scene_memory = base_memory + assets_memory

# 示例估算:
# CULTIVATION: 50MB (背景 + 角色 + 音效)
# BOSS_INTERVIEW: 30MB (BOSS 立绘 + 背景)
# MAIN_MENU: 20MB (UI + 背景)
```

## Edge Cases

| 边缘情况 | 处理方式 | 影响范围 |
|----------|----------|----------|
| **场景加载失败** | 显示错误提示，返回主菜单 | 场景切换 |
| **场景参数缺失** | 使用默认值，记录警告日志 | 场景初始化 |
| **重复切换场景** | 忽略后续请求，等待当前切换完成 | 场景切换 |
| **切换过程中断** | 确保资源正确释放，防止内存泄漏 | 资源管理 |
| **场景不存在** | 记录错误，返回主菜单 | 场景切换 |
| **内存不足** | 强制 GC 后重试，失败则提示重启 | 性能 |

## Dependencies

### 上游依赖（无）
场景管理系统是核心层，**无上游依赖**。

### 下游依赖（被依赖）

| 系统 | 依赖类型 | 接口契约 |
|------|----------|----------|
| **主菜单系统** | 硬依赖 | `change_scene(scene_id, params)` |
| **修炼场景系统** | 硬依赖 | `change_scene(MAIN_MENU)` |
| **对话UI系统** | 硬依赖 | `change_scene(BOSS_INTERVIEW, params)` |
| **境界突破系统** | 硬依赖 | `change_scene(REALM_BREAKTHROUGH, params)` |
| **心魔复习系统** | 硬依赖 | `change_scene(DEMON_REALM, params)` |

## Tuning Knobs

| Knob | 类型 | 默认值 | 范围 | 影响范围 |
|------|------|--------|------|----------|
| `fade_duration_seconds` | float | 0.3 | 0.1-1.0 | 淡入淡出时长 |
| `cloud_duration_seconds` | float | 0.5 | 0.3-1.5 | 云雾过渡时长 |
| `show_loading_screen` | bool | true | - | 是否显示加载界面 |
| `preload_adjacent_scenes` | bool | false | - | 是否预加载相邻场景 |
| `cache_scene_count` | int | 2 | 1-5 | 缓存场景数量 |

### 调参指南
- **过渡时长**：若觉得切换太慢，可降低 `fade_duration_seconds`
- **预加载**：若需优化加载时间，可启用 `preload_adjacent_scenes`
- **缓存数量**：若内存紧张，可降低 `cache_scene_count`

## Acceptance Criteria

### 功能验收

| # | 验收条件 | 优先级 | 测试方法 |
|---|----------|--------|----------|
| AC-01 | 可切换到任意场景 | P0 | 单元测试 |
| AC-02 | 场景参数正确传递 | P0 | 单元测试 |
| AC-03 | 过渡动画正常播放 | P1 | 手动测试 |
| AC-04 | 场景切换过程中无法重复切换 | P1 | 单元测试 |
| AC-05 | 场景加载失败时返回主菜单 | P1 | 单元测试 |
| AC-06 | 场景资源正确释放 | P1 | 性能测试 |
| AC-07 | 返回按钮正确返回上一场景 | P2 | 手动测试 |

### 性能验收

| # | 验收条件 | 目标值 |
|---|----------|--------|
| AC-08 | 场景切换总时间 | < 1.5s |
| AC-09 | 场景内存无泄漏 | 内存稳定 |

## Open Questions

| # | 问题 | 状态 | 决策/负责人 | 目标日期 |
|---|------|------|-------------|----------|
| OQ-01 | 是否需要场景返回栈（支持多层返回）？ | 待讨论 | 游戏设计师 | Alpha 前 |
| OQ-02 | 是否支持场景间共享数据？ | 待确认 | 技术设计师 | 开发前 |
| OQ-03 | 云雾过渡特效具体实现？ | 待设计 | 美术团队 | Alpha 前 |
| OQ-04 | 是否需要加载进度条？ | 待讨论 | UX 设计师 | Alpha 前 |
| OQ-05 | 移动端场景切换优化策略？ | 待确认 | 技术团队 | Beta 前 |

---

## 附录：场景文件结构

```
res://scenes/
├── MainMenu.tscn
├── CultivationScene.tscn
├── BossInterviewScene.tscn
├── RealmBreakthroughScene.tscn
├── DemonRealmScene.tscn
└── transitions/
    ├── FadeTransition.tscn
    └── CloudTransition.tscn
```

## 附录：场景切换流程代码示例

```gdscript
# scene_manager.gd
extends Node

signal scene_changed(scene_id: SceneId)

func change_scene(scene_id: SceneId, params: Dictionary = {}, transition: String = "fade") -> void:
    if _is_transitioning:
        push_warning("Scene transition already in progress")
        return

    _is_transitioning = true
    _transition_type = transition
    _next_scene_id = scene_id
    _next_scene_params = params

    # 开始过渡动画
    await _play_transition_out()

    # 卸载当前场景
    if _current_scene:
        _current_scene.queue_free()

    # 加载新场景
    var scene_path = _scenes[scene_id]
    var scene_resource = load(scene_path)
    _current_scene = scene_resource.instantiate()
    add_child(_current_scene)

    # 初始化场景参数
    if _current_scene.has_method("init_with_params"):
        _current_scene.init_with_params(params)

    # 结束过渡动画
    await _play_transition_in()

    _is_transitioning = false
    scene_changed.emit(scene_id)
```