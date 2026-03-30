## 自定义进度条组件
## 支持平滑动画、渐变填充、多种显示模式
@tool
class_name UIProgressBar
extends Range

# ============================================
# 信号（Signals）
# ============================================
## 进度变化时发出
signal progress_changed(old_value: float, new_value: float)
## 进度完成时发出
signal progress_completed()
## 动画完成时发出
signal animation_completed()

# ============================================
# 导出属性（Export Properties）
# ============================================

## 进度条样式
enum ProgressBarStyle {
	DEFAULT,    ## 默认样式 - 纯色填充
	GRADIENT,   ## 渐变样式 - 从左到右渐变
	SEGMENTED,  ## 分段样式 - 多个小段
	PULSE       ## 脉冲样式 - 带脉冲动画
}

## 进度条方向
enum ProgressBarDirection {
	LEFT_TO_RIGHT,   ## 从左到右
	RIGHT_TO_LEFT,   ## 从右到左
	BOTTOM_TO_TOP,   ## 从下到上
	TOP_TO_BOTTOM    ## 从上到下
}

## 进度显示格式
enum ProgressLabelFormat {
	NONE,           ## 不显示
	PERCENTAGE,     ## 百分比 (0%)
	FRACTION,       ## 分数 (0/100)
	VALUE_ONLY,     ## 仅值 (0)
	CUSTOM          ## 自定义格式
}

@export var bar_style: ProgressBarStyle = ProgressBarStyle.DEFAULT:
	set(value):
		if bar_style != value:
			bar_style = value
			queue_redraw()

@export var direction: ProgressBarDirection = ProgressBarDirection.LEFT_TO_RIGHT:
	set(value):
		if direction != value:
			direction = value
			queue_redraw()

@export var label_format: ProgressLabelFormat = ProgressLabelFormat.PERCENTAGE:
	set(value):
		if label_format != value:
			label_format = value
			_update_label()

## 自定义标签格式字符串（使用 {value}, {max}, {percent} 占位符）
@export var custom_label_format: String = "{percent}%"

## 是否显示标签
@export var show_label: bool = true:
	set(value):
		if show_label != value:
			show_label = value
			if _label:
				_label.visible = value

## 是否启用平滑动画
@export var enable_animation: bool = true

## 动画持续时间（秒）
@export_range(0.1, 2.0, 0.1) var animation_duration: float = 0.3

## 动画曲线
@export var animation_curve: Curve

## 背景颜色
@export var background_color: Color = UIColors.BG_SECONDARY:
	set(value):
		if background_color != value:
			background_color = value
			queue_redraw()

## 填充颜色（DEFAULT 样式）
@export var fill_color: Color = UIColors.PRIMARY_DEFAULT:
	set(value):
		if fill_color != value:
			fill_color = value
			queue_redraw()

## 渐变起始颜色（GRADIENT 样式）
@export var gradient_start_color: Color = UIColors.PRIMARY_DARK:
	set(value):
		if gradient_start_color != value:
			gradient_start_color = value
			queue_redraw()

## 渐变结束颜色（GRADIENT 样式）
@export var gradient_end_color: Color = UIColors.PRIMARY_LIGHT:
	set(value):
		if gradient_end_color != value:
			gradient_end_color = value
			queue_redraw()

## 分段数量（SEGMENTED 样式）
@export_range(2, 20, 1) var segment_count: int = 10:
	set(value):
		if segment_count != value:
			segment_count = value
			queue_redraw()

## 分段间距（SEGMENTED 样式）
@export var segment_gap: int = 4:
	set(value):
		if segment_gap != value:
			segment_gap = value
			queue_redraw()

## 脉冲速度（PULSE 样式）
@export_range(0.5, 3.0, 0.1) var pulse_speed: float = 1.0

## 圆角半径
@export var corner_radius: int = UISpacing.RADIUS_MD:
	set(value):
		if corner_radius != value:
			corner_radius = value
			queue_redraw()

## 边框宽度
@export var border_width: int = UISpacing.BORDER_THIN:
	set(value):
		if border_width != value:
			border_width = value
			queue_redraw()

## 边框颜色
@export var border_color: Color = UIColors.BORDER_DEFAULT:
	set(value):
		if border_color != value:
			border_color = value
			queue_redraw()

# ============================================
# 内部变量（Internal Variables）
# ============================================
var _display_value: float = 0.0
var _target_value: float = 0.0
var _animation_tween: Tween
var _label: Label
var _is_animating: bool = false
var _pulse_time: float = 0.0

# ============================================
# 生命周期（Lifecycle）
# ============================================

func _ready() -> void:
	# 初始化显示值
	_display_value = value
	_target_value = value

	# 创建标签
	_create_label()

	# 连接值变化信号
	value_changed.connect(_on_value_changed)

	# 设置最小尺寸
	custom_minimum_size = Vector2(100, 20)

func _process(delta: float) -> void:
	# 处理脉冲动画
	if bar_style == ProgressBarStyle.PULSE and _display_value > 0:
		_pulse_time += delta * pulse_speed
		queue_redraw()

func _draw() -> void:
	var rect := get_rect()
	var size := rect.size

	# 绘制背景
	_draw_background(size)

	# 绘制填充
	if _display_value > 0:
		_draw_fill(size)

	# 绘制边框
	if border_width > 0:
		_draw_border(size)

# ============================================
# 绘制方法（Drawing Methods）
# ============================================

## 绘制背景
func _draw_background(size: Vector2) -> void:
	var bg_rect := Rect2(Vector2.ZERO, size)
	var style := StyleBoxFlat.new()
	style.bg_color = background_color
	style.set_corner_radius_all(corner_radius)
	style.draw(get_canvas_item(), bg_rect)

## 绘制填充
func _draw_fill(size: Vector2) -> void:
	var fill_ratio := _display_value / max_value
	var fill_rect := _calculate_fill_rect(size, fill_ratio)

	match bar_style:
		ProgressBarStyle.DEFAULT:
			_draw_default_fill(fill_rect)
		ProgressBarStyle.GRADIENT:
			_draw_gradient_fill(fill_rect, fill_ratio)
		ProgressBarStyle.SEGMENTED:
			_draw_segmented_fill(size, fill_ratio)
		ProgressBarStyle.PULSE:
			_draw_pulse_fill(fill_rect)

## 计算填充矩形
func _calculate_fill_rect(size: Vector2, ratio: float) -> Rect2:
	var fill_size: Vector2
	var fill_position: Vector2

	match direction:
		ProgressBarDirection.LEFT_TO_RIGHT:
			fill_size = Vector2(size.x * ratio, size.y)
			fill_position = Vector2.ZERO
		ProgressBarDirection.RIGHT_TO_LEFT:
			fill_size = Vector2(size.x * ratio, size.y)
			fill_position = Vector2(size.x - fill_size.x, 0)
		ProgressBarDirection.BOTTOM_TO_TOP:
			fill_size = Vector2(size.x, size.y * ratio)
			fill_position = Vector2(0, size.y - fill_size.y)
		ProgressBarDirection.TOP_TO_BOTTOM:
			fill_size = Vector2(size.x, size.y * ratio)
			fill_position = Vector2.ZERO

	return Rect2(fill_position, fill_size)

## 绘制默认填充
func _draw_default_fill(fill_rect: Rect2) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color
	style.set_corner_radius_all(corner_radius)
	style.draw(get_canvas_item(), fill_rect)

## 绘制渐变填充
func _draw_gradient_fill(fill_rect: Rect2, ratio: float) -> void:
	# 创建渐变
	var gradient := Gradient.new()
	gradient.add_point(0.0, gradient_start_color)
	gradient.add_point(1.0, gradient_end_color)

	# 根据方向设置渐变方向
	var gradient_direction: int
	match direction:
		ProgressBarDirection.LEFT_TO_RIGHT, ProgressBarDirection.RIGHT_TO_LEFT:
			gradient_direction = GradientTexture2D.GRADIENT_HORIZONTAL
		_:
			gradient_direction = GradientTexture2D.GRADIENT_VERTICAL

	var gradient_tex := GradientTexture2D.new()
	gradient_tex.gradient = gradient
	gradient_tex.fill_from = Vector2.ZERO
	gradient_tex.fill_to = Vector2.ONE
	gradient_tex.fill = gradient_direction

	# 绘制渐变矩形
	draw_texture_rect(gradient_tex, fill_rect, false)

## 绘制分段填充
func _draw_segmented_fill(size: Vector2, ratio: float) -> void:
	var filled_segments := int(segment_count * ratio)
	var segment_width := (size.x - segment_gap * (segment_count - 1)) / segment_count
	var segment_height := size.y

	for i in range(segment_count):
		var segment_x := i * (segment_width + segment_gap)
		var segment_rect := Rect2(segment_x, 0, segment_width, segment_height)

		var segment_color: Color
		if i < filled_segments:
			segment_color = fill_color
		else:
			segment_color = UIColors.with_alpha(fill_color, 0.2)

		var style := StyleBoxFlat.new()
		style.bg_color = segment_color
		style.set_corner_radius_all(corner_radius)
		style.draw(get_canvas_item(), segment_rect)

## 绘制脉冲填充
func _draw_pulse_fill(fill_rect: Rect2) -> void:
	# 基础填充
	_draw_default_fill(fill_rect)

	# 脉冲效果
	var pulse_alpha := 0.3 + 0.2 * sin(_pulse_time * PI * 2)
	var pulse_color := Color(1, 1, 1, pulse_alpha)

	# 绘制脉冲叠加层
	var pulse_rect := fill_rect
	pulse_rect.size.x = min(fill_rect.size.x * 0.3, fill_rect.size.x)

	draw_rect(pulse_rect, pulse_color)

## 绘制边框
func _draw_border(size: Vector2) -> void:
	var border_rect := Rect2(Vector2.ZERO, size)
	var style := StyleBoxFlat.new()
	style.bg_color = Color.TRANSPARENT
	style.set_border_width_all(border_width)
	style.border_color = border_color
	style.set_corner_radius_all(corner_radius)
	style.draw(get_canvas_item(), border_rect)

# ============================================
# 标签管理（Label Management）
# ============================================

## 创建标签
func _create_label() -> void:
	_label = Label.new()
	_label.name = "ProgressLabel"
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.size_flags_horizontal = Control.SIZE_FILL
	_label.size_flags_vertical = Control.SIZE_FILL
	_label.visible = show_label
	add_child(_label)

	# 设置标签样式
	if ThemeManager and ThemeManager.current_theme:
		_label.theme = ThemeManager.current_theme

	_update_label()

## 更新标签文本
func _update_label() -> void:
	if not _label:
		return

	var text := ""
	var percent := round((_display_value / max_value) * 100) if max_value > 0 else 0

	match label_format:
		ProgressLabelFormat.NONE:
			text = ""
		ProgressLabelFormat.PERCENTAGE:
			text = "%d%%" % percent
		ProgressLabelFormat.FRACTION:
			text = "%d/%d" % [_display_value, max_value]
		ProgressLabelFormat.VALUE_ONLY:
			text = "%d" % _display_value
		ProgressLabelFormat.CUSTOM:
			text = custom_label_format.format({
				"value": _display_value,
				"max": max_value,
				"percent": percent
			})

	_label.text = text

# ============================================
# 动画（Animation）
# ============================================

## 平滑更新值
func _animate_to_value(target: float) -> void:
	if not enable_animation or ThemeManager.should_skip_animation():
		_display_value = target
		queue_redraw()
		_update_label()
		_check_completion()
		return

	_target_value = target
	_is_animating = true

	# 停止之前的动画
	if _animation_tween:
		_animation_tween.kill()

	# 创建新动画
	_animation_tween = create_tween()
	_animation_tween.set_ease(Tween.EASE_OUT)
	_animation_tween.set_trans(Tween.TRANS_CUBIC)

	# 使用曲线或默认曲线
	if animation_curve:
		_animation_tween.tween_method(_set_display_value, _display_value, target, animation_duration).set_ease(Tween.EASE_OUT)
	else:
		_animation_tween.tween_method(_set_display_value, _display_value, target, animation_duration)

	_animation_tween.tween_callback(_on_animation_finished)

## 设置显示值（用于动画）
func _set_display_value(val: float) -> void:
	_display_value = val
	queue_redraw()
	_update_label()

## 动画完成回调
func _on_animation_finished() -> void:
	_is_animating = false
	animation_completed.emit()
	_check_completion()

## 检查是否完成
func _check_completion() -> void:
	if _display_value >= max_value:
		progress_completed.emit()

# ============================================
# 事件处理（Event Handling）
# ============================================

func _on_value_changed(new_value: float) -> void:
	var old_value := _display_value

	# 平滑动画
	_animate_to_value(new_value)

	# 发出进度变化信号
	progress_changed.emit(old_value, new_value)

# ============================================
# 公共方法（Public Methods）
# ============================================

## 设置进度值（带动画）
func set_progress(new_value: float, animate: bool = true) -> void:
	if animate and enable_animation:
		value = new_value
	else:
		_display_value = new_value
		value = new_value
		queue_redraw()
		_update_label()

## 设置进度百分比
func set_progress_percent(percent: float, animate: bool = true) -> void:
	set_progress(max_value * (percent / 100.0), animate)

## 立即设置进度（无动画）
func set_progress_immediate(new_value: float) -> void:
	set_progress(new_value, false)

## 增加进度
func increase_progress(amount: float = 1.0, animate: bool = true) -> void:
	set_progress(value + amount, animate)

## 减少进度
func decrease_progress(amount: float = 1.0, animate: bool = true) -> void:
	set_progress(value - amount, animate)

## 重置进度
func reset_progress(animate: bool = true) -> void:
	set_progress(min_value, animate)

## 设置最大值并调整当前值
func set_max_value(new_max: float, preserve_ratio: bool = false) -> void:
	var ratio := value / max_value if max_value > 0 else 0.0
	max_value = new_max

	if preserve_ratio:
		value = new_max * ratio

	queue_redraw()
	_update_label()

## 设置颜色
func set_fill_color(color: Color) -> void:
	fill_color = color

## 设置渐变颜色
func set_gradient_colors(start: Color, end: Color) -> void:
	gradient_start_color = start
	gradient_end_color = end
	bar_style = ProgressBarStyle.GRADIENT

## 获取当前百分比
func get_percent() -> float:
	return (value / max_value) * 100 if max_value > 0 else 0.0

## 是否正在动画
func is_animating() -> bool:
	return _is_animating

## 跳过动画
func skip_animation() -> void:
	if _is_animating:
		if _animation_tween:
			_animation_tween.kill()
		_display_value = _target_value
		_is_animating = false
		queue_redraw()
		_update_label()
		_check_completion()