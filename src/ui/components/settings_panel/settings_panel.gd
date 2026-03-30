## 设置面板组件
## 游戏设置界面，包含音频、显示、控制、无障碍等设置项
class_name SettingsPanel
extends Control

# ============================================
# 信号（Signals）
# ============================================
## 设置变更时发出
signal setting_changed(category: String, key: String, value: Variant)
## 设置保存完成时发出
signal settings_saved()
## 设置重置完成时发出
signal settings_reset()
## 面板关闭时发出
signal panel_closed()

# ============================================
# 导出属性（Export Properties）
# ============================================

## 当前选中的设置页
enum SettingsPage {
	AUDIO,        ## 音频设置
	DISPLAY,      ## 显示设置
	CONTROLS,     ## 控制设置
	ACCESSIBILITY ## 无障碍设置
}

@export var current_page: SettingsPage = SettingsPage.DISPLAY:
	set(value):
		if current_page != value:
			current_page = value
			_switch_page(value)

## 是否显示保存按钮
@export var show_save_button: bool = true

## 是否显示重置按钮
@export var show_reset_button: bool = true

## 是否显示关闭按钮
@export var show_close_button: bool = true

## 设置文件路径
@export var settings_file: String = "user://game_settings.cfg"

# ============================================
# 内部变量（Internal Variables）
# ============================================
var _main_container: VBoxContainer
var _header: HBoxContainer
var _title_label: Label
var _close_button: UIButton

var _tabs_container: HBoxContainer
var _tab_buttons: Array[UIButton] = []

var _content_container: ScrollContainer
var _content_stack: Dictionary = {}  # 页面内容缓存

var _footer: HBoxContainer
var _reset_button: UIButton
var _save_button: UIButton

var _settings_config: ConfigFile = ConfigFile.new()
var _pending_changes: Dictionary = {}  # 待保存的变更

# 设置项数据结构
const SETTINGS_DATA := {
	SettingsPage.AUDIO: [
		{
			"id": "master_volume",
			"type": "slider",
			"label": "主音量",
			"min": 0.0,
			"max": 1.0,
			"step": 0.05,
			"default": 0.8
		},
		{
			"id": "music_volume",
			"type": "slider",
			"label": "音乐音量",
			"min": 0.0,
			"max": 1.0,
			"step": 0.05,
			"default": 0.6
		},
		{
			"id": "sfx_volume",
			"type": "slider",
			"label": "音效音量",
			"min": 0.0,
			"max": 1.0,
			"step": 0.05,
			"default": 0.8
		},
		{
			"id": "voice_volume",
			"type": "slider",
			"label": "语音音量",
			"min": 0.0,
			"max": 1.0,
			"step": 0.05,
			"default": 0.9
		},
		{
			"id": "mute_on_focus_lost",
			"type": "toggle",
			"label": "失焦时静音",
			"default": true
		}
	],
	SettingsPage.DISPLAY: [
		{
			"id": "resolution",
			"type": "dropdown",
			"label": "分辨率",
			"options": ["1920x1080", "1600x900", "1280x720", "自动"],
			"default": "自动"
		},
		{
			"id": "fullscreen",
			"type": "toggle",
			"label": "全屏模式",
			"default": false
		},
		{
			"id": "vsync",
			"type": "toggle",
			"label": "垂直同步",
			"default": true
		},
		{
			"id": "brightness",
			"type": "slider",
			"label": "亮度",
			"min": 0.5,
			"max": 1.5,
			"step": 0.1,
			"default": 1.0
		},
		{
			"id": "theme",
			"type": "dropdown",
			"label": "主题",
			"options": ["默认", "深色", "沉浸"],
			"default": "默认"
		},
		{
			"id": "font_scale",
			"type": "slider",
			"label": "字体大小",
			"min": 0.8,
			"max": 1.5,
			"step": 0.1,
			"default": 1.0
		}
	],
	SettingsPage.CONTROLS: [
		{
			"id": "mouse_sensitivity",
			"type": "slider",
			"label": "鼠标灵敏度",
			"min": 0.5,
			"max": 2.0,
			"step": 0.1,
			"default": 1.0
		},
		{
			"id": "invert_y",
			"type": "toggle",
			"label": "反转Y轴",
			"default": false
		},
		{
			"id": "key_bindings",
			"type": "custom",
			"label": "按键绑定",
			"custom_type": "key_binding_editor"
		},
		{
			"id": "gamepad_enabled",
			"type": "toggle",
			"label": "启用手柄",
			"default": true
		},
		{
			"id": "gamepad_sensitivity",
			"type": "slider",
			"label": "手柄灵敏度",
			"min": 0.5,
			"max": 2.0,
			"step": 0.1,
			"default": 1.0
		}
	],
	SettingsPage.ACCESSIBILITY: [
		{
			"id": "colorblind_mode",
			"type": "dropdown",
			"label": "色盲模式",
			"options": ["无", "红绿色盲", "蓝黄色盲", "全色盲"],
			"default": "无"
		},
		{
			"id": "high_contrast",
			"type": "toggle",
			"label": "高对比度",
			"default": false
		},
		{
			"id": "reduced_motion",
			"type": "toggle",
			"label": "减少动画",
			"default": false
		},
		{
			"id": "screen_shake",
			"type": "slider",
			"label": "画面震动",
			"min": 0.0,
			"max": 1.0,
			"step": 0.1,
			"default": 1.0
		},
		{
			"id": "tooltip_delay",
			"type": "slider",
			"label": "提示延迟",
			"min": 0.0,
			"max": 2.0,
			"step": 0.1,
			"default": 0.5
		},
		{
			"id": "always_show_health",
			"type": "toggle",
			"label": "始终显示血条",
			"default": true
		}
	]
}

const PAGE_NAMES := {
	SettingsPage.AUDIO: "音频",
	SettingsPage.DISPLAY: "显示",
	SettingsPage.CONTROLS: "控制",
	SettingsPage.ACCESSIBILITY: "无障碍"
}

# ============================================
# 生命周期（Lifecycle）
# ============================================

func _ready() -> void:
	# 加载设置
	_load_settings()

	# 创建组件
	_create_header()
	_create_tabs()
	_create_content()
	_create_footer()

	# 设置布局
	_setup_layout()

	# 初始化页面
	_switch_page(current_page)

	# 应用当前设置
	_apply_all_settings()

func _create_header() -> void:
	_header = HBoxContainer.new()
	_header.name = "Header"

	# 标题
	_title_label = Label.new()
	_title_label.name = "Title"
	_title_label.text = "设置"
	_title_label.add_theme_font_size_override("font_size", UITypography.SIZE_H3)
	_title_label.add_theme_color_override("font_color", UIColors.TEXT_PRIMARY)
	_header.add_child(_title_label)

	# 分隔符
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_header.add_child(spacer)

	# 关闭按钮
	if show_close_button:
		_close_button = UIButton.new()
		_close_button.name = "CloseButton"
		_close_button.text = "关闭"
		_close_button.style = UIButton.ButtonStyle.GHOST
		_close_button.size = UIButton.ButtonSize.SMALL
		_close_button.pressed.connect(_on_close_pressed)
		_header.add_child(_close_button)

	add_child(_header)

func _create_tabs() -> void:
	_tabs_container = HBoxContainer.new()
	_tabs_container.name = "Tabs"
	_tabs_container.alignment = HBoxContainer.ALIGNMENT_CENTER
	_tabs_container.add_theme_constant_override("separation", UISpacing.SPACE_MD)

	# 创建标签页按钮
	for page in [SettingsPage.AUDIO, SettingsPage.DISPLAY, SettingsPage.CONTROLS, SettingsPage.ACCESSIBILITY]:
		var button := UIButton.new()
		button.name = "Tab_%s" % PAGE_NAMES[page]
		button.text = PAGE_NAMES[page]
		button.style = UIButton.ButtonStyle.GHOST
		button.set_meta("page", page)
		button.pressed.connect(_on_tab_pressed.bind(page))
		_tab_buttons.append(button)
		_tabs_container.add_child(button)

	add_child(_tabs_container)

func _create_content() -> void:
	_content_container = ScrollContainer.new()
	_content_container.name = "ContentScroll"
	_content_container.size_flags_vertical = Control.SIZE_EXPAND_FILL

	# 为每个页面创建内容
	for page in [SettingsPage.AUDIO, SettingsPage.DISPLAY, SettingsPage.CONTROLS, SettingsPage.ACCESSIBILITY]:
		var page_content := _create_page_content(page)
		_content_stack[page] = page_content
		_content_container.add_child(page_content)
		page_content.visible = false

	add_child(_content_container)

func _create_page_content(page: SettingsPage) -> VBoxContainer:
	var container := VBoxContainer.new()
	container.name = "PageContent_%s" % PAGE_NAMES[page]
	container.add_theme_constant_override("separation", UISpacing.SPACE_MD)
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# 创建设置项
	var settings_list := SETTINGS_DATA.get(page, [])
	for setting in settings_list:
		var item := _create_setting_item(setting, page)
		container.add_child(item)

	return container

func _create_setting_item(setting_data: Dictionary, page: SettingsPage) -> HBoxContainer:
	var container := HBoxContainer.new()
	container.name = "Setting_%s" % setting_data.id
	container.add_theme_constant_override("separation", UISpacing.SPACE_LG)

	# 标签
	var label := Label.new()
	label.text = setting_data.label
	label.add_theme_font_size_override("font_size", UITypography.SIZE_BODY)
	label.add_theme_color_override("font_color", UIColors.TEXT_PRIMARY)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_child(label)

	# 控件
	var control: Control
	var setting_type: String = setting_data.type

	match setting_type:
		"slider":
			control = _create_slider_control(setting_data)
		"toggle":
			control = _create_toggle_control(setting_data)
		"dropdown":
			control = _create_dropdown_control(setting_data)
		"custom":
			control = _create_custom_control(setting_data)

	if control:
		control.set_meta("setting_id", setting_data.id)
		control.set_meta("setting_page", page)
		control.set_meta("setting_default", setting_data.default)
		container.add_child(control)

	return container

func _create_slider_control(setting_data: Dictionary) -> HSlider:
	var slider := HSlider.new()
	slider.min_value = setting_data.min
	slider.max_value = setting_data.max
	slider.step = setting_data.step

	# 加载当前值
	var current_value := _get_setting_value(setting_data.id, setting_data.default)
	slider.value = current_value

	# 连接信号
	slider.value_changed.connect(_on_slider_changed.bind(setting_data.id))

	# 添加数值标签
	# TODO: 在 slider 后添加数值显示标签

	return slider

func _create_toggle_control(setting_data: Dictionary) -> CheckBox:
	var checkbox := CheckBox.new()
	checkbox.text = ""

	# 加载当前值
	var current_value := _get_setting_value(setting_data.id, setting_data.default)
	checkbox.button_pressed = current_value

	# 连接信号
	checkbox.toggled.connect(_on_toggle_changed.bind(setting_data.id))

	return checkbox

func _create_dropdown_control(setting_data: Dictionary) -> OptionButton:
	var dropdown := OptionButton.new()

	# 添加选项
	var options: Array = setting_data.options
	for option in options:
		dropdown.add_item(option)

	# 设置当前值
	var current_value: String = _get_setting_value(setting_data.id, setting_data.default)
	var index := options.find(current_value)
	if index >= 0:
		dropdown.selected = index

	# 连接信号
	dropdown.item_selected.connect(_on_dropdown_changed.bind(setting_data.id, options))

	return dropdown

func _create_custom_control(setting_data: Dictionary) -> Control:
	# 自定义控件（如按键绑定编辑器）
	var custom_type: String = setting_data.custom_type

	if custom_type == "key_binding_editor":
		# TODO: 实现按键绑定编辑器
		var button := UIButton.new()
		button.text = "编辑按键"
		button.style = UIButton.ButtonStyle.GHOST
		button.pressed.connect(_on_key_binding_edit_pressed)
		return button

	return Control.new()

func _create_footer() -> void:
	_footer = HBoxContainer.new()
	_footer.name = "Footer"
	_footer.alignment = HBoxContainer.ALIGNMENT_CENTER
	_footer.add_theme_constant_override("separation", UISpacing.SPACE_MD)

	# 重置按钮
	if show_reset_button:
		_reset_button = UIButton.new()
		_reset_button.name = "ResetButton"
		_reset_button.text = "重置默认"
		_reset_button.style = UIButton.ButtonStyle.GHOST
		_reset_button.pressed.connect(_on_reset_pressed)
		_footer.add_child(_reset_button)

	# 保存按钮
	if show_save_button:
		_save_button = UIButton.new()
		_save_button.name = "SaveButton"
		_save_button.text = "保存设置"
		_save_button.style = UIButton.ButtonStyle.PRIMARY
		_save_button.pressed.connect(_on_save_pressed)
		_footer.add_child(_save_button)

	add_child(_footer)

func _setup_layout() -> void:
	# 设置锚点
	anchors_preset = PRESET_FULL_RECT
	offset_top = 50
	offset_bottom = -50
	offset_left = 100
	offset_right = -100

	custom_minimum_size = Vector2(600, 400)

# ============================================
# 页面切换（Page Switching）
# ============================================

func _switch_page(page: SettingsPage) -> void:
	# 更新标签按钮样式
	for i in range(_tab_buttons.size()):
		var button := _tab_buttons[i]
		var button_page: int = button.get_meta("page")
		if button_page == page:
			button.style = UIButton.ButtonStyle.PRIMARY
		else:
			button.style = UIButton.ButtonStyle.GHOST

	# 显示对应内容
	for key in _content_stack.keys():
		var content := _content_stack[key]
		if key == page:
			content.visible = true
		else:
			content.visible = false

# ============================================
# 设置读写（Settings Read/Write）
# ============================================

func _load_settings() -> void:
	var err := _settings_config.load(settings_file)
	if err != OK:
		# 使用默认值
		return

func _save_settings() -> void:
	# 先保存待处理的变更
	for key in _pending_changes.keys():
		var parts := key.split(":")
		if parts.size() == 2:
			var category := parts[0]
			var setting_id := parts[1]
			_settings_config.set_value(category, setting_id, _pending_changes[key])

	_pending_changes.clear()

	# 保存到文件
	var err := _settings_config.save(settings_file)
	if err != OK:
		push_warning("SettingsPanel: 无法保存设置，错误码: %d" % err)
		return

	settings_saved.emit()

func _get_setting_value(setting_id: String, default_value: Variant) -> Variant:
	# 检查待处理的变更
	var pending_key := "%s:%s" % [current_page, setting_id]
	if _pending_changes.has(pending_key):
		return _pending_changes[pending_key]

	# 从配置文件读取
	return _settings_config.get_value(PAGE_NAMES[current_page], setting_id, default_value)

func _set_setting_value(category: String, setting_id: String, value: Variant) -> void:
	var key := "%s:%s" % [category, setting_id]
	_pending_changes[key] = value

	setting_changed.emit(category, setting_id, value)

func _apply_all_settings() -> void:
	# 应用所有设置到游戏
	for page in _content_stack.keys():
		var content := _content_stack[page] as VBoxContainer
		if not content:
			continue

		for child in content.get_children():
			if child is HBoxContainer:
				_apply_setting_from_container(child, page)

func _apply_setting_from_container(container: HBoxContainer, page: SettingsPage) -> void:
	for child in container.get_children():
		if child.has_meta("setting_id"):
			var setting_id: String = child.get_meta("setting_id")
			var value: Variant

			if child is HSlider:
				value = child.value
			elif child is CheckBox:
				value = child.button_pressed
			elif child is OptionButton:
				value = child.get_item_text(child.selected)

			_apply_setting_immediate(setting_id, value, page)

func _apply_setting_immediate(setting_id: String, value: Variant, page: SettingsPage) -> void:
	# 立即应用设置效果
	match page:
		SettingsPage.DISPLAY:
			_apply_display_setting(setting_id, value)
		SettingsPage.AUDIO:
			_apply_audio_setting(setting_id, value)
		SettingsPage.ACCESSIBILITY:
			_apply_accessibility_setting(setting_id, value)
		SettingsPage.CONTROLS:
			_apply_control_setting(setting_id, value)

func _apply_display_setting(setting_id: String, value: Variant) -> void:
	match setting_id:
		"fullscreen":
			if value:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		"vsync":
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if value else DisplayServer.VSYNC_DISABLED)
		"theme":
			if ThemeManager:
				var theme_name := str(value).to_lower()
				ThemeManager.switch_theme(theme_name)
		"font_scale":
			if ThemeManager:
				ThemeManager.set_font_scale(float(value))

func _apply_audio_setting(setting_id: String, value: Variant) -> void:
	# TODO: 与 AudioManager 集成
	match setting_id:
		"master_volume":
			# AudioManager.set_master_volume(float(value))
			pass
		"music_volume":
			# AudioManager.set_music_volume(float(value))
			pass
		"sfx_volume":
			# AudioManager.set_sfx_volume(float(value))
			pass

func _apply_accessibility_setting(setting_id: String, value: Variant) -> void:
	if not ThemeManager:
		return

	match setting_id:
		"colorblind_mode":
			var mode_name := str(value)
			ThemeManager.set_colorblind_mode(mode_name != "无")
		"high_contrast":
			ThemeManager.set_high_contrast_mode(bool(value))
		"reduced_motion":
			ThemeManager.set_reduced_motion(bool(value))

func _apply_control_setting(setting_id: String, value: Variant) -> void:
	match setting_id:
		"mouse_sensitivity":
			# InputManager.set_mouse_sensitivity(float(value))
			pass
		"gamepad_enabled":
			# InputManager.set_gamepad_enabled(bool(value))
			pass

# ============================================
# 事件处理（Event Handling）
# ============================================

func _on_tab_pressed(page: SettingsPage) -> void:
	current_page = page

func _on_slider_changed(setting_id: String, value: float) -> void:
	_set_setting_value(PAGE_NAMES[current_page], setting_id, value)
	_apply_setting_immediate(setting_id, value, current_page)

func _on_toggle_changed(setting_id: String, is_on: bool) -> void:
	_set_setting_value(PAGE_NAMES[current_page], setting_id, is_on)
	_apply_setting_immediate(setting_id, is_on, current_page)

func _on_dropdown_changed(setting_id: String, options: Array, index: int) -> void:
	var value := options[index]
	_set_setting_value(PAGE_NAMES[current_page], setting_id, value)
	_apply_setting_immediate(setting_id, value, current_page)

func _on_key_binding_edit_pressed() -> void:
	# TODO: 打开按键绑定编辑界面
	pass

func _on_save_pressed() -> void:
	_save_settings()
	_play_sound("ui_save")

func _on_reset_pressed() -> void:
	_reset_to_defaults()
	settings_reset.emit()
	_play_sound("ui_reset")

func _on_close_pressed() -> void:
	panel_closed.emit()
	_play_sound("ui_close")

func _reset_to_defaults() -> void:
	# 重置所有设置到默认值
	for page in SETTINGS_DATA.keys():
		var settings_list := SETTINGS_DATA[page]
		for setting in settings_list:
			var default_value := setting.default
			_set_setting_value(PAGE_NAMES[page], setting.id, default_value)
			_apply_setting_immediate(setting.id, default_value, page)

	# 更新控件显示
	for page in _content_stack.keys():
		var content := _content_stack[page] as VBoxContainer
		if not content:
			continue

		for child in content.get_children():
			if child is HBoxContainer:
				_reset_setting_container(child)

func _reset_setting_container(container: HBoxContainer) -> void:
	for child in container.get_children():
		if child.has_meta("setting_id") and child.has_meta("setting_default"):
			var default_value: Variant = child.get_meta("setting_default")

			if child is HSlider:
				child.value = default_value
			elif child is CheckBox:
				child.button_pressed = default_value
			elif child is OptionButton:
				var options: Array = []
				for i in range(child.get_item_count()):
					options.append(child.get_item_text(i))
				var index := options.find(default_value)
				if index >= 0:
					child.selected = index

# ============================================
# 公共方法（Public Methods）
# ============================================

## 打开指定页面
func open_page(page: SettingsPage) -> void:
	current_page = page

## 保存设置
func save_settings() -> void:
	_save_settings()

## 重置设置
func reset_settings() -> void:
	_reset_to_defaults()

## 关闭面板
func close_panel() -> void:
	panel_closed.emit()

## 获取设置值
func get_value(category: String, key: String, default: Variant = null) -> Variant:
	return _settings_config.get_value(category, key, default)

## 设置值
func set_value(category: String, key: String, value: Variant) -> void:
	_set_setting_value(category, key, value)

## 播放音效
func _play_sound(sound_id: String) -> void:
	# AudioManager.play_ui_sound(sound_id)
	pass