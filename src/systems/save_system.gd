## SaveSystem.gd
## 存档系统 (AutoLoad)
## 单存档 + 实时自动保存
extends Node

# 信号
signal save_loaded(data: Dictionary)
signal save_failed(error: String)
signal data_changed(key: String, value: Variant)

# 存档版本
const SAVE_VERSION: int = 1
const SAVE_FILE_NAME: String = "save.json"

# 存档数据
var _data: Dictionary = {}
var _is_loaded: bool = false
var _save_pending: bool = false
var _auto_save_timer: Timer

# 配置
@export var auto_save_interval: float = 30.0  # 自动保存间隔(秒)
@export var debug_mode: bool = false


func _ready() -> void:
	# 创建自动保存计时器
	_auto_save_timer = Timer.new()
	_auto_save_timer.wait_time = auto_save_interval
	_auto_save_timer.autostart = true
	_auto_save_timer.timeout.connect(_on_auto_save_timeout)
	add_child(_auto_save_timer)

	# 加载存档
	load_save()


## 获取存档路径
func _get_save_path() -> String:
	return OS.get_user_data_dir() + "/" + SAVE_FILE_NAME


## 初始化默认存档
func _create_default_save() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"created_at": Time.get_datetime_string_from_system(),
		"last_played_at": Time.get_datetime_string_from_system(),

		# 玩家基础信息
		"faction_id": "java",  # 默认Java派
		"realm_id": 0,         # 凡人
		"cultivation": 0,

		# 答题记录
		"answered_questions": {},
		"total_correct": 0,
		"total_answered": 0,

		# 错题记录（心魔）
		"wrong_questions": {},

		# BOSS 挑战记录
		"boss_challenges": {},

		# 境界突破记录
		"realm_breakthroughs": {},

		# 门派进度
		"faction_mastery": {},

		# 用户设置
		"settings": {
			"volume_master": 1.0,
			"volume_bgm": 0.8,
			"volume_sfx": 1.0,
			"notifications_enabled": true,
			"auto_play_next": true,
		}
	}


## 加载存档
func load_save() -> bool:
	var path := _get_save_path()

	if not FileAccess.file_exists(path):
		# 创建新存档
		_data = _create_default_save()
		_is_loaded = true
		_schedule_save()
		save_loaded.emit(_data)
		if debug_mode:
			print("[SaveSystem] Created new save file")
		return true

	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("[SaveSystem] Cannot open save file")
		save_failed.emit("无法打开存档文件")
		return false

	var json_text := file.get_as_text()
	var json := JSON.new()
	var parse_result := json.parse(json_text)

	if parse_result != OK:
		push_error("[SaveSystem] JSON parse error: %s" % json.get_error_message())
		save_failed.emit("存档文件损坏")
		return false

	_data = json.data as Dictionary

	# 版本迁移
	if _data.get("version", 0) < SAVE_VERSION:
		_migrate_save(_data)

	# 更新最后游玩时间
	_data["last_played_at"] = Time.get_datetime_string_from_system()

	_is_loaded = true
	save_loaded.emit(_data)

	if debug_mode:
		print("[SaveSystem] Loaded save file: %d records" % _data.size())

	return true


## 存档版本迁移
func _migrate_save(data: Dictionary) -> void:
	var version: int = data.get("version", 0)

	# 未来版本迁移逻辑
	# if version < 2:
	#     data["new_field"] = default_value

	data["version"] = SAVE_VERSION
	print("[SaveSystem] Migrated save from version %d to %d" % [version, SAVE_VERSION])


## 保存存档
func save() -> bool:
	if not _is_loaded:
		push_warning("[SaveSystem] Cannot save - not loaded")
		return false

	var path := _get_save_path()
	var dir_path := path.get_base_dir()

	# 确保目录存在
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)

	# 更新保存时间
	_data["last_played_at"] = Time.get_datetime_string_from_system()

	var json_string := JSON.stringify(_data, "  ")
	var file := FileAccess.open(path, FileAccess.WRITE)

	if not file:
		push_error("[SaveSystem] Cannot write save file")
		return false

	file.store_string(json_string)
	file.close()
	_save_pending = false

	if debug_mode:
		print("[SaveSystem] Saved to %s" % path)

	return true


## 安排保存（延迟保存，避免频繁IO）
func _schedule_save() -> void:
	_save_pending = true


## 自动保存触发
func _on_auto_save_timeout() -> void:
	if _save_pending:
		save()


## 退出时保存
func _exit_tree() -> void:
	if _save_pending:
		save()


## 获取存档数据
func get_data(key: String, default: Variant = null) -> Variant:
	return _data.get(key, default)


## 设置存档数据
func set_data(key: String, value: Variant) -> void:
	_data[key] = value
	_schedule_save()
	data_changed.emit(key, value)


# ============================================
# 便捷访问方法
# ============================================

## 获取门派ID
func get_faction_id() -> String:
	return _data.get("faction_id", "java")


## 设置门派ID
func set_faction_id(faction_id: String) -> void:
	set_data("faction_id", faction_id)


## 获取境界ID
func get_realm_id() -> int:
	return _data.get("realm_id", 0)


## 设置境界ID
func set_realm_id(realm_id: int) -> void:
	set_data("realm_id", realm_id)


## 获取修为
func get_cultivation() -> int:
	return _data.get("cultivation", 0)


## 设置修为
func set_cultivation(value: int) -> void:
	set_data("cultivation", value)


## 增加修为
func add_cultivation(amount: int) -> void:
	var current := get_cultivation()
	set_cultivation(current + amount)


## 获取答题总数
func get_total_answered() -> int:
	return _data.get("total_answered", 0)


## 获取答对总数
func get_total_correct() -> int:
	return _data.get("total_correct", 0)


## 记录答题结果
func record_answer(question_id: String, correct: bool, score: int = 0) -> void:
	var answered: Dictionary = _data.get("answered_questions", {})
	answered[question_id] = {
		"correct": correct,
		"answered_at": Time.get_datetime_string_from_system(),
		"score": score
	}

	_data["answered_questions"] = answered
	_data["total_answered"] = get_total_answered() + 1

	if correct:
		_data["total_correct"] = get_total_correct() + 1
		add_cultivation(score)

	_schedule_save()


## 检查题目是否已答过
func has_answered(question_id: String) -> bool:
	var answered: Dictionary = _data.get("answered_questions", {})
	return answered.has(question_id)


## 获取答题记录
func get_answer_record(question_id: String) -> Dictionary:
	var answered: Dictionary = _data.get("answered_questions", {})
	return answered.get(question_id, {})


## 获取错题列表
func get_wrong_questions() -> Dictionary:
	return _data.get("wrong_questions", {})


## 添加错题
func add_wrong_question(question_id: String) -> void:
	var wrong: Dictionary = _data.get("wrong_questions", {})
	var record: Dictionary = wrong.get(question_id, {"wrong_count": 0, "last_wrong_at": ""})

	record["wrong_count"] = record.get("wrong_count", 0) + 1
	record["last_wrong_at"] = Time.get_datetime_string_from_system()

	wrong[question_id] = record
	_data["wrong_questions"] = wrong
	_schedule_save()


## 移除错题（祛除心魔）
func remove_wrong_question(question_id: String) -> void:
	var wrong: Dictionary = _data.get("wrong_questions", {})
	wrong.erase(question_id)
	_data["wrong_questions"] = wrong
	_schedule_save()


## 获取设置
func get_setting(key: String, default: Variant = null) -> Variant:
	var settings: Dictionary = _data.get("settings", {})
	return settings.get(key, default)


## 设置设置
func set_setting(key: String, value: Variant) -> void:
	var settings: Dictionary = _data.get("settings", {})
	settings[key] = value
	_data["settings"] = settings
	_schedule_save()
	data_changed.emit("settings." + key, value)


## 获取完整存档数据（调试用）
func get_full_save_data() -> Dictionary:
	return _data.duplicate(true)


## 重置存档
func reset_save() -> void:
	_data = _create_default_save()
	_schedule_save()
	save_loaded.emit(_data)

	if debug_mode:
		print("[SaveSystem] Save reset to default")