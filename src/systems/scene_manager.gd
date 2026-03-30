## SceneManager.gd
## 场景管理器 (AutoLoad)
## 管理场景切换、过渡动画、场景栈
extends Node

# 信号
signal scene_changed(scene_name: String)
signal transition_started()
signal transition_completed()

# 场景枚举
enum SceneType {
	MAIN_MENU,
	PRACTICE,
	BOSS_INTERVIEW,
	SETTINGS,
	REALM_BREAKTHROUGH,
}

# 配置
const TRANSITION_DURATION: float = 0.3

# 状态
var _current_scene: String = ""
var _scene_stack: Array[String] = []
var _is_transitioning: bool = false

# 场景路径映射
var _scene_paths: Dictionary = {
	SceneType.MAIN_MENU: "res://scenes/main_menu.tscn",
	SceneType.PRACTICE: "res://scenes/practice.tscn",
	SceneType.BOSS_INTERVIEW: "res://scenes/boss_interview.tscn",
	SceneType.SETTINGS: "res://scenes/settings.tscn",
	SceneType.REALM_BREAKTHROUGH: "res://scenes/realm_breakthrough.tscn",
}


func _ready() -> void:
	# 记录初始场景
	_current_scene = get_tree().current_scene.scene_file_path


## 切换到指定场景
func change_scene(scene_type: SceneType) -> void:
	if _is_transitioning:
		push_warning("[SceneManager] Already transitioning")
		return

	var scene_path: String = _scene_paths.get(scene_type, "")
	if scene_path.is_empty():
		push_error("[SceneManager] Unknown scene type: %d" % scene_type)
		return

	_await_transition(scene_path)


## 切换到指定路径场景
func change_scene_by_path(scene_path: String) -> void:
	if _is_transitioning:
		return

	_await_transition(scene_path)


## 异步过渡
func _await_transition(scene_path: String) -> void:
	_is_transitioning = true
	transition_started.emit()

	# 保存当前场景到栈
	if not _current_scene.is_empty():
		_scene_stack.append(_current_scene)

	# 淡出效果
	await _fade_out()

	# 切换场景
	var result := get_tree().change_scene_to_file(scene_path)
	if result != OK:
		push_error("[SceneManager] Failed to change scene to %s" % scene_path)
		_is_transitioning = false
		return

	_current_scene = scene_path

	# 等待一帧让场景加载
	await get_tree().process_frame

	# 淡入效果
	await _fade_in()

	_is_transitioning = false
	transition_completed.emit()
	scene_changed.emit(scene_path)


## 淡出效果
func _fade_out() -> void:
	# TODO: 实现实际的淡出动画
	# 目前使用简单的延迟模拟
	await get_tree().create_timer(TRANSITION_DURATION / 2).timeout


## 淡入效果
func _fade_in() -> void:
	# TODO: 实现实际的淡入动画
	await get_tree().create_timer(TRANSITION_DURATION / 2).timeout


## 返回上一场景
func go_back() -> bool:
	if _scene_stack.is_empty():
		push_warning("[SceneManager] No previous scene to go back to")
		return false

	var previous_scene: String = _scene_stack.pop_back()
	_await_transition(previous_scene)
	return true


## 获取当前场景路径
func get_current_scene() -> String:
	return _current_scene


## 获取场景栈深度
func get_stack_depth() -> int:
	return _scene_stack.size()


## 清空场景栈
func clear_stack() -> void:
	_scene_stack.clear()


## 注册自定义场景路径
func register_scene(scene_type: SceneType, path: String) -> void:
	_scene_paths[scene_type] = path


## 重新加载当前场景
func reload_current_scene() -> void:
	if _current_scene.is_empty():
		return

	get_tree().reload_current_scene()


## 切换到主菜单
func go_to_main_menu() -> void:
	change_scene(SceneType.MAIN_MENU)


## 切换到修炼场景
func go_to_practice() -> void:
	change_scene(SceneType.PRACTICE)


## 切换到BOSS面试场景
func go_to_boss_interview() -> void:
	change_scene(SceneType.BOSS_INTERVIEW)


## 切换到设置场景
func go_to_settings() -> void:
	change_scene(SceneType.SETTINGS)