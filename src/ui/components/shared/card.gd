## 卡片容器组件
## 提供统一的卡片样式、阴影、悬停效果和点击交互
@tool
class_name UICard
extends PanelContainer

# ============================================
# 信号（Signals）
# ============================================
## 卡片被点击时发出
signal card_clicked(card: UICard)
## 卡片被双击时发出
signal card_double_clicked(card: UICard)
## 卡片悬停状态变化时发出
signal card_hover_changed(is_hovered: bool)
## 卡片选中状态变化时发出
signal card_selected_changed(is_selected: bool)

# ============================================
# 导出属性（Export Properties）
# ============================================

## 卡片样式
enum CardStyle {
	ELEVATED,   ## 浮起样式 - 带阴影
	OUTLINED,   ## 描边样式 - 无阴影
	FILLED,     ## 填充样式 - 无边框
	TRANSPARENT ## 透明样式
}

## 卡片尺寸预设
enum CardSize {
	SMALL,   ## 小卡片
	MEDIUM,  ## 中等卡片
	LARGE,   ## 大卡片
	CUSTOM   ## 自定义尺寸
}

@export var card_style: CardStyle = CardStyle.ELEVATED:
	set(value):
		if card_style != value:
			card_style = value
			_update_style()

@export var card_size: CardSize = CardSize.MEDIUM:
	set(value):
		if card_size != value:
			card_size = value
			_update_size()

## 是否可交互（悬停和点击效果）
@export var interactive: bool = true:
	set(value):
		if interactive != value:
			interactive = value
			_update_style()

## 是否可选中
@export var selectable: bool = false

## 是否选中
@export var is_selected: bool = false:
	set(value):
		if is_selected != value:
			is_selected = value
			_update_style()
			card_selected_changed.emit(value)

## 选中时的高亮颜色
@export var selected_color: Color = UIColors.PRIMARY_DEFAULT:
	set(value):
		if selected_color != value:
			selected_color = value
			_update_style()

## 悬停时是否抬起
@export var hover_elevation: bool = true

## 点击时是否缩放
@export var click_scale: bool = true

## 自定义背景颜色（覆盖主题颜色）
@export var custom_bg_color: Color = Color.TRANSPARENT:
	set(value):
		if custom_bg_color != value:
			custom_bg_color = value
			_update_style()

## 自定义边框颜色
@export var custom_border_color: Color = Color.TRANSPARENT:
	set(value):
		if custom_border_color != value:
			custom_border_color = value
			_update_style()

## 圆角半径（-1 表示使用主题默认）
@export var custom_corner_radius: int = -1:
	set(value):
		if custom_corner_radius != value:
			custom_corner_radius = value
			_update_style()

## 内边距（-1 表示使用主题默认）
@export var custom_padding: int = -1:
	set(value):
		if custom_padding != value:
			custom_padding = value
			_update_style()

# ============================================
# 内部变量（Internal Variables）
# ============================================
var _is_hovered: bool = false
var _is_pressed: bool = false
var _tween: Tween
var _original_position: Vector2 = Vector2.ZERO
var _click_count: int = 0
var _click_timer: float = 0.0
var _double_click_threshold: float = 0.3

# 尺寸预设
const SIZE_SMALL := Vector2(200, 100)
const SIZE_MEDIUM := Vector2(300, 150)
const SIZE_LARGE := Vector2(400, 200)

# ============================================
# 生命周期（Lifecycle）
# ============================================

func _ready() -> void:
	# 初始化样式
	_update_style()
	_update_size()

	# 连接输入事件
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	# 主题变更
	if ThemeManager:
		ThemeManager.theme_changed.connect(_on_theme_changed)

func _exit_tree() -> void:
	if _tween:
		_tween.kill()

func _process(delta: float) -> void:
	# 处理双击计时
	if _click_count > 0:
		_click_timer += delta
		if _click_timer > _double_click_threshold:
			_click_count = 0
			_click_timer = 0.0

# ============================================
# 样式更新（Style Updates）
# ============================================

## 更新卡片样式
func _update_style() -> void:
	var style := StyleBoxFlat.new()

	# 设置背景颜色
	var bg_color := _get_background_color()
	style.bg_color = bg_color

	# 设置圆角
	var radius := _get_corner_radius()
	style.set_corner_radius_all(radius)

	# 设置内边距
	var padding := _get_padding()
	style.set_content_margin_all(padding)

	# 设置边框
	match card_style:
		CardStyle.OUTLINED:
			style.set_border_width_all(UISpacing.BORDER_THIN)
			style.border_color = _get_border_color()
		CardStyle.ELEVATED:
			style.set_border_width_all(UISpacing.BORDER_NONE)
			# 添加阴影
			style.shadow_color = Color(0, 0, 0, 0.3)
			style.shadow_offset = UISpacing.SHADOW_OFFSET_LG
			style.shadow_size = UISpacing.SHADOW_BLUR_MD
		CardStyle.FILLED, CardStyle.TRANSPARENT:
			style.set_border_width_all(UISpacing.BORDER_NONE)

	# 选中状态
	if is_selected:
		style.set_border_width_all(UISpacing.BORDER_FOCUS)
		style.border_color = selected_color

	# 应用样式
	add_theme_stylebox_override("panel", style)

	# 设置鼠标光标
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if interactive else Control.CURSOR_ARROW

## 获取背景颜色
func _get_background_color() -> Color:
	var base_color: Color

	if custom_bg_color != Color.TRANSPARENT:
		base_color = custom_bg_color
	else:
		match card_style:
			CardStyle.ELEVATED:
				base_color = UIColors.BG_CARD
			CardStyle.OUTLINED:
				base_color = UIColors.BG_CARD
			CardStyle.FILLED:
				base_color = UIColors.BG_SECONDARY
			CardStyle.TRANSPARENT:
				base_color = Color.TRANSPARENT

	# 悬停状态
	if interactive and _is_hovered:
		base_color = base_color.lerp(Color.WHITE, 0.05)

	# 按下状态
	if _is_pressed:
		base_color = base_color.lerp(Color.WHITE, 0.1)

	return base_color

## 获取边框颜色
func _get_border_color() -> Color:
	if custom_border_color != Color.TRANSPARENT:
		return custom_border_color
	return UIColors.BORDER_DEFAULT

## 获取圆角半径
func _get_corner_radius() -> int:
	if custom_corner_radius >= 0:
		return custom_corner_radius
	return UISpacing.RADIUS_CARD

## 获取内边距
func _get_padding() -> int:
	if custom_padding >= 0:
		return custom_padding
	return UISpacing.PADDING_CARD

## 更新卡片尺寸
func _update_size() -> void:
	if card_size == CardSize.CUSTOM:
		return

	var target_size: Vector2
	match card_size:
		CardSize.SMALL:
			target_size = SIZE_SMALL
		CardSize.MEDIUM:
			target_size = SIZE_MEDIUM
		CardSize.LARGE:
			target_size = SIZE_LARGE

	custom_minimum_size = target_size

# ============================================
# 动画（Animation）
# ============================================

## 播放悬停动画
func _play_hover_animation(is_entering: bool) -> void:
	if not interactive or not hover_elevation:
		return

	if ThemeManager.should_skip_animation():
		return

	if _tween:
		_tween.kill()

	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_CUBIC)

	if is_entering:
		# 抬起效果
		_tween.tween_property(self, "position:y", _original_position.y - 4, 0.15)
		_tween.parallel().tween_property(self, "modulate", Color(1, 1, 1, 1), 0.15)
	else:
		# 恢复
		_tween.tween_property(self, "position:y", _original_position.y, 0.15)

## 播放点击动画
func _play_click_animation() -> void:
	if not interactive or not click_scale:
		return

	if ThemeManager.should_skip_animation():
		return

	if _tween:
		_tween.kill()

	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_BACK)

	# 缩小 -> 恢复
	_tween.tween_property(self, "scale", Vector2(0.98, 0.98), 0.05)
	_tween.tween_property(self, "scale", Vector2.ONE, 0.15)

## 播放选中动画
func _play_selected_animation() -> void:
	if ThemeManager.should_skip_animation():
		return

	if _tween:
		_tween.kill()

	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_CUBIC)

	# 边框闪烁效果
	_tween.tween_property(self, "modulate", Color(1.1, 1.1, 1.1, 1), 0.1)
	_tween.tween_property(self, "modulate", Color.ONE, 0.15)

# ============================================
# 事件处理（Event Handling）
# ============================================

func _on_gui_input(event: InputEvent) -> void:
	if not interactive:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_is_pressed = true
				_original_position = position
			else:
				if _is_pressed:
					_is_pressed = false
					_handle_click()

	elif event is InputEventKey:
		if event.keycode == KEY_ENTER or event.keycode == KEY_SPACE:
			if event.pressed:
				_is_pressed = true
			else:
				if _is_pressed:
					_is_pressed = false
					_handle_click()

func _handle_click() -> void:
	_click_count += 1
	_click_timer = 0.0

	if _click_count >= 2:
		# 双击
		_click_count = 0
		_play_click_animation()
		card_double_clicked.emit(self)
		_play_sound("ui_double_click")
	else:
		# 单击
		_play_click_animation()
		card_clicked.emit(self)
		_play_sound("ui_click")

	# 处理选中
	if selectable:
		is_selected = not is_selected
		_play_selected_animation()

func _on_mouse_entered() -> void:
	_is_hovered = true
	_original_position = position
	_play_hover_animation(true)
	card_hover_changed.emit(true)
	_play_sound("ui_hover")

func _on_mouse_exited() -> void:
	_is_hovered = false
	_play_hover_animation(false)
	card_hover_changed.emit(false)

func _on_theme_changed(_theme_name: String) -> void:
	_update_style()

# ============================================
# 公共方法（Public Methods）
# ============================================

## 设置选中状态
func set_selected(selected: bool) -> void:
	is_selected = selected

## 切换选中状态
func toggle_selected() -> void:
	is_selected = not is_selected

## 设置内容
func set_content(content_node: Control) -> void:
	# 清除现有内容
	for child in get_children():
		child.queue_free()

	# 添加新内容
	add_child(content_node)

## 设置标题和内容
func set_title_and_content(title: String, content: Control) -> void:
	var container := VBoxContainer.new()
	container.add_theme_constant_override("separation", UISpacing.SPACE_SM)

	# 标题
	var title_label := Label.new()
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", UITypography.SIZE_H4)
	title_label.add_theme_color_override("font_color", UIColors.TEXT_PRIMARY)
	container.add_child(title_label)

	# 分隔
	var separator := HSeparator.new()
	separator.add_theme_stylebox_override("separator", StyleBoxEmpty.new())
	container.add_child(separator)

	# 内容
	container.add_child(content)

	set_content(container)

## 设置可交互性
func set_interactive(enabled: bool) -> void:
	interactive = enabled

## 设置卡片样式
func set_card_style(new_style: CardStyle) -> void:
	card_style = new_style

## 设置尺寸预设
func set_card_size(new_size: CardSize) -> void:
	card_size = new_size

## 设置自定义背景颜色
func set_custom_background(color: Color) -> void:
	custom_bg_color = color

## 设置自定义圆角
func set_custom_corner(radius: int) -> void:
	custom_corner_radius = radius

## 设置自定义内边距
func set_custom_padding(padding: int) -> void:
	custom_padding = padding

## 播放音效
func _play_sound(sound_id: String) -> void:
	# 通过 AudioManager 播放音效
	# AudioManager.play_ui_sound(sound_id)
	pass

## 模拟点击
func simulate_click() -> void:
	_handle_click()

# ============================================
# 静态工厂方法（Static Factory Methods）
# ============================================

## 创建简单的文本卡片
static func create_text_card(title: String, description: String = "") -> UICard:
	var card := UICard.new()
	card.card_style = CardStyle.ELEVATED

	var container := VBoxContainer.new()
	container.add_theme_constant_override("separation", UISpacing.SPACE_SM)

	var title_label := Label.new()
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", UITypography.SIZE_H5)
	title_label.add_theme_color_override("font_color", UIColors.TEXT_PRIMARY)
	container.add_child(title_label)

	if not description.is_empty():
		var desc_label := Label.new()
		desc_label.text = description
		desc_label.add_theme_font_size_override("font_size", UITypography.SIZE_BODY_SMALL)
		desc_label.add_theme_color_override("font_color", UIColors.TEXT_SECONDARY)
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		container.add_child(desc_label)

	card.add_child(container)
	return card