## 对话框组件
## 用于 NPC 对话、剧情文本、提示信息等场景
class_name DialogueBox
extends PanelContainer

# ============================================
# 信号（Signals）
# ============================================
## 对话行显示完成时发出
signal line_displayed(line_index: int)
## 对话序列完成时发出
signal dialogue_completed()
## 选择项被选择时发出
signal choice_selected(choice_index: int, choice_id: String)
## 对话跳过时发出
signal dialogue_skipped()

# ============================================
# 导出属性（Export Properties）
# ============================================

## 对话数据
@export var dialogue_lines: Array[Dictionary] = []:
	set(value):
		dialogue_lines = value
		_reset_dialogue()

## 当前对话行索引
@export_range(0, 99, 1) var current_line_index: int = 0:
	set(value):
		current_line_index = clamp(value, 0, max(0, dialogue_lines.size() - 1))
		_show_line(current_line_index)

## 文本显示速度（字符/秒）
@export_range(5, 100, 1) var text_speed: int = 30:
	set(value):
		text_speed = clamp(value, 5, 100)

## 是否自动播放下一行
@export var auto_play: bool = false

## 自动播放延迟（秒）
@export_range(0.5, 5.0, 0.1) var auto_play_delay: float = 1.5

## 是否可跳过
@export var skippable: bool = true

## 是否显示角色名称
@export var show_character_name: bool = true

## 是否显示继续提示
@export var show_continue_hint: bool = true

## 对话框位置
enum DialoguePosition {
	TOP,        ## 顶部
	CENTER,     ## 中央（默认）
	BOTTOM      ## 底部
}

@export var box_position: DialoguePosition = DialoguePosition.BOTTOM:
	set(value):
		box_position = value
		_update_position()

## 对话框尺寸预设
enum DialogueSize {
	SMALL,   ## 小尺寸（提示用）
	MEDIUM,  ## 中等尺寸（默认）
	LARGE    ## 大尺寸（剧情用）
}

@export var box_size: DialogueSize = DialogueSize.MEDIUM:
	set(value):
		box_size = value
		_update_size()

# ============================================
# 内部变量（Internal Variables）
# ============================================
var _character_label: Label
var _content_label: RichTextLabel
var _choices_container: VBoxContainer
var _continue_hint: Control
var _portrait_container: Control
var _portrait: TextureRect

var _is_displaying: bool = false
var _current_text: String = ""
var _display_progress: float = 0.0
var _auto_play_timer: float = 0.0
var _text_tween: Tween

# 尺寸预设
const SIZE_SMALL := Vector2(400, 80)
const SIZE_MEDIUM := Vector2(600, 120)
const SIZE_LARGE := Vector2(800, 160)

# ============================================
# 生命周期（Lifecycle）
# ============================================

func _ready() -> void:
	# 创建组件
	_create_components()

	# 设置样式
	_apply_style()

	# 初始化位置和尺寸
	_update_position()
	_update_size()

	# 连接输入事件
	gui_input.connect(_on_gui_input)

func _create_components() -> void:
	# 主容器
	var main_container := HBoxContainer.new()
	main_container.name = "MainContainer"
	main_container.add_theme_constant_override("separation", UISpacing.SPACE_MD)
	add_child(main_container)

	# 角色头像容器
	_portrait_container = Control.new()
	_portrait_container.name = "PortraitContainer"
	_portrait_container.custom_minimum_size = Vector2(80, 80)
	main_container.add_child(_portrait_container)

	_portrait = TextureRect.new()
	_portrait.name = "Portrait"
	_portrait.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait.visible = false
	_portrait_container.add_child(_portrait)

	# 文本容器
	var text_container := VBoxContainer.new()
	text_container.name = "TextContainer"
	text_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_container.add_theme_constant_override("separation", UISpacing.SPACE_XS)
	main_container.add_child(text_container)

	# 角色名称
	_character_label = Label.new()
	_character_label.name = "CharacterName"
	_character_label.visible = show_character_name
	_character_label.add_theme_font_size_override("font_size", UITypography.SIZE_H5)
	_character_label.add_theme_color_override("font_color", UIColors.PRIMARY_DEFAULT)
	text_container.add_child(_character_label)

	# 对话内容
	_content_label = RichTextLabel.new()
	_content_label.name = "DialogueContent"
	_content_label.bbcode_enabled = true
	_content_label.fit_content = true
	_content_label.scroll_active = false
	_content_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content_label.add_theme_font_size_override("normal_font_size", UITypography.SIZE_BODY)
	_content_label.add_theme_color_override("default_color", UIColors.TEXT_PRIMARY)
	text_container.add_child(_content_label)

	# 选择项容器
	_choices_container = VBoxContainer.new()
	_choices_container.name = "ChoicesContainer"
	_choices_container.visible = false
	_choices_container.add_theme_constant_override("separation", UISpacing.SPACE_SM)
	text_container.add_child(_choices_container)

	# 继续提示
	_continue_hint = _create_continue_hint()
	_continue_hint.visible = show_continue_hint
	text_container.add_child(_continue_hint)

func _create_continue_hint() -> Control:
	var container := HBoxContainer.new()
	container.name = "ContinueHint"
	container.alignment = HORIZONTAL_ALIGNMENT_RIGHT

	var hint_label := Label.new()
	hint_label.text = "点击继续..."
	hint_label.add_theme_font_size_override("font_size", UITypography.SIZE_CAPTION)
	hint_label.add_theme_color_override("font_color", UIColors.TEXT_HINT)
	container.add_child(hint_label)

	# 闪烁动画提示
	var arrow := Label.new()
	arrow.text = ">"
	arrow.add_theme_font_size_override("font_size", UITypography.SIZE_CAPTION)
	arrow.add_theme_color_override("font_color", UIColors.TEXT_HINT)
	container.add_child(arrow)

	# 添加闪烁动画
	if not ThemeManager.should_skip_animation():
		var tween := create_tween()
		tween.set_loops()
		tween.tween_property(arrow, "modulate:a", 0.3, 0.5)
		tween.tween_property(arrow, "modulate:a", 1.0, 0.5)

	return container

func _apply_style() -> void:
	# 背景样式
	var style := StyleBoxFlat.new()
	style.bg_color = UIColors.BG_CARD
	style.set_border_width_all(UISpacing.BORDER_THIN)
	style.border_color = UIColors.BORDER_DEFAULT
	style.set_corner_radius_all(UISpacing.RADIUS_DIALOG)
	style.set_content_margin_all(UISpacing.PADDING_DIALOG)

	# 添加阴影
	style.shadow_color = Color(0, 0, 0, 0.5)
	style.shadow_offset = Vector2(0, 8)
	style.shadow_size = UISpacing.SHADOW_BLUR_XL

	add_theme_stylebox_override("panel", style)

# ============================================
# 更新方法（Update Methods）
# ============================================

func _update_position() -> void:
	# 根据预设位置设置锚点
	var parent := get_parent()
	if not parent:
		return

	match box_position:
		DialoguePosition.TOP:
			anchors_preset = PRESET_TOP_WIDE
			offset_bottom = custom_minimum_size.y
		DialoguePosition.CENTER:
			anchors_preset = PRESET_CENTER
			offset_left = -custom_minimum_size.x / 2
			offset_right = custom_minimum_size.x / 2
			offset_top = -custom_minimum_size.y / 2
			offset_bottom = custom_minimum_size.y / 2
		DialoguePosition.BOTTOM:
			anchors_preset = PRESET_BOTTOM_WIDE
			offset_top = -custom_minimum_size.y

func _update_size() -> void:
	var target_size: Vector2
	match box_size:
		DialogueSize.SMALL:
			target_size = SIZE_SMALL
			if _portrait_container:
				_portrait_container.custom_minimum_size = Vector2(48, 48)
		DialogueSize.LARGE:
			target_size = SIZE_LARGE
			if _portrait_container:
				_portrait_container.custom_minimum_size = Vector2(100, 100)
		_:  # DialogueSize.MEDIUM
			target_size = SIZE_MEDIUM
			if _portrait_container:
				_portrait_container.custom_minimum_size = Vector2(80, 80)

	custom_minimum_size = target_size

func _show_line(index: int) -> void:
	if index >= dialogue_lines.size():
		dialogue_completed.emit()
		return

	var line := dialogue_lines[index]
	_display_line(line)

func _display_line(line_data: Dictionary) -> void:
	# 获取角色信息
	var character_name := line_data.get("character", "")
	var portrait_path := line_data.get("portrait", "")
	var text := line_data.get("text", "")
	var choices := line_data.get("choices", [])

	# 更新角色名称
	if _character_label:
		_character_label.text = character_name
		_character_label.visible = show_character_name and character_name != ""

	# 更新头像
	if _portrait:
		if portrait_path != "" and ResourceLoader.exists(portrait_path):
			_portrait.texture = load(portrait_path)
			_portrait.visible = true
		else:
			_portrait.visible = false

	# 隐藏选择项
	if _choices_container:
		_choices_container.visible = false

	# 隐藏继续提示
	if _continue_hint:
		_continue_hint.visible = false

	# 播放文本动画
	_play_text_animation(text)

	# 如果有选择项，在文本完成后显示
	if choices.size() > 0:
		_prepare_choices(choices)

func _play_text_animation(text: String) -> void:
	_is_displaying = true
	_current_text = text
	_display_progress = 0.0

	if _content_label:
		_content_label.text = ""

	# 停止之前的动画
	if _text_tween:
		_text_tween.kill()

	# 计算动画时长
	var duration := text.length() / float(text_speed)

	if ThemeManager.should_skip_animation():
		# 无动画模式
		if _content_label:
			_content_label.text = text
		_on_text_display_complete()
		return

	# 创建文字渐显动画
	_text_tween = create_tween()
	_text_tween.tween_method(_update_text_display, 0.0, text.length(), duration)
	_text_tween.tween_callback(_on_text_display_complete)

func _update_text_display(char_count: float) -> void:
	if not _content_label:
		return

	var visible_chars := int(char_count)
	var visible_text := _current_text.substr(0, visible_chars)

	# 添加渐隐效果
	if visible_chars < _current_text.length():
		var remaining := _current_text.length() - visible_chars
		visible_text += "[color=808080]" + _current_text.substr(visible_chars, min(3, remaining)) + "[/color]"

	_content_label.text = visible_text

func _on_text_display_complete() -> void:
	_is_displaying = false

	if _content_label:
		_content_label.text = _current_text

	# 发出信号
	line_displayed.emit(current_line_index)

	# 检查是否有选择项
	var current_line := dialogue_lines[current_line_index]
	var choices := current_line.get("choices", [])

	if choices.size() > 0:
		_show_choices()
	elif current_line_index < dialogue_lines.size() - 1:
		# 显示继续提示
		if _continue_hint:
			_continue_hint.visible = show_continue_hint

		# 自动播放
		if auto_play:
			_start_auto_play_timer()
	else:
		dialogue_completed.emit()

func _prepare_choices(choices: Array) -> void:
	if not _choices_container:
		return

	# 清除现有选择项
	for child in _choices_container.get_children():
		child.queue_free()

	# 创建新选择项
	for i in range(choices.size()):
		var choice := choices[i]
		var button := _create_choice_button(choice, i)
		_choices_container.add_child(button)

func _create_choice_button(choice_data: Dictionary, index: int) -> UIButton:
	var button := UIButton.new()
	button.text = choice_data.get("text", "")
	button.style = UIButton.ButtonStyle.GHOST
	button.size = UIButton.ButtonSize.MEDIUM
	button.set_meta("choice_index", index)
	button.set_meta("choice_id", choice_data.get("id", ""))

	button.pressed.connect(_on_choice_pressed.bind(index))

	return button

func _show_choices() -> void:
	if _choices_container:
		_choices_container.visible = true

	# 隐藏继续提示
	if _continue_hint:
		_continue_hint.visible = false

func _start_auto_play_timer() -> void:
	_auto_play_timer = auto_play_delay

func _reset_dialogue() -> void:
	current_line_index = 0
	_is_displaying = false
	if _text_tween:
		_text_tween.kill()

# ============================================
# 事件处理（Event Handling）
# ============================================

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_handle_click()

	elif event is InputEventKey:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			if event.pressed:
				_handle_click()
		elif event.keycode == KEY_ESCAPE and skippable:
			if event.pressed:
				_skip_dialogue()

func _handle_click() -> void:
	if _is_displaying:
		# 快速完成当前文本
		_skip_text()
	elif _choices_container and _choices_container.visible:
		# 有选择项时不自动前进
		pass
	else:
		# 前进到下一行
		_advance_dialogue()

func _skip_text() -> void:
	if _text_tween:
		_text_tween.kill()

	_on_text_display_complete()

func _advance_dialogue() -> void:
	if current_line_index < dialogue_lines.size() - 1:
		current_line_index += 1
	else:
		dialogue_completed.emit()

func _skip_dialogue() -> void:
	_skip_text()
	dialogue_skipped.emit()

func _on_choice_pressed(index: int) -> void:
	var choice_id: String = ""
	if _choices_container:
		var button := _choices_container.get_child(index) as UIButton
		if button:
			choice_id = button.get_meta("choice_id", "")

	choice_selected.emit(index, choice_id)
	_play_sound("ui_click")

func _process(delta: float) -> void:
	# 处理自动播放计时器
	if auto_play and _auto_play_timer > 0 and not _is_displaying:
		_auto_play_timer -= delta
		if _auto_play_timer <= 0:
			_advance_dialogue()
			_auto_play_timer = 0.0

# ============================================
# 公共方法（Public Methods）
# ============================================

## 开始对话
func start_dialogue(lines: Array[Dictionary] = []) -> void:
	if lines.size() > 0:
		dialogue_lines = lines

	_reset_dialogue()
	_show_line(0)

## 继续对话
func continue_dialogue() -> void:
	_advance_dialogue()

## 显示指定行
func show_line(index: int) -> void:
	current_line_index = index

## 选择选项
func select_choice(index: int) -> void:
	if _choices_container and _choices_container.visible:
		var button := _choices_container.get_child(index) as UIButton
		if button:
			button.simulate_click()

## 获取当前行数据
func get_current_line() -> Dictionary:
	if current_line_index < dialogue_lines.size():
		return dialogue_lines[current_line_index]
	return {}

## 是否正在显示文本
func is_displaying_text() -> bool:
	return _is_displaying

## 是否已完成
func is_completed() -> bool:
	return current_line_index >= dialogue_lines.size() - 1 and not _is_displaying

## 设置文本速度
func set_text_speed(speed: int) -> void:
	text_speed = speed

## 设置自动播放
func set_auto_play(enabled: bool, delay: float = 1.5) -> void:
	auto_play = enabled
	auto_play_delay = delay

## 跳过当前文本
func skip_current_text() -> void:
	_skip_text()

## 跳过整个对话
func skip_all_dialogue() -> void:
	_skip_dialogue()

## 播放音效
func _play_sound(sound_id: String) -> void:
	# AudioManager.play_ui_sound(sound_id)
	pass

# ============================================
# 静态工厂方法（Static Factory Methods）
# ============================================

## 创建简单对话
static func create_simple_dialogue(speaker: String, text: String) -> DialogueBox:
	var box := DialogueBox.new()
	box.dialogue_lines = [{"character": speaker, "text": text}]
	return box

## 创建带选择项的对话
static func create_dialogue_with_choices(speaker: String, text: String, choices: Array[Dictionary]) -> DialogueBox:
	var box := DialogueBox.new()
	box.dialogue_lines = [{"character": speaker, "text": text, "choices": choices}]
	return box