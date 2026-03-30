extends Control

class_name Main

# 原型： Core Loop Validation
# 道码修仙 - 核心循环验证
# 快速验证"答题→修为→境界→BOSS面试"是否有用/有趣

# 单人开发，6周完成 MVP

const SAMPLE_QUESTIONS_PATH = "res://data/sample_questions.json"
const REALMS_PATH = "res://data/realms.json"

const CULTIVATION_LABEL_PATH = "CultivationLabel"
const REALM_LABEL_PATH = "RealmLabel"

var questions: Array = []
var current_question: Dictionary = {}
var current_index: int = 0
var score: int = 0
var realm_index: int = 0

# Realm thresholds (原型测试用，降低了阈值)
const REALM_THRESHOLDS = [0, 25, 45, 60, 100]
const REALM_NAMES = ["炼气期", "筑基期", "金丹期", "元婴期", "化神期"]
const REALM_COLORS = [
	Color(0.565, 0.792, 0.988),  # Light Blue
	Color(0.647, 0.839, 0.655),  # Light Green
	Color(1.0, 0.835, 0.310),  # Gold
	Color(1.0, 0.541, 0.396),  # Orange
	Color(0.812, 0.576, 0.847),  # Purple
]

func _ready():
	_load_data()
	_show_next_question()

func _load_data():
	_load_questions()
	_load_realms()
	_update_display()

func _load_questions():
	var file = FileAccess.open(SAMPLE_QUESTIONS_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			questions = json.data
			print("Loaded ", questions.size(), " questions")
		else:
			push_error("Failed to parse questions: ", parse_result)
	else:
		push_error("Failed to load questions file")

func _load_realms():
	# Realms are defined inline for prototype
	print("Realms loaded: ", REALM_NAMES)

func _update_display():
	$CultivationLabel.text = "修为: " + str(score)
	$RealmLabel.text = "境界: " + REALM_NAMES[realm_index]
	$RealmLabel.modulate = REALM_COLORS[realm_index]

func _show_next_question():
	if current_index >= questions.size():
		_show_game_over()
		return

	current_question = questions[current_index]
	$QuestionLabel.text = current_question["question"]

	# Clear old options
	for child in $OptionsContainer.get_children():
		child.queue_free()

	# Create option buttons
	for i in range(current_question["options"].size()):
		var button = Button.new()
		button.text = current_question["options"][i]
		button.button_up.connect(_on_option_selected.bind(i))
		$OptionsContainer.add_child(button)

	# Reset realm label to normal format after breakthrough animation
	$RealmLabel.text = "境界: " + REALM_NAMES[realm_index]

func _on_option_selected(index: int):
	if index == current_question["correct_answer"]:
		_correct_answer()
	else:
		_wrong_answer()

func _correct_answer():
	var base_score = current_question["base_score"]
	score += base_score
	$FeedbackLabel.text = "✓ 正确! 修为 +" + str(base_score)
	$FeedbackLabel.modulate = Color(0.4, 1.0, 0.4)  # Green
	_update_display()

	await _check_realm_up()
	_next_question()

func _wrong_answer():
	var penalty = 5
	score = max(0, score - penalty)
	$FeedbackLabel.text = "✗ 错误! 修为 -" + str(penalty)
	$FeedbackLabel.modulate = Color(1.0, 0.4, 0.4)  # Red
	
	_update_display()
	_next_question()

func _check_realm_up():
	while realm_index < REALM_THRESHOLDS.size() - 1 and score >= REALM_THRESHOLDS[realm_index + 1]:
		realm_index += 1
		await _show_realm_up_animation()

func _show_realm_up_animation():
	# Flash effect
	$RealmLabel.modulate = Color.WHITE
	await get_tree().create_timer(0.15).timeout
	$RealmLabel.modulate = REALM_COLORS[realm_index]
	$RealmLabel.text = "★ 境界提升! " + REALM_NAMES[realm_index] + " ★"
	# Wait so player can see the message
	await get_tree().create_timer(1.0).timeout

func _next_question():
	current_index += 1
	await get_tree().create_timer(1.0).timeout
	_show_next_question()

func _show_game_over():
	$GameOverPanel.visible = true
	$GameOverPanel/FinalScoreLabel.text = "最终修为: " + str(score) + "\n最终境界: " + REALM_NAMES[realm_index]

func _on_restart_button_up():
	# Reset game state
	current_index = 0
	score = 0
	realm_index = 0
	$GameOverPanel.visible = false
	_update_display()
	_show_next_question()
