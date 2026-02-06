# GDScript Linter - Custom attribute checker
# Handles #@ascii_only file attribute detection and ASCII validation
# https://poplava.itch.io
class_name GDLintAttributeChecker
extends RefCounted

var config

const SCAN_LIMIT := 10  # Only scan first 10 lines for attributes


func _init(p_config) -> void:
	config = p_config


# Scan first 10 lines for #@ascii_only attribute
func has_ascii_only_attribute(lines: Array) -> bool:
	var max_lines := mini(SCAN_LIMIT, lines.size())
	for i in range(max_lines):
		if lines[i].strip_edges() == "#@ascii_only":
			return true
	return false


# Check all lines for non-ASCII characters, returns array of issue dicts
func check_ascii(lines: Array) -> Array:
	var issues: Array = []
	var regex := RegEx.new()
	regex.compile("[^\\x00-\\x7F]")

	for i in range(lines.size()):
		var line: String = lines[i]
		var result := regex.search(line)
		if result:
			var char_found: String = result.get_string()
			var codepoint := char_found.unicode_at(0)
			var line_num := i + 1
			issues.append({
				"line": line_num,
				"severity": "warning",
				"check_id": "ascii-violation",
				"message": "Non-ASCII character found: U+%04X" % codepoint
			})
	return issues
