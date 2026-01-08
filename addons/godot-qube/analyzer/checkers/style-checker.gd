# Godot Qube - Style checker (magic numbers, commented code, type hints)
# https://poplava.itch.io
class_name QubeStyleChecker
extends RefCounted

var config


func _init(p_config) -> void:
	config = p_config


# Returns issue dictionary or null
func check_magic_numbers(line: String, line_num: int) -> Variant:
	# Skip comments, const declarations, and common safe patterns
	if line.begins_with("#") or line.begins_with("const "):
		return null
	if "enum " in line or "@export" in line:
		return null

	var regex := RegEx.new()
	regex.compile("(?<![a-zA-Z_])(-?\\d+\\.?\\d*)(?![a-zA-Z_\\d])")

	for regex_match in regex.search_all(line):
		var num_str: String = regex_match.get_string()
		var num_val: float = float(num_str)

		# Skip allowed numbers
		if num_val in config.allowed_numbers:
			continue

		# Skip if it's part of a variable name or in a string
		var pos: int = regex_match.get_start()
		if pos > 0 and line[pos - 1] == '"':
			continue

		return {
			"line": line_num,
			"severity": "info",
			"check_id": "magic-number",
			"message": "Magic number %s (consider using a named constant)" % num_str
		}

	return null


# Returns issue dictionary or null
func check_commented_code(line: String, line_num: int) -> Variant:
	for pattern in config.commented_code_patterns:
		if line.begins_with(pattern) or ("\t" + pattern) in line or (" " + pattern) in line:
			return {
				"line": line_num,
				"severity": "info",
				"check_id": "commented-code",
				"message": "Commented-out code detected"
			}
	return null


# Returns issue dictionary or null
func check_variable_type_hints(line: String, line_num: int) -> Variant:
	# Check for untyped variable declarations
	if not line.begins_with("var ") and not line.begins_with("\tvar "):
		return null

	# Skip if it has a type annotation
	if ":" in line.split("=")[0]:
		return null

	# Skip @onready and inferred types from literals
	if "@onready" in line:
		return null

	# Extract variable name
	var after_var := line.strip_edges().substr(4)  # After "var "
	var var_name := after_var.split("=")[0].split(":")[0].strip_edges()

	return {
		"line": line_num,
		"severity": "info",
		"check_id": "missing-type-hint",
		"message": "Variable '%s' has no type annotation" % var_name
	}


# Returns issue dictionary or null
func check_todo_comments(trimmed: String, line_num: int) -> Variant:
	for pattern in config.todo_patterns:
		if pattern in trimmed:
			var severity := "info" if pattern == "TODO" else "warning"
			var comment_text := trimmed.substr(trimmed.find(pattern) + pattern.length()).strip_edges()
			if comment_text.begins_with(":"):
				comment_text = comment_text.substr(1).strip_edges()
			return {
				"line": line_num,
				"severity": severity,
				"check_id": "todo-comment",
				"message": "%s: %s" % [pattern, comment_text]
			}
	return null


# Returns issue dictionary or null
func check_print_statements(trimmed: String, line_num: int) -> Variant:
	var is_whitelisted := false
	for whitelist_item in config.print_whitelist:
		if whitelist_item in trimmed:
			is_whitelisted = true
			break

	if not is_whitelisted:
		for pattern in config.print_patterns:
			if pattern in trimmed and not trimmed.begins_with("#"):
				return {
					"line": line_num,
					"severity": "warning",
					"check_id": "print-statement",
					"message": "Debug print statement: %s" % trimmed.substr(0, mini(60, trimmed.length()))
				}
	return null
