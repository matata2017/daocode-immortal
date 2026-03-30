# 音频系统 (Audio System)

> **Status**: Designed
> **Author**: User + Claude Code
> **Last Updated**: 2026-03-30
> **Implements Pillar**: 沉浸修仙

## Overview

**音频系统**负责播放游戏中的背景音乐、环境音效、UI音效，以及音量设置。是营造游戏氛围的基础设施层。

系统提供BGM播放、SFX播放、音量控制、场景音频切换等功能。所有系统通过统一接口调用音频功能，确保音频体验一致性。

**为什么需要这个系统**: 没有音频系统，游戏缺乏听觉反馈，沉浸感大幅降低。系统化的音频管理让BGM切换平滑、音效响应及时、音量设置持久化。

## Player Fantasy

玩家期望体验：

**1. 沉浸感氛围**
- 进入不同场景自动切换BGM，氛围随场景变化
- 修炼场景平静舒缓，BOSS面试紧张压迫
- 音效反馈及时，操作有"手感"

**2. 个性化控制**
- 随时调整主音量、音乐音量、音效音量
- 设置持久保存，下次启动保持
- 静音选项，适合公共场所游玩

**3. 无干扰体验**
- BGM循环平滑，无明显断点
- 音效不重叠刺耳
- 场景切换时音乐淡入淡出，不突兀

## Detailed Design

### Core Rules

#### 音频分类

| 分类 | 说明 | 播放方式 | 音量控制 |
|------|------|----------|----------|
| **BGM（背景音乐）** | 场景背景音乐，循环播放 | `play_bgm()` | `volume_music` |
| **SFX（音效）** | UI点击、答题反馈、斩除音效 | `play_sfx()` | `volume_sfx` |
| **环境音** | 场景环境音效（风声、水声等） | `play_ambient()` | `volume_sfx` |

#### 场景BGM配置

| 场景 | BGM文件 | 氛围描述 |
|------|---------|----------|
| **主菜单** | `main_menu.mp3` | 中速、平和、欢迎感 |
| **修炼场景** | `practice.mp3` | 缓慢、宁静、修仙氛围 |
| **心魔场景** | `demon_cave.mp3` | 压抑、暗沉、紧张感 |
| **BOSS面试** | `boss_interview.mp3` | 紧张、压迫、严肃感 |
| **突破场景** | `breakthrough.mp3` | 激昂、振奋、成就感 |

#### 音效事件定义

| 事件名 | 触发场景 | 音效文件 |
|--------|----------|----------|
| `button_click` | UI按钮点击 | `sfx_click.ogg` |
| `answer_correct` | 答题正确 | `sfx_correct.ogg` |
| `answer_wrong` | 答题错误 | `sfx_wrong.ogg` |
| `demon_exorcise` | 心魔斩除 | `sfx_exorcise.ogg` |
| `realm_breakthrough` | 境界突破 | `sfx_breakthrough.ogg` |
| `notification` | 通知提示 | `sfx_notify.ogg` |

#### 音量设置数据结构

```gdscript
# 存储在存档系统的 settings 中
var audio_settings: Dictionary = {
    "volume_master": 1.0,      # 主音量 (0.0-1.0)
    "volume_music": 0.8,       # 音乐音量 (0.0-1.0)
    "volume_sfx": 0.8,         # 音效音量 (0.0-1.0)
    "mute_all": false          # 全局静音
}
```

#### 音频文件位置

```
res://assets/audio/
├── bgm/
│   ├── main_menu.mp3
│   ├── practice.mp3
│   ├── demon_cave.mp3
│   ├── boss_interview.mp3
│   └── breakthrough.mp3
└── sfx/
    ├── sfx_click.ogg
    ├── sfx_correct.ogg
    ├── sfx_wrong.ogg
    ├── sfx_exorcise.ogg
    ├── sfx_breakthrough.ogg
    └── sfx_notify.ogg
```

### States and Transitions

```
┌─────────────────┐
│   音频系统初始化  │  游戏启动
└────────┬────────┘
         │ 加载音量设置
         ↓
┌─────────────────┐
│   空闲状态        │  无BGM播放
└────────┬────────┘
         │ play_bgm()
         ↓
┌─────────────────┐
│   BGM播放中      │  循环播放当前BGM
└────────┬────────┘
         │ play_bgm(new) / stop_bgm()
         ↓
┌─────────────────┐
│   BGM切换中      │  淡出旧BGM，淡入新BGM
└────────┬────────┘
         │ 切换完成
         ↓
┌─────────────────┐
│   新BGM播放中    │
└─────────────────┘
```

### Interactions with Other Systems

| 系统 | 数据流向 | 接口 |
|------|----------|------|
| **存档系统** | 双向 | `get/set_audio_settings()` |
| **设置系统** | 写入 | `on_volume_changed()` |
| **场景管理系统** | 写入 | `on_scene_changed()` 触发BGM切换 |
| **答题反馈系统** | 写入 | `play_sfx("answer_correct/wrong")` |
| **心魔UI系统** | 写入 | `play_sfx("demon_exorcise")` |
| **境界突破系统** | 写入 | `play_sfx("realm_breakthrough")` |
| **主菜单系统** | 写入 | `play_bgm("main_menu")` |

## Formulas

### 实际播放音量计算
```
actual_volume = volume_master × volume_category × (1 if not mute_all else 0)

where:
  volume_master = 主音量 (0.0-1.0)
  volume_category = 分类音量（music或sfx）(0.0-1.0)
  mute_all = 全局静音开关
```

**示例**:
- 主音量80%，音乐音量60%，未静音 → `0.8 × 0.6 × 1 = 0.48` (48%)
- 主音量100%，音效音量80%，静音 → `1.0 × 0.8 × 0 = 0` (静音)

### BGM淡入淡出时长
```
fade_duration = crossfade_time  # 默认1.0秒

where:
  crossfade_time = 场景切换时BGM过渡时长
```

**设计意图**: 1秒淡入淡出让BGM切换平滑，不突兀。

### 音效并发限制
```
max_concurrent_sfx = 8  # 同时播放的最大音效数

IF current_sfx_count >= max_concurrent_sfx:
  ignore_new_sfx()  # 忽略新的音效请求
```

**设计意图**: 防止音效叠加过多导致噪音。

### 音量滑块映射（UI显示）
```
display_volume_percent = volume × 100  # 转换为百分比显示

where:
  volume = 0.0-1.0 范围的音量值
```

**示例**: volume = 0.8 → UI显示 "80%"

## Edge Cases

| 边缘情况 | 处理方式 | 影响范围 |
|----------|----------|----------|
| **音频文件缺失** | 静默处理，不播放，记录警告日志 | 音频播放 |
| **BGM切换时快速切换场景** | 取消前一个淡入，直接淡入最新BGM | 场景切换 |
| **音效请求超过并发上限** | 忽略新请求，保留当前播放的音效 | 音效播放 |
| **音量设置为0** | 实际音量=0，但仍占用音频通道 | 音量控制 |
| **全局静音后调节音量** | 仍静音，音量设置保存但不生效 | 音量控制 |
| **音频系统初始化失败** | 游戏继续运行，无音频，显示警告 | 游戏启动 |
| **同时播放多个相同音效** | 正常播放，可能叠加（如快速点击） | 音效播放 |
| **BGM淡入淡出被中断** | 立即停止淡入淡出，切换到目标状态 | BGM播放 |
| **存档中无音量设置** | 使用默认值（master=1.0, music=0.8, sfx=0.8） | 存档加载 |
| **音频格式不支持** | 跳过该文件，记录错误日志 | 音频加载 |

## Dependencies

### 上游依赖（此系统依赖的系统）
**无** — 音频系统是Foundation层基础设施，无上游依赖。

### 下游依赖（依赖此系统的系统）
| 系统 | 依赖类型 | 依赖内容 | 接口契约 |
|------|----------|----------|----------|
| **场景管理系统** | 软依赖 | 场景切换时触发BGM切换 | `on_scene_changed(scene_type)` |
| **答题反馈系统** | 硬依赖 | 播放答题正确/错误音效 | `play_sfx("answer_correct/wrong")` |
| **心魔UI系统** | 硬依赖 | 播放心魔斩除音效 | `play_sfx("demon_exorcise")` |
| **境界突破系统** | 硬依赖 | 播放突破音效 | `play_sfx("realm_breakthrough")` |
| **主菜单系统** | 硬依赖 | 播放主菜单BGM | `play_bgm("main_menu")` |
| **设置系统** | 双向 | 音量设置UI和持久化 | `get/set_audio_settings()` |
| **BOSS面试系统** | 硬依赖 | 播放BOSS面试BGM | `play_bgm("boss_interview")` |
| **修炼场景系统** | 硬依赖 | 播放修炼场景BGM | `play_bgm("practice")` |

### 依赖关系图
```
音频系统（Foundation Layer，无上游依赖）
    │
    ├──→ 场景管理系统（BGM切换）
    │
    ├──→ 答题反馈系统（答题音效）
    │
    ├──→ 心魔UI系统（斩除音效）
    │
    ├──→ 境界突破系统（突破音效）
    │
    ├──→ 主菜单系统（主菜单BGM）
    │
    ├──→ 设置系统（音量设置）
    │
    ├──→ BOSS面试系统（BOSS BGM）
    │
    └──→ 修炼场景系统（修炼BGM）
```

## Tuning Knobs

| Knob | 类型 | 默认值 | 范围 | 影响范围 |
|------|------|--------|------|----------|
| `default_volume_master` | float | 1.0 | 0.0-1.0 | 新玩家默认主音量 |
| `default_volume_music` | float | 0.8 | 0.0-1.0 | 新玩家默认音乐音量 |
| `default_volume_sfx` | float | 0.8 | 0.0-1.0 | 新玩家默认音效音量 |
| `crossfade_duration` | float | 1.0 | 0.0-3.0 | BGM切换淡入淡出时长（秒） |
| `max_concurrent_sfx` | int | 8 | 4-16 | 同时播放的最大音效数量 |
| `bgm_volume_boost` | float | 0.0 | -0.2-0.2 | BGM整体音量微调（补偿） |
| `sfx_volume_boost` | float | 0.0 | -0.2-0.2 | SFX整体音量微调（补偿） |

### 调参指南

**`crossfade_duration`（BGM切换时长）**
- **调低**: 切换更快，可能突兀
- **调高**: 切换更平滑，但可能拖沓
- **观察指标**: 玩家对场景切换音频的感知（是否注意到BGM变化）

**`max_concurrent_sfx`（音效并发上限）**
- **调低**: 减少音频混杂，但可能丢失重要音效
- **调高**: 更多音效同时播放，但可能导致噪音
- **观察指标**: 快速操作时的音效播放质量（如快速点击按钮）

**`bgm_volume_boost` / `sfx_volume_boost`（音量微调）**
- **用途**: 后期混音调整，平衡不同音频素材的音量差异
- **调低**: 该类别音量降低
- **调高**: 该类别音量提升
- **观察指标**: 音频素材之间的音量平衡（BGM是否盖过SFX）

## Acceptance Criteria

### 功能验收
| # | 验收条件 | 优先级 | 测试方法 |
|---|----------|--------|----------|
| AC-01 | BGM播放正常（循环播放） | P0 | 单元测试 |
| AC-02 | 音效播放正常（一次性播放） | P0 | 单元测试 |
| AC-03 | 音量设置正确保存和加载 | P0 | 单元测试 |
| AC-04 | 主音量控制所有音频 | P0 | 单元测试 |
| AC-05 | 分类音量独立控制 | P0 | 单元测试 |
| AC-06 | 全局静音生效 | P0 | 单元测试 |
| AC-07 | 场景切换时BGM正确切换 | P0 | 集成测试 |
| AC-08 | BGM淡入淡出正常工作 | P1 | 手动测试 |
| AC-09 | 音效并发限制生效 | P1 | 单元测试 |
| AC-10 | 音频文件缺失时静默处理 | P1 | 手动测试 |
| AC-11 | 设置持久化到存档系统 | P0 | 集成测试 |
| AC-12 | 音量变化立即生效 | P0 | 手动测试 |

### 性能验收
| # | 验收条件 | 目标值 |
|---|----------|--------|
| AC-13 | BGM加载时间 | < 500ms |
| AC-14 | 音效加载时间 | < 100ms |
| AC-15 | 音效播放延迟 | < 50ms |
| AC-16 | 音频系统内存占用 | < 50MB |
| AC-17 | 音频系统初始化时间 | < 200ms |

### 集成验收
| # | 验收条件 | 优先级 | 测试方法 |
|---|----------|--------|----------|
| AC-18 | 存档系统正确保存音量设置 | P0 | 集成测试 |
| AC-19 | 设置系统UI正确显示音量滑块 | P1 | 手动测试 |
| AC-20 | 场景管理系统触发BGM切换 | P0 | 集成测试 |
| AC-21 | 各系统正确调用音效接口 | P0 | 集成测试 |

### 用户体验验收
| # | 验收条件 | 优先级 | 测试方法 |
|---|----------|--------|----------|
| AC-22 | BGM切换平滑无突兀感 | P2 | Playtest |
| AC-23 | 音效不重叠刺耳 | P2 | Playtest |
| AC-24 | 音量滑块响应灵敏 | P2 | Playtest |
| AC-25 | 静音后无任何音频 | P1 | 手动测试 |

## Open Questions

| # | 问题 | 状态 | 决策/负责人 | 目标日期 |
|---|------|------|-------------|----------|
| OQ-01 | 是否支持用户自定义BGM（导入音乐）？ | 待讨论 | 产品团队 | 发布后 |
| OQ-02 | 是否支持音效预加载（提升响应速度）？ | 待讨论 | 技术团队 | Alpha前 |
| OQ-03 | 是否需要音频可视化（波形、频谱）？ | 待讨论 | UI设计师 | Beta前 |
| OQ-04 | 是否支持3D空间音效（如BOSS战斗）？ | 待讨论 | 技术团队 | 发布后 |
| OQ-05 | 音频文件是否需要加密保护？ | 待讨论 | 法务团队 | 发布前 |

---

## 附录：音频文件清单

### BGM文件

| 文件名 | 场景 | 时长 | 格式 | 大小预估 |
|--------|------|------|------|----------|
| `main_menu.mp3` | 主菜单 | 2-3分钟 | MP3 | ~3MB |
| `practice.mp3` | 修炼场景 | 3-5分钟 | MP3 | ~4MB |
| `demon_cave.mp3` | 心魔场景 | 2-3分钟 | MP3 | ~3MB |
| `boss_interview.mp3` | BOSS面试 | 3-4分钟 | MP3 | ~4MB |
| `breakthrough.mp3` | 境界突破 | 1-2分钟 | MP3 | ~2MB |

### SFX文件

| 文件名 | 事件 | 时长 | 格式 | 大小预估 |
|--------|------|------|------|----------|
| `sfx_click.ogg` | UI点击 | <0.5秒 | OGG | ~50KB |
| `sfx_correct.ogg` | 答题正确 | <1秒 | OGG | ~100KB |
| `sfx_wrong.ogg` | 答题错误 | <1秒 | OGG | ~100KB |
| `sfx_exorcise.ogg` | 心魔斩除 | 1-2秒 | OGG | ~200KB |
| `sfx_breakthrough.ogg` | 境界突破 | 2-3秒 | OGG | ~300KB |
| `sfx_notify.ogg` | 通知提示 | <0.5秒 | OGG | ~50KB |

**总音频资源预估**: ~20MB