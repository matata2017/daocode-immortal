## 间距常量系统
## 定义统一的间距、边距、圆角等布局常量
class_name UISpacing
extends RefCounted

# ============================================
# 基础间距单位（Base Spacing Units）
# ============================================
# 基于 4px 网格系统
const UNIT := 4          # 基础单位
const UNIT_2 := 8        # 2单位
const UNIT_3 := 12       # 3单位
const UNIT_4 := 16       # 4单位
const UNIT_5 := 20       # 5单位
const UNIT_6 := 24       # 6单位
const UNIT_8 := 32       # 8单位
const UNIT_10 := 40      # 10单位
const UNIT_12 := 48      # 12单位
const UNIT_16 := 64      # 16单位
const UNIT_20 := 80      # 20单位
const UNIT_24 := 96      # 24单位

# ============================================
# 标准间距（Standard Spacing）
# ============================================
const SPACE_NONE := 0
const SPACE_XS := 4       # 极小间距
const SPACE_SM := 8       # 小间距
const SPACE_MD := 16      # 中等间距（默认）
const SPACE_LG := 24      # 大间距
const SPACE_XL := 32      # 超大间距
const SPACE_2XL := 48     # 巨大间距
const SPACE_3XL := 64     # 超巨大间距

# ============================================
# 内边距（Padding）
# ============================================
const PADDING_NONE := 0
const PADDING_XS := 4
const PADDING_SM := 8
const PADDING_MD := 16
const PADDING_LG := 24
const PADDING_XL := 32
const PADDING_2XL := 48

# 组件专用内边距
const PADDING_BUTTON := 16          # 按钮内边距（水平）
const PADDING_BUTTON_VERTICAL := 8  # 按钮内边距（垂直）
const PADDING_CARD := 16            # 卡片内边距
const PADDING_PANEL := 24           # 面板内边距
const PADDING_DIALOG := 24          # 对话框内边距
const PADDING_INPUT := 12           # 输入框内边距
const PADDING_TOOLTIP := 8          # 提示框内边距

# ============================================
# 外边距（Margin）
# ============================================
const MARGIN_NONE := 0
const MARGIN_XS := 4
const MARGIN_SM := 8
const MARGIN_MD := 16
const MARGIN_LG := 24
const MARGIN_XL := 32
const MARGIN_2XL := 48

# ============================================
# 圆角半径（Border Radius）
# ============================================
const RADIUS_NONE := 0
const RADIUS_SM := 4        # 小圆角
const RADIUS_MD := 8        # 中等圆角
const RADIUS_LG := 12       # 大圆角
const RADIUS_XL := 16       # 超大圆角
const RADIUS_2XL := 24      # 巨大圆角
const RADIUS_FULL := 9999   # 完全圆形

# 组件专用圆角
const RADIUS_BUTTON := 8        # 按钮圆角
const RADIUS_CARD := 12         # 卡片圆角
const RADIUS_PANEL := 16        # 面板圆角
const RADIUS_DIALOG := 16       # 对话框圆角
const RADIUS_INPUT := 6         # 输入框圆角
const RADIUS_BADGE := 12        # 徽章圆角
const RADIUS_TOOLTIP := 6       # 提示框圆角
const RADIUS_AVATAR := 9999     # 头像圆角（圆形）

# ============================================
# 边框宽度（Border Width）
# ============================================
const BORDER_NONE := 0
const BORDER_THIN := 1       # 细边框
const BORDER_NORMAL := 2     # 普通边框
const BORDER_THICK := 3      # 粗边框
const BORDER_FOCUS := 3      # 焦点边框

# ============================================
# 分隔线（Divider）
# ============================================
const DIVIDER_HEIGHT := 1
const DIVIDER_MARGIN_SM := 8
const DIVIDER_MARGIN_MD := 16
const DIVIDER_MARGIN_LG := 24

# ============================================
# 阴影（Shadows）
# ============================================
# 阴影偏移量
const SHADOW_OFFSET_SM := Vector2(0, 1)
const SHADOW_OFFSET_MD := Vector2(0, 2)
const SHADOW_OFFSET_LG := Vector2(0, 4)
const SHADOW_OFFSET_XL := Vector2(0, 8)

# 阴影模糊半径
const SHADOW_BLUR_SM := 2
const SHADOW_BLUR_MD := 4
const SHADOW_BLUR_LG := 8
const SHADOW_BLUR_XL := 16

# ============================================
# 图标大小（Icon Sizes）
# ============================================
const ICON_XS := 12
const ICON_SM := 16
const ICON_MD := 24
const ICON_LG := 32
const ICON_XL := 48
const ICON_2XL := 64

# ============================================
# 按钮尺寸（Button Sizes）
# ============================================
const BUTTON_HEIGHT_SM := 28
const BUTTON_HEIGHT_MD := 40
const BUTTON_HEIGHT_LG := 52
const BUTTON_MIN_WIDTH := 80
const BUTTON_ICON_SIZE := 20

# ============================================
# 输入框尺寸（Input Sizes）
# ============================================
const INPUT_HEIGHT_SM := 28
const INPUT_HEIGHT_MD := 40
const INPUT_HEIGHT_LG := 52

# ============================================
# 列表项高度（List Item Heights）
# ============================================
const LIST_ITEM_HEIGHT_SM := 32
const LIST_ITEM_HEIGHT_MD := 48
const LIST_ITEM_HEIGHT_LG := 64

# ============================================
# 导航栏尺寸（Navigation Sizes）
# ============================================
const NAV_BAR_HEIGHT := 56
const NAV_BAR_ICON_SIZE := 24
const TAB_HEIGHT := 48

# ============================================
# 安全区域（Safe Areas）
# ============================================
const SAFE_AREA_TOP := 0      # 顶部安全区域（运行时获取）
const SAFE_AREA_BOTTOM := 0   # 底部安全区域（运行时获取）
const SAFE_AREA_LEFT := 0     # 左侧安全区域
const SAFE_AREA_RIGHT := 0    # 右侧安全区域

# ============================================
# 动画距离（Animation Distances）
# ============================================
const ANIM_SLIDE_DISTANCE := 100   # 滑动动画距离
const ANIM_FADE_DISTANCE := 20     # 淡入淡出距离

# ============================================
# 辅助方法（Helper Methods）
# ============================================

## 创建 PaddingValues 对象
static func padding(all: int = MARGIN_MD) -> Dictionary:
	return {
		left = all,
		top = all,
		right = all,
		bottom = all
	}

## 创建不对称内边距
static func padding_xy(horizontal: int, vertical: int) -> Dictionary:
	return {
		left = horizontal,
		top = vertical,
		right = horizontal,
		bottom = vertical
	}

## 创建四个方向独立的内边距
static func padding_sides(left: int = 0, top: int = 0, right: int = 0, bottom: int = 0) -> Dictionary:
	return {
		left = left,
		top = top,
		right = right,
		bottom = bottom
	}

## 创建 MarginValues 对象
static func margin(all: int = MARGIN_MD) -> Dictionary:
	return {
		left = all,
		top = all,
		right = all,
		bottom = all
	}

## 创建不对称外边距
static func margin_xy(horizontal: int, vertical: int) -> Dictionary:
	return {
		left = horizontal,
		top = vertical,
		right = horizontal,
		bottom = vertical
	}

## 创建四个方向独立的外边距
static func margin_sides(left: int = 0, top: int = 0, right: int = 0, bottom: int = 0) -> Dictionary:
	return {
		left = left,
		top = top,
		right = right,
		bottom = bottom
	}

## 创建 StyleBoxFlat 的快捷方法
static func create_stylebox(
	bg_color: Color,
	border_radius: int = RADIUS_MD,
	border_color: Color = Color.TRANSPARENT,
	border_width: int = BORDER_NONE,
	padding_all: int = PADDING_MD
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(border_radius)
	style.set_content_margin_all(padding_all)
	return style

## 创建带阴影的 StyleBoxFlat
static func create_stylebox_with_shadow(
	bg_color: Color,
	border_radius: int = RADIUS_MD,
	shadow_color: Color = Color.BLACK,
	shadow_offset: Vector2 = SHADOW_OFFSET_MD,
	shadow_blur: float = SHADOW_BLUR_MD
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.set_corner_radius_all(border_radius)
	style.shadow_color = shadow_color
	style.shadow_offset = shadow_offset
	style.shadow_size = shadow_blur
	return style

## 获取响应式间距（根据屏幕尺寸调整）
static func get_responsive_spacing(base_spacing: int, screen_scale: float = 1.0) -> int:
	return int(base_spacing * screen_scale)

## 计算网格间距
static func calculate_grid_spacing(container_width: float, item_width: float, columns: int) -> float:
	if columns <= 1:
		return 0
	var total_item_width := item_width * columns
	var remaining_space := container_width - total_item_width
	return max(0, remaining_space / (columns - 1))
