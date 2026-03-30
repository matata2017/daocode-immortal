## AudioManager.gd
## 音频管理器 (AutoLoad)
## 管理BGM、SFX播放和音量控制
extends Node

# 信号
signal volume_changed(bus_name: String, volume: float)

# 音频总线名称
const BUS_MASTER: String = "Master"
const BUS_BGM: String = "BGM"
const BUS_SFX: String = "SFX"

# BGM播放器
var _bgm_player: AudioStreamPlayer
var _bgm_queue: Array[AudioStream] = []
var _is_bgm_playing: bool = false

# SFX池（同时播放多个音效）
var _sfx_pool: Array[AudioStreamPlayer] = []
const SFX_POOL_SIZE: int = 8

# 配置
@export var default_bgm_volume: float = 0.8
@export var default_sfx_volume: float = 1.0
@export var fade_duration: float = 1.0

# 调试
@export var debug_mode: bool = false


func _ready() -> void:
	# 确保音频总线存在
	_ensure_audio_buses()

	# 初始化BGM播放器
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.bus = BUS_BGM
	add_child(_bgm_player)
	_bgm_player.finished.connect(_on_bgm_finished)

	# 初始化SFX池
	for i: int in SFX_POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.bus = BUS_SFX
		add_child(player)
		_sfx_pool.append(player)

	# 从存档加载音量设置
	_load_volume_settings()


## 确保音频总线存在
func _ensure_audio_buses() -> void:
	var layout := AudioServer.get_bus_layout()

	# 检查并创建BGM总线
	if AudioServer.get_bus_index(BUS_BGM) == -1:
		AudioServer.add_bus(AudioServer.get_bus_count())
		AudioServer.set_bus_name(AudioServer.get_bus_count() - 1, BUS_BGM)
		AudioServer.set_bus_send(AudioServer.get_bus_count() - 1, BUS_MASTER)

	# 检查并创建SFX总线
	if AudioServer.get_bus_index(BUS_SFX) == -1:
		AudioServer.add_bus(AudioServer.get_bus_count())
		AudioServer.set_bus_name(AudioServer.get_bus_count() - 1, BUS_SFX)
		AudioServer.set_bus_send(AudioServer.get_bus_count() - 1, BUS_MASTER)


## 从存档加载音量设置
func _load_volume_settings() -> void:
	# 如果SaveSystem已加载，读取设置
	if SaveSystem and SaveSystem._is_loaded:
		var master_vol: float = SaveSystem.get_setting("volume_master", 1.0)
		var bgm_vol: float = SaveSystem.get_setting("volume_bgm", default_bgm_volume)
		var sfx_vol: float = SaveSystem.get_setting("volume_sfx", default_sfx_volume)

		set_bus_volume(BUS_MASTER, master_vol)
		set_bus_volume(BUS_BGM, bgm_vol)
		set_bus_volume(BUS_SFX, sfx_vol)


# ============================================
# BGM 控制
# ============================================

## 播放BGM
func play_bgm(stream: AudioStream, fade_in: bool = true) -> void:
	if _bgm_player.stream == stream and _is_bgm_playing:
		return  # 已经在播放

	if fade_in and _is_bgm_playing:
		# 淡出当前BGM，然后播放新的
		await _fade_out_bgm()

	_bgm_player.stream = stream
	_bgm_player.volume_db = linear_to_db(1.0) if not fade_in else linear_to_db(0.0)
	_bgm_player.play()
	_is_bgm_playing = true

	if fade_in:
		_fade_in_bgm()

	if debug_mode:
		print("[AudioManager] Playing BGM: %s" % stream.resource_path)


## 停止BGM
func stop_bgm(fade_out: bool = true) -> void:
	if not _is_bgm_playing:
		return

	if fade_out:
		await _fade_out_bgm()
	else:
		_bgm_player.stop()

	_is_bgm_playing = false


## 暂停BGM
func pause_bgm() -> void:
	_bgm_player.stream_paused = true


## 恢复BGM
func resume_bgm() -> void:
	_bgm_player.stream_paused = false


## BGM播放完成回调
func _on_bgm_finished() -> void:
	_is_bgm_playing = false

	# 如果有队列，播放下一首
	if not _bgm_queue.is_empty():
		var next_stream: AudioStream = _bgm_queue.pop_front()
		play_bgm(next_stream)


## 淡入BGM
func _fade_in_bgm() -> void:
	var tween := create_tween()
	tween.tween_method(_set_bgm_volume, 0.0, 1.0, fade_duration)
	await tween.finished


## 淡出BGM
func _fade_out_bgm() -> void:
	var tween := create_tween()
	tween.tween_method(_set_bgm_volume, 1.0, 0.0, fade_duration)
	await tween.finished
	_bgm_player.stop()


## 设置BGM音量（0.0-1.0）
func _set_bgm_volume(volume: float) -> void:
	_bgm_player.volume_db = linear_to_db(clamp(volume, 0.0, 1.0))


# ============================================
# SFX 控制
# ============================================

## 播放音效
func play_sfx(stream: AudioStream, volume: float = 1.0) -> void:
	# 找一个空闲的播放器
	for player: AudioStreamPlayer in _sfx_pool:
		if not player.playing:
			player.stream = stream
			player.volume_db = linear_to_db(volume)
			player.play()

			if debug_mode:
				print("[AudioManager] Playing SFX: %s" % stream.resource_path)
			return

	# 没有空闲播放器，复用第一个
	push_warning("[AudioManager] SFX pool exhausted, reusing first player")
	_sfx_pool[0].stream = stream
	_sfx_pool[0].volume_db = linear_to_db(volume)
	_sfx_pool[0].play()


## 停止所有音效
func stop_all_sfx() -> void:
	for player: AudioStreamPlayer in _sfx_pool:
		player.stop()


# ============================================
# 音量控制
# ============================================

## 设置总线音量
func set_bus_volume(bus_name: String, volume: float) -> void:
	var bus_idx: int = AudioServer.get_bus_index(bus_name)
	if bus_idx == -1:
		push_warning("[AudioManager] Bus not found: %s" % bus_name)
		return

	var volume_db: float = linear_to_db(clamp(volume, 0.0, 1.0))
	AudioServer.set_bus_volume_db(bus_idx, volume_db)

	# 保存到存档
	if SaveSystem and SaveSystem._is_loaded:
		SaveSystem.set_setting("volume_%s" % bus_name.to_lower(), volume)

	volume_changed.emit(bus_name, volume)

	if debug_mode:
		print("[AudioManager] Set %s volume to %.2f" % [bus_name, volume])


## 获取总线音量
func get_bus_volume(bus_name: String) -> float:
	var bus_idx: int = AudioServer.get_bus_index(bus_name)
	if bus_idx == -1:
		return 0.0

	return db_to_linear(AudioServer.get_bus_volume_db(bus_idx))


## 静音总线
func set_bus_mute(bus_name: String, mute: bool) -> void:
	var bus_idx: int = AudioServer.get_bus_index(bus_name)
	if bus_idx == -1:
		return

	AudioServer.set_bus_mute(bus_idx, mute)


## 切换静音
func toggle_bus_mute(bus_name: String) -> bool:
	var bus_idx: int = AudioServer.get_bus_index(bus_name)
	if bus_idx == -1:
		return false

	var current: bool = AudioServer.is_bus_mute(bus_idx)
	AudioServer.set_bus_mute(bus_idx, not current)
	return not current


# ============================================
# 便捷方法
# ============================================

## 播放点击音效
func play_click() -> void:
	# TODO: 加载点击音效资源
	# var click_sfx = preload("res://assets/audio/sfx/click.wav")
	# play_sfx(click_sfx)
	pass


## 播放正确答案音效
func play_correct() -> void:
	# TODO: 加载正确音效
	pass


## 播放错误答案音效
func play_wrong() -> void:
	# TODO: 加载错误音效
	pass


## 播放境界突破音效
func play_breakthrough() -> void:
	# TODO: 加载突破音效
	pass


## 线性到分贝转换
static func linear_to_db(linear: float) -> float:
	if linear <= 0.0:
		return -80.0
	return 20.0 * log(linear) / log(10.0)


## 分贝到线性转换
static func db_to_linear(db: float) -> float:
	return pow(10.0, db / 20.0)