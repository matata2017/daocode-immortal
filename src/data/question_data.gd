## QuestionData.gd
## 题目数据类
## 存储单道题目的所有信息
extends Resource

class_name QuestionData

# 题目类型枚举
enum QuestionType {
	CHOICE,       # 选择题
	SHORT_ANSWER, # 简答题
	CODING,       # 编程题
	OPEN          # 开放问答
}

# 难度枚举
enum Difficulty {
	EASY,    # 炼气期
	MEDIUM,  # 筑基期
	HARD     # 金丹期及以上
}

# 基础信息
@export var id: String = ""
@export var title: String = ""
@export_multiline var content: String = ""
@export var question_type: QuestionType = QuestionType.CHOICE
@export var difficulty: Difficulty = Difficulty.EASY
@export var realm: String = "Java"  # 门派

# 分类信息
@export var topic: String = ""  # 知识点
@export var tags: Array[String] = []

# 选择题选项 (仅选择题使用)
@export var options: Array[String] = []
@export var correct_answer: int = 0  # 正确选项索引

# 简答题/开放问答答案
@export_multiline var answer: String = ""
@export var keywords: Array[String] = []  # 关键词评分

# 编程题相关
@export var leetcode_id: String = ""
@export var leetcode_url: String = ""
@export_multiline var code_template: String = ""

# 解析内容
@export_multiline var explanation: String = ""
@export_multiline var knowledge_point: String = ""
@export_multiline var code_example: String = ""
@export var reference_links: Array[String] = []

# 元数据
@export var estimated_time: int = 60  # 预估答题时间(秒)
@export var base_score: int = 10  # 基础修为值


## 获取难度对应的境界名称
func get_difficulty_realm_name() -> String:
	match difficulty:
		Difficulty.EASY:
			return "炼气期"
		Difficulty.MEDIUM:
			return "筑基期"
		Difficulty.HARD:
			return "金丹期"
		_:
			return "未知境界"


## 获取题型显示名称
func get_type_display_name() -> String:
	match question_type:
		QuestionType.CHOICE:
			return "选择题"
		QuestionType.SHORT_ANSWER:
			return "简答题"
		QuestionType.CODING:
			return "编程题"
		QuestionType.OPEN:
			return "开放问答"
		_:
			return "未知题型"


## 验证数据完整性
func validate() -> bool:
	if id.is_empty():
		push_error("QuestionData: id is empty")
		return false
	if content.is_empty():
		push_error("QuestionData: content is empty for id=%s" % id)
		return false

	# 选择题必须有选项
	if question_type == QuestionType.CHOICE:
		if options.size() < 2:
			push_error("QuestionData: choice question needs at least 2 options, id=%s" % id)
			return false
		if correct_answer < 0 or correct_answer >= options.size():
			push_error("QuestionData: invalid correct_answer for id=%s" % id)
			return false

	return true


## 从字典创建
static func from_dict(data: Dictionary) -> QuestionData:
	var q := QuestionData.new()
	q.id = data.get("id", "")
	q.title = data.get("title", "")
	q.content = data.get("content", data.get("question", ""))

	# 解析题型
	var type_str: String = data.get("type", "choice")
	match type_str.to_lower():
		"choice":
			q.question_type = QuestionType.CHOICE
		"short_answer":
			q.question_type = QuestionType.SHORT_ANSWER
		"coding":
			q.question_type = QuestionType.CODING
		"open":
			q.question_type = QuestionType.OPEN

	# 解析难度
	var diff_str: String = data.get("difficulty", "easy")
	match diff_str.to_lower():
		"easy", "1":
			q.difficulty = Difficulty.EASY
		"medium", "2":
			q.difficulty = Difficulty.MEDIUM
		"hard", "3":
			q.difficulty = Difficulty.HARD

	q.realm = data.get("realm", data.get("faction", "Java"))
	q.topic = data.get("topic", "")
	q.tags = data.get("tags", [])

	# 选择题数据
	q.options = data.get("options", [])
	q.correct_answer = data.get("correct_answer", 0)

	# 答案数据
	q.answer = data.get("answer", "")
	q.keywords = data.get("keywords", [])

	# 编程题数据
	q.leetcode_id = data.get("leetcode_id", "")
	q.leetcode_url = data.get("leetcode_url", "")
	q.code_template = data.get("code_template", "")

	# 解析内容
	q.explanation = data.get("explanation", "")
	q.knowledge_point = data.get("knowledge_point", "")
	q.code_example = data.get("code_example", "")
	q.reference_links = data.get("reference_links", [])

	# 元数据
	q.estimated_time = data.get("estimated_time", 60)
	q.base_score = data.get("base_score", 10)

	return q


## 转换为字典 (用于存档)
func to_dict() -> Dictionary:
	var data := {
		"id": id,
		"title": title,
		"content": content,
		"type": get_type_display_name(),
		"difficulty": get_difficulty_realm_name(),
		"realm": realm,
		"topic": topic,
		"tags": tags,
		"base_score": base_score,
	}

	if question_type == QuestionType.CHOICE:
		data["options"] = options
		data["correct_answer"] = correct_answer

	if not answer.is_empty():
		data["answer"] = answer

	if not explanation.is_empty():
		data["explanation"] = explanation

	if question_type == QuestionType.CODING:
		data["leetcode_url"] = leetcode_url
		data["code_template"] = code_template

	return data