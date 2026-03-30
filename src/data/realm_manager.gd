## RealmManager.gd
## 境界管理器
## 加载和管理所有境界数据
extends RefCounted

class_name RealmManager

# 境界列表 (按索引排序)
var _realms: Array[RealmData] = []
var _realms_by_id: Dictionary = {}
var _loaded: bool = false

# 配置
var realms_path: String = "res://assets/data/realms.json"


## 加载境界数据
func load_realms() -> bool:
	_realms.clear()
	_realms_by_id.clear()

	var file := FileAccess.open(realms_path, FileAccess.READ)
	if not file:
		push_error("RealmManager: Cannot open file %s" % realms_path)
		# 使用默认配置
		return _load_defaults()

	var json_text := file.get_as_text()
	var json := JSON.new()
	var parse_result := json.parse(json_text)

	if parse_result != OK:
		push_error("RealmManager: JSON parse error: %s" % json.get_error_message())
		return _load_defaults()

	var data: Variant = json.data
	if data is Dictionary and data.has("realms"):
		data = data["realms"]

	if not data is Array:
		push_error("RealmManager: Invalid JSON structure")
		return _load_defaults()

	for item: Variant in data:
		if item is Dictionary:
			var realm := RealmData.from_dict(item as Dictionary)
			_realms.append(realm)
			_realms_by_id[realm.id] = realm

	_loaded = _realms.size() > 0

	# 验证数据
	_validate_realms()

	return _loaded


## 加载默认配置
func _load_defaults() -> bool:
	# 定义默认境界
	var default_realms := [
		{
			"id": 0, "name": "凡人", "title": "凡人",
			"description": "汝乃凡人，当勤勉修炼，方可踏入仙途。",
			"required_cultivation": 0,
			"unlocked_difficulties": ["easy"],
			"theme_color": "#B0BEC5",
			"real_world_level": "入门级"
		},
		{
			"id": 1, "name": "炼气", "title": "炼气期弟子",
			"description": "初踏仙途，吸收天地灵气，感悟编程之道。",
			"required_cultivation": 100,
			"unlocked_difficulties": ["easy", "medium"],
			"breakthrough_trial": {"question_count": 5, "difficulty": "easy", "required_correct": 3, "fail_penalty_percent": 5},
			"theme_color": "#90CAF9",
			"real_world_level": "初级工程师"
		},
		{
			"id": 2, "name": "筑基", "title": "筑基期修士",
			"description": "奠定修炼根基，筑基之期已到。",
			"required_cultivation": 500,
			"unlocked_difficulties": ["easy", "medium", "hard"],
			"breakthrough_trial": {"question_count": 8, "difficulty": "medium", "required_correct": 5, "fail_penalty_percent": 10},
			"theme_color": "#A5D6A7",
			"real_world_level": "中级工程师"
		},
		{
			"id": 3, "name": "金丹", "title": "金丹期真人",
			"description": "凝聚金丹，脱胎换骨，已是大能。",
			"required_cultivation": 1500,
			"breakthrough_trial": {"question_count": 10, "difficulty": "medium", "required_correct": 8, "time_limit_seconds": 900, "fail_penalty_percent": 10},
			"theme_color": "#FFD54F",
			"real_world_level": "高级工程师"
		},
		{
			"id": 4, "name": "元婴", "title": "元婴期老祖",
			"description": "元婴出窍，神游太虚，智慧通天。",
			"required_cultivation": 4000,
			"breakthrough_trial": {"question_count": 8, "difficulty": "hard", "required_correct": 6, "time_limit_seconds": 1200, "fail_penalty_percent": 15},
			"theme_color": "#FF8A65",
			"real_world_level": "资深工程师"
		},
		{
			"id": 5, "name": "化神", "title": "化神期尊者",
			"description": "化神分身，千变万化，已近大道。",
			"required_cultivation": 10000,
			"breakthrough_trial": {"question_count": 12, "difficulty": "hard", "required_correct": 10, "time_limit_seconds": 1800, "fail_penalty_percent": 15},
			"theme_color": "#CE93D8",
			"real_world_level": "架构师/专家"
		},
		{
			"id": 6, "name": "飞升", "title": "飞升仙人",
			"description": "白日飞升，得道成仙，Offer在手！",
			"required_cultivation": 999999,
			"theme_color": "#FFD700",
			"real_world_level": "拿到Offer"
		}
	]

	for item: Dictionary in default_realms:
		var realm := RealmData.from_dict(item)
		_realms.append(realm)
		_realms_by_id[realm.id] = realm

	_loaded = true
	return true


## 验证境界数据
func _validate_realms() -> bool:
	var last_cultivation := -1
	for i: int in _realms.size():
		var realm: RealmData = _realms[i]

		# 检查ID连续性
		if realm.id != i:
			push_warning("RealmManager: Realm ID mismatch at index %d" % i)

		# 检查修为阈值递增
		if realm.required_cultivation <= last_cultivation:
			push_error("RealmManager: Realm cultivation not increasing at %s" % realm.name)
			return false
		last_cultivation = realm.required_cultivation

	return true


## 获取境界数量
func get_count() -> int:
	return _realms.size()


## 是否已加载
func is_loaded() -> bool:
	return _loaded


## 按索引获取境界
func get_realm(index: int) -> RealmData:
	if index >= 0 and index < _realms.size():
		return _realms[index]
	return null


## 按ID获取境界
func get_realm_by_id(id: RealmData.RealmId) -> RealmData:
	return _realms_by_id.get(id, null)


## 获取所有境界
func get_all_realms() -> Array[RealmData]:
	return _realms


## 获取突破所需修为
func get_required_cultivation(realm_index: int) -> int:
	var realm: RealmData = get_realm(realm_index)
	if realm:
		return realm.required_cultivation
	return 0


## 检查是否可以突破
func can_breakthrough(current_realm: int, current_cultivation: int) -> bool:
	# 已是最高境界
	if current_realm >= _realms.size() - 1:
		return false

	var next_realm: RealmData = get_realm(current_realm + 1)
	if not next_realm:
		return false

	return current_cultivation >= next_realm.required_cultivation


## 根据修为获取对应境界索引
func get_realm_by_cultivation(cultivation: int) -> int:
	for i: int in range(_realms.size() - 1, -1, -1):
		if cultivation >= _realms[i].required_cultivation:
			return i
	return 0


## 计算境界进度百分比 (0.0 - 1.0)
func get_realm_progress(current_realm: int, current_cultivation: int) -> float:
	# 最高境界
	if current_realm >= _realms.size() - 1:
		return 1.0

	var current_threshold: int = _realms[current_realm].required_cultivation
	var next_threshold: int = _realms[current_realm + 1].required_cultivation

	var progress: float = float(current_cultivation - current_threshold) / float(next_threshold - current_threshold)
	return clamp(progress, 0.0, 1.0)


## 获取到下一境界所需修为
func get_cultivation_to_next(current_realm: int, current_cultivation: int) -> int:
	if current_realm >= _realms.size() - 1:
		return 0

	var next_threshold: int = _realms[current_realm + 1].required_cultivation
	return max(0, next_threshold - current_cultivation)


## 获取突破试炼配置
func get_breakthrough_trial(target_realm: int) -> RealmData.TrialConfig:
	if target_realm <= 0 or target_realm >= _realms.size():
		return null

	var realm: RealmData = _realms[target_realm]
	return realm.breakthrough_trial


## 获取解锁的难度
func get_unlocked_difficulties(realm_index: int) -> Array[String]:
	var realm: RealmData = get_realm(realm_index)
	if realm:
		return realm.unlocked_difficulties
	return ["easy"]