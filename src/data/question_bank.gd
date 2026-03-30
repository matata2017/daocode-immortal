## QuestionBank.gd
## 题库管理器
## 负责加载、缓存和查询题目
extends RefCounted

class_name QuestionBank

# 信号
signal questions_loaded(count: int)
signal load_failed(error: String)

# 缓存
var _questions: Array[QuestionData] = []
var _questions_by_id: Dictionary = {}
var _loaded: bool = false

# 配置
var questions_path: String = "res://assets/data/questions/"


## 加载所有题目
func load_questions() -> bool:
	_questions.clear()
	_questions_by_id.clear()

	# 查找所有 JSON 文件
	var dir := DirAccess.open(questions_path)
	if not dir:
		push_error("QuestionBank: Cannot open directory %s" % questions_path)
		load_failed.emit("无法打开题库目录")
		return false

	var json_files: PackedStringArray = []
	if dir.list_dir_begin() == OK:
		var file_name := dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".json"):
				json_files.append(file_name)
			file_name = dir.get_next()
		dir.list_dir_end()

	if json_files.is_empty():
		push_warning("QuestionBank: No JSON files found in %s" % questions_path)
		# 尝试从单文件加载
		return _load_from_single_file("res://assets/data/questions.json")

	# 加载所有文件
	var total_loaded := 0
	for json_file: String in json_files:
		var file_path := questions_path + json_file
		var loaded := _load_questions_from_file(file_path)
		total_loaded += loaded

	_loaded = total_loaded > 0
	questions_loaded.emit(total_loaded)
	return _loaded


## 从单个文件加载
func _load_from_single_file(path: String) -> bool:
	var loaded := _load_questions_from_file(path)
	_loaded = loaded > 0
	if _loaded:
		questions_loaded.emit(loaded)
	else:
		load_failed.emit("无法加载题目文件")
	return _loaded


## 从文件加载题目
func _load_questions_from_file(path: String) -> int:
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("QuestionBank: Cannot open file %s" % path)
		return 0

	var json_text := file.get_as_text()
	var json := JSON.new()
	var parse_result := json.parse(json_text)

	if parse_result != OK:
		push_error("QuestionBank: JSON parse error in %s: %s" % [path, json.get_error_message()])
		return 0

	var data: Variant = json.data
	if data is Array:
		# 直接是题目数组
		return _import_questions(data)
	elif data is Dictionary and data.has("questions"):
		# 包含 questions 字段的对象
		return _import_questions(data["questions"])
	else:
		push_error("QuestionBank: Invalid JSON structure in %s" % path)
		return 0


## 导入题目数据
func _import_questions(data: Array) -> int:
	var imported := 0

	for item: Variant in data:
		if not item is Dictionary:
			continue

		var q := QuestionData.from_dict(item as Dictionary)
		if q.validate():
			_questions.append(q)
			_questions_by_id[q.id] = q
			imported += 1
		else:
			push_warning("QuestionBank: Skipped invalid question: %s" % q.id)

	return imported


## 获取题目数量
func get_count() -> int:
	return _questions.size()


## 是否已加载
func is_loaded() -> bool:
	return _loaded


## 按 ID 获取题目
func get_question_by_id(id: String) -> QuestionData:
	return _questions_by_id.get(id, null)


## 批量获取题目
func get_questions_by_ids(ids: Array[String]) -> Array[QuestionData]:
	var result: Array[QuestionData] = []
	for id: String in ids:
		var q: QuestionData = _questions_by_id.get(id)
		if q:
			result.append(q)
	return result


## 查询参数类
class QueryParams extends RefCounted:
	var topic: String = ""       # 知识点筛选
	var difficulty: int = -1     # 难度筛选 (-1 = 不筛选)
	var realm: String = ""       # 门派筛选
	var question_type: int = -1  # 题型筛选 (-1 = 不筛选)
	var limit: int = 10          # 返回数量
	var random: bool = false     # 随机排序
	var exclude_ids: Array[String] = []  # 排除的 ID


## 多条件查询
func query_questions(params: QueryParams) -> Array[QuestionData]:
	var result: Array[QuestionData] = []

	for q: QuestionData in _questions:
		# 排除指定 ID
		if q.id in params.exclude_ids:
			continue

		# 知识点筛选
		if not params.topic.is_empty() and q.topic != params.topic:
			continue

		# 难度筛选
		if params.difficulty >= 0 and q.difficulty != params.difficulty:
			continue

		# 门派筛选
		if not params.realm.is_empty() and q.realm != params.realm:
			continue

		# 题型筛选
		if params.question_type >= 0 and q.question_type != params.question_type:
			continue

		result.append(q)

	# 排序
	if params.random:
		result.shuffle()

	# 限制数量
	if result.size() > params.limit:
		result = result.slice(0, params.limit)

	return result


## 获取所有知识点
func get_all_topics(realm: String = "") -> Array[String]:
	var topics: Array[String] = []
	for q: QuestionData in _questions:
		if not realm.is_empty() and q.realm != realm:
			continue
		if not q.topic.is_empty() and q.topic not in topics:
			topics.append(q.topic)
	return topics


## 获取所有门派
func get_all_realms() -> Array[String]:
	var realms: Array[String] = []
	for q: QuestionData in _questions:
		if q.realm not in realms:
			realms.append(q.realm)
	return realms


## 统计各难度题目数量
func get_difficulty_stats(realm: String = "") -> Dictionary:
	var stats := {
		"easy": 0,
		"medium": 0,
		"hard": 0
	}

	for q: QuestionData in _questions:
		if not realm.is_empty() and q.realm != realm:
			continue

		match q.difficulty:
			QuestionData.Difficulty.EASY:
				stats["easy"] += 1
			QuestionData.Difficulty.MEDIUM:
				stats["medium"] += 1
			QuestionData.Difficulty.HARD:
				stats["hard"] += 1

	return stats


## 按难度获取随机题目
func get_random_by_difficulty(difficulty: QuestionData.Difficulty, limit: int = 10) -> Array[QuestionData]:
	var params := QueryParams.new()
	params.difficulty = difficulty
	params.limit = limit
	params.random = true
	return query_questions(params)


## 获取指定知识点的题目
func get_by_topic(topic: String, limit: int = 10) -> Array[QuestionData]:
	var params := QueryParams.new()
	params.topic = topic
	params.limit = limit
	return query_questions(params)