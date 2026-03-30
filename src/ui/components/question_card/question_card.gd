## 题目卡片组件
## 显示单个题目，包含题号、题型、难度、题目内容和选项
class_name QuestionCard
extends UICard

# ============================================
# 信号（Signals）
# ============================================
## 答案提交时发出
signal answer_submitted(question_id: String, answer: String, is_correct: bool)
## 答案选择变化时发出
signal answer_changed(question_id: String, answer: String)
## 题目展开/折叠时发出
signal question_expanded(question_id: String, is_expanded: bool)
## 请求查看提示时发出
signal hint_requested(question_id: String)
## 请求查看解析时发出
signal explanation_requested(question_id: String)

# ============================================
# 导出属性（Export Properties）
# ============================================

## 题目数据
@export var question_id: String = "":
	set(value):
		if question_id != value:
			question_id = value
			_update_display()

## 题号
@export_range(1, 999, 1) var question_number: int = 1:
	set(value):
		if question_number != value:
			question_number = value
			_update_header()

## 题型
enum QuestionType {
	MULTIPLE_CHOICE,    ## 单选题
	MULTI_SELECT,       ## 多选题
	JUDGE,              ## 判断题
	FILL_BLANK,         ## 填空题
	CODE,               ## 代码题
	SHORT_ANSWER        ## 简答题
}

@export var question_type: QuestionType = QuestionType.MULTIPLE_CHOICE:
	set(value):
		if question_type != value:
			question_type = value
			_update_type_indicator()

## 题目标题
@export var question_title: String = "":
	set(value):
		if question_title != value:
			question_title = value
			_update_title()

## 题目内容
@export_multiline var question_content: String = "":
	set(value):
		if question_content != value:
			question_content = value
			_update_content()

## 题目选项（选择题）
@export var question_options: Array[String] = []:
	set(value):
		question_options = value
		_update_options()

## 题目难度
enum QuestionDifficulty {
	EASY,       ## 简单
	MEDIUM,     ## 中等
	HARD,       ## 困难
	VERY_HARD,  ## 极难
	HELL        ## 地狱
}

@export var difficulty: QuestionDifficulty = QuestionDifficulty.MEDIUM:
	set(value):
		if difficulty != value:
			difficulty = value
			_update_difficulty_indicator()

## 知识点标签
@export var knowledge_tags: Array[String] = []:
	set(value):
		knowledge_tags = value
		_update_tags()

## 题目分数
@export_range(1, 100, 1) var score: int = 10:
	set(value):
		if score != value:
			score = value
			_update_score()

## 是否显示提示按钮
@export var show_hint_button: bool = true:
	set(value):
		if show_hint_button != value:
			show_hint_button = value
			if _hint_button:
				_hint_button.visible = value

## 是否显示解析按钮
@export var show_explanation_button: bool = false:
	set(value):
		if show_explanation_button != value:
			show_explanation_button = value
			if _explanation_button:
				_explanation_button.visible = value

## 是否已答题
@export var is_answered: bool = false:
	set(value):
		if is_answered != value:
			is_answered = value
			_update_answer_status()

## 是否正确
@export var is_correct: bool = false:
	set(value):
		if is_correct != value:
			is_correct = value
			_update_correct_status()

## 用户答案
@export var user_answer: String = "":
	set(value):
		if user_answer != value:
			user_answer = value
			_update_user_answer()

## 是否可展开
@export var expandable: bool = false:
	set(value):
		expandable = value

## 是否已展开
@export var is_expanded: bool = false:
	set(value):
		if is_expanded != value:
			is_expanded = value
			_update_expansion()
			question_expanded.emit(question_id, value)

# ============================================
# 内部变量（Internal Variables）
# ============================================
var _header_container: HBoxContainer
var _number_label: Label
var _type_icon: TextureRect
var _type_label: Label
var _difficulty_indicator: Control
var _score_label: Label

var _content_container: VBoxContainer
var _title_label: Label
var _content_label: RichTextLabel
var _options_container: VBoxContainer
var _options_buttons: Array[BaseButton] = []

var _footer_container: HBoxContainer
var _tags_container: HFlowContainer
var _hint_button: UIButton
var _explanation_button: UIButton
var _expand_button: UIButton

var _answer_feedback: Control
var _correct_icon: TextureRect
var _incorrect_icon: TextureRect

# 题型图标路径
const TYPE_ICONS := {
	QuestionType.MULTIPLE_CHOICE: "res://assets/icons/type_single.png",
	QuestionType.MULTI_SELECT: "res://assets/icons/type_multi.png",
	QuestionType.JUDGE: "res://assets/icons/type_judge.png",
	QuestionType.FILL_BLANK: "res://assets/icons/type_fill.png",
	QuestionType.CODE: "res://assets/icons/type_code.png",
	QuestionType.SHORT_ANSWER: "res://assets/icons/type_short.png"
}

const TYPE_NAMES := {
	QuestionType.MULTIPLE_CHOICE: "单选",
	QuestionType.MULTI_SELECT: "多选",
	QuestionType.JUDGE: "判断",
	QuestionType.FILL_BLANK: "填空",
	QuestionType.CODE: "代码",
	QuestionType.SHORT_ANSWER: "简答"
}

# ============================================
# 生命周期（Lifecycle）
# ============================================

func _ready() -> void:
	super._ready()

	# 创建组件
	_create_header()
	_create_content()
	_create_footer()
	_create_answer_feedback()

	# 初始化显示
	_update_display()

	# 设置卡片属性
	card_style = CardStyle.ELEVATED
	interactive = false

func _create_header() -> void:
	_header_container = HBoxContainer.new()
	_header_container.name = "Header"

	# 题号
	_number_label = Label.new()
	_number_label.name = "Number"
	_number_label.text = "#%d" % question_number
	_number_label.add_theme_font_size_override("font_size", UITypography.SIZE_H5)
	_number_label.add_theme_color_override("font_color", UIColors.PRIMARY_DEFAULT)
	_header_container.add_child(_number_label)

	# 题型图标
	_type_icon = TextureRect.new()
	_type_icon.name = "TypeIcon"
	_type_icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	_type_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_type_icon.custom_minimum_size = Vector2(20, 20)
	_header_container.add_child(_type_icon)

	# 题型标签
	_type_label = Label.new()
	_type_label.name = "TypeLabel"
	_type_label.add_theme_font_size_override("font_size", UITypography.SIZE_CAPTION)
	_type_label.add_theme_color_override("font_color", UIColors.TEXT_SECONDARY)
	_header_container.add_child(_type_label)

	# 分隔符
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_header_container.add_child(spacer)

	# 难度指示器
	_difficulty_indicator = _create_difficulty_indicator()
	_header_container.add_child(_difficulty_indicator)

	# 分数
	_score_label = Label.new()
	_score_label.name = "Score"
	_score_label.text = "%d分" % score
	_score_label.add_theme_font_size_override("font_size", UITypography.SIZE_CAPTION)
	_score_label.add_theme_color_override("font_color", UIColors.TEXT_SECONDARY)
	_header_container.add_child(_score_label)

	add_child(_header_container)

func _create_content() -> void:
	_content_container = VBoxContainer.new()
	_content_container.name = "Content"
	_content_container.add_theme_constant_override("separation", UISpacing.SPACE_MD)

	# 题目标题
	_title_label = Label.new()
	_title_label.name = "Title"
	_title_label.add_theme_font_size_override("font_size", UITypography.SIZE_H5)
	_title_label.add_theme_color_override("font_color", UIColors.TEXT_PRIMARY)
	_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_content_container.add_child(_title_label)

	# 题目内容
	_content_label = RichTextLabel.new()
	_content_label.name = "QuestionContent"
	_content_label.bbcode_enabled = true
	_content_label.fit_content = true
	_content_label.scroll_active = false
	_content_label.add_theme_font_size_override("normal_font_size", UITypography.SIZE_BODY)
	_content_label.add_theme_color_override("default_color", UIColors.TEXT_PRIMARY)
	_content_container.add_child(_content_label)

	# 选项容器
	_options_container = VBoxContainer.new()
	_options_container.name = "Options"
	_options_container.add_theme_constant_override("separation", UISpacing.SPACE_SM)
	_content_container.add_child(_options_container)

	add_child(_content_container)

func _create_footer() -> void:
	_footer_container = HBoxContainer.new()
	_footer_container.name = "Footer"
	_footer_container.add_theme_constant_override("separation", UISpacing.SPACE_MD)

	# 知识点标签容器
	_tags_container = HFlowContainer.new()
	_tags_container.name = "Tags"
	_footer_container.add_child(_tags_container)

	# 分隔符
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_footer_container.add_child(spacer)

	# 提示按钮
	_hint_button = UIButton.new()
	_hint_button.name = "HintButton"
	_hint_button.text = "提示"
	_hint_button.style = UIButton.ButtonStyle.GHOST
	_hint_button.size = UIButton.ButtonSize.SMALL
	_hint_button.visible = show_hint_button
	_hint_button.pressed.connect(_on_hint_pressed)
	_footer_container.add_child(_hint_button)

	# 解析按钮
	_explanation_button = UIButton.new()
	_explanation_button.name = "ExplanationButton"
	_explanation_button.text = "解析"
	_explanation_button.style = UIButton.ButtonStyle.GHOST
	_explanation_button.size = UIButton.ButtonSize.SMALL
	_explanation_button.visible = show_explanation_button
	_explanation_button.pressed.connect(_on_explanation_pressed)
	_footer_container.add_child(_explanation_button)

	# 展开/折叠按钮
	if expandable:
		_expand_button = UIButton.new()
		_expand_button.name = "ExpandButton"
		_expand_button.text = "展开" if not is_expanded else "折叠"
		_expand_button.style = UIButton.ButtonStyle.GHOST
		_expand_button.size = UIButton.ButtonSize.SMALL
		_expand_button.pressed.connect(_on_expand_pressed)
		_footer_container.add_child(_expand_button)

	add_child(_footer_container)

func _create_answer_feedback() -> void:
	_answer_feedback = PanelContainer.new()
	_answer_feedback.name = "AnswerFeedback"
	_answer_feedback.visible = false

	var style := StyleBoxFlat.new()
	style.bg_color = UIColors.with_alpha(UIColors.SUCCESS, 0.1)
	style.set_corner_radius_all(UISpacing.RADIUS_SM)
	_answer_feedback.add_theme_stylebox_override("panel", style)

	# 正确图标
	_correct_icon = TextureRect.new()
	_correct_icon.name = "CorrectIcon"
	_correct_icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	_correct_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_correct_icon.custom_minimum_size = Vector2(24, 24)
	_correct_icon.visible = false
	_answer_feedback.add_child(_correct_icon)

	# 错误图标
	_incorrect_icon = TextureRect.new()
	_incorrect_icon.name = "IncorrectIcon"
	_incorrect_icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	_incorrect_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_incorrect_icon.custom_minimum_size = Vector2(24, 24)
	_incorrect_icon.visible = false
	_answer_feedback.add_child(_incorrect_icon)

	_content_container.add_child(_answer_feedback)

func _create_difficulty_indicator() -> Control:
	var container := HBoxContainer.new()
	container.name = "DifficultyIndicator"

	# 难度星星（1-5颗）
	for i in range(5):
		var star := TextureRect.new()
		star.name = "Star_%d" % i
		star.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		star.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		star.custom_minimum_size = Vector2(12, 12)
		container.add_child(star)

	return container

func _create_option_button(option_text: String, option_index: int) -> BaseButton:
	var button: BaseButton

	if question_type == QuestionType.MULTI_SELECT:
		# 多选题使用 CheckBox
		var checkbox := CheckBox.new()
		checkbox.text = option_text
		checkbox.toggled.connect(_on_option_toggled.bind(option_index))
		button = checkbox
	else:
		# 单选题使用普通按钮
		var btn := UIButton.new()
		btn.text = option_text
		btn.style = UIButton.ButtonStyle.GHOST
		btn.pressed.connect(_on_option_pressed.bind(option_index))
		button = btn

	button.name = "Option_%d" % option_index
	button.set_meta("option_index", option_index)
	button.set_meta("option_text", option_text)

	return button

func _create_tag_label(tag: String) -> Label:
	var label := Label.new()
	label.text = tag
	label.add_theme_font_size_override("font_size", UITypography.SIZE_CAPTION)
	label.add_theme_color_override("font_color", UIColors.TEXT_SECONDARY)

	# 添加背景
	var style := StyleBoxFlat.new()
	style.bg_color = UIColors.with_alpha(UIColors.BG_CARD, 0.5)
	style.set_corner_radius_all(UISpacing.RADIUS_SM)
	style.set_content_margin_all(4)
	label.add_theme_stylebox_override("normal", style)

	return label

# ============================================
# 更新方法（Update Methods）
# ============================================

func _update_display() -> void:
	_update_header()
	_update_title()
	_update_content()
	_update_options()
	_update_tags()
	_update_answer_status()

func _update_header() -> void:
	if _number_label:
		_number_label.text = "#%d" % question_number

	if _score_label:
		_score_label.text = "%d分" % score

func _update_title() -> void:
	if _title_label:
		_title_label.text = question_title

func _update_content() -> void:
	if _content_label:
		_content_label.text = question_content

func _update_options() -> void:
	# 清除现有选项
	if _options_container:
		for child in _options_container.get_children():
			child.queue_free()
		_options_buttons.clear()

	# 创建新选项
	for i in range(question_options.size()):
		var option := question_options[i]
		var button := _create_option_button(option, i)
		_options_buttons.append(button)
		_options_container.add_child(button)

	# 恢复用户选择
	_restore_user_answer()

func _update_tags() -> void:
	if not _tags_container:
		return

	# 清除现有标签
	for child in _tags_container.get_children():
		child.queue_free()

	# 创建新标签
	for tag in knowledge_tags:
		var label := _create_tag_label(tag)
		_tags_container.add_child(label)

func _update_type_indicator() -> void:
	if _type_icon:
		var icon_path := TYPE_ICONS.get(question_type, "")
		if ResourceLoader.exists(icon_path):
			_type_icon.texture = load(icon_path)

	if _type_label:
		_type_label.text = TYPE_NAMES.get(question_type, "")

func _update_difficulty_indicator() -> void:
	if not _difficulty_indicator:
		return

	var difficulty_level := difficulty + 1  # 1-5
	var stars := _difficulty_indicator.get_children()

	for i in range(stars.size()):
		var star := stars[i] as TextureRect
		if star:
			var is_filled := i < difficulty_level
			var star_path := "res://assets/icons/star_filled.png" if is_filled else "res://assets/icons/star_empty.png"
			if ResourceLoader.exists(star_path):
				star.texture = load(star_path)
			star.modulate = UIColors.WARNING if is_filled else UIColors.TEXT_DISABLED

func _update_score() -> void:
	if _score_label:
		_score_label.text = "%d分" % score

func _update_answer_status() -> void:
	if not _answer_feedback:
		return

	_answer_feedback.visible = is_answered

	if is_answered:
		_correct_icon.visible = is_correct
		_incorrect_icon.visible = not is_correct

		# 更新背景颜色
		var style := _answer_feedback.get_theme_stylebox("panel") as StyleBoxFlat
		if style:
			if is_correct:
				style.bg_color = UIColors.with_alpha(UIColors.SUCCESS, 0.1)
			else:
				style.bg_color = UIColors.with_alpha(UIColors.ERROR, 0.1)

func _update_correct_status() -> void:
	_update_answer_status()

func _update_user_answer() -> void:
	_restore_user_answer()

func _restore_user_answer() -> void:
	if user_answer == "" or _options_buttons.is_empty():
		return

	# 根据题型恢复答案
	if question_type == QuestionType.MULTI_SELECT:
		# 多选题：答案格式如 "A,B,C"
		var selected := user_answer.split(",")
		for btn in _options_buttons:
			if btn is CheckBox:
				var index: int = btn.get_meta("option_index")
				var option_key := _get_option_key(index)
				btn.button_pressed = option_key in selected
	else:
		# 单选题
		for btn in _options_buttons:
			if btn is UIButton:
				var index: int = btn.get_meta("option_index")
				var option_key := _get_option_key(index)
				if option_key == user_answer:
					_select_option(index)
					break

func _update_expansion() -> void:
	# TODO: 实现展开/折叠动画
	if _expand_button:
		_expand_button.text = "展开" if not is_expanded else "折叠"

# ============================================
# 事件处理（Event Handling）
# ============================================

func _on_option_pressed(index: int) -> void:
	_select_option(index)
	var answer := _get_option_key(index)
	answer_changed.emit(question_id, answer)

	# 自动提交
	_submit_answer(answer)

func _on_option_toggled(index: int, is_pressed: bool) -> void:
	# 多选题：更新选中状态
	var answer := _get_multi_select_answer()
	answer_changed.emit(question_id, answer)

func _on_hint_pressed() -> void:
	hint_requested.emit(question_id)
	_play_sound("ui_click")

func _on_explanation_pressed() -> void:
	explanation_requested.emit(question_id)
	_play_sound("ui_click")

func _on_expand_pressed() -> void:
	is_expanded = not is_expanded

# ============================================
# 答题逻辑（Answer Logic）
# ============================================

func _select_option(index: int) -> void:
	# 更新选项样式
	for i in range(_options_buttons.size()):
		var btn := _options_buttons[i]
		if btn is UIButton:
			if i == index:
				btn.style = UIButton.ButtonStyle.PRIMARY
			else:
				btn.style = UIButton.ButtonStyle.GHOST

func _get_option_key(index: int) -> String:
	# A, B, C, D...
	return char(ord('A') + index)

func _get_multi_select_answer() -> String:
	# 获取多选题答案（如 "A,C"）
	var selected: Array[String] = []
	for btn in _options_buttons:
		if btn is CheckBox and btn.button_pressed:
			var index: int = btn.get_meta("option_index")
			selected.append(_get_option_key(index))
	selected.sort()
	return ",".join(selected)

func _submit_answer(answer: String) -> void:
	# TODO: 验证答案正确性
	# 这里需要与题库系统集成
	var correct := false  # 临时变量

	is_answered = true
	is_correct = correct
	answer_submitted.emit(question_id, answer, correct)

	_play_sound("ui_submit")

# ============================================
# 公共方法（Public Methods）
# ============================================

## 设置题目数据
func set_question_data(data: Dictionary) -> void:
	question_id = data.get("id", "")
	question_number = data.get("number", 1)
	question_type = data.get("type", QuestionType.MULTIPLE_CHOICE)
	question_title = data.get("title", "")
	question_content = data.get("content", "")
	question_options = data.get("options", [])
	difficulty = data.get("difficulty", QuestionDifficulty.MEDIUM)
	knowledge_tags = data.get("tags", [])
	score = data.get("score", 10)

## 提交答案
func submit_answer(answer: String) -> void:
	user_answer = answer
	_submit_answer(answer)

## 显示答案结果
func show_result(correct: bool) -> void:
	is_answered = true
	is_correct = correct

## 设置用户答案
func set_user_answer(answer: String) -> void:
	user_answer = answer
	_restore_user_answer()

## 获取用户答案
func get_user_answer() -> String:
	return user_answer

## 重置题目
func reset_question() -> void:
	is_answered = false
	is_correct = false
	user_answer = ""

	# 清除选择状态
	for btn in _options_buttons:
		if btn is CheckBox:
			btn.button_pressed = false
		elif btn is UIButton:
			btn.style = UIButton.ButtonStyle.GHOST

## 播放音效
func _play_sound(sound_id: String) -> void:
	# AudioManager.play_ui_sound(sound_id)
	pass