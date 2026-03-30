## FactionData.gd
## 门派数据类
## 定义编程门派的信息和绝学领域
extends Resource

class_name FactionData

# 门派ID枚举
enum FactionId {
	JAVA,    # Java派
	GO,      # Go派
	CPP,     # C++派 (DLC)
	PYTHON,  # Python派 (DLC)
	RUST,    # Rust派 (DLC)
}

# 基础信息
@export var id: FactionId = FactionId.JAVA
@export var name: String = ""
@export var full_name: String = ""
@export var tagline: String = ""           # 口号
@export_multiline var lore: String = ""    # 背景故事

# 显示配置
@export var theme_color: Color = Color.WHITE
@export var icon_path: String = ""
@export var banner_path: String = ""

# 解锁条件
@export var unlock_realm: int = 0          # 解锁所需境界
@export var is_dlc: bool = false           # 是否是DLC


## 绝学领域
class SkillDomain extends Resource:
	@export var id: String = ""
	@export var name: String = ""
	@export var description: String = ""
	@export var icon_path: String = ""
	@export var topic_ids: Array[String] = []
	@export var question_count: int = 0

	## 从字典创建
	static func from_dict(data: Dictionary) -> SkillDomain:
		var domain := SkillDomain.new()
		domain.id = data.get("id", "")
		domain.name = data.get("name", "")
		domain.description = data.get("description", "")
		domain.icon_path = data.get("icon_path", "")
		domain.topic_ids = data.get("topic_ids", [])
		domain.question_count = data.get("question_count", 0)
		return domain


@export var skill_domains: Array[SkillDomain] = []


## 从字典创建
static func from_dict(data: Dictionary) -> FactionData:
	var f := FactionData.new()
	f.id = data.get("id", 0)
	f.name = data.get("name", "")
	f.full_name = data.get("full_name", "")
	f.tagline = data.get("tagline", "")
	f.lore = data.get("lore", "")

	# 解析颜色
	var color_hex: String = data.get("theme_color", "#FFFFFF")
	f.theme_color = Color(color_hex)

	f.icon_path = data.get("icon_path", "")
	f.banner_path = data.get("banner_path", "")
	f.unlock_realm = data.get("unlock_realm", 0)
	f.is_dlc = data.get("is_dlc", false)

	# 解析绝学领域
	if data.has("skill_domains"):
		for domain_data: Variant in data["skill_domains"]:
			if domain_data is Dictionary:
				f.skill_domains.append(SkillDomain.from_dict(domain_data as Dictionary))

	return f


## 获取门派索引
func get_index() -> int:
	return id


## 是否已解锁
func is_unlocked(player_realm: int) -> bool:
	return player_realm >= unlock_realm and not is_dlc


## 获取题目总数
func get_total_questions() -> int:
	var total := 0
	for domain: SkillDomain in skill_domains:
		total += domain.question_count
	return total