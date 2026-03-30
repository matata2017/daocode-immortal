# Game Concept: 道码修仙 (DaoCode Immortal)

*Created: 2026-03-30*
*Status: Draft*

---

## Elevator Pitch

> 一款修仙主题的编程面试学习游戏。玩家选择门派（Java/Go/C++等），通过日常刷题积累修为，以境界突破检验学习成果，最终通过模拟面试BOSS战获得"飞升"——拿到大厂Offer。
>
> "像LeetCode，但每道题都是修行，每次面试都是渡劫。"

---

## Core Identity

| Aspect | Detail |
| ---- | ---- |
| **Genre** | 教育游戏 / 修仙RPG / 卡牌答题 |
| **Platform** | 跨平台（移动端 + PC） |
| **Target Audience** | 准备技术面试的程序员（1-5年经验） |
| **Player Count** | 单人 |
| **Session Length** | 碎片5分钟 / 深度30分钟 |
| **Monetization** | 免费基础版 + 付费门派/题库DLC |
| **Estimated Scope** | MVP: 4-8周 / 完整版: 3-6个月 |
| **Comparable Titles** | 想不想修真、Anki、LeetCode、鬼谷八荒 |

---

## Core Fantasy

**你是修仙界的程序员求道者。**

在这个世界里，编程知识就是修为，算法能力是内功，语言特性是门派绝学。你从一个凡人程序员开始，通过不断刷题修炼，突破一个个境界（炼气→筑基→金丹→元婴...），最终面对各大门派的面试官长老，通过试炼获得"飞升"——入职理想公司。

**这个游戏让你体验的不仅是刷题的成就感，更是修仙小说中那种"默默修炼，一朝突破"的爽感。**

---

## Unique Hook

**"像LeetCode，但每道题都有修仙叙事包装和即时成长反馈。"**

- 传统刷题工具：冷冰冰的界面，纯粹的功利性
- 道码修仙：正统东方修仙世界观 + 角色动画反馈 + 境界成长系统

**And Also:**
- 错题不是"错题本"，而是"心魔"，需要主动镇压
- 面试不是"模拟器"，而是与角色化面试官的"渡劫"对话
- 进步不是"进度条"，而是实实在在的境界突破

---

## Player Experience Analysis (MDA Framework)

### Target Aesthetics (What the player FEELS)

| Aesthetic | Priority | How We Deliver It |
| ---- | ---- | ---- |
| **Fantasy** (修仙代入感) | 1 (Primary) | 正统修仙世界观、角色成长、境界突破仪式感 |
| **Challenge** (挑战与成长) | 2 | 题目难度递进、BOSS面试压力、心魔来袭 |
| **Submission** (舒适刷题) | 3 | 日常修炼的放松感、碎片时间友好 |
| **Narrative** (叙事驱动) | 4 | 门派故事、面试官性格、修仙剧情 |
| **Discovery** (探索知识) | 5 | 题目解析、知识点关联、隐藏彩蛋 |
| **Sensation** (感官反馈) | 6 | 角色动画、音效、视觉特效 |
| **Expression** (自我表达) | N/A | MVP不包含 |
| **Fellowship** (社交) | N/A | MVP不包含 |

### Key Dynamics (Emergent player behaviors)

1. **日常修炼习惯** — 玩家会养成每天"上线修炼"的习惯，因为修为积累需要持续
2. **主动复习心魔** — 错题本变成"待办事项"，玩家会主动清理心魔以避免积累过多
3. **BOSS战前冲刺** — 面对面试官前，玩家会集中复习相关知识点
4. **分享突破时刻** — 境界突破时的成就感会驱动玩家分享截图

### Core Mechanics (Systems we build)

1. **答题修炼系统** — 选择题目类型 → 修仙场景答题 → 即时反馈（动画+数值+解析）→ 获得修为
2. **境界突破系统** — 修为积累 → 突破考试（连续答题验证）→ 境界提升 → 解锁新内容
3. **心魔系统** — 错题记录 → 错题本界面 → 主动选择复习 → 消除心魔
4. **BOSS面试系统** — 对话式面试 → 角色化面试官 → 动态追问 → 答案讲解反馈

---

## Player Motivation Profile

### Primary Psychological Needs Served

| Need | How This Game Satisfies It | Strength |
| ---- | ---- | ---- |
| **Competence** (能力感) | 每道题都有即时反馈，修为增长可见，境界突破有仪式感 | Core |
| **Autonomy** (自主感) | 自由选择刷什么题、何时复习心魔、何时挑战BOSS | Core |
| **Relatedness** (关联感) | 与面试官角色的对话互动，门派归属感 | Supporting |

### Player Type Appeal (Bartle Taxonomy)

- [x] **Achievers** (成就型) — How: 境界系统、修为数值、BOSS通关记录
- [x] **Explorers** (探索型) — How: 题目解析深度、知识点关联、隐藏成就
- [ ] **Socializers** (社交型) — MVP不包含
- [ ] **Killers/Competitors** (竞争型) — MVP不包含

### Flow State Design

- **Onboarding curve**: 前5题有引导，熟悉答题→修为→反馈循环；第1次心魔有教程
- **Difficulty scaling**: 题目按难度分级（简单/中等/困难），境界越高解锁越难的题目
- **Feedback clarity**: 答对：角色发光+修为+X飘字+音效；答错：角色晃动+显示正确答案+解析
- **Recovery from failure**: 答错立即看解析，可重试；BOSS战失败可重新挑战

---

## Core Loop

### Moment-to-Moment (30 seconds)

```
选择题目 → 阅读题目和选项 → 思考并作答 →
即时反馈（正确：角色发光+修为+X；错误：晃动+解析）→ 下一题
```

**这是游戏的心跳。** 答题本身必须令人满足——不是靠外部奖励，而是靠：
- 修仙场景的氛围感
- 角色动画的反馈感
- "我又学会了一个知识点"的进步感

### Short-Term (5-15 minutes)

**一次"修炼 session"：**
1. 进入修炼场景（洞府/灵山）
2. 选择今日修炼目标（如"Java集合框架"）
3. 连续刷5-10道题
4. 可能遭遇心魔（随机触发错题复习）
5. 结算：获得修为、可能触发突破条件

**"再来一次"心理学：**
- 差一点就突破境界 → "再刷几题"
- 心魔快清完了 → "把这几个复习完"
- BOSS战差一题通关 → "再试一次"

### Session-Level (30-120 minutes)

**深度学习 session（周末/晚上）：**
1. 日常修炼刷题（15分钟）
2. 复习心魔错题（10分钟）
3. 尝试境界突破（5分钟）
4. 挑战BOSS面试官（15-30分钟）
5. 查看解析、做笔记（10分钟）

**自然停止点：** 完成一次BOSS战、突破一个境界、清空心魔列表

### Long-Term Progression

**境界系统（从凡人到仙人）：**

| 境界 | 修为要求 | 解锁内容 | 对应能力 |
|------|----------|----------|----------|
| 凡人 | 0 | 基础题 | 入门级 |
| 炼气期 | 100 | 中等题 | 初级工程师 |
| 筑基期 | 500 | 困难题 | 中级工程师 |
| 金丹期 | 1500 | 独角兽BOSS | 高级工程师 |
| 元婴期 | 4000 | 大厂BOSS | 资深工程师 |
| 化神期 | 10000 | 全部门派 | 架构师/专家 |
| 飞升 | 通关所有BOSS | 结局动画 | 拿到Offer |

### Retention Hooks

- **Curiosity**: "下一个境界解锁什么？" / "大厂面试官会问什么？"
- **Investment**: 修为积累、境界进度、已清心魔数量
- **Mastery**: 正确率提升、BOSS战通关速度、知识点掌握度
- **实用价值**: 真正学会面试题，实际面试中用得上

---

## Game Pillars

### Pillar 1: 实用至上

**每道题都必须有真实的面试价值。** 不是为了游戏而编题，而是将真实面试题用修仙包装。

*Design test*: 如果一道题"游戏性很好但面试用不上"，我们选择**删除或替换**。

### Pillar 2: 沉浸修仙

**正统东方修仙氛围，不是恶搞或戏谑。** 文案有韵味，场景有仙气，角色有仙风道骨。

*Design test*: 如果一个UI设计"很现代但破坏修仙感"，我们选择**改用修仙风格**。

### Pillar 3: 成长可见

**玩家的每一点进步都要被看见。** 修为数值、境界提升、心魔清零——进步不是抽象概念，是具体反馈。

*Design test*: 如果一个系统"好玩但玩家感觉不到进步"，我们选择**加入可视化成长元素**。

### Pillar 4: 碎片友好

**5分钟也能有效修炼。** 地铁上刷几道题，午休清几个心魔，不要求大块时间。

*Design test*: 如果一个功能"需要30分钟才能完成一次"，我们选择**拆分成更小的单元**。

### Anti-Pillars (What This Game Is NOT)

- **NOT 纯娱乐游戏** — 如果牺牲学习效果换游戏性，不做
- **NOT 社交平台** — MVP不包含好友、公会、排行榜功能
- **NOT 完整 IDE** — 代码编辑器是基础级别，复杂编码建议跳转 LeetCode
- **NOT 竞技游戏** — 不做PVP、限时赛、实时对战
- **NOT 通用学习平台** — 专注技术面试，不扩展到其他领域

---

## Inspiration and References

| Reference | What We Take From It | What We Do Differently | Why It Matters |
| ---- | ---- | ---- | ---- |
| **想不想修真** | 放置修仙的成长感、境界系统 | 加入真实的编程学习内容 | 验证了修仙+日常成长的可行性 |
| **Anki** | 间隔重复的记忆曲线原理 | 游戏化包装，不再是枯燥卡片 | 科学记忆法的有效性 |
| **LeetCode** | 面试题库的权威性和实用性 | 修仙主题、角色反馈、境界系统 | 目标用户熟悉的产品 |
| **鬼谷八荒** | 商业修仙风的美术品质 | 更轻量，专注刷题而非开放世界 | 美术风格参考 |

**Non-game inspirations:**
- 《上瘾式学习》— 核心方法论来源：即时反馈、渐进难度、间隔重复
- 修仙网文 — 境界设定、突破爽感、门派文化
- 真实面试经历 — BOSS面试官的性格和提问风格

---

## Target Player Profile

| Attribute | Detail |
| ---- | ---- |
| **Age range** | 22-35岁 |
| **Gaming experience** | 休闲到中核玩家，玩过手游或独立游戏 |
| **Time availability** | 工作日碎片时间（地铁/午休）+ 周末深度学习 |
| **Platform preference** | 移动端为主，PC端辅助 |
| **Current games they play** | 想不想修真、原神、各种学习APP |
| **What they're looking for** | 刷题不枯燥、有成就感、能看到进步 |
| **What would turn them away** | 太肝、太氪、题目质量差、反馈延迟 |

---

## Technical Considerations

| Consideration | Assessment |
| ---- | ---- |
| **Recommended Engine** | Godot 4 — 跨平台支持好、轻量级、GDScript开发快、2D能力强 |
| **Key Technical Challenges** | 题库数据结构设计、PDF导入解析、角色动画系统、AI面试官集成 |
| **Art Style** | 2D商业修仙风（类似鬼谷八荒） |
| **Art Pipeline** | MiniMax AI 生成 + 人工筛选微调 |
| **Art Pipeline Complexity** | 中 — AI生成降低成本，需要统一风格处理 |
| **Audio Needs** | 中等 — 修仙BGM、答题音效、境界突破音效 |
| **Networking** | MVP需要网络调用 MiniMax API（需后端代理） |
| **Content Volume** | MVP: 300+道题、1个门派、2个BOSS、6个境界 |
| **Procedural Systems** | AI 面试官对话 — 动态生成追问和点评 |

### AI Integration Stack

| System | Technology | Purpose |
| ---- | ---- | ---- |
| **BOSS 面试官** | MiniMax API | 动态追问、答案点评、面试报告生成 |
| **美术素材** | MiniMax 图像生成 | 角色立绘、场景背景、UI元素 |
| **代码编辑** | Godot CodeEdit | 内置基础语法高亮代码编辑器 |
| **题目链接** | LeetCode 外链 | 算法题可跳转 LeetCode 提交验证 |

### AI 面试官工作流

```
┌─────────────────────────────────────────────────────┐
│                   AI 面试官流程                       │
├─────────────────────────────────────────────────────┤
│  1. 面试官提出问题（预设题库）                         │
│  2. 玩家作答（选择/简答）                             │
│  3. MiniMax API 分析回答                             │
│     ├─ 回答正确 → 追问进阶问题                        │
│     ├─ 回答部分正确 → 给提示，再给一次机会             │
│     └─ 回答错误 → 讲解正确答案                        │
│  4. 面试结束生成报告                                  │
│     └─ 优势领域、薄弱环节、建议复习方向                │
└─────────────────────────────────────────────────────┘
```

### MiniMax 素材生成清单

| 素材类型 | 数量 | Prompt 要点 |
| ---- | ---- | ---- |
| **玩家角色立绘** | 1套（多境界形态） | 修仙者、渐进仙气、正统东方风格 |
| **BOSS立绘** | 2个 | 外包厂面试官（年轻HR）、大厂面试官（仙风道骨长老） |
| **修炼场景** | 1-2个 | 灵山洞府、云雾缭绕、仙气氛围 |
| **UI元素** | 1套 | 卷轴、石碑、玉简、仙术边框 |

---

## Risks and Open Questions

### Design Risks

- **学习与游戏平衡** — 修仙包装是否会分散学习注意力？
- **长期留存** — 通关所有BOSS后，玩家还有动力继续吗？
- **题目难度匹配** — 自动推荐难度是否准确？太难或太简单都会流失

### Technical Risks

- **PDF解析质量** — 300+道题的PDF解析可能需要人工校对
- **角色动画成本** — 商业修仙风的完整动画制作周期长
- **跨平台适配** — 移动端和PC端的UI/UX需要分别优化

### Market Risks

- **目标用户规模** — 准备面试的程序员市场是否足够大？
- **竞品压力** — LeetCode、牛客等已有品牌优势
- **付费意愿** — 用户是否愿意为游戏化刷题付费？

### Scope Risks

- **美术优先策略** — 可能导致4-8周内玩法不够完善
- **题目内容量** — 300+道题的内容整理和校对工作量大
- **3种题型支持** — 选择题、简答题、开放问答的实现复杂度不同

### Open Questions

- **题目来源扩展** — 后续如何持续补充新题目？社区贡献？爬虫抓取？
- **AI 成本控制** — MiniMax API 调用频率和成本如何平衡？是否需要缓存常见回答？
- **离线体验** — AI 面试官需要网络，如何处理无网络情况？
- **多人模式** — 后期是否加入好友PK、排行榜等社交功能？

---

## MVP Definition

**Core hypothesis**: 玩家会因为修仙主题、AI面试官互动和即时反馈而更愿意持续刷题，并且真的能学到面试知识。

**Required for MVP**:
1. **1个门派（Java派）** — 完整的门派体验，验证核心循环
2. **300+道题目** — 从PDF导入，优先选择题
3. **完整答题循环** — 修仙场景 + 题卡 + 角色动画反馈 + 数值飘字 + 音效 + 解析
4. **境界系统** — 6个境界，修为积累 + 突破考试
5. **心魔系统** — 错题本界面 + 主动复习
6. **2个AI BOSS** — 外包厂面试官 + 大厂面试官，MiniMax 驱动对话式面试
7. **代码编辑器** — Godot CodeEdit 内置编辑器，支持基础语法高亮
8. **MiniMax 生成美术** — 1个玩家角色（带动画）、2个BOSS立绘、1个修炼场景

**AI 面试官 MVP 功能**:
- 根据玩家回答动态追问或给提示
- 错误时讲解正确答案
- 面试结束生成简单报告
- 2个BOSS有不同的"性格"（Prompt 设定）

**代码编辑器 MVP 功能**:
- 基础代码输入和展示
- 简单语法高亮（关键字着色）
- "在 LeetCode 提交"按钮（外链跳转）

**Explicitly NOT in MVP** (defer to later):
- 多门派系统（Go、C++等）
- 社交功能（好友、排行榜）
- 云存档和账号系统
- 付费内容和商业化
- 简答题/编程题的AI评分

### Scope Tiers (if budget/time shrinks)

| Tier | Content | Features | Timeline |
| ---- | ---- | ---- | ---- |
| **Minimal MVP** | 50道精选题、1个BOSS | 核心答题循环 | 2-3周 |
| **MVP** | 300+题、2个BOSS、完整境界 | 全部核心系统 | 4-8周 |
| **Vertical Slice** | 1个门派完整体验 | + 心魔系统优化 | 8-12周 |
| **Full Vision** | 3+门派、云存档、社交 | 所有规划功能 | 3-6个月 |

---

## Next Steps

- [ ] Get concept approval from creative-director
- [ ] Fill in CLAUDE.md technology stack (`/setup-engine godot 4`)
- [ ] Create game pillars document (`/design-review`)
- [ ] Decompose concept into systems (`/map-systems`)
- [ ] Design PDF import pipeline for question data
- [ ] Create first architecture decision record (`/architecture-decision`)
- [ ] Prototype core loop (`/prototype answer-feedback`)
- [ ] Validate core loop with playtest (`/playtest-report`)
- [ ] Plan first milestone (`/sprint-plan new`)
