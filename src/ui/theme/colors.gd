## 颜色常量定义
## 定义游戏中使用的所有颜色，支持主题切换和色盲模式
class_name UIColors
extends RefCounted

# ============================================
# 主色调（Primary）- 修仙主题金色
# ============================================
const PRIMARY_DEFAULT := Color("#D4AF37")  # 金色
const PRIMARY_LIGHT := Color("#E6C65C")    # 浅金色
const PRIMARY_DARK := Color("#B8942D")     # 深金色
const PRIMARY_BG := Color("#1A1410")       # 金色背景（深褐）

# ============================================
# 次要色（Secondary）- 紫色灵气
# ============================================
const SECONDARY_DEFAULT := Color("#9B59B6")  # 紫色
const SECONDARY_LIGHT := Color("#AF7AC5")    # 浅紫色
const SECONDARY_DARK := Color("#7D3C98")     # 深紫色

# ============================================
# 境界颜色（Realm Colors）
# ============================================
const REALM_MORTAL := Color("#8B8B8B")        # 凡人 - 灰色
const REALM_QI_REFINING := Color("#87CEEB")   # 炼气 - 天蓝
const REALM_FOUNDATION := Color("#90EE90")    # 筑基 - 浅绿
const REALM_GOLDEN_CORE := Color("#FFD700")   # 金丹 - 金黄
const REALM_NASCENT_SOUL := Color("#9B59B6")  # 元婴 - 紫色
const REALM_SPIRIT_SEVERING := Color("#E74C3C") # 化神 - 红色
const REALM_VOID_REFINING := Color("#1ABC9C")   # 炼虚 - 青色
const REALM_BODY_FUSION := Color("#3498DB")     # 合体 - 蓝色
const REALM_MAHAYANA := Color("#F39C12")        # 大乘 - 橙色
const REALM_TRIBULATION := Color("#FFFFFF")     # 渡劫 - 白色

# ============================================
# 状态颜色（Status Colors）
# ============================================
const SUCCESS := Color("#2ECC71")     # 成功 - 绿色
const WARNING := Color("#F39C12")     # 警告 - 橙色
const ERROR := Color("#E74C3C")       # 错误 - 红色
const INFO := Color("#3498DB")        # 信息 - 蓝色

# ============================================
# 文本颜色（Text Colors）
# ============================================
const TEXT_PRIMARY := Color("#FFFFFF")      # 主要文本 - 白色
const TEXT_SECONDARY := Color("#B0B0B0")    # 次要文本 - 灰色
const TEXT_DISABLED := Color("#666666")     # 禁用文本 - 深灰
const TEXT_HINT := Color("#808080")         # 提示文本 - 中灰
const TEXT_LINK := Color("#5DADE2")         # 链接文本 - 浅蓝

# ============================================
# 背景颜色（Background Colors）
# ============================================
const BG_PRIMARY := Color("#1A1A2E")       # 主背景 - 深紫黑
const BG_SECONDARY := Color("#16213E")     # 次要背景 - 深蓝
const BG_CARD := Color("#0F3460")          # 卡片背景 - 深蓝灰
const BG_OVERLAY := Color("#00000080")     # 遮罩背景 - 半透明黑
const BG_TRANSPARENT := Color("#00000000") # 完全透明

# ============================================
# 边框颜色（Border Colors）
# ============================================
const BORDER_DEFAULT := Color("#3D5A80")   # 默认边框
const BORDER_LIGHT := Color("#4A7C9B")     # 浅边框
const BORDER_FOCUS := Color("#D4AF37")     # 焦点边框 - 金色
const BORDER_DISABLED := Color("#2C3E50")  # 禁用边框

# ============================================
# 门派颜色（Sect Colors）
# ============================================
const SECT_SWORD := Color("#E74C3C")       # 剑修 - 红色
const SECT_SPELL := Color("#9B59B6")       # 法修 - 紫色
const SECT_BODY := Color("#E67E22")        # 体修 - 橙色
const SECT_ALCHEMY := Color("#27AE60")     # 丹修 - 绿色
const SECT_FORMATION := Color("#3498DB")   # 阵修 - 蓝色

# ============================================
# 稀有度颜色（Rarity Colors）
# ============================================
const RARITY_COMMON := Color("#FFFFFF")      # 普通 - 白色
const RARITY_UNCOMMON := Color("#2ECC71")    # 稀有 - 绿色
const RARITY_RARE := Color("#3498DB")        # 史诗 - 蓝色
const RARITY_LEGENDARY := Color("#9B59B6")   # 传说 - 紫色
const RARITY_MYTHIC := Color("#F39C12")      # 神话 - 橙色

# ============================================
# 色盲模式颜色（Colorblind Mode）
# ============================================
# 使用蓝橙配色方案，适合红绿色盲
const CB_PRIMARY := Color("#0077BB")       # 色盲主色 - 蓝
const CB_SECONDARY := Color("#EE7733")     # 色盲次色 - 橙
const CB_SUCCESS := Color("#009988")       # 色盲成功 - 青绿
const CB_WARNING := Color("#CCBB44")       # 色盲警告 - 黄
const CB_ERROR := Color("#CC3311")         # 色盲错误 - 红褐
const CB_INFO := Color("#33BBEE")          # 色盲信息 - 浅蓝

# ============================================
# 辅助方法
# ============================================

## 获取境界颜色
static func get_realm_color(realm_id: String) -> Color:
	match realm_id.to_lower():
		"mortal", "凡人":
			return REALM_MORTAL
		"qi_refining", "炼气":
			return REALM_QI_REFINING
		"foundation", "筑基":
			return REALM_FOUNDATION
		"golden_core", "金丹":
			return REALM_GOLDEN_CORE
		"nascent_soul", "元婴":
			return REALM_NASCENT_SOUL
		"spirit_severing", "化神":
			return REALM_SPIRIT_SEVERING
		"void_refining", "炼虚":
			return REALM_VOID_REFINING
		"body_fusion", "合体":
			return REALM_BODY_FUSION
		"mahayana", "大乘":
			return REALM_MAHAYANA
		"tribulation", "渡劫":
			return REALM_TRIBULATION
		_:
			return TEXT_SECONDARY

## 获取门派颜色
static func get_sect_color(sect_type: String) -> Color:
	match sect_type.to_lower():
		"sword", "剑修":
			return SECT_SWORD
		"spell", "法修":
			return SECT_SPELL
		"body", "体修":
			return SECT_BODY
		"alchemy", "丹修":
			return SECT_ALCHEMY
		"formation", "阵修":
			return SECT_FORMATION
		_:
			return PRIMARY_DEFAULT

## 获取稀有度颜色
static func get_rarity_color(rarity: String) -> Color:
	match rarity.to_lower():
		"common", "普通":
			return RARITY_COMMON
		"uncommon", "稀有":
			return RARITY_UNCOMMON
		"rare", "史诗":
			return RARITY_RARE
		"legendary", "传说":
			return RARITY_LEGENDARY
		"mythic", "神话":
			return RARITY_MYTHIC
		_:
			return RARITY_COMMON

## 获取状态颜色
static func get_status_color(status: String) -> Color:
	match status.to_lower():
		"success", "成功":
			return SUCCESS
		"warning", "警告":
			return WARNING
		"error", "错误":
			return ERROR
		"info", "信息":
			return INFO
		_:
			return TEXT_SECONDARY

## 色盲模式转换
static func to_colorblind(color: Color, colorblind_enabled: bool = true) -> Color:
	if not colorblind_enabled:
		return color

	# 映射主要颜色到色盲友好色
	if color.is_equal_approx(SUCCESS):
		return CB_SUCCESS
	elif color.is_equal_approx(WARNING):
		return CB_WARNING
	elif color.is_equal_approx(ERROR):
		return CB_ERROR
	elif color.is_equal_approx(INFO):
		return CB_INFO
	elif color.is_equal_approx(PRIMARY_DEFAULT):
		return CB_PRIMARY

	return color

## 创建带透明度的颜色变体
static func with_alpha(color: Color, alpha: float) -> Color:
	return Color(color.r, color.g, color.b, alpha)
