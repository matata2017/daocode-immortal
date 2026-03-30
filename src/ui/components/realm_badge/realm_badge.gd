## 境界徽章组件
## 显示玩家当前境界，包含等级图标、境界名称和进度条
@tool
class_name RealmBadge
extends HBoxContainer

# ============================================
# 信号（Signals）
# ============================================
## 点击徽章时发出
signal badge_clicked()

# ============================================
# 导出属性（Export Properties）
# ============================================

## 境界数据
@export var realm_id: String = "mortal":
	set(value):
		if realm_id != value:
			realm_id = value
			_update_display()

## 境界名称（可覆盖自动获取的名称）
@export var realm_name: String = "":
	set(value):
		if realm_name != value:
			realm_name = value
			_update_display()

## 当前等级（1-10）
@export_range(1, 10, 1) var realm_level: int = 1:
	set(value):
		realm_level = clamp(value, 1, 10)
		_update_display()

## 修为进度（0-100）
@export_range(0, 100, 0.1) var progress_percent: float = 0.0:
	set(value):
		progress_percent = clamp(value, 0, 100)
		_update_progress()

## 境界图标（可自定义）
@export var custom_icon: Texture2D:
	set(value):
		custom_icon = value
		_update_icon()

## 是否显示进度条
@export var show_progress: bool = true:
	set(value):
		if show_progress != value:
			show_progress = value
			if _progress_bar:
				_progress_bar.visible = value

## 是否显示等级
@export var show_level: bool = true:
	set(value):
		if show_level != value:
			show_level = value
			if _level_label:
				_level_label.visible = value

## 徽章尺寸
enum BadgeSize {
	SMALL,   ## 小尺寸（紧凑）
	MEDIUM,  ## 中等尺寸（默认）
	LARGE    ## 大尺寸（详情页）
}

@export var badge_size: BadgeSize = BadgeSize.MEDIUM:
	set(value):
		if badge_size != value:
			badge_size = value
			_update_layout()

## 是否可点击
@export var clickable: bool = false:
	set(value):
		clickable = value
		if _icon_button:
			_icon_button.disabled = not value

# ============================================
# 内部变量（Internal Variables）
# ============================================
var _icon_button: TextureButton
var _level_label: Label
var _name_label: Label
var _progress_bar: UIProgressBar
var _info_container: VBoxContainer

# 境界数据映射
const REALM_DATA := {
	"mortal": {"name": "凡人", "color": UIColors.REALM_MORTAL, "icon": "res://assets/icons/realm_mortal.png"},
	"qi_refining": {"name": "炼气", "color": UIColors.REALM_QI_REFINING, "icon": "res://assets/icons/realm_qi_refining.png"},
	"foundation": {"name": "筑基", "color": UIColors.REALM_FOUNDATION, "icon": "res://assets/icons/realm_foundation.png"},
	"golden_core": {"name": "金丹", "color": UIColors.REALM_GOLDEN_CORE, "icon": "res://assets/icons/realm_golden_core.png"},
	"nascent_soul": {"name": "元婴", "color": UIColors.REALM_NASCENT_SOUL, "icon": "res://assets/icons/realm_nascent_soul.png"},
	"spirit_severing": {"name": "化神", "color": UIColors.REALM_SPIRIT_SEVERING, "icon": "res://assets/icons/realm_spirit_severing.png"},
	"void_refining": {"name": "炼虚", "color": UIColors.REALM_VOID_REFINING, "icon": "res://assets/icons/realm_void_refining.png"},
	"body_fusion": {"name": "合体", "color": UIColors.REALM_BODY_FUSION, "icon": "res://assets/icons/realm_body_fusion.png"},
	"mahayana": {"name": "大乘", "color": UIColors.REALM_MAHAYANA, "icon": "res://assets/icons/realm_mahayana.png"},
	"tribulation": {"name": "渡劫", "color": UIColors.REALM_TRIBULATION, "icon": "res://assets/icons/realm_tribulation.png"}
}

# ============================================
# 生命周期（Lifecycle）
# ============================================

func _ready() -> void:
	# 创建子节点
	_create_components()

	# 初始化显示
	_update_layout()
	_update_display()
	_update_progress()

	# 连接信号
	if _icon_button:
		_icon_button.pressed.connect(_on_icon_pressed)

func _create_components() -> void:
	# 图标按钮
	_icon_button = TextureButton.new()
	_icon_button.name = "RealmIcon"
	_icon_button.expand_mode = TextureButton.EXPAND_FIT_WIDTH_PROPORTIONAL
	_icon_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	add_child(_icon_button)

	# 信息容器
	_info_container = VBoxContainer.new()
	_info_container.name = "InfoContainer"
	add_child(_info_container)

	# 等级标签
	_level_label = Label.new()
	_level_label.name = "LevelLabel"
	_level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_info_container.add_child(_level_label)

	# 名称标签
	_name_label = Label.new()
	_name_label.name = "RealmName"
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_info_container.add_child(_name_label)

	# 进度条
	_progress_bar = UIProgressBar.new()
	_progress_bar.name = "Progress"
	_progress_bar.show_label = false
	_progress_bar.custom_minimum_size.y = 4
	_progress_bar.corner_radius = 2
	_progress_bar.border_width = 0
	_info_container.add_child(_progress_bar)

# ============================================
# 更新方法（Update Methods）
# ============================================

## 更新布局
func _update_layout() -> void:
	var icon_size: int
	var font_size_level: int
	var font_size_name: int
	var spacing: int

	match badge_size:
		BadgeSize.SMALL:
			icon_size = 24
			font_size_level = UITypography.SIZE_CAPTION
			font_size_name = UITypography.SIZE_BODY_SMALL
			spacing = UISpacing.SPACE_SM
		BadgeSize.LARGE:
			icon_size = 48
			font_size_level = UITypography.SIZE_H5
			font_size_name = UITypography.SIZE_H4
			spacing = UISpacing.SPACE_MD
		_:  # BadgeSize.MEDIUM
			icon_size = 32
			font_size_level = UITypography.SIZE_LABEL
			font_size_name = UITypography.SIZE_BODY
			spacing = UISpacing.SPACE_SM

	# 更新图标尺寸
	if _icon_button:
		_icon_button.custom_minimum_size = Vector2(icon_size, icon_size)

	# 更新字体大小
	if _level_label:
		_level_label.add_theme_font_size_override("font_size", font_size_level)
		_level_label.visible = show_level

	if _name_label:
		_name_label.add_theme_font_size_override("font_size", font_size_name)

	# 更新间距
	add_theme_constant_override("separation", spacing)
	if _info_container:
		_info_container.add_theme_constant_override("separation", 2)

	# 更新进度条尺寸
	if _progress_bar:
		_progress_bar.visible = show_progress
		if badge_size == BadgeSize.LARGE:
			_progress_bar.custom_minimum_size.y = 6
		else:
			_progress_bar.custom_minimum_size.y = 4

## 更新显示
func _update_display() -> void:
	# 获取境界数据
	var data := _get_realm_data()

	# 更新名称
	if _name_label:
		var display_name := realm_name if realm_name != "" else data.name
		_name_label.text = display_name
		_name_label.add_theme_color_override("font_color", data.color)

	# 更新等级
	if _level_label:
		_level_label.text = "Lv.%d" % realm_level
		_level_label.add_theme_color_override("font_color", UIColors.TEXT_SECONDARY)

	# 更新图标
	_update_icon()

## 更新图标
func _update_icon() -> void:
	if not _icon_button:
		return

	var texture: Texture2D

	if custom_icon:
		texture = custom_icon
	else:
		var icon_path := _get_realm_icon_path()
		if ResourceLoader.exists(icon_path):
			texture = load(icon_path)

	_icon_button.texture_normal = texture
	_icon_button.texture_disabled = texture

	# 创建悬停和按下状态
	if texture:
		var hover_texture := _create_tinted_texture(texture, UIColors.PRIMARY_LIGHT)
		_icon_button.texture_hover = hover_texture
		_icon_button.texture_pressed = _create_tinted_texture(texture, UIColors.PRIMARY_DARK)

## 更新进度
func _update_progress() -> void:
	if not _progress_bar:
		return

	_progress_bar.value = progress_percent
	_progress_bar.fill_color = _get_realm_color()

## 获取境界数据
func _get_realm_data() -> Dictionary:
	var key := realm_id.to_lower()

	if REALM_DATA.has(key):
		return REALM_DATA[key]

	# 默认返回凡人
	return REALM_DATA["mortal"]

## 获取境界颜色
func _get_realm_color() -> Color:
	var data := _get_realm_data()
	return data.color

## 获取境界图标路径
func _get_realm_icon_path() -> String:
	var data := _get_realm_data()
	return data.icon

## 创建着色纹理
func _create_tinted_texture(source: Texture2D, tint_color: Color) -> Texture2D:
	# 使用着色方法创建变体
	# 注意：在 @tool 脚本中可能需要使用其他方法
	return source

# ============================================
# 事件处理（Event Handling）
# ============================================

func _on_icon_pressed() -> void:
	badge_clicked.emit()
	_play_sound("ui_click")

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if clickable:
				badge_clicked.emit()
				_play_sound("ui_click")

# ============================================
# 公共方法（Public Methods）
# ============================================

## 设置境界信息
func set_realm(new_realm_id: String, new_level: int = 1, progress: float = 0.0) -> void:
	realm_id = new_realm_id
	realm_level = new_level
	progress_percent = progress

## 设置进度百分比
func set_progress(percent: float, animate: bool = true) -> void:
	if animate and _progress_bar:
		_progress_bar.set_progress_percent(percent, true)
	else:
		progress_percent = percent

## 增加进度
func increase_progress(amount: float, animate: bool = true) -> void:
	set_progress(progress_percent + amount, animate)

## 设置等级
func set_level(level: int) -> void:
	realm_level = level

## 升级（境界等级提升）
func level_up() -> void:
	if realm_level < 10:
		realm_level += 1
		_play_level_up_animation()

## 境界突破（进入下一境界）
func realm_breakthrough(new_realm_id: String) -> void:
	realm_id = new_realm_id
	realm_level = 1
	progress_percent = 0.0
	_play_breakthrough_animation()

## 获取境界颜色
func get_current_realm_color() -> Color:
	return _get_realm_color()

## 获取境界名称
func get_current_realm_name() -> String:
	return realm_name if realm_name != "" else _get_realm_data().name

## 获取完整境界描述
func get_full_description() -> String:
	return "%s Lv.%d (%.1f%%)" % [get_current_realm_name(), realm_level, progress_percent]

## 播放升级动画
func _play_level_up_animation() -> void:
	if ThemeManager.should_skip_animation():
		return

	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)

	# 放大 -> 恢复
	tween.tween_property(_icon_button, "scale", Vector2(1.2, 1.2), 0.2)
	tween.tween_property(_icon_button, "scale", Vector2.ONE, 0.3)

	_play_sound("realm_level_up")

## 播放突破动画
func _play_breakthrough_animation() -> void:
	if ThemeManager.should_skip_animation():
		return

	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)

	# 弹跳效果
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.3)
	tween.tween_property(self, "scale", Vector2.ONE, 0.5)

	# 闪光效果
	var flash_tween := create_tween()
	flash_tween.tween_property(self, "modulate", Color(1.5, 1.5, 1.5, 1), 0.1)
	flash_tween.tween_property(self, "modulate", Color.ONE, 0.3)

	_play_sound("realm_breakthrough")

## 播放音效
func _play_sound(sound_id: String) -> void:
	# AudioManager.play_ui_sound(sound_id)
	pass

# ============================================
# 静态方法（Static Methods）
# ============================================

## 获取所有境界列表
static func get_all_realms() -> Array[String]:
	var realms: Array[String] = []
	for key in REALM_DATA.keys():
		realms.append(key)
	return realms

## 获取境界信息
static func get_realm_info(realm_key: String) -> Dictionary:
	if REALM_DATA.has(realm_key):
		return REALM_DATA[realm_key]
	return {}

## 比较境界高低
static func compare_realms(realm_a: String, realm_b: String) -> int:
	var realms := get_all_realms()
	var index_a := realms.find(realm_a)
	var index_b := realms.find(realm_b)

	if index_a < index_b:
		return -1  # a 低于 b
	elif index_a > index_b:
		return 1   # a 高于 b
	else:
		return 0   # 相同境界