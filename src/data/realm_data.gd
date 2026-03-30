## RealmData.gd
## 境界数据类
## 定义修仙境界的信息和突破配置
extends Resource

class_name RealmData

# 境界ID枚举
enum RealmId {
	MORTAL,       # 凡人
	QI_REFINING,  # 炼气
	FOUNDATION,   # 筑基
	GOLDEN_CORE,  # 金丹
	NASCENT_SOUL, # 元婴
	SPIRIT_SEVER, # 化神
	ASCENSION     # 飞升
}

# 基础信息
@export var id: RealmId = RealmId.MORTAL
@export var name: String = ""
@export var title: String = ""           # 称号
@export_multiline var description: String = ""

# 修为要求
@export var required_cultivation: int = 0

# 解锁内容
@export var unlocked_difficulties: Array[String] = []  # 可访问的难度
@export var unlocked_bosses: Array[String] = []        # 解锁的BOSS

# 显示配置
@export var theme_color: Color = Color.WHITE
@export var icon_path: String = ""

# 现实对应
@export var real_world_level: String = ""


## 突破试炼配置
class TrialConfig extends Resource:
	@export var question_count: int = 5
	@export var difficulty: String = "easy"        # easy/medium/hard
	@export var required_correct: int = 3
	@export var time_limit_seconds: int = 0        # 0 = 无限制
	@export var fail_penalty_percent: float = 10.0

	## 从字典创建
	static func from_dict(data: Dictionary) -> TrialConfig:
		var config := TrialConfig.new()
		config.question_count = data.get("question_count", 5)
		config.difficulty = data.get("difficulty", "easy")
		config.required_correct = data.get("required_correct", 3)
		config.time_limit_seconds = data.get("time_limit_seconds", 0)
		config.fail_penalty_percent = data.get("fail_penalty_percent", 10.0)
		return config


@export var breakthrough_trial: TrialConfig


## 获取境界索引
func get_index() -> int:
	return id


## 是否是最终境界
func is_final_realm() -> bool:
	return id == RealmId.ASCENSION


## 从字典创建
static func from_dict(data: Dictionary) -> RealmData:
	var r := RealmData.new()
	r.id = data.get("id", 0)
	r.name = data.get("name", "")
	r.title = data.get("title", "")
	r.description = data.get("description", "")
	r.required_cultivation = data.get("required_cultivation", 0)
	r.unlocked_difficulties = data.get("unlocked_difficulties", [])
	r.unlocked_bosses = data.get("unlocked_bosses", [])
	r.real_world_level = data.get("real_world_level", "")

	# 解析颜色
	var color_hex: String = data.get("theme_color", "#FFFFFF")
	r.theme_color = Color(color_hex)

	r.icon_path = data.get("icon_path", "")

	# 解析突破试炼
	if data.has("breakthrough_trial"):
		r.breakthrough_trial = TrialConfig.from_dict(data["breakthrough_trial"])

	return r