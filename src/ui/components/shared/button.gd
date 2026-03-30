## 自定义按钮组件
## 提供统一的按钮样式、动画和交互效果
@tool
class_name UIButton
extends Button

# ============================================
# 信号（Signals）
# ============================================
## 按钮点击时发出（带防抖）
signal button_clicked(button: UIButton)
## 长按触发时发出
signal long_pressed(button: UIButton)
## 焦点状态变化时发出
signal focus_changed(has_focus: bool)

# ============================================
# 导出属性（Export Properties）
# ============================================

## 按钮样式类型
enum ButtonStyle {
	PRIMARY,    ## 主要按钮 - 金色背景
	SECONDARY,  ## 次要按钮 - 紫色背景
	SUCCESS,    ## 成功按钮 - 绿色背景
	WARNING,    ## 警告按钮 - 橙色背景
	DANGER,     ## 危险按钮 - 红色背景
	GHOST,      ## 幽灵按钮 - 透明背景
	LINK        ## 链接按钮 - 无背景
}

## 按钮尺寸
enum ButtonSize {
	SMALL,   ## 小尺寸
	MEDIUM,  ## 中等尺寸（默认）
	LARGE    ## 大尺寸
}

@export var style: ButtonStyle = ButtonStyle.PRIMARY:
	set(value):
		if style != value:
			style = value
			_update_button_style()

@export var size: ButtonSize = ButtonSize.MEDIUM:
	set(value):
		if size != value:
			size = value
			_update_button_size()

@export var icon_position: Side = SIDE_LEFT:
	set(value):
		if icon_position != value:
			icon_position = value
			_update_layout()

## 是否禁用点击动画
@export var disable_click_animation: bool = false

## 长按触发时间（秒）
@export_range(0.3, 2.0, 0.1) var long_press_duration: float = 0.5

## 是否启用长按
@export var enable_long_press: bool = false

## 点击音效
@export var click_sound: String = "ui_click"

## 悬停音效
@export var hover_sound: String = "ui_hover"

# ============================================
# 内部变量（Internal Variables）
# ============================================
var _is_pressed: bool = false
var _is_hovered: bool = false
var _long_press_timer: float = 0.0
var _is_long_pressing: bool = false
var _click_cooldown: float = 0.0
var _tween: Tween
var _original_scale: Vector2 = Vector2.ONE
var _original_position: Vector2 = Vector2.ZERO

# 样式缓存
var _style_normal: StyleBoxFlat
var _style_hover: StyleBoxFlat
var _style_pressed: StyleBoxFlat
var _style_disabled: StyleBoxFlat
var _style_focus: StyleBoxFlat

# ============================================
# 生命周期（Lifecycle）
# ============================================

func _ready() -> void:
	# 初始化
	_original_scale = scale

	# 设置初始样式
	_update_button_style()
	_update_button_size()

	# 连接信号
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)

	# 主题变更
	if ThemeManager:
		ThemeManager.theme_changed.connect(_on_theme_changed)

func _exit_tree() -> void:
	# 清理
	if _tween:
		_tween.kill()
		_tween = null

func _process(delta: float) -> void:
	# 处理长按计时器
	if _is_long_pressing and enable_long_press:
		_long_press_timer += delta
		if _long_press_timer >= long_press_duration:
			_on_long_press_triggered()

	# 处理点击冷却
	if _click_cooldown > 0:
		_click_cooldown -= delta

func _input(event: InputEvent) -> void:
	# 处理键盘/手柄导航
	if event is InputEventKey or event is InputEventJoypadButton:
		if has_focus() and event.is_action_pressed("ui_accept"):
			_on_button_down()
			await get_tree().process_frame
			_on_button_up()

# ============================================
# 样式更新（Style Updates）
# ============================================

## 更新按钮样式
func _update_button_style() -> void:
	if not is_inside_tree():
		return

	# 获取颜色
	var colors := _get_style_colors()

	# 创建样式
	_style_normal = _create_stylebox(colors.normal)
	_style_hover = _create_stylebox(colors.hover)
	_style_pressed = _create_stylebox(colors.pressed)
	_style_disabled = _create_stylebox(colors.disabled)
	_style_focus = _create_stylebox(Color.TRANSPARENT, true)

	# 应用样式
	add_theme_stylebox_override("normal", _style_normal)
	add_theme_stylebox_override("hover", _style_hover)
	add_theme_stylebox_override("pressed", _style_pressed)
	add_theme_stylebox_override("disabled", _style_disabled)
	add_theme_stylebox_override("focus", _style_focus)

	# 设置字体颜色
	var font_color := colors.text
	add_theme_color_override("font_color", font_color)
	add_theme_color_override("font_hover_color", font_color)
	add_theme_color_override("font_pressed_color", font_color)
	add_theme_color_override("font_disabled_color", UIColors.TEXT_DISABLED)
	add_theme_color_override("font_focus_color", font_color)

## 获取样式颜色
func _get_style_colors() -> Dictionary:
	var bg_color: Color
	var bg_hover: Color
	var bg_pressed: Color
	var text_color: Color = UIColors.BG_PRIMARY

	match style:
		ButtonStyle.PRIMARY:
			bg_color = UIColors.PRIMARY_DEFAULT
			bg_hover = UIColors.PRIMARY_LIGHT
			bg_pressed = UIColors.PRIMARY_DARK
		ButtonStyle.SECONDARY:
			bg_color = UIColors.SECONDARY_DEFAULT
			bg_hover = UIColors.SECONDARY_LIGHT
			bg_pressed = UIColors.SECONDARY_DARK
		ButtonStyle.SUCCESS:
			bg_color = UIColors.SUCCESS
			bg_hover = _lighten_color(UIColors.SUCCESS, 0.15)
			bg_pressed = _darken_color(UIColors.SUCCESS, 0.15)
		ButtonStyle.WARNING:
			bg_color = UIColors.WARNING
			bg_hover = _lighten_color(UIColors.WARNING, 0.15)
			bg_pressed = _darken_color(UIColors.WARNING, 0.15)
		ButtonStyle.DANGER:
			bg_color = UIColors.ERROR
			bg_hover = _lighten_color(UIColors.ERROR, 0.15)
			bg_pressed = _darken_color(UIColors.ERROR, 0.15)
		ButtonStyle.GHOST:
			bg_color = Color.TRANSPARENT
			bg_hover = UIColors.with_alpha(UIColors.PRIMARY_DEFAULT, 0.1)
			bg_pressed = UIColors.with_alpha(UIColors.PRIMARY_DEFAULT, 0.2)
			text_color = UIColors.PRIMARY_DEFAULT
		ButtonStyle.LINK:
			bg_color = Color.TRANSPARENT
			bg_hover = Color.TRANSPARENT
			bg_pressed = Color.TRANSPARENT
			text_color = UIColors.TEXT_LINK

	return {
		normal = bg_color,
		hover = bg_hover,
		pressed = bg_pressed,
		disabled = UIColors.with_alpha(bg_color, 0.5),
		text = text_color
	}

## 创建样式盒
func _create_stylebox(bg_color: Color, is_focus: bool = false) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.set_corner_radius_all(UISpacing.RADIUS_BUTTON)
	style.set_content_margin_horizontal(UISpacing.PADDING_BUTTON)
	style.set_content_margin_vertical(UISpacing.PADDING_BUTTON_VERTICAL)

	# 边框
	if style == ButtonStyle.GHOST or style == ButtonStyle.LINK:
		style.set_border_width_all(UISpacing.BORDER_THIN)
		style.border_color = UIColors.with_alpha(UIColors.PRIMARY_DEFAULT, 0.5) if style == ButtonStyle.GHOST else Color.TRANSPARENT

	# 焦点边框
	if is_focus:
		style.set_border_width_all(UISpacing.BORDER_FOCUS)
		style.border_color = UIColors.PRIMARY_LIGHT

	# 阴影（非幽灵/链接按钮）
	if bg_color.a > 0 and not is_focus:
		style.shadow_color = Color(0, 0, 0, 0.3)
		style.shadow_offset = UISpacing.SHADOW_OFFSET_MD
		style.shadow_size = UISpacing.SHADOW_BLUR_SM

	return style

## 更新按钮尺寸
func _update_button_size() -> void:
	var height: int
	var font_size: int

	match size:
		ButtonSize.SMALL:
			height = UISpacing.BUTTON_HEIGHT_SM
			font_size = UITypography.SIZE_BODY_SMALL
		ButtonSize.LARGE:
			height = UISpacing.BUTTON_HEIGHT_LG
			font_size = UITypography.SIZE_BODY_LARGE
		_:  # ButtonSize.MEDIUM
			height = UISpacing.BUTTON_HEIGHT_MD
			font_size = UITypography.SIZE_BUTTON

	# 设置最小尺寸
	custom_minimum_size.y = height
	add_theme_font_size_override("font_size", font_size)

## 更新布局
func _update_layout() -> void:
	# 根据图标位置更新对齐方式
	match icon_position:
		SIDE_LEFT:
			alignment = HORIZONTAL_ALIGNMENT_CENTER
		SIDE_RIGHT:
			alignment = HORIZONTAL_ALIGNMENT_CENTER
		SIDE_TOP:
			alignment = HORIZONTAL_ALIGNMENT_CENTER
		SIDE_BOTTOM:
			alignment = HORIZONTAL_ALIGNMENT_CENTER

# ============================================
# 动画（Animation）
# ============================================

## 播放点击动画
func _play_click_animation() -> void:
	if disable_click_animation or ThemeManager.should_skip_animation():
		return

	# 停止之前的动画
	if _tween:
		_tween.kill()

	# 创建缩放动画
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_BACK)

	# 缩小 -> 恢复
	_tween.tween_property(self, "scale", _original_scale * 0.95, 0.05)
	_tween.tween_property(self, "scale", _original_scale, 0.15)

## 播放悬停动画
func _play_hover_animation(is_entering: bool) -> void:
	if ThemeManager.should_skip_animation():
		return

	# 停止之前的动画
	if _tween:
		_tween.kill()

	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_CUBIC)

	if is_entering:
		_tween.tween_property(self, "scale", _original_scale * 1.02, 0.15)
	else:
		_tween.tween_property(self, "scale", _original_scale, 0.15)

## 播放禁用动画
func _play_disabled_animation(is_disabled: bool) -> void:
	if ThemeManager.should_skip_animation():
		modulate.a = 0.5 if is_disabled else 1.0
		return

	if _tween:
		_tween.kill()

	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 0.5 if is_disabled else 1.0, 0.2)

# ============================================
# 事件处理（Event Handling）
# ============================================

func _on_button_down() -> void:
	_is_pressed = true
	_is_long_pressing = enable_long_press
	_long_press_timer = 0.0

	# 播放点击音效
	_play_sound(click_sound)

func _on_button_up() -> void:
	if not _is_pressed:
		return

	_is_pressed = false
	_is_long_pressing = false

	# 播放动画
	_play_click_animation()

	# 触发点击（带防抖）
	if _click_cooldown <= 0:
		_click_cooldown = 0.1  # 100ms 冷却
		button_clicked.emit(self)

func _on_long_press_triggered() -> void:
	_is_long_pressing = false
	_is_pressed = false
	long_pressed.emit(self)
	_play_sound("ui_long_press")

func _on_mouse_entered() -> void:
	_is_hovered = true
	_play_hover_animation(true)
	_play_sound(hover_sound)

func _on_mouse_exited() -> void:
	_is_hovered = false
	_play_hover_animation(false)

func _on_focus_entered() -> void:
	focus_changed.emit(true)

func _on_focus_exited() -> void:
	focus_changed.emit(false)

func _on_theme_changed(_theme_name: String) -> void:
	_update_button_style()

# ============================================
# 公共方法（Public Methods）
# ============================================

## 设置按钮文本
func set_button_text(text: String) -> void:
	self.text = text

## 设置按钮图标
func set_button_icon(icon_texture: Texture2D) -> void:
	icon = icon_texture
	_update_layout()

## 设置加载状态
func set_loading(is_loading: bool) -> void:
	disabled = is_loading
	_play_disabled_animation(is_loading)

	# TODO: 添加加载动画图标

## 模拟点击
func simulate_click() -> void:
	_on_button_down()
	await get_tree().create_timer(0.05).timeout
	_on_button_up()

## 播放音效
func _play_sound(sound_id: String) -> void:
	# 通过 AudioManager 播放音效
	# AudioManager.play_ui_sound(sound_id)
	pass

# ============================================
# 工具方法（Utility Methods）
# ============================================

func _lighten_color(color: Color, amount: float) -> Color:
	return color.lerp(Color.WHITE, amount)

func _darken_color(color: Color, amount: float) -> Color:
	return color.lerp(Color.BLACK, amount)

## 重写禁用属性
func set_disabled(value: bool) -> void:
	super.set_disabled(value)
	_play_disabled_animation(value)