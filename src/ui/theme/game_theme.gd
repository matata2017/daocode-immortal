## 游戏主题资源
## 定义 Godot Theme 资源，包含所有 UI 组件的默认样式
@tool
class_name GameTheme
extends Theme

# ============================================
# 信号（Signals）
# ============================================
signal theme_changed

# ============================================
# 常量（Constants）
# ============================================
const THEME_NAME_DEFAULT := "default"
const THEME_NAME_DARK := "dark"
const THEME_NAME_LIGHT := "light"
const THEME_NAME_IMMERSIVE := "immersive"

# ============================================
# 配置引用（Configuration References）
# ============================================
var colors: RefCounted = UIColors.new()
var typography: RefCounted = UITypography.new()
var spacing: RefCounted = UISpacing.new()

# ============================================
# 主题状态（Theme State）
# ============================================
var current_theme_name: String = THEME_NAME_DEFAULT
var colorblind_mode_enabled: bool = false
var high_contrast_enabled: bool = false
var reduced_motion_enabled: bool = false

# ============================================
# 初始化（Initialization）
# ============================================

func _init() -> void:
	# 设置基础字体
	var primary_font = UITypography.load_font("primary")
	if primary_font:
		set_font("primary", "", primary_font)

	var display_font = UITypography.load_font("display")
	if display_font:
		set_font("display", "", display_font)

	var mono_font = UITypography.load_font("monospace")
	if mono_font:
		set_font("mono", "", mono_font)

	# 设置基础字体大小
	set_font_size("font_size", "", UITypography.SIZE_BODY)

	# 初始化所有组件样式
	_initialize_button_styles()
	_initialize_label_styles()
	_initialize_panel_styles()
	_initialize_line_edit_styles()
	_initialize_progress_bar_styles()
	_initialize_slider_styles()
	_initialize_scrollbar_styles()

# ============================================
# 按钮样式（Button Styles）
# ============================================

func _initialize_button_styles() -> void:
	# 正常状态
	var btn_normal := UISpacing.create_stylebox_with_shadow(
		UIColors.PRIMARY_DEFAULT,
		UISpacing.RADIUS_BUTTON,
		Color(0, 0, 0, 0.3),
		UISpacing.SHADOW_OFFSET_MD,
		UISpacing.SHADOW_BLUR_SM
	)
	btn_normal.set_content_margin_all(UISpacing.PADDING_BUTTON)
	btn_normal.set_content_margin_vertical(UISpacing.PADDING_BUTTON_VERTICAL)

	# 悬停状态
	var btn_hover := btn_normal.duplicate()
	btn_hover.bg_color = UIColors.PRIMARY_LIGHT

	# 按下状态
	var btn_pressed := btn_normal.duplicate()
	btn_pressed.bg_color = UIColors.PRIMARY_DARK
	btn_pressed.shadow_offset = Vector2(0, 1)

	# 禁用状态
	var btn_disabled := btn_normal.duplicate()
	btn_disabled.bg_color = UIColors.with_alpha(UIColors.PRIMARY_DEFAULT, 0.5)

	# 焦点状态
	var btn_focus := UISpacing.create_stylebox(
		Color.TRANSPARENT,
		UISpacing.RADIUS_BUTTON,
		UIColors.PRIMARY_LIGHT,
		UISpacing.BORDER_FOCUS,
		UISpacing.PADDING_BUTTON
	)

	set_stylebox("normal", "Button", btn_normal)
	set_stylebox("hover", "Button", btn_hover)
	set_stylebox("pressed", "Button", btn_pressed)
	set_stylebox("disabled", "Button", btn_disabled)
	set_stylebox("focus", "Button", btn_focus)

	# 按钮字体颜色
	set_color("font_color", "Button", UIColors.BG_PRIMARY)
	set_color("font_hover_color", "Button", UIColors.BG_PRIMARY)
	set_color("font_pressed_color", "Button", UIColors.BG_PRIMARY)
	set_color("font_disabled_color", "Button", UIColors.TEXT_DISABLED)
	set_color("font_focus_color", "Button", UIColors.BG_PRIMARY)

	# 按钮字体大小
	set_font_size("font_size", "Button", UITypography.SIZE_BUTTON)

# ============================================
# 标签样式（Label Styles）
# ============================================

func _initialize_label_styles() -> void:
	# 默认标签颜色
	set_color("font_color", "Label", UIColors.TEXT_PRIMARY)
	set_color("font_shadow_color", "Label", Color(0, 0, 0, 0.5))
	set_color("font_outline_color", "Label", Color.BLACK)

	# 默认字体大小
	set_font_size("font_size", "Label", UITypography.SIZE_BODY)

	# 标题样式
	for i in range(1, 7):
		var heading_size := UITypography.get_heading_size(i)
		set_font_size("font_size", "Heading%d" % i, heading_size)

	set_color("font_color", "Heading", UIColors.PRIMARY_DEFAULT)

	# 链接样式
	set_color("font_color", "Link", UIColors.TEXT_LINK)
	set_color("font_hover_color", "Link", UIColors.PRIMARY_LIGHT)

	# 说明文字样式
	set_font_size("font_size", "Caption", UITypography.SIZE_CAPTION)
	set_color("font_color", "Caption", UIColors.TEXT_SECONDARY)

# ============================================
# 面板样式（Panel Styles）
# ============================================

func _initialize_panel_styles() -> void:
	# 默认面板
	var panel_normal := UISpacing.create_stylebox(
		UIColors.BG_CARD,
		UISpacing.RADIUS_PANEL,
		UIColors.BORDER_DEFAULT,
		UISpacing.BORDER_THIN,
		UISpacing.PADDING_PANEL
	)
	set_stylebox("panel", "Panel", panel_normal)

	# 透明面板
	var panel_transparent := StyleBoxEmpty.new()
	set_stylebox("panel_transparent", "Panel", panel_transparent)

	# 卡片面板
	var card_panel := UISpacing.create_stylebox_with_shadow(
		UIColors.BG_CARD,
		UISpacing.RADIUS_CARD,
		Color(0, 0, 0, 0.4),
		UISpacing.SHADOW_OFFSET_LG,
		UISpacing.SHADOW_BLUR_MD
	)
	card_panel.set_content_margin_all(UISpacing.PADDING_CARD)
	set_stylebox("card", "Panel", card_panel)

	# 弹窗面板
	var dialog_panel := UISpacing.create_stylebox_with_shadow(
		UIColors.BG_SECONDARY,
		UISpacing.RADIUS_DIALOG,
		Color(0, 0, 0, 0.5),
		Vector2(0, 12),
		UISpacing.SHADOW_BLUR_XL
	)
	dialog_panel.set_content_margin_all(UISpacing.PADDING_DIALOG)
	dialog_panel.set_border_width_all(UISpacing.BORDER_THIN)
	dialog_panel.border_color = UIColors.BORDER_DEFAULT
	set_stylebox("dialog", "Panel", dialog_panel)

# ============================================
# 输入框样式（LineEdit Styles）
# ============================================

func _initialize_line_edit_styles() -> void:
	# 正常状态
	var input_normal := UISpacing.create_stylebox(
		UIColors.BG_SECONDARY,
		UISpacing.RADIUS_INPUT,
		UIColors.BORDER_DEFAULT,
		UISpacing.BORDER_THIN,
		UISpacing.PADDING_INPUT
	)

	# 焦点状态
	var input_focus := input_normal.duplicate()
	input_focus.border_color = UIColors.BORDER_FOCUS
	input_focus.set_border_width_all(UISpacing.BORDER_FOCUS)

	# 禁用状态
	var input_disabled := input_normal.duplicate()
	input_disabled.bg_color = UIColors.with_alpha(UIColors.BG_SECONDARY, 0.5)

	# 只读状态
	var input_readonly := input_normal.duplicate()
	input_readonly.bg_color = UIColors.with_alpha(UIColors.BG_CARD, 0.8)

	set_stylebox("normal", "LineEdit", input_normal)
	set_stylebox("focus", "LineEdit", input_focus)
	set_stylebox("disabled", "LineEdit", input_disabled)
	set_stylebox("read_only", "LineEdit", input_readonly)

	# 字体颜色
	set_color("font_color", "LineEdit", UIColors.TEXT_PRIMARY)
	set_color("font_placeholder_color", "LineEdit", UIColors.TEXT_HINT)
	set_color("font_readonly_color", "LineEdit", UIColors.TEXT_SECONDARY)
	set_color("font_selected_color", "LineEdit", UIColors.BG_PRIMARY)
	set_color("font_uneditable_color", "LineEdit", UIColors.TEXT_DISABLED)

	# 光标颜色
	set_color("caret_color", "LineEdit", UIColors.PRIMARY_DEFAULT)

	# 选中背景色
	set_color("selection_color", "LineEdit", UIColors.PRIMARY_DEFAULT)

	# 清除按钮颜色
	set_color("clear_button_color", "LineEdit", UIColors.TEXT_SECONDARY)

	# 字体大小
	set_font_size("font_size", "LineEdit", UITypography.SIZE_BODY)

	# 最小高度
	set_constant("minimum_height", "LineEdit", UISpacing.INPUT_HEIGHT_MD)

# ============================================
# 进度条样式（ProgressBar Styles）
# ============================================

func _initialize_progress_bar_styles() -> void:
	# 背景
	var progress_bg := UISpacing.create_stylebox(
		UIColors.BG_SECONDARY,
		UISpacing.RADIUS_MD,
		UIColors.BORDER_DEFAULT,
		UISpacing.BORDER_THIN,
		0
	)

	# 填充
	var progress_fill := UISpacing.create_stylebox(
		UIColors.PRIMARY_DEFAULT,
		UISpacing.RADIUS_MD,
		Color.TRANSPARENT,
		UISpacing.BORDER_NONE,
		0
	)

	set_stylebox("background", "ProgressBar", progress_bg)
	set_stylebox("fill", "ProgressBar", progress_fill)

	# 字体颜色
	set_color("font_color", "ProgressBar", UIColors.TEXT_PRIMARY)
	set_color("font_outline_color", "ProgressBar", Color.BLACK)

	# 字体大小
	set_font_size("font_size", "ProgressBar", UITypography.SIZE_CAPTION)

# ============================================
# 滑块样式（Slider Styles）
# ============================================

func _initialize_slider_styles() -> void:
	# 滑块轨道
	var slider_bg := UISpacing.create_stylebox(
		UIColors.BG_SECONDARY,
		UISpacing.RADIUS_SM,
		Color.TRANSPARENT,
		UISpacing.BORDER_NONE,
		0
	)

	# 滑块填充
	var slider_fill := UISpacing.create_stylebox(
		UIColors.PRIMARY_DEFAULT,
		UISpacing.RADIUS_SM,
		Color.TRANSPARENT,
		UISpacing.BORDER_NONE,
		0
	)

	# 滑块把手
	var slider_grabber := UISpacing.create_stylebox(
		UIColors.PRIMARY_LIGHT,
		UISpacing.RADIUS_FULL,
		Color.TRANSPARENT,
		UISpacing.BORDER_NONE,
		0
	)

	var slider_grabber_highlight := slider_grabber.duplicate()
	slider_grabber_highlight.bg_color = UIColors.PRIMARY_DEFAULT

	set_stylebox("slider", "HSlider", slider_bg)
	set_stylebox("grabber_area", "HSlider", slider_fill)
	set_stylebox("grabber_area_highlight", "HSlider", slider_fill)
	set_stylebox("grabber", "HSlider", slider_grabber)
	set_stylebox("grabber_highlight", "HSlider", slider_grabber_highlight)
	set_stylebox("grabber_disabled", "HSlider", slider_grabber)

	# 垂直滑块
	set_stylebox("slider", "VSlider", slider_bg)
	set_stylebox("grabber_area", "VSlider", slider_fill)
	set_stylebox("grabber_area_highlight", "VSlider", slider_fill)
	set_stylebox("grabber", "VSlider", slider_grabber)
	set_stylebox("grabber_highlight", "VSlider", slider_grabber_highlight)
	set_stylebox("grabber_disabled", "VSlider", slider_grabber)

# ============================================
# 滚动条样式（ScrollBar Styles）
# ============================================

func _initialize_scrollbar_styles() -> void:
	# 滚动条背景
	var scroll_bg := StyleBoxEmpty.new()

	# 滚动条滑块
	var scroll_grabber := UISpacing.create_stylebox(
		UIColors.with_alpha(UIColors.TEXT_SECONDARY, 0.5),
		UISpacing.RADIUS_FULL,
		Color.TRANSPARENT,
		UISpacing.BORDER_NONE,
		0
	)

	var scroll_grabber_highlight := scroll_grabber.duplicate()
	scroll_grabber_highlight.bg_color = UIColors.with_alpha(UIColors.TEXT_PRIMARY, 0.7)

	var scroll_grabber_pressed := scroll_grabber.duplicate()
	scroll_grabber_pressed.bg_color = UIColors.PRIMARY_DEFAULT

	# 水平滚动条
	set_stylebox("scroll", "HScrollBar", scroll_bg)
	set_stylebox("grabber", "HScrollBar", scroll_grabber)
	set_stylebox("grabber_highlight", "HScrollBar", scroll_grabber_highlight)
	set_stylebox("grabber_pressed", "HScrollBar", scroll_grabber_pressed)

	# 垂直滚动条
	set_stylebox("scroll", "VScrollBar", scroll_bg)
	set_stylebox("grabber", "VScrollBar", scroll_grabber)
	set_stylebox("grabber_highlight", "VScrollBar", scroll_grabber_highlight)
	set_stylebox("grabber_pressed", "VScrollBar", scroll_grabber_pressed)

# ============================================
# 主题切换方法（Theme Switching）
# ============================================

## 切换到指定主题
func switch_theme(theme_name: String) -> void:
	if theme_name == current_theme_name:
		return

	current_theme_name = theme_name

	match theme_name:
		THEME_NAME_LIGHT:
			_apply_light_theme()
		THEME_NAME_IMMERSIVE:
			_apply_immersive_theme()
		_:
			_apply_default_theme()

	theme_changed.emit()

## 应用默认主题
func _apply_default_theme() -> void:
	# 重新初始化所有样式
	_initialize_button_styles()
	_initialize_label_styles()
	_initialize_panel_styles()
	_initialize_line_edit_styles()
	_initialize_progress_bar_styles()

## 应用浅色主题
func _apply_light_theme() -> void:
	# TODO: 实现浅色主题
	_apply_default_theme()

## 应用沉浸式主题
func _apply_immersive_theme() -> void:
	# TODO: 实现沉浸式主题（更暗的背景，更强的对比）
	_apply_default_theme()

## 启用/禁用色盲模式
func set_colorblind_mode(enabled: bool) -> void:
	colorblind_mode_enabled = enabled
	_apply_colorblind_mode()
	theme_changed.emit()

## 应用色盲模式
func _apply_colorblind_mode() -> void:
	if not colorblind_mode_enabled:
		return

	# 替换关键颜色为色盲友好色
	# 这需要重新创建所有 StyleBox
	pass

## 启用/禁用高对比度模式
func set_high_contrast(enabled: bool) -> void:
	high_contrast_enabled = enabled
	_apply_high_contrast()
	theme_changed.emit()

## 应用高对比度
func _apply_high_contrast() -> void:
	if not high_contrast_enabled:
		return
	# 增加颜色对比度
	pass

## 启用/禁用减少动画模式
func set_reduced_motion(enabled: bool) -> void:
	reduced_motion_enabled = enabled
	theme_changed.emit()
