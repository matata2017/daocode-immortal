# 题库数据系统 (Question Bank Data System)

> **Status**: Designed
> **Author**: User + Claude Code
> **Last Updated**: 2026-03-30
> **Implements Pillar**: 实用至上、成长可见

## Overview

**题库数据系统**是道码修仙的核心数据基础，负责存储、加载和管理 300+ 道编程面试题目。

系统支持四种题型（选择题、简答题、编程题、开放问答），按知识点、难度、门派三个维度分类。每道题目包含完整的内容：题干、选项（如适用）、标准答案、详细解析、知识点讲解、代码示例和延伸阅读链接。

玩家通过**答题修炼系统**与此数据交互——选择想练习的知识点或难度，系统返回匹配的题目。编程题在游戏内置 CodeEdit 编辑器中展示，玩家可复制代码到 LeetCode 提交验证。

**为什么需要这个系统**：题库是游戏的"内容心脏"。没有它，答题修炼、境界突破、心魔复习、BOSS 面试四大核心玩法都无法运作。数据结构的设计直接影响后续所有系统的实现难度。

## Player Fantasy

**你是修仙界的求道者，每一道面试题都是一道"心法口诀"。**

在这个世界里，编程知识就是修为。题库不是冰冷的数据库——它是**万法藏经阁**，收藏着各门派的绝学和心法。

### 玩家体验场景

**场景 1：日常修炼**
玩家进入 Java 洞府，选择今日修炼"集合框架"心法。系统从藏经阁取出相关题目——每道题都是一段口诀，玩家需要领悟其中的奥义。答对了，修为增长；答错了，心魔滋生。

**场景 2：境界突破**
炼气期弟子想要突破筑基，需要通过"筑基试炼"。系统从题库中抽取中等难度的题目，玩家需连续答对多道才能突破成功。

**场景 3：心魔来袭**
玩家答错过"HashMap 底层原理"这道题，它变成了心魔。几天后，心魔突然袭来——系统弹出这道错题，玩家必须重新作答才能镇压心魔。

**场景 4：BOSS 面试**
玩家挑战大厂 BOSS"仙风道骨长老"。长老从题库中选取高难度题目，以对话形式提问。玩家的回答会影响长老的追问方向。

### 支撑的游戏支柱

| 支柱 | 如何体现 |
|------|----------|
| **实用至上** | 每道题都是真实面试题，解析详尽，学完真能用 |
| **沉浸修仙** | 题目有修仙风格描述（"炼气期弟子需掌握此法"），门派有背景故事 |
| **成长可见** | 题目难度与境界对应（简单=炼气，中等=筑基，困难=金丹） |
| **碎片友好** | 每道题独立，5 分钟可刷 2-3 道 |

### 数据系统如何支持这些体验

- **快速筛选**：按知识点/难度/门派秒速返回题目
- **完整解析**：答错立即看到详细讲解，不留疑惑
- **LeetCode 联动**：算法题一键跳转实战验证
- **错题追踪**：记录每道错题的时间戳，支持心魔系统

## Detailed Design

### Core Rules

#### 数据存储

**存储方案**：SQLite 本地数据库

**优势**：
- 查询效率高，支持索引
- 支持复杂筛选（知识点 + 难度 + 门派）
- 300+ 题目无性能压力

#### 数据库表结构

```sql
-- 知识点表（支持无限层级）
CREATE TABLE topics (
    id INTEGER PRIMARY KEY,
    parent_id INTEGER REFERENCES topics(id),  -- NULL 表示根节点
    name TEXT NOT NULL,                        -- 如 "集合框架"
    realm TEXT NOT NULL,                       -- 门派：Java/Go/C++
    description TEXT,                          -- 知识点描述
    sort_order INTEGER DEFAULT 0               -- 排序权重
);

-- 题目表
CREATE TABLE questions (
    id INTEGER PRIMARY KEY,
    topic_id INTEGER REFERENCES topics(id),
    title TEXT NOT NULL,                       -- 题目标题
    content TEXT NOT NULL,                     -- 题目内容（支持 Markdown）
    question_type TEXT NOT NULL,               -- choice/short_answer/coding/open
    difficulty TEXT NOT NULL,                  -- easy/medium/hard
    realm TEXT NOT NULL,                       -- 门派
    leetcode_id TEXT,                          -- LeetCode 题号（如算法题）
    leetcode_url TEXT,                         -- LeetCode 链接
    estimated_time INTEGER,                    -- 预估答题时间（秒）
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 选项表（仅选择题使用）
CREATE TABLE choices (
    id INTEGER PRIMARY KEY,
    question_id INTEGER REFERENCES questions(id),
    content TEXT NOT NULL,                     -- 选项内容
    is_correct BOOLEAN NOT NULL,               -- 是否正确答案
    sort_order INTEGER DEFAULT 0               -- 选项顺序
);

-- 答案表（非选择题）
CREATE TABLE answers (
    id INTEGER PRIMARY KEY,
    question_id INTEGER REFERENCES questions(id),
    content TEXT NOT NULL,                     -- 标准答案
    keywords TEXT                              -- 关键词（用于简答题评分）
);

-- 解析表
CREATE TABLE explanations (
    id INTEGER PRIMARY KEY,
    question_id INTEGER REFERENCES questions(id),
    analysis TEXT NOT NULL,                    -- 答案解析
    knowledge_point TEXT,                      -- 知识点讲解
    code_example TEXT,                         -- 代码示例
    reference_links TEXT                       -- 延伸阅读链接（JSON 数组）
);

-- 标签表（多对多）
CREATE TABLE tags (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE                  -- 如 "高频题"、"手写代码"
);

CREATE TABLE question_tags (
    question_id INTEGER REFERENCES questions(id),
    tag_id INTEGER REFERENCES tags(id),
    PRIMARY KEY (question_id, tag_id)
);

-- 索引优化
CREATE INDEX idx_questions_topic ON questions(topic_id);
CREATE INDEX idx_questions_difficulty ON questions(difficulty);
CREATE INDEX idx_questions_realm ON questions(realm);
CREATE INDEX idx_questions_type ON questions(question_type);
```

#### 核心查询规则

**规则 1：题目加载**
```
游戏启动时：
1. 检查 SQLite 数据库是否存在
2. 不存在 → 从 JSON 种子文件创建数据库
3. 存在 → 直接连接
4. 预加载常用数据到内存（题目数量、知识点树）
```

**规则 2：题目查询接口**
```gdscript
# 查询参数
func get_questions(
    topic_id: int = -1,        # -1 表示不筛选
    difficulty: String = "",   # "" 表示不筛选
    realm: String = "",        # "" 表示不筛选
    question_type: String = "",# "" 表示不筛选
    limit: int = 10,           # 返回数量
    random: bool = false,      # 是否随机排序
    exclude_ids: Array = []    # 排除的题目 ID
) -> Array[QuestionData]
```

**规则 3：单题查询**
```gdscript
func get_question_by_id(id: int) -> QuestionData
func get_questions_by_ids(ids: Array[int]) -> Array[QuestionData]
```

**规则 4：知识点树查询**
```gdscript
func get_topic_tree(realm: String) -> TopicNode  # 返回知识点树
func get_all_topics(realm: String) -> Array[TopicData]  # 扁平列表
```

### States and Transitions

题目本身无状态。**玩家对题目的状态**由错题记录系统管理。

| 玩家-题目状态 | 含义 | 转换条件 |
|---------------|------|----------|
| **未见过** | 玩家从未遇到此题 | 首次展示 → 已见 |
| **已见** | 玩家看过但未答 | 作答 → 正确/错误 |
| **正确** | 最近一次答对 | 答错 → 错误 |
| **错误（心魔）** | 最近一次答错 | 复习答对 → 正确 |

> 注意：状态管理由**错题记录系统**负责，题库系统只提供题目数据。

### Interactions with Other Systems

| 系统 | 数据流向 | 接口 |
|------|----------|------|
| **答题修炼系统** | 题库 → 答题 | `get_questions(filters)` |
| **错题记录系统** | 题库 → 错题 | `get_question_by_id(id)` |
| **突破考试系统** | 题库 → 考试 | `get_questions_by_difficulty(diff)` |
| **代码编辑器** | 题库 → 编辑器 | `get_coding_question(id)` |
| **心魔复习系统** | 题库 → 复习 | `get_questions_by_ids(ids)` |
| **BOSS 面试系统** | 题库 → 面试 | `get_questions_by_topic_and_difficulty(topic, diff)` |

### 数据导入流程

```
PDF/外部数据 → Python 脚本解析 → JSON 中间格式 → SQLite 导入 → 游戏使用
                                    ↓
                              Git 版本控制
```

**MVP 阶段**：
1. 手工从 PDF 提取前 50-100 道核心题
2. 保存为 JSON 格式
3. 游戏首次启动时导入 SQLite

## Formulas

### 查询相关公式

**公式 1：题目数量统计**
```
count_questions(topic_id, difficulty, realm) =
    SELECT COUNT(*) FROM questions
    WHERE (topic_id = :topic_id OR :topic_id = -1)
      AND (difficulty = :difficulty OR :difficulty = '')
      AND (realm = :realm OR :realm = '')
```

**公式 2：随机选题**
```
get_random_questions(topic_id, difficulty, limit) =
    SELECT * FROM questions
    WHERE topic_id = :topic_id
      AND difficulty = :difficulty
    ORDER BY RANDOM()
    LIMIT :limit
```

**公式 3：知识点完成度**
```
topic_completion_rate(topic_id, player_id) =
    COUNT(player.answered_questions WHERE topic_id = :topic_id)
    / COUNT(all_questions WHERE topic_id = :topic_id)

返回值范围：[0.0, 1.0]
```

### 统计查询公式

**公式 4：难度分布**
```
difficulty_distribution(realm) =
    SELECT difficulty, COUNT(*) as count
    FROM questions
    WHERE realm = :realm
    GROUP BY difficulty

返回示例：
{ "easy": 100, "medium": 150, "hard": 50 }
```

**公式 5：门派题目总数**
```
realm_question_count(realm) =
    SELECT COUNT(*) FROM questions WHERE realm = :realm
```

### 数据导入公式

**公式 6：JSON → SQLite 导入**
```python
def import_from_json(json_path: str) -> int:
    """
    从 JSON 文件导入题目到 SQLite
    返回：成功导入的题目数量
    """
    data = json.load(open(json_path))
    count = 0
    for q in data["questions"]:
        question_id = insert_question(q)
        if q["type"] == "choice":
            insert_choices(question_id, q["choices"])
        insert_answer(question_id, q["answer"])
        insert_explanation(question_id, q["explanation"])
        count += 1
    return count
```

## Edge Cases

| 边缘情况 | 处理方式 | 影响范围 |
|----------|----------|----------|
| **数据库文件损坏** | 检测到损坏 → 从 JSON 种子重建 → 提示玩家"藏经阁重建完成" | 所有系统 |
| **查询结果为空** | 返回空数组，UI 显示"该知识点暂无题目" | 答题修炼 |
| **题目 ID 不存在** | 返回 null，调用方需要处理 null 检查 | 错题记录、心魔复习 |
| **知识点树循环引用** | 导入时检测 → 拒绝导入并报错日志 | 数据导入 |
| **选择题无正确答案** | 导入时验证 → 至少有一个 `is_correct = true`，否则拒绝 | 数据导入 |
| **多选题多个正确答案** | 允许多个 `is_correct = true`，玩家需全选才对 | 答题判定 |
| **LeetCode 链接失效** | 不在数据层处理，由 UI 层捕获异常显示"无法跳转" | 代码编辑器 |
| **代码示例为空** | 允许为空，UI 条件渲染，无代码时隐藏代码块 | 题目解析 |
| **知识点无限嵌套** | 查询时限制深度（最多 5 层），超出部分折叠 | 知识点树 |
| **并发访问** | SQLite 默认支持并发读，写操作使用互斥锁 | 存档系统 |
| **题库版本更新** | 检测版本号 → 自动迁移数据 → 保留玩家进度 | 存档系统 |
| **门派无题目** | 返回空，UI 提示"该门派正在建设中" | 门派选择 |
| **难度无题目** | 返回空，UI 提示"该难度暂无题目" | 突破考试 |

## Dependencies

### 上游依赖（此系统依赖的系统）

**无** — 这是基础数据系统，没有上游依赖。

### 下游依赖（依赖此系统的系统）

| 系统 | 依赖类型 | 接口需求 | 设计状态 |
|------|----------|----------|----------|
| **错题记录系统** | 硬依赖 | `get_question_by_id(id)` 返回完整题目 | 未设计 |
| **代码编辑器** | 硬依赖 | `get_coding_question(id)` 返回编程题 | 未设计 |
| **突破考试系统** | 硬依赖 | `get_questions_by_difficulty(diff)` | 未设计 |
| **答题修炼系统** | 硬依赖 | `get_questions(filters)` 多条件查询 | 未设计 |
| **心魔复习系统** | 硬依赖 | `get_questions_by_ids(ids)` 批量查询 | 未设计 |
| **BOSS 面试系统** | 软依赖 | `get_questions_by_topic(topic, diff)` | 未设计 |

### 接口契约

**契约 1：`get_question_by_id(id: int) -> QuestionData | null`**
- 输入：题目 ID
- 输出：完整题目数据（含选项、答案、解析）或 null
- 保证：如果 ID 存在，返回的数据结构完整
- 性能：< 1ms（内存缓存）或 < 10ms（数据库查询）

**契约 2：`get_questions(filters: QueryFilters) -> Array[QuestionData]`**
- 输入：筛选条件对象
  ```gdscript
  {
    topic_id: int = -1,      # -1 = 不筛选
    difficulty: String = "", # "" = 不筛选
    realm: String = "",      # "" = 不筛选
    question_type: String = "",
    limit: int = 10,
    random: bool = false,
    exclude_ids: Array[int] = []
  }
  ```
- 输出：匹配的题目数组（可能为空）
- 保证：即使无匹配也返回空数组，不返回 null

**契约 3：`get_topic_tree(realm: String) -> TopicNode`**
- 输入：门派名称（如 "Java"）
- 输出：知识点树（嵌套结构）
- 保证：至少返回根节点
- 示例输出：
  ```gdscript
  {
    id: 0,
    name: "Java",
    children: [
      { id: 1, name: "Java 基础", children: [...] },
      { id: 2, name: "Spring 框架", children: [...] },
      { id: 3, name: "多线程", children: [...] },
      { id: 4, name: "高并发", children: [...] },
      { id: 5, name: "架构设计", children: [...] }
    ]
  }
  ```

**契约 4：`get_question_count(filters: QueryFilters) -> int`**
- 输入：筛选条件
- 输出：匹配的题目数量
- 用途：显示"共 X 道题"

## Tuning Knobs

| 参数名 | 类型 | 默认值 | 安全范围 | 调整影响 |
|--------|------|--------|----------|----------|
| `cache_size_limit` | int | 100 | 50-500 | 内存缓存题目数量上限。太小→频繁查库；太大→内存占用高 |
| `max_topic_depth` | int | 5 | 3-10 | 知识点树最大嵌套深度。太大→查询慢、UI 复杂 |
| `default_query_limit` | int | 10 | 5-50 | 默认返回题目数量。太大→内存压力 |
| `random_seed` | int | 0 | 0-999999 | 随机选题种子。0=使用时间戳（真随机） |
| `db_pool_size` | int | 5 | 1-20 | 数据库连接池大小。移动端建议 1-3 |
| `query_timeout_ms` | int | 5000 | 1000-30000 | 查询超时时间（毫秒） |

### 参数调整建议

**场景 1：移动端低端设备**
```
cache_size_limit = 50
db_pool_size = 1
default_query_limit = 5
```

**场景 2：PC 端 / 高端设备**
```
cache_size_limit = 200
db_pool_size = 5
default_query_limit = 20
```

**场景 3：测试 / 调试**
```
random_seed = 12345  # 固定随机，便于复现问题
query_timeout_ms = 30000  # 更长超时，便于断点调试
```

## Acceptance Criteria

### 功能验收标准

| ID | 测试场景 | 预期结果 | 优先级 |
|----|----------|----------|--------|
| **AC-01** | 首次启动，数据库不存在 | 从 JSON 种子创建数据库，加载成功 | P0 |
| **AC-02** | 按知识点查询题目 | 返回该知识点下所有题目（含子知识点） | P0 |
| **AC-03** | 按难度筛选 | 只返回指定难度的题目 | P0 |
| **AC-04** | 随机选题 | 每次调用返回不同题目（种子相同则相同） | P0 |
| **AC-05** | 查询不存在的 ID | 返回 null，不崩溃 | P0 |
| **AC-06** | 空筛选条件 | 返回所有题目（受 limit 限制） | P1 |
| **AC-07** | 多条件组合筛选 | 返回同时满足所有条件的题目 | P1 |
| **AC-08** | 知识点树查询 | 返回完整的嵌套树结构 | P1 |
| **AC-09** | 题目数量统计 | 返回准确的 count 值 | P1 |
| **AC-10** | 数据库损坏恢复 | 自动重建，提示用户"藏经阁重建完成" | P2 |
| **AC-11** | LeetCode 链接跳转 | 正确打开浏览器跳转到对应题目 | P2 |

### 性能验收标准

| ID | 测试场景 | 预期结果 | 测试方法 |
|----|----------|----------|----------|
| **AC-P01** | 单次 ID 查询（缓存命中） | < 1ms | Godot 性能分析器 |
| **AC-P02** | 单次 ID 查询（缓存未命中） | < 10ms | SQLite EXPLAIN |
| **AC-P03** | 批量查询 100 道题 | < 50ms | 批量查询测试 |
| **AC-P04** | 知识点树加载 | < 20ms | 场景加载测试 |
| **AC-P05** | 游戏启动时数据库初始化 | < 500ms | 启动时间测试 |
| **AC-P06** | 内存占用（300 道题缓存） | < 10MB | 内存分析器 |

### 数据完整性验收

| ID | 验证规则 | 错误处理 |
|----|----------|----------|
| **AC-D01** | 选择题必须有 ≥1 个正确答案 | 导入时拒绝，记录日志 |
| **AC-D02** | 题目必须关联知识点 | 导入时拒绝，记录日志 |
| **AC-D03** | 难度只能是 easy/medium/hard | 导入时拒绝，记录日志 |
| **AC-D04** | 门派必须存在 | 导入时拒绝，记录日志 |
| **AC-D05** | 编程题必须有 LeetCode URL | 导入时警告，但允许通过 |
| **AC-D06** | 题目内容不能为空 | 导入时拒绝，记录日志 |

### 验证清单（QA 使用）

```markdown
## 题库数据系统验收清单

### 基础功能
- [ ] 首次启动能自动创建数据库
- [ ] 能按知识点筛选题目
- [ ] 能按难度筛选题目
- [ ] 能随机选题
- [ ] 查询不存在的 ID 返回 null
- [ ] 能获取知识点树

### 性能
- [ ] 单题查询 < 10ms
- [ ] 100 题批量查询 < 50ms
- [ ] 启动初始化 < 500ms
- [ ] 内存占用 < 10MB

### 异常处理
- [ ] 数据库损坏能自动重建
- [ ] 错误数据导入被拒绝
- [ ] 空结果返回空数组不崩溃
```

## Open Questions

| # | 问题 | 状态 | 决策/负责人 | 目标日期 |
|---|------|------|-------------|----------|
| OQ-01 | PDF 解析脚本如何处理表格和代码块？ | 待研究 | 后端开发者 | 开发前 |
| OQ-02 | 是否支持用户自定义题目导入？ | 待讨论 | 产品决策 | Alpha 前 |
| OQ-03 | 知识点树是否支持动态更新（不重启游戏）？ | 待设计 | 系统设计师 | Alpha 前 |
| OQ-04 | 如何处理题目依赖关系（如"需先掌握 X 才能做 Y"）？ | 待讨论 | 游戏设计师 | MVP 后 |
| OQ-05 | 是否支持题目收藏功能？ | 待讨论 | 产品决策 | MVP 后 |

---

## 附录：Java 门派知识点树示例

```
Java（根节点）
├── Java 基础
│   ├── 语法基础
│   ├── 面向对象
│   ├── 集合框架
│   └── 异常处理
├── Spring 框架
│   ├── Spring Core
│   ├── Spring MVC
│   ├── Spring Boot
│   └── Spring Cloud
├── 多线程
│   ├── 线程基础
│   ├── 锁机制
│   ├── 线程池
│   └── 并发工具类
├── 高并发
│   ├── 并发模型
│   ├── 消息队列
│   ├── 分布式锁
│   └── 缓存策略
└── 架构设计
    ├── 设计模式
    ├── 分布式架构
    ├── 微服务
    └── 系统设计
```
