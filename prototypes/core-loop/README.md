# Prototype: Core Loop Validation

> **Purpose**: Validate "答题→修为→境界→BOSS面试" core循环是否有用/有趣
> **Status**: Throwaway — 快速验证，代码可丢弃
> **Duration**: 1-2 days
> **Created**: 2026-03-30

---

## Hypothesis to Validate

**核心假设**: 答题获得修为、境界提升、挑战BOSS面试的循环能让玩家感到：
1. **成长感**: 修为数字增长、境界提升带来成就感
2. **挑战感**: BOSS面试有难度，需要认真答题
3. **学习价值**: 通过答题真正学到面试知识

---

## What to Test

| 测试项 | 验证方法 | 成功标准 |
|--------|----------|----------|
| 答题流程 | 看题目→选择→提交→反馈 | 流程顺畅，反馈清晰 |
| 修为计算 | 答对加修为，答错扣修为 | 数字变化直观，计算正确 |
| 境界突破 | 修达到阈值→触发突破→境界提升 | 突破有仪式感，境界变化明显 |
| BOSS面试 | 选择BOSS→对话→答题→评分 | AI对话自然，评分合理 |

---

## Minimal Scope

**只做**:
- 5道示例题目（选择题）
- 修为数字显示和增长
- 境界显示和突破触发
- 1个BOSS面试对话（简化版）
- 主菜单入口

**不做**:
- 精美UI/动画
- 完整题库
- 心魔复习系统
- 存档持久化
- AI真实API调用（用Mock）

---

## File Structure

```
prototypes/core-loop/
├── README.md                   # 本文件
├── main.tscn                   # 主场景
├── main.gd                     # 主逻辑
├── data/
│   ├── sample_questions.json   # 5道示例题
│   └── realms.json             # 境界配置
├── ui/
│   ├── question_panel.gd       # 题目面板
│   ├── cultivation_bar.gd      # 修为进度条
│   └── realm_display.gd        # 境界显示
└── systems/
    ├── cultivation_calc.gd     # 修为计算（简化）
    └── boss_interview_mock.gd  # BOSS面试Mock
```

---

## Sample Questions (5道)

```json
[
  {
    "id": "q001",
    "type": "choice",
    "faction": "大厂",
    "difficulty": 1,
    "question": "Java中HashMap的底层实现是什么？",
    "options": ["数组+链表", "红黑树", "哈希表", "跳表"],
    "correct_answer": 0,
    "explanation": "HashMap底层是数组+链表，JDK8后链表过长会转红黑树。",
    "tags": ["Java", "集合", "HashMap"],
    "base_score": 10
  },
  {
    "id": "q002",
    "type": "choice",
    "faction": "大厂",
    "difficulty": 2,
    "question": "Spring Bean的生命周期包含哪些阶段？",
    "options": ["实例化→属性注入→初始化→销毁", "加载→运行→停止", "创建→使用→回收", "编译→执行→结束"],
    "correct_answer": 0,
    "explanation": "Bean生命周期：实例化→属性注入→初始化（Aware接口、BeanPostProcessor）→销毁。",
    "tags": ["Java", "Spring", "Bean"],
    "base_score": 15
  },
  {
    "id": "q003",
    "type": "choice",
    "faction": "技术公司",
    "difficulty": 1,
    "question": "MySQL索引的最左匹配原则是什么？",
    "options": ["联合索引从左到右依次匹配", "任意字段都能用索引", "只有第一字段有效", "索引无顺序"],
    "correct_answer": 0,
    "explanation": "联合索引按定义顺序从左匹配，如(a,b,c)索引，查询a或a+b或a+b+c都能用索引。",
    "tags": ["MySQL", "索引", "数据库"],
    "base_score": 12
  },
  {
    "id": "q004",
    "type": "choice",
    "faction": "外包",
    "difficulty": 1,
    "question": "Git中merge和rebase的区别是什么？",
    "options": ["merge保留历史，rebase线性化历史", "两者相同", "rebase更安全", "merge更快"],
    "correct_answer": 0,
    "explanation": "merge会保留分支历史，产生分叉；rebase会将提交移到目标分支末尾，历史线性化。",
    "tags": ["Git", "版本控制"],
    "base_score": 10
  },
  {
    "id": "q005",
    "type": "choice",
    "faction": "大厂",
    "difficulty": 2,
    "question": "线程安全的HashMap实现方式有哪些？",
    "options": ["ConcurrentHashMap、Collections.synchronizedMap", "只有Hashtable", "加锁即可", "HashMap本身就是线程安全"],
    "correct_answer": 0,
    "explanation": "线程安全的实现：ConcurrentHashMap（分段锁/JDK8 CAS）、Collections.synchronizedMap（全表锁）、Hashtable（遗留类）。",
    "tags": ["Java", "并发", "线程安全"],
    "base_score": 18
  }
]
```

---

## Realm Configuration

```json
{
  "realms": [
    {"id": "low_qi", "name": "炼气期", "threshold": 0, "color": "#90CAF9"},
    {"id": "build_base", "name": "筑基期", "threshold": 100, "color": "#A5D6A7"},
    {"id": "golden_core", "name": "金丹期", "threshold": 500, "color": "#FFD54F"},
    {"id": "nascent_soul", "name": "元婴期", "threshold": 1500, "color": "#FF8A65"},
    {"id": "spirit_severing", "name": "化神期", "threshold": 4000, "color": "#CE93D8"}
  ]
}
```

---

## Core Logic Flow

```
┌─────────────────────────────────────────────────────────────┐
│                        主菜单                                │
│  [开始修炼]  [退出]                                          │
└─────────────────────┬───────────────────────────────────────┘
                      │ 点击开始
                      ↓
┌─────────────────────────────────────────────────────────────┐
│                      修炼场景                                │
│                                                             │
│  境界: 炼气期        修为: 0/100                             │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Q: Java中HashMap的底层实现是什么？                  │   │
│  │                                                     │   │
│  │ [数组+链表]  [红黑树]  [哈希表]  [跳表]             │   │
│  │                                                     │   │
│  │                          [提交答案]                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  [心魔: 0个]  [BOSS面试]                                     │
└─────────────────────────────────────────────────────────────┘
                      │ 答对
                      ↓
┌─────────────────────────────────────────────────────────────┐
│                      答题反馈                                │
│                                                             │
│  ✓ 正确！修为 +10                                           │
│                                                             │
│  解析: HashMap底层是数组+链表...                            │
│                                                             │
│  [继续修炼]                                                  │
└─────────────────────────────────────────────────────────────┘
                      │ 修为达到阈值
                      ↓
┌─────────────────────────────────────────────────────────────┐
│                      境界突破                                │
│                                                             │
│  ⚡ 修为已满！准备突破筑基期...                              │
│                                                             │
│  [开始突破]                                                  │
└─────────────────────────────────────────────────────────────┘
                      │ 点击突破
                      ↓
┌─────────────────────────────────────────────────────────────┐
│                      突破考试                                │
│                                                             │
│  答对3道题即可突破                                           │
│                                                             │
│  [题目...]                                                   │
│                                                             │
│  进度: 0/3                                                   │
└─────────────────────────────────────────────────────────────┘
                      │ 答对3道
                      ↓
┌─────────────────────────────────────────────────────────────┐
│                      突破成功                                │
│                                                             │
│  ★ 境界提升！筑基期                                          │
│                                                             │
│  [继续修炼]                                                  │
└─────────────────────────────────────────────────────────────┘
```

---

## Mock BOSS Interview

由于原型不调用真实AI API，使用预设对话：

```
BOSS: 大厂长老

对话轮次:
1. BOSS: "年轻人，吾且问你，Java集合框架中，HashMap与ConcurrentHashMap有何区别？"
   → 玩家选择答案或输入

2. BOSS: (根据答案) "不错，那继续追问，ConcurrentHashMap在JDK7和JDK8的实现有何不同？"
   → 玩家回答

3. BOSS: "最后一问，如何保证线程安全？除了ConcurrentHashMap还有什么方案？"
   → 玩家回答

评分: 预设分数（随机60-95分）
```

---

## Success Criteria

原型成功验证的条件：

| # | 条件 | 如何验证 |
|---|------|----------|
| 1 | 答题流程顺畅 | 自己运行，无卡顿 |
| 2 | 修为变化直观 | 数字变化有动画 |
| 3 | 境界提升有感 | 突破有仪式感 |
| 4 | BOSS对话自然 | 对话文本流畅 |
| 5 | 有"再玩一次"冲动 | 自己想继续答题 |

---

## How to Run

```bash
# 1. 在 Godot 编辑器中打开项目
# 2. 打开 prototypes/core-loop/main.tscn
# 3. 按 F5 运行
# 4. 测试完整流程：答题→修为→境界→BOSS面试
```

---

## Learnings to Capture

运行原型后，记录以下观察：

1. **答题体验**: 题目难度是否合适？选项是否清晰？
2. **修为反馈**: 修为变化是否有足够激励？
3. **境界突破**: 突破考试是否有挑战感？
4. **BOSS面试**: AI对话是否自然？评分是否合理？
5. **整体节奏**: 循环是否太慢/太快？

---

## Next Steps After Validation

- **通过**: 开始 Sprint 1 实现
- **失败**: 调整 GDD 设计，重新验证核心循环假设
- **部分通过**: 标记需要改进的系统，在 Sprint 中优化