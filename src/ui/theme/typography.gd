## 字体排版系统
## 定义字体大小、字重、行高等排版常量
class_name UITypography
extends RefCounted

# ============================================
# 字体资源路径（Font Resource Paths）
# ============================================
# 主字体 - 用于大部分UI文本
const FONT_PRIMARY := "res://assets/fonts/NotoSansSC-Regular.ttf"
const FONT_PRIMARY_BOLD := "res://assets/fonts/NotoSansSC-Bold.ttf"

# 标题字体 - 用于大标题
const FONT_DISPLAY := "res://assets/fonts/ZCOOLKuaiLe-Regular.ttf"

# 等宽字体 - 用于代码显示
const FONT_MONOSPACE := "res://assets/fonts/JetBrainsMono-Regular.ttf"
const FONT_MONOSPACE_BOLD := "res://assets/fonts/JetBrainsMono-Bold.ttf"

# 书法字体 - 用于特殊标题、装饰
const FONT_CALLIGRAPHY := "res://assets/fonts/MaShanZheng-Regular.ttf"

# ============================================
# 字体大小（Font Sizes）
# ============================================
# 标题大小
const SIZE_H1 := 48      # 主标题
const SIZE_H2 := 36      # 副标题
const SIZE_H3 := 28      # 三级标题
const SIZE_H4 := 24      # 四级标题
const SIZE_H5 := 20      # 五级标题
const SIZE_H6 := 18      # 六级标题

# 正文大小
const SIZE_BODY_LARGE := 18   # 大正文
const SIZE_BODY := 16         # 默认正文
const SIZE_BODY_SMALL := 14   # 小正文
const SIZE_CAPTION := 12      # 说明文字

# 特殊大小
const SIZE_BUTTON := 16       # 按钮文字
const SIZE_LABEL := 14        # 标签文字
const SIZE_TOOLTIP := 13      # 提示文字
const SIZE_OVERLINE := 10     # 上标线文字

# 代码大小
const SIZE_CODE := 14         # 代码文字
const SIZE_CODE_LARGE := 16   # 大代码文字

# ============================================
# 字重（Font Weights）
# ============================================
const WEIGHT_THIN := 100
const WEIGHT_LIGHT := 300
const WEIGHT_REGULAR := 400
const WEIGHT_MEDIUM := 500
const WEIGHT_SEMIBOLD := 600
const WEIGHT_BOLD := 700
const WEIGHT_EXTRABOLD := 800

# ============================================
# 行高（Line Heights）
# ============================================
const LINE_HEIGHT_TIGHT := 1.2
const LINE_HEIGHT_NORMAL := 1.5
const LINE_HEIGHT_RELAXED := 1.75
const LINE_HEIGHT_LOOSE := 2.0

# ============================================
# 字间距（Letter Spacing）
# ============================================
const LETTER_SPACING_TIGHT := -0.5
const LETTER_SPACING_NORMAL := 0.0
const LETTER_SPACING_WIDE := 0.5
const LETTER_SPACING_WIDER := 1.0
const LETTER_SPACING_WIDEST := 2.0

# ============================================
# 段落间距（Paragraph Spacing）
# ============================================
const PARAGRAPH_SPACING_SMALL := 8
const PARAGRAPH_SPACING_NORMAL := 16
const PARAGRAPH_SPACING_LARGE := 24

# ============================================
# 文本对齐（Text Alignment）
# ============================================
enum Alignment {
	LEFT = HORIZONTAL_ALIGNMENT_LEFT,
	CENTER = HORIZONTAL_ALIGNMENT_CENTER,
	RIGHT = HORIZONTAL_ALIGNMENT_RIGHT,
	FILL = HORIZONTAL_ALIGNMENT_FILL
}

# ============================================
# 辅助方法（Helper Methods）
# ============================================

## 创建 LabelSettings 用于标题
static func create_heading_settings(level: int = 1) -> LabelSettings:
	var settings := LabelSettings.new()

	match level:
		1:
			settings.font_size = SIZE_H1
			settings.font_weight = WEIGHT_BOLD
		2:
			settings.font_size = SIZE_H2
			settings.font_weight = WEIGHT_BOLD
		3:
			settings.font_size = SIZE_H3
			settings.font_weight = WEIGHT_SEMIBOLD
		4:
			settings.font_size = SIZE_H4
			settings.font_weight = WEIGHT_SEMIBOLD
		5:
			settings.font_size = SIZE_H5
			settings.font_weight = WEIGHT_MEDIUM
		_:
			settings.font_size = SIZE_H6
			settings.font_weight = WEIGHT_MEDIUM

	settings.line_spacing = LINE_HEIGHT_TIGHT
	return settings

## 创建 LabelSettings 用于正文
static func create_body_settings(size: String = "normal") -> LabelSettings:
	var settings := LabelSettings.new()
	settings.font_weight = WEIGHT_REGULAR
	settings.line_spacing = LINE_HEIGHT_NORMAL

	match size:
		"large":
			settings.font_size = SIZE_BODY_LARGE
		"small":
			settings.font_size = SIZE_BODY_SMALL
		_:
			settings.font_size = SIZE_BODY

	return settings

## 创建 LabelSettings 用于按钮
static func create_button_settings() -> LabelSettings:
	var settings := LabelSettings.new()
	settings.font_size = SIZE_BUTTON
	settings.font_weight = WEIGHT_MEDIUM
	settings.line_spacing = LINE_HEIGHT_TIGHT
	return settings

## 创建 LabelSettings 用于代码
static func create_code_settings(large: bool = false) -> LabelSettings:
	var settings := LabelSettings.new()
	settings.font_size = SIZE_CODE if not large else SIZE_CODE_LARGE
	settings.font_weight = WEIGHT_REGULAR
	settings.line_spacing = LINE_HEIGHT_NORMAL
	return settings

## 获取标题大小
static func get_heading_size(level: int) -> int:
	match level:
		1: return SIZE_H1
		2: return SIZE_H2
		3: return SIZE_H3
		4: return SIZE_H4
		5: return SIZE_H5
		_: return SIZE_H6

## 计算文本高度
static func calculate_text_height(text: String, font_size: int, line_height: float = LINE_HEIGHT_NORMAL, width: float = -1) -> float:
	# 估算文本高度
	var lines := 1
	if width > 0:
		# 简单估算（实际应使用 Font.get_string_size）
		var chars_per_line := int(width / (font_size * 0.6))  # 假设平均字符宽度
		lines = ceili(text.length() / float(chars_per_line))

	return lines * font_size * line_height

## 加载字体资源
static func load_font(font_type: String) -> Font:
	var path := ""

	match font_type.to_lower():
		"primary", "default":
			path = FONT_PRIMARY
		"primary_bold", "bold":
			path = FONT_PRIMARY_BOLD
		"display", "heading":
			path = FONT_DISPLAY
		"monospace", "code":
			path = FONT_MONOSPACE
		"monospace_bold", "code_bold":
			path = FONT_MONOSPACE_BOLD
		"calligraphy", "decorative":
			path = FONT_CALLIGRAPHY
		_:
			path = FONT_PRIMARY

	if ResourceLoader.exists(path):
		return load(path) as Font
	else:
		# 返回默认字体
		return ThemeDB.fallback_font
