# Godot Qube - Claude Code Card UI Builder
# https://poplava.itch.io
@tool
extends RefCounted
class_name QubeClaudeCodeCardBuilder
## Creates the Claude Code integration settings card

const DEFAULT_COMMAND := "claude --permission-mode plan"

var _reset_icon: Texture2D


func _init(reset_icon: Texture2D) -> void:
	_reset_icon = reset_icon


# Create Claude Code settings card
func create_card(controls: Dictionary) -> PanelContainer:
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", QubeSettingsCardBuilder.create_card_style())

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	card.add_child(vbox)

	# Header
	var header := Label.new()
	header.text = "Claude Code Integration"
	header.add_theme_font_size_override("font_size", 15)
	header.add_theme_color_override("font_color", Color(0.9, 0.92, 0.95))
	vbox.add_child(header)

	# Enable checkbox
	controls.claude_enabled_check = CheckBox.new()
	controls.claude_enabled_check.text = "Enable Claude Code buttons"
	vbox.add_child(controls.claude_enabled_check)

	# Description
	var desc := Label.new()
	desc.text = "Adds Claude Code button to launch directly into plan mode with issue context."
	desc.add_theme_font_size_override("font_size", 11)
	desc.add_theme_color_override("font_color", Color(0.5, 0.52, 0.55))
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc)

	# Command label
	var cmd_label := Label.new()
	cmd_label.text = "Launch Command:"
	cmd_label.add_theme_color_override("font_color", Color(0.7, 0.72, 0.75))
	vbox.add_child(cmd_label)

	# Command input with reset button
	var cmd_hbox := HBoxContainer.new()
	cmd_hbox.add_theme_constant_override("separation", 8)
	vbox.add_child(cmd_hbox)

	controls.claude_command_edit = LineEdit.new()
	controls.claude_command_edit.placeholder_text = DEFAULT_COMMAND
	controls.claude_command_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cmd_hbox.add_child(controls.claude_command_edit)

	controls.claude_reset_button = Button.new()
	controls.claude_reset_button.icon = _reset_icon
	controls.claude_reset_button.tooltip_text = "Reset to default"
	controls.claude_reset_button.flat = true
	controls.claude_reset_button.custom_minimum_size = Vector2(16, 16)
	cmd_hbox.add_child(controls.claude_reset_button)

	# Hint label
	var hint := Label.new()
	hint.text = "Issue context is passed automatically. Add CLI flags as needed (e.g. --verbose)."
	hint.add_theme_font_size_override("font_size", 10)
	hint.add_theme_color_override("font_color", Color(0.45, 0.47, 0.5))
	vbox.add_child(hint)

	# Custom instructions label
	var instructions_label := Label.new()
	instructions_label.text = "Custom Instructions (optional):"
	instructions_label.add_theme_color_override("font_color", Color(0.7, 0.72, 0.75))
	vbox.add_child(instructions_label)

	# Custom instructions text area
	controls.claude_instructions_edit = TextEdit.new()
	controls.claude_instructions_edit.placeholder_text = "Add extra instructions to append to the prompt..."
	controls.claude_instructions_edit.custom_minimum_size = Vector2(0, 60)
	controls.claude_instructions_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(controls.claude_instructions_edit)

	return card
