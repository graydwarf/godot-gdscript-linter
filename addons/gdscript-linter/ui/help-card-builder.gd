# GDScript Linter - Help Card UI Builder
# https://poplava.itch.io
@tool
extends RefCounted
class_name GDLintHelpCardBuilder
## Creates the Help section card with ignore rules, CLI usage, and shortcuts


# Create Help card (returns content to be added to a collapsible card)
func create_card_content(container: VBoxContainer) -> void:
	_add_ignore_rules_section(container)
	_add_separator(container)
	_add_defensive_attributes_section(container)
	_add_separator(container)
	_add_cli_section(container)
	_add_separator(container)
	_add_shortcuts_section(container)
	_add_separator(container)
	_add_license_section(container)


func _add_separator(parent: VBoxContainer) -> void:
	var sep := HSeparator.new()
	sep.add_theme_color_override("separator", GDLintThemeColors.get_color("separator"))
	parent.add_child(sep)


func _add_section_header(parent: VBoxContainer, title: String, description: String) -> void:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 0)
	parent.add_child(hbox)

	var header := Label.new()
	header.text = title
	header.add_theme_font_size_override("font_size", 15)
	hbox.add_child(header)

	var desc := Label.new()
	desc.text = " -   " + description
	desc.add_theme_font_size_override("font_size", 15)
	desc.add_theme_color_override("font_color", GDLintThemeColors.get_color("font_muted"))
	hbox.add_child(desc)


func _add_code_block(parent: VBoxContainer, code: String) -> void:
	var code_label := Label.new()
	code_label.text = code
	code_label.add_theme_font_size_override("font_size", 13)
	code_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(code_label)


func _add_defensive_attributes_section(parent: VBoxContainer) -> void:
	_add_section_header(parent, "Defensive Attributes", "Enforce stricter rules on specific files or functions")

	# Summary table
	_add_defensive_table(parent)

	# Examples for each directive
	_add_thin_separator(parent)
	_add_ignore_example(parent, "#@ascii_only (per-file)",
		"#@ascii_only\n# Place in first 10 lines. Raises ascii-violation WARNING\n# for any non-ASCII characters in the file.\n# Also available: ascii_only_project_wide in config")

	_add_thin_separator(parent)
	_add_ignore_example(parent, "gdlint:strict-file:rule=value",
		"# gdlint:strict-file:long-function=20\n# Place in first 10 lines. Applies stricter limit to all\n# functions in the file. Raises strict-limit CRITICAL.")

	_add_thin_separator(parent)
	_add_ignore_example(parent, "gdlint:strict-function:rule=value",
		"# gdlint:strict-function:long-function=15\nfunc tight_func():\n    # Applies stricter limit to this function only.\n    # Raises strict-limit CRITICAL. Suppresses normal check.")

	_add_thin_separator(parent)
	_add_ignore_example(parent, "#@Sealed (prevent inheritance)",
		"#@Sealed\nclass_name MyBaseClass\n# Requires class_name on next line. Raises sealed-violation\n# CRITICAL when another file extends a sealed class.")


func _add_defensive_table(parent: VBoxContainer) -> void:
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 20)
	grid.add_theme_constant_override("v_separation", 2)
	parent.add_child(grid)

	var directives := [
		["#@ascii_only", "ASCII enforcement (WARNING)"],
		["gdlint:strict-file:rule=val", "File-level strict limit (CRITICAL)"],
		["gdlint:strict-function:rule=val", "Function-level strict limit (CRITICAL)"],
		["#@Sealed", "Prevent inheritance (CRITICAL)"],
	]

	for entry in directives:
		var directive_label := Label.new()
		directive_label.text = entry[0]
		directive_label.add_theme_font_size_override("font_size", 13)
		grid.add_child(directive_label)

		var scope_label := Label.new()
		scope_label.text = entry[1]
		scope_label.add_theme_font_size_override("font_size", 13)
		scope_label.add_theme_color_override("font_color", GDLintThemeColors.get_color("font_muted"))
		grid.add_child(scope_label)


func _add_ignore_rules_section(parent: VBoxContainer) -> void:
	_add_section_header(parent, "Ignore Rules", "Suppress warnings for intentional code patterns")

	# Summary table
	_add_ignore_table(parent)

	# Examples for each directive
	_add_thin_separator(parent)
	_add_ignore_example(parent, "gdlint:ignore-file",
		"# gdlint:ignore-file\n# gdlint:ignore-file:file-length,long-function")

	_add_thin_separator(parent)
	_add_ignore_example(parent, "gdlint:ignore-below",
		"# gdlint:ignore-below\n# gdlint:ignore-below:magic-number")

	_add_thin_separator(parent)
	_add_ignore_example(parent, "gdlint:ignore-function",
		"# gdlint:ignore-function\nfunc _debug(): ...\n\n# gdlint:ignore-function:print-statement\nfunc _log(): ...")

	_add_thin_separator(parent)
	_add_ignore_example(parent, "gdlint:ignore-block-start/end",
		"# gdlint:ignore-block-start:magic-number\nvar x = 42\nvar y = 100\n# gdlint:ignore-block-end")

	_add_thin_separator(parent)
	_add_ignore_example(parent, "gdlint:ignore-next-line",
		"# gdlint:ignore-next-line\nvar magic = 42")

	_add_thin_separator(parent)
	_add_ignore_example(parent, "gdlint:ignore-line",
		"var magic = 42  # gdlint:ignore-line\nvar x = 100  # gdlint:ignore-line:magic-number")

	_add_thin_separator(parent)
	_add_ignore_example(parent, "Pinned Exceptions (=value)",
		"# gdlint:ignore-function:long-function=35\nfunc complex(): ...  # Warns if exceeds 35 lines")


func _add_ignore_table(parent: VBoxContainer) -> void:
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 20)
	grid.add_theme_constant_override("v_separation", 2)
	parent.add_child(grid)

	var directives := [
		["gdlint:ignore-file", "Entire file"],
		["gdlint:ignore-below", "Line to EOF"],
		["gdlint:ignore-function", "Entire function"],
		["gdlint:ignore-block-start/end", "Code block"],
		["gdlint:ignore-next-line", "Next line"],
		["gdlint:ignore-line", "Same line"],
	]

	for entry in directives:
		var directive_label := Label.new()
		directive_label.text = entry[0]
		directive_label.add_theme_font_size_override("font_size", 13)
		grid.add_child(directive_label)

		var scope_label := Label.new()
		scope_label.text = entry[1]
		scope_label.add_theme_font_size_override("font_size", 13)
		scope_label.add_theme_color_override("font_color", GDLintThemeColors.get_color("font_muted"))
		grid.add_child(scope_label)


# Example directive header + code block, both at the same size/color as table entries
func _add_ignore_example(parent: VBoxContainer, directive: String, code: String) -> void:
	# Directive name as mini-header (same style as table directive labels)
	var header := Label.new()
	header.text = directive
	header.add_theme_font_size_override("font_size", 13)
	parent.add_child(header)

	# Code example (same size as table entries, muted for secondary emphasis)
	var code_label := Label.new()
	code_label.text = code
	code_label.add_theme_font_size_override("font_size", 13)
	code_label.add_theme_color_override("font_color", GDLintThemeColors.get_color("font_muted"))
	parent.add_child(code_label)


func _add_thin_separator(parent: VBoxContainer) -> void:
	var sep := HSeparator.new()
	sep.add_theme_constant_override("separation", 4)
	sep.add_theme_color_override("separator", GDLintThemeColors.get_color("separator_thin"))
	parent.add_child(sep)


func _add_cli_section(parent: VBoxContainer) -> void:
	_add_section_header(parent, "CLI Usage", "Run analysis from command line")

	# Output formats table
	_add_cli_table(parent, "Output Formats", [
		["--clickable", "Godot Output panel (default)"],
		["--json", "JSON format"],
		["--html -o file.html", "HTML report"],
		["--no-ignore", "Bypass all ignore directives"],
	])

	# Exit codes table
	_add_cli_table(parent, "Exit Codes", [
		["0", "No issues"],
		["1", "Warnings only"],
		["2", "Critical issues"],
	])

	# Examples
	_add_thin_separator(parent)
	_add_cli_example(parent, "Basic scan",
		"godot --headless --script res://addons/gdscript-linter/analyzer/analyze-cli.gd")

	_add_thin_separator(parent)
	_add_cli_example(parent, "JSON output",
		"godot --headless --script res://addons/gdscript-linter/analyzer/analyze-cli.gd -- --json")

	_add_thin_separator(parent)
	_add_cli_example(parent, "HTML report",
		"godot --headless --script res://addons/gdscript-linter/analyzer/analyze-cli.gd -- --html -o report.html")

	_add_thin_separator(parent)
	_add_cli_example(parent, "Scan external project",
		"godot --headless --script res://addons/gdscript-linter/analyzer/analyze-cli.gd -- --path \"C:/my/project\"")


func _add_cli_table(parent: VBoxContainer, title: String, entries: Array) -> void:
	var title_label := Label.new()
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", 13)
	parent.add_child(title_label)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 20)
	grid.add_theme_constant_override("v_separation", 2)
	parent.add_child(grid)

	for entry in entries:
		var key_label := Label.new()
		key_label.text = entry[0]
		key_label.add_theme_font_size_override("font_size", 13)
		grid.add_child(key_label)

		var value_label := Label.new()
		value_label.text = entry[1]
		value_label.add_theme_font_size_override("font_size", 13)
		value_label.add_theme_color_override("font_color", GDLintThemeColors.get_color("font_muted"))
		grid.add_child(value_label)


func _add_cli_example(parent: VBoxContainer, title: String, command: String) -> void:
	var title_label := Label.new()
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", 13)
	parent.add_child(title_label)

	var cmd_label := Label.new()
	cmd_label.text = command
	cmd_label.add_theme_font_size_override("font_size", 13)
	cmd_label.add_theme_color_override("font_color", GDLintThemeColors.get_color("font_muted"))
	cmd_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(cmd_label)


func _add_shortcuts_section(parent: VBoxContainer) -> void:
	_add_section_header(parent, "Claude Code Shortcuts", "When Claude Code integration is enabled")

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 20)
	grid.add_theme_constant_override("v_separation", 4)
	parent.add_child(grid)

	var shortcuts := [
		["Click", "Plan mode (safe, reviews first)"],
		["Shift+Click", "Immediate mode (fixes directly)"],
		["Right-click", "Context menu with options"]
	]

	for shortcut in shortcuts:
		var key_label := Label.new()
		key_label.text = shortcut[0]
		key_label.add_theme_font_size_override("font_size", 13)
		grid.add_child(key_label)

		var desc_label := Label.new()
		desc_label.text = shortcut[1]
		desc_label.add_theme_font_size_override("font_size", 13)
		desc_label.add_theme_color_override("font_color", GDLintThemeColors.get_color("font_muted"))
		grid.add_child(desc_label)


func _add_license_section(parent: VBoxContainer) -> void:
	var license_lbl := Label.new()
	license_lbl.text = "MIT License - Copyright (c) 2025 Poplava"
	license_lbl.add_theme_font_size_override("font_size", 12)
	license_lbl.add_theme_color_override("font_color", GDLintThemeColors.get_color("font_dimmed"))
	parent.add_child(license_lbl)
