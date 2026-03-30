<p align="center">
  <h1 align="center">道码修仙 DaoCode Immortal</h1>
  <p align="center">
    以修炼为主题的编程面试学习游戏
    <br />
    答题 → 修为 → 境界 → BOSS面试
  </p>
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License"></a>
  <a href="design/gdd"><img src="https://img.shields.io/badge/系统设计-26个GDD-blueviolet" alt="26 GDDs"></a>
  <a href="src"><img src="https://img.shields.io/badge/引擎-Godot%204.6.1-478cbf" alt="Godot 4.6.1"></a>
  <a href="design/narrative"><img src="https://img.shields.io/badge/叙事-修炼隐喻-green" alt="Cultivation Metaphor"></a>
</p>

---

## 游戏简介

**道码修仙**是一款将编程面试学习融入修仙世界观的游戏。在这里：

- **门派** = 编程语言（Java派、Go派）
- **境界** = 技能等级（凡人→炼气期→筑基期→金丹期→元婴期→化神期→飞升）
- **修炼** = 刷题学习
- **心魔** = 曾经答错的题目
- **BOSS** = 面试官
- **飞升** = 获得 Offer

### 核心循环

```
答题修炼 → 积累修为 → 境界突破 → BOSS面试 → 获得Offer（飞升）
    ↑                                    ↓
    ←←←←←← 心魔复习（错题回顾） ←←←←←←←←←
```

---

## 项目状态

🚧 **预制作阶段** - 26个MVP系统GDD设计完成，原型验证通过

| 模块 | 状态 | 说明 |
|------|------|------|
| 系统设计 | ✅ 完成 | 26个GDD文档 |
| 叙事设计 | ✅ 完成 | 世界规则、门派背景、对话库 |
| UX设计 | ✅ 完成 | 完整UX规格文档 |
| 核心原型 | ✅ 验证 | Godot核心循环可运行 |
| 视觉设计 | 🚧 进行中 | UI视觉规范 |
| 功能实现 | 📅 计划中 | Sprint 1-3 已规划 |

---

## 技术栈

| 类别 | 选择 |
|------|------|
| **游戏引擎** | Godot 4.6.1 |
| **主要语言** | GDScript |
| **物理引擎** | Jolt Physics (Godot 4.6 默认) |
| **测试框架** | GUT (Godot Unit Testing) |
| **AI服务** | MiniMax API (通过后端代理) |
| **数据存储** | JSON |

---

## 项目结构

```
design/
├── gdd/                    # 26个系统设计文档
│   ├── game-concept.md     # 游戏概念
│   ├── systems-index.md    # 系统索引
│   └── *.md                # 各系统GDD
├── narrative/              # 叙事内容
│   ├── world-rules.md      # 世界规则
│   ├── sect-lore.md        # 门派背景
│   └── dialogue/           # 对话库
│       ├── boss-dialogue.md
│       ├── realm-text.md
│       └── heart-demon-text.md
└── ui/                     # UI设计
    └── UX-SPEC.md          # UX规格文档

src/
├── data/                   # 数据结构
│   ├── question_data.gd
│   ├── realm_data.gd
│   └── faction_data.gd
└── systems/                # 游戏系统
    ├── save_system.gd
    ├── scene_manager.gd
    └── audio_manager.gd

assets/
└── data/                   # JSON数据
    ├── questions.json
    ├── realms.json
    └── factions.json

prototypes/
└── core-loop/              # 核心循环原型
```

---

## 快速开始

### 运行原型

```bash
# 在 Godot 编辑器中打开
godot4 prototypes/core-loop/project.godot

# 或直接运行
godot4 --path prototypes/core-loop
```

### 运行测试

```bash
godot4 --headless --path . -s addons/gut/gut_cmdln.gd
```

---

## 设计文档

### 核心系统

| 层级 | 系统 | 说明 |
|------|------|------|
| **基础层** | 题库、境界、门派、BOSS数据 | 数据结构与管理 |
| **核心层** | 修为计算、错题记录、回答分析 | 核心逻辑 |
| **表现层** | 答题反馈、对话UI、心魔UI、代码编辑器 | 玩家界面 |
| **功能层** | 答题修炼、境界突破、心魔复习、BOSS面试 | 完整功能 |

### 设计原则

- **隐喻优先**：修炼世界是叙事视角，不是真正的奇幻世界
- **成长导向**：失败是"尚未准备好"，永远鼓励再试
- **无时间压力**：唯一的威胁是准备不足
- **门派无冲突**：门派是专精选择，不是竞争关系

---

## 开发计划

### Sprint 1: 基础层 ✅
- 数据结构实现
- 存档系统
- 场景管理
- 音频框架

### Sprint 2: 核心循环 🚧
- 答题系统
- 修为计算
- 境界突破

### Sprint 3: 功能层 📅
- 心魔复习
- BOSS面试
- 学习分析

---

## 贡献指南

本项目目前处于早期开发阶段。欢迎：
- 提交 Issue 报告问题或建议
- 提交 PR 改进代码或文档
- 在 Discussions 中讨论设计想法

---

## 许可证

MIT License - 详见 [LICENSE](LICENSE)

---

*"修炼之路，从一行代码开始。"*
