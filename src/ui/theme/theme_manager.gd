## 主题管理器
## 管理 UI 主题的加载、切换和持久化，作为 AutoLoad 单例使用
extends Node

# ============================================
# 信号（Signals）
# ============================================
## 主题变更时发出
signal theme_changed(theme_name: String)
## 色盲模式变更时发出
signal colorblind_mode_changed(enabled: bool)
## 高对比度模式变更时发出
signal high_contrast_changed(enabled: bool)
## 减少动画模式变更时发出
signal reduced_motion_changed(enabled: bool)
## 字体缩放变更时发出
signal font_scale_changed(scale: float)

# ============================================
# 常量（Constants）
# ============================================
const SETTINGS_FILE := "user://ui_settings.cfg"
const SETTINGS_SECTION := "ui"

# 字体缩放范围
const FONT_SCALE_MIN := 0.8
const FONT_SCALE_MAX := 1.5
const FONT_SCALE_DEFAULT := 1.0

# ============================================
# 配置（Configuration）
# ============================================
var _theme: GameTheme
var _settings: ConfigFile = ConfigFile.new()

# 当前状态
var _current_theme_name: String = GameTheme.THEME_NAME_DEFAULT
var _colorblind_mode: bool = false
var _high_contrast_mode: bool = false
var _reduced_motion: bool = false
var _font_scale: float = FONT_SCALE_DEFAULT

# ============================================
# 属性访问器（Property Accessors）
# ============================================

## 获取当前主题
var current_theme: GameTheme:
	get: return _theme

## 获取当前主题名称
var current_theme_name: String:
	get: return _current_theme_name

## 色盲模式是否启用
var is_colorblind_mode: bool:
	get: return _colorblind_mode

## 高对比度模式是否启用
var is_high_contrast_mode: bool:
	get: return _high_contrast_mode

## 减少动画模式是否启用
var is_reduced_motion: bool:
	get: return _reduced_motion

## 当前字体缩放
var current_font_scale: float:
	get: return _font_scale

# ============================================
# 生命周期（Lifecycle）
# ============================================

func _ready() -> void:
	# 加载设置
	_load_settings()

	# 初始化主题
	_initialize_theme()

	# 应用当前设置
	_apply_all_settings()

	# 监听系统无障碍设置变化
	_check_system_accessibility()

# ============================================
# 初始化（Initialization）
# ============================================

## 初始化主题资源
func _initialize_theme() -> void:
	_theme = GameTheme.new()
	_theme.switch_theme(_current_theme_name)
	_theme.set_colorblind_mode(_colorblind_mode)
	_theme.set_high_contrast(_high_contrast_mode)
	_theme.set_reduced_motion(_reduced_motion)

	# 连接主题内部信号
	_theme.theme_changed.connect(_on_theme_internal_changed)

## 应用所有设置
func _apply_all_settings() -> void:
	_apply_font_scale()
	_apply_theme_to_all_controls()

## 检查系统无障碍设置
func _check_system_accessibility() -> void:
	# 检查系统是否启用了减少动画
	if DisplayServer.has_feature(DisplayServer.FEATURE reduced_motion):
		# 注意：GDScript 中没有直接的 reduced_motion 特性检查
		# 这里使用操作系统设置（如果可用）
		pass

# ============================================
# 主题切换（Theme Switching）
# ============================================

## 切换主题
func switch_theme(theme_name: String) -> void:
	if theme_name == _current_theme_name:
		return

	_current_theme_name = theme_name
	_theme.switch_theme(theme_name)

	# 保存设置
	_save_settings()

	# 发出信号
	theme_changed.emit(theme_name)

## 获取可用主题列表
func get_available_themes() -> Array[Dictionary]:
	return [
		{
			"id": GameTheme.THEME_NAME_DEFAULT,
			"name": "默认主题",
			"description": "经典修仙风格，深邃紫黑背景"
		},
		{
			"id": GameTheme.THEME_NAME_DARK,
			"name": "深色主题",
			"description": "更深的背景，更强的对比度"
		},
		{
			"id": GameTheme.THEME_NAME_IMMERSIVE,
			"name": "沉浸主题",
			"description": "极简界面，专注修炼体验"
		}
	]

# ============================================
# 色盲模式（Colorblind Mode）
# ============================================

## 启用/禁用色盲模式
func set_colorblind_mode(enabled: bool) -> void:
	if enabled == _colorblind_mode:
		return

	_colorblind_mode = enabled
	_theme.set_colorblind_mode(enabled)

	# 保存设置
	_save_settings()

	# 发出信号
	colorblind_mode_changed.emit(enabled)

## 切换色盲模式
func toggle_colorblind_mode() -> void:
	set_colorblind_mode(not _colorblind_mode)

# ============================================
# 高对比度模式（High Contrast Mode）
# ============================================

## 启用/禁用高对比度模式
func set_high_contrast_mode(enabled: bool) -> void:
	if enabled == _high_contrast_mode:
		return

	_high_contrast_mode = enabled
	_theme.set_high_contrast(enabled)

	# 保存设置
	_save_settings()

	# 发出信号
	high_contrast_changed.emit(enabled)

## 切换高对比度模式
func toggle_high_contrast_mode() -> void:
	set_high_contrast_mode(not _high_contrast_mode)

# ============================================
# 减少动画模式（Reduced Motion）
# ============================================

## 启用/禁用减少动画模式
func set_reduced_motion(enabled: bool) -> void:
	if enabled == _reduced_motion:
		return

	_reduced_motion = enabled
	_theme.set_reduced_motion(enabled)

	# 保存设置
	_save_settings()

	# 发出信号
	reduced_motion_changed.emit(enabled)

## 切换减少动画模式
func toggle_reduced_motion() -> void:
	set_reduced_motion(not _reduced_motion)

# ============================================
# 字体缩放（Font Scale）
# ============================================

## 设置字体缩放
func set_font_scale(scale: float) -> void:
	# 限制范围
	scale = clamp(scale, FONT_SCALE_MIN, FONT_SCALE_MAX)

	if is_equal_approx(scale, _font_scale):
		return

	_font_scale = scale
	_apply_font_scale()

	# 保存设置
	_save_settings()

	# 发出信号
	font_scale_changed.emit(scale)

## 增加字体大小
func increase_font_scale(step: float = 0.1) -> void:
	set_font_scale(_font_scale + step)

## 减小字体大小
func decrease_font_scale(step: float = 0.1) -> void:
	set_font_scale(_font_scale - step)

## 重置字体大小
func reset_font_scale() -> void:
	set_font_scale(FONT_SCALE_DEFAULT)

## 应用字体缩放
func _apply_font_scale() -> void:
	# 更新主题中的字体大小
	# 注意：这会影响所有使用主题的控件
	if _theme:
		var base_sizes := [
			"font_size", UITypography.SIZE_BODY,
			"font_size_heading", UITypography.SIZE_H3,
			"font_size_caption", UITypography.SIZE_CAPTION,
			"font_size_button", UITypography.SIZE_BUTTON
		]

		for i in range(0, base_sizes.size(), 2):
			var key: String = base_sizes[i]
			var base_size: int = base_sizes[i + 1]
			var scaled_size := int(base_size * _font_scale)
			_theme.set_font_size(key, "", scaled_size)

# ============================================
# 主题应用（Theme Application）
# ============================================

## 将主题应用到指定控件及其子控件
func apply_theme_to_control(control: Control) -> void:
	if not control or not _theme:
		return

	control.theme = _theme

	# 递归应用到所有子控件
	for child in control.get_children():
		if child is Control:
			apply_theme_to_control(child)

## 将主题应用到场景中的所有控件
func _apply_theme_to_all_controls() -> void:
	var scene_tree := get_tree()
	if not scene_tree:
		return

	var root := scene_tree.root
	if root:
		apply_theme_to_control(root)

## 重新应用主题（用于动态创建的控件）
func refresh_theme() -> void:
	_apply_theme_to_all_controls()

# ============================================
# 设置持久化（Settings Persistence）
# ============================================

## 保存设置到文件
func _save_settings() -> void:
	_settings.set_value(SETTINGS_SECTION, "theme", _current_theme_name)
	_settings.set_value(SETTINGS_SECTION, "colorblind_mode", _colorblind_mode)
	_settings.set_value(SETTINGS_SECTION, "high_contrast_mode", _high_contrast_mode)
	_settings.set_value(SETTINGS_SECTION, "reduced_motion", _reduced_motion)
	_settings.set_value(SETTINGS_SECTION, "font_scale", _font_scale)

	var err := _settings.save(SETTINGS_FILE)
	if err != OK:
		push_warning("ThemeManager: 无法保存 UI 设置，错误码: %d" % err)

## 从文件加载设置
func _load_settings() -> void:
	var err := _settings.load(SETTINGS_FILE)
	if err != OK:
		# 文件不存在或加载失败，使用默认值
		return

	_current_theme_name = _settings.get_value(SETTINGS_SECTION, "theme", GameTheme.THEME_NAME_DEFAULT)
	_colorblind_mode = _settings.get_value(SETTINGS_SECTION, "colorblind_mode", false)
	_high_contrast_mode = _settings.get_value(SETTINGS_SECTION, "high_contrast_mode", false)
	_reduced_motion = _settings.get_value(SETTINGS_SECTION, "reduced_motion", false)
	_font_scale = _settings.get_value(SETTINGS_SECTION, "font_scale", FONT_SCALE_DEFAULT)

## 重置所有设置为默认值
func reset_all_settings() -> void:
	_current_theme_name = GameTheme.THEME_NAME_DEFAULT
	_colorblind_mode = false
	_high_contrast_mode = false
	_reduced_motion = false
	_font_scale = FONT_SCALE_DEFAULT

	_apply_all_settings()
	_save_settings()

# ============================================
# 工具方法（Utility Methods）
# ============================================

## 获取调整后的颜色（考虑色盲模式）
func get_adjusted_color(color: Color) -> Color:
	return UIColors.to_colorblind(color, _colorblind_mode)

## 获取境界颜色（考虑色盲模式）
func get_realm_color(realm_id: String) -> Color:
	var base_color := UIColors.get_realm_color(realm_id)
	return get_adjusted_color(base_color)

## 获取状态颜色（考虑色盲模式）
func get_status_color(status: String) -> Color:
	var base_color := UIColors.get_status_color(status)
	return get_adjusted_color(base_color)

## 检查是否应该跳过动画
func should_skip_animation() -> bool:
	return _reduced_motion

## 获取动画持续时间（考虑减少动画模式）
func get_animation_duration(base_duration: float) -> float:
	if _reduced_motion:
		return 0.0
	return base_duration

## 创建 LabelSettings（考虑字体缩放）
func create_label_settings(style: String = "body") -> LabelSettings:
	var settings: LabelSettings

	match style:
		"h1", "heading1":
			settings = UITypography.create_heading_settings(1)
		"h2", "heading2":
			settings = UITypography.create_heading_settings(2)
		"h3", "heading3":
			settings = UITypography.create_heading_settings(3)
		"caption":
			settings = UITypography.create_body_settings("small")
			settings.font_size = UITypography.SIZE_CAPTION
		"button":
			settings = UITypography.create_button_settings()
		_:
			settings = UITypography.create_body_settings()

	# 应用字体缩放
	if settings and not is_equal_approx(_font_scale, 1.0):
		settings.font_size = int(settings.font_size * _font_scale)

	return settings

# ============================================
# 信号回调（Signal Callbacks）
# ============================================

func _on_theme_internal_changed() -> void:
	# 主题内部变更时，重新应用到所有控件
	_apply_theme_to_all_controls()
