# GDScript Linter - Theme-Aware Color Provider
# https://poplava.itch.io
@tool
extends RefCounted
class_name GDLintThemeColors
## Provides semantic colors derived from the active editor theme.
## All UI files use these instead of hardcoded Color() values.
##
## Design principle: only override colors where we MUST differ from the editor
## theme. Standard controls (Button, CheckBox, Label) should inherit from the
## editor theme directly - no font_color overrides on them.

static var _colors: Dictionary = {}
static var _initialized: bool = false


# Reads the editor theme and populates the semantic color dictionary
static func refresh() -> void:
	var theme := EditorInterface.get_editor_theme()
	var settings := EditorInterface.get_editor_settings()

	# Read base colors from editor settings
	var base_color: Color = settings.get_setting("interface/theme/base_color")
	var accent_color: Color = settings.get_setting("interface/theme/accent_color")

	# Read computed colors from editor theme
	var font_color: Color = theme.get_color("font_color", "Editor")
	var disabled_font_color: Color = theme.get_color("disabled_font_color", "Editor")
	var dark_color_1: Color = theme.get_color("dark_color_1", "Editor")
	var dark_color_2: Color = theme.get_color("dark_color_2", "Editor")
	var dark_color_3: Color = theme.get_color("dark_color_3", "Editor")
	var success_color: Color = theme.get_color("success_color", "Editor")

	# -- Panel & Background --
	# base_color matches the editor's own background
	_colors["main_bg"] = base_color
	_colors["panel_bg"] = dark_color_2
	_colors["input_bg"] = dark_color_3

	# -- Borders --
	_colors["border"] = Color(dark_color_1.r, dark_color_1.g, dark_color_1.b, 0.5)
	_colors["input_border"] = dark_color_1.lerp(font_color, 0.1)
	_colors["separator"] = Color(dark_color_1.r, dark_color_1.g, dark_color_1.b, 0.5)
	_colors["separator_thin"] = Color(dark_color_1.r, dark_color_1.g, dark_color_1.b, 0.4)

	# -- Font colors --
	# Only used where we need semantic differentiation from the default.
	# Standard labels should NOT get font overrides - they inherit from theme.
	_colors["font_muted"] = disabled_font_color
	# "dimmed" = slightly less visible than disabled, staying between disabled and bg
	_colors["font_dimmed"] = disabled_font_color.lerp(base_color, 0.25)

	# -- Accent colors --
	_colors["accent"] = accent_color
	_colors["accent_hover"] = accent_color.lerp(font_color, 0.3)
	_colors["accent_muted"] = accent_color.lerp(disabled_font_color, 0.3)
	_colors["accent_section"] = accent_color.lerp(font_color, 0.3)

	# -- Code/directive color (greenish tint) --
	# Blend accent toward green, then toward font_color for readability
	_colors["code"] = accent_color.lerp(Color(0.5, 0.9, 0.3), 0.5).lerp(font_color, 0.3)

	# -- Overlay / popup --
	_colors["overlay_bg"] = Color(dark_color_3.r, dark_color_3.g, dark_color_3.b, 0.85)
	_colors["overlay_panel"] = Color(dark_color_2.r, dark_color_2.g, dark_color_2.b, 0.95)
	_colors["popup_bg"] = Color(dark_color_3.r, dark_color_3.g, dark_color_3.b, 0.98)
	_colors["popup_border"] = Color(dark_color_1.r, dark_color_1.g, dark_color_1.b, 0.8)
	_colors["tooltip_bg"] = Color(dark_color_3.r, dark_color_3.g, dark_color_3.b, 0.95)
	_colors["tooltip_border"] = dark_color_1

	# -- Spinner / busy --
	_colors["spinner"] = accent_color

	# -- Success (export notification) --
	_colors["success_bg"] = dark_color_2.lerp(success_color, 0.15)
	_colors["success_border"] = Color(
		success_color.lerp(dark_color_1, 0.3).r,
		success_color.lerp(dark_color_1, 0.3).g,
		success_color.lerp(dark_color_1, 0.3).b,
		0.8
	)
	_colors["success_text"] = success_color.lerp(font_color, 0.3)
	_colors["success_text_light"] = success_color.lerp(font_color, 0.6)

	_initialized = true


# Returns a named semantic color. Auto-initializes on first call.
static func get_color(color_name: String) -> Color:
	if not _initialized:
		refresh()
	if _colors.has(color_name):
		return _colors[color_name]
	push_warning("GDLintThemeColors: Unknown color '%s'" % color_name)
	return Color.MAGENTA


# Creates a card-style StyleBoxFlat (used by collapsible cards and settings panels)
static func create_card_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = get_color("panel_bg")
	style.border_color = get_color("border")
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(12)
	return style


# Creates an input field StyleBoxFlat (used by LineEdit/TextEdit controls)
static func create_input_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = get_color("input_bg")
	style.border_color = get_color("input_border")
	style.set_border_width_all(1)
	style.set_corner_radius_all(2)
	style.content_margin_left = 8
	return style
