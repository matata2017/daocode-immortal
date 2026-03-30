## 底部导航栏组件
## 提供游戏主要导航功能，包含修炼、题库、境界、设置等入口
class_name BottomNavBar
extends HBoxContainer

# ============================================
# 信号（Signals）
# ============================================
## 导航项选中时发出
signal nav_item_selected(item_id: String)
## 当前页面变化时发出
signal current_page_changed(page_index: int)

# ============================================
# 常量（Constants）
# ============================================
const NAV_HEIGHT := 56
const NAV_ICON_SIZE := 24
const NAV_ITEM_SPACING := 0

# ============================================
# 导出属性（Export Properties）
# ============================================

## 当前选中的页面索引
@export_range(0, 4, 1) var current_page: int = 0:
	set(value):
		if current_page != value:
			current_page = value
			_update_selection()
			current_page_changed.emit(value)

## 是否显示标签
@export var show_labels: bool = true:
	set(value):
		if show_labels != value:
			show_labels = value
			_update_labels_visibility()

## 是否启用动画
@export var enable_animation: bool = true

## 自定义导航项（覆盖默认）
@export var custom_nav_items: Array[Dictionary] = []:
	set(value):
		custom_nav_items = value
		_rebuild_nav_items()

# ============================================
# 导航项定义（Navigation Items Definition）
# ============================================
const DEFAULT_NAV_ITEMS := [
	{
		"id": "cultivate",
		"label": "修炼",
		"icon": "res://assets/icons/nav_cultivate.png",
		"icon_selected": "res://assets/icons/nav_cultivate_selected.png"
	},
	{
		"id": "questions",
		"label": "题库",
		"icon": "res://assets/icons/nav_questions.png",
		"icon_selected": "res://assets/icons/nav_questions_selected.png"
	},
	{
		"id": "realm",
		"label": "境界",
		"icon": "res://assets/icons/nav_realm.png",
		"icon_selected": "res://assets/icons/nav_realm_selected.png"
	},
	{
		"id": "boss",
		"label": "面试",
		"icon": "res://assets/icons/nav_boss.png",
		"icon_selected": "res://assets/icons/nav_boss_selected.png"
	},
	{
		"id": "settings",
		"label": "设置",
		"icon": "res://assets/icons/nav_settings.png",
		"icon_selected": "res://assets/icons/nav_settings_selected.png"
	}
]

# ============================================
# 内部变量（Internal Variables）
# ============================================
var _nav_buttons: Array[Button] = []
var _nav_container: HBoxContainer
var _background: PanelContainer
var _indicator: Control
var _tween: Tween

# ============================================
# 生命周期（Lifecycle）
# ============================================

func _ready() -> void:
	# 创建背景
	_create_background()

	# 创建导航项
	_create_nav_items()

	# 创建指示器
	_create_indicator()

	# 初始化选中状态
	_update_selection()

	# 设置布局
	_setup_layout()

func _create_background() -> void:
	_background = PanelContainer.new()
	_background.name = "NavBarBackground"
	_background.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# 创建背景样式
	var style := StyleBoxFlat.new()
	style.bg_color = UIColors.BG_SECONDARY
	style.set_border_width_all(UISpacing.BORDER_THIN)
	style.border_color = UIColors.BORDER_DEFAULT
	style.set_corner_radius_all(0)  # 底部导航栏无圆角

	_background.add_theme_stylebox_override("panel", style)

func _create_nav_items() -> void:
	var items := custom_nav_items if custom_nav_items.size() > 0 else DEFAULT_NAV_ITEMS

	_nav_container = HBoxContainer.new()
	_nav_container.name = "NavItemsContainer"
	_nav_container.alignment = HBoxContainer.ALIGNMENT_CENTER
	_nav_container.add_theme_constant_override("separation", NAV_ITEM_SPACING)

	for i in range(items.size()):
		var item := items[i]
		var button := _create_nav_button(item, i)
		_nav_buttons.append(button)
		_nav_container.add_child(button)

	add_child(_nav_container)

func _create_nav_button(item: Dictionary, index: int) -> Button:
	var button := Button.new()
	button.name = "NavItem_%s" % item.id
	button.custom_minimum_size.y = NAV_HEIGHT

	# 设置图标
	var icon_path: String = item.icon
	if ResourceLoader.exists(icon_path):
		button.icon = load(icon_path)
		button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# 设置文本
	button.text = item.label if show_labels else ""
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER

	# 应用样式
	_apply_button_style(button, false)

	# 连接信号
	button.pressed.connect(_on_nav_button_pressed.bind(index))

	# 存储数据
	button.set_meta("nav_id", item.id)
	button.set_meta("nav_index", index)
	button.set_meta("icon_path", item.icon)
	button.set_meta("icon_selected_path", item.icon_selected)

	return button

func _create_indicator() -> void:
	# 创建选中指示器
	_indicator = Control.new()
	_indicator.name = "SelectionIndicator"
	_indicator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_indicator.custom_minimum_size.y = 3

	# 指示器样式（使用自定义绘制）
	_indicator.draw.connect(_draw_indicator)

	# 添加到背景
	_background.add_child(_indicator)

func _draw_indicator() -> void:
	if not _indicator:
		return

	var width := _indicator.get_parent().size.x / float(_nav_buttons.size())
	var x_pos := current_page * width

	# 绘制指示条
	var rect := Rect2(x_pos, 0, width, 3)
	var color := UIColors.PRIMARY_DEFAULT

	# 使用 StyleBoxFlat 绘制
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.draw(_indicator.get_canvas_item(), rect)

# ============================================
# 样式应用（Style Application）
# ============================================

func _apply_button_style(button: Button, is_selected: bool) -> void:
	# 创建样式
	var style_normal := StyleBoxFlat.new()
	style_normal.bg_color = Color.TRANSPARENT
	style_normal.set_content_margin_all(8)

	var style_hover := style_normal.duplicate()
	style_hover.bg_color = UIColors.with_alpha(UIColors.PRIMARY_DEFAULT, 0.1)

	var style_pressed := style_normal.duplicate()
	style_pressed.bg_color = UIColors.with_alpha(UIColors.PRIMARY_DEFAULT, 0.2)

	# 应用样式
	button.add_theme_stylebox_override("normal", style_normal)
	button.add_theme_stylebox_override("hover", style_hover)
	button.add_theme_stylebox_override("pressed", style_pressed)

	# 设置字体颜色
	var font_color := UIColors.TEXT_SECONDARY if not is_selected else UIColors.PRIMARY_DEFAULT
	button.add_theme_color_override("font_color", font_color)
	button.add_theme_color_override("font_hover_color", UIColors.PRIMARY_LIGHT)
	button.add_theme_color_override("font_pressed_color", UIColors.PRIMARY_DARK)

	# 设置字体大小
	button.add_theme_font_size_override("font_size", UITypography.SIZE_LABEL)

	# 设置图标颜色
	button.modulate = Color.ONE if is_selected else Color(0.7, 0.7, 0.7, 1)

func _update_button_icon(button: Button, is_selected: bool) -> void:
	var icon_selected_path: String = button.get_meta("icon_selected_path", "")
	var icon_path: String = button.get_meta("icon_path", "")

	var path := icon_selected_path if is_selected else icon_path
	if ResourceLoader.exists(path):
		button.icon = load(path)

# ============================================
# 更新方法（Update Methods）
# ============================================

func _update_selection() -> void:
	for i in range(_nav_buttons.size()):
		var button := _nav_buttons[i]
		var is_selected := i == current_page

		_apply_button_style(button, is_selected)
		_update_button_icon(button, is_selected)

	# 更新指示器位置
	_update_indicator_position()

func _update_indicator_position() -> void:
	if not _indicator or _nav_buttons.size() == 0:
		return

	var target_button := _nav_buttons[current_page]
	var target_x := target_button.position.x

	if enable_animation and not ThemeManager.should_skip_animation():
		_animate_indicator(target_x)
	else:
		_indicator.position.x = target_x

func _animate_indicator(target_x: float) -> void:
	if _tween:
		_tween.kill()

	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_CUBIC)
	_tween.tween_property(_indicator, "position:x", target_x, 0.3)

func _update_labels_visibility() -> void:
	for button in _nav_buttons:
		if show_labels:
			var nav_id: String = button.get_meta("nav_id")
			var item := _get_item_by_id(nav_id)
			button.text = item.label if item else ""
		else:
			button.text = ""

func _rebuild_nav_items() -> void:
	# 清除现有导航项
	if _nav_container:
		for child in _nav_container.get_children():
			child.queue_free()
		_nav_buttons.clear()

	# 重新创建
	_create_nav_items()
	_update_selection()

func _setup_layout() -> void:
	# 设置尺寸
	custom_minimum_size.y = NAV_HEIGHT + 3  # 包含指示器高度

	# 添加安全区域底部间距（移动端）
	# if DisplayServer.screen_get_safe_area():
	#	custom_minimum_size.y += DisplayServer.screen_get_safe_area().size.y

# ============================================
# 事件处理（Event Handling）
# ============================================

func _on_nav_button_pressed(index: int) -> void:
	if index == current_page:
		return

	current_page = index
	nav_item_selected.emit(_get_item_id(index))
	_play_sound("nav_click")

func _get_item_id(index: int) -> String:
	if index >= 0 and index < _nav_buttons.size():
		return _nav_buttons[index].get_meta("nav_id", "")
	return ""

func _get_item_by_id(item_id: String) -> Dictionary:
	var items := custom_nav_items if custom_nav_items.size() > 0 else DEFAULT_NAV_ITEMS
	for item in items:
		if item.id == item_id:
			return item
	return {}

# ============================================
# 公共方法（Public Methods）
# ============================================

## 导航到指定页面
func navigate_to(page_index: int) -> void:
	current_page = page_index

## 导航到指定 ID
func navigate_to_id(item_id: String) -> void:
	var items := custom_nav_items if custom_nav_items.size() > 0 else DEFAULT_NAV_ITEMS
	for i in range(items.size()):
		if items[i].id == item_id:
			current_page = i
			break

## 获取当前页面 ID
func get_current_page_id() -> String:
	return _get_item_id(current_page)

## 获取当前页面索引
func get_current_page_index() -> int:
	return current_page

## 获取导航项数量
func get_nav_count() -> int:
	return _nav_buttons.size()

## 设置导航项可见性
func set_item_visible(item_id: String, visible: bool) -> void:
	for button in _nav_buttons:
		if button.get_meta("nav_id") == item_id:
			button.visible = visible
			break

## 设置导航项可用性
func set_item_disabled(item_id: String, disabled: bool) -> void:
	for button in _nav_buttons:
		if button.get_meta("nav_id") == item_id:
			button.disabled = disabled
			break

## 高亮指定项（临时高亮，不影响选中状态）
func highlight_item(item_id: String) -> void:
	for button in _nav_buttons:
		if button.get_meta("nav_id") == item_id:
			_highlight_button(button)
			break

func _highlight_button(button: Button) -> void:
	if ThemeManager.should_skip_animation():
		return

	var tween := create_tween()
	tween.tween_property(button, "modulate", Color(1.2, 1.2, 1.2, 1), 0.2)
	tween.tween_property(button, "modulate", Color.ONE, 0.3)

## 播放音效
func _play_sound(sound_id: String) -> void:
	# AudioManager.play_ui_sound(sound_id)
	pass

# ============================================
# 键盘/手柄导航支持
# ============================================

func _input(event: InputEvent) -> void:
	if not has_focus():
		return

	# 键盘导航
	if event.is_action_pressed("ui_left"):
		var new_index := current_page - 1
		if new_index >= 0:
			navigate_to(new_index)
	elif event.is_action_pressed("ui_right"):
		var new_index := current_page + 1
		if new_index < _nav_buttons.size():
			navigate_to(new_index)

# ============================================
# 响应式布局（Responsive Layout）
# ============================================

func _on_resized() -> void:
	# 根据宽度调整布局
	var width := size.x
	var item_width := width / float(_nav_buttons.size())

	for button in _nav_buttons:
		button.custom_minimum_size.x = item_width

	_update_indicator_position()