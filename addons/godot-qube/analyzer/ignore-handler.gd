# Godot Qube - Ignore directive handler
# https://poplava.itch.io
class_name QubeIgnoreHandler
extends RefCounted
## Handles parsing and checking of qube:ignore directives

const IGNORE_PATTERN := "qube:ignore"
const IGNORE_NEXT_LINE_PATTERN := "qube:ignore-next-line"
const IGNORE_FUNCTION_PATTERN := "qube:ignore-function"
const IGNORE_BLOCK_START_PATTERN := "qube:ignore-block-start"
const IGNORE_BLOCK_END_PATTERN := "qube:ignore-block-end"

var _lines: Array = []
var _ignored_ranges: Array = []  # Array of {start: int, end: int, check_id: String}


func initialize(lines: Array) -> void:
	_lines = lines
	_ignored_ranges = _parse_ignored_ranges(lines)


func clear() -> void:
	_lines = []
	_ignored_ranges = []


# Check if an issue should be ignored based on inline comments or ignored ranges
func should_ignore(line_num: int, check_id: String) -> bool:
	if _lines.is_empty():
		return false

	var line_idx := line_num - 1
	if line_idx < 0 or line_idx >= _lines.size():
		return false

	# Check if line is within an ignored range (function or block)
	for ignored_range in _ignored_ranges:
		if line_num >= ignored_range.start and line_num <= ignored_range.end:
			if ignored_range.check_id == "" or ignored_range.check_id == check_id:
				return true

	var current_line: String = _lines[line_idx]

	# Check current line for # qube:ignore or # qube:ignore:check-id
	if IGNORE_PATTERN in current_line:
		var ignore_pos := current_line.find(IGNORE_PATTERN)
		if ignore_pos >= 0 and not IGNORE_NEXT_LINE_PATTERN in current_line:
			var after_ignore := current_line.substr(ignore_pos + IGNORE_PATTERN.length())
			if after_ignore.begins_with(":"):
				var specific_check := after_ignore.substr(1).split(" ")[0].split("\t")[0].strip_edges()
				return specific_check == check_id
			else:
				return true

	# Check previous line for # qube:ignore-next-line
	if line_idx > 0:
		var prev_line: String = _lines[line_idx - 1]
		if IGNORE_NEXT_LINE_PATTERN in prev_line:
			var ignore_pos := prev_line.find(IGNORE_NEXT_LINE_PATTERN)
			if ignore_pos >= 0:
				var after_ignore := prev_line.substr(ignore_pos + IGNORE_NEXT_LINE_PATTERN.length())
				if after_ignore.begins_with(":"):
					var specific_check := after_ignore.substr(1).split(" ")[0].split("\t")[0].strip_edges()
					return specific_check == check_id
				else:
					return true

	return false


# Parse ignored ranges from qube:ignore-function and qube:ignore-block directives
func _parse_ignored_ranges(lines: Array) -> Array:
	var ranges: Array = []

	# Track block starts for matching with ends
	var block_starts: Array = []  # Array of {line: int, check_id: String}

	for i in range(lines.size()):
		var line: String = lines[i]
		var line_num := i + 1

		# Check for ignore-function directive
		if IGNORE_FUNCTION_PATTERN in line:
			var check_id := _extract_check_id(line, IGNORE_FUNCTION_PATTERN)
			var func_range := _find_function_range(lines, i)
			if func_range.start > 0:
				ranges.append({
					"start": func_range.start,
					"end": func_range.end,
					"check_id": check_id
				})

		# Check for ignore-block-start directive
		if IGNORE_BLOCK_START_PATTERN in line:
			var check_id := _extract_check_id(line, IGNORE_BLOCK_START_PATTERN)
			block_starts.append({"line": line_num, "check_id": check_id})

		# Check for ignore-block-end directive
		if IGNORE_BLOCK_END_PATTERN in line:
			if block_starts.size() > 0:
				var block_start = block_starts.pop_back()
				ranges.append({
					"start": block_start.line,
					"end": line_num,
					"check_id": block_start.check_id
				})

	return ranges


# Extract optional check_id from directive (e.g., "qube:ignore-function:print-statement" -> "print-statement")
func _extract_check_id(line: String, pattern: String) -> String:
	var pos := line.find(pattern)
	if pos < 0:
		return ""

	var after := line.substr(pos + pattern.length())
	if after.begins_with(":"):
		return after.substr(1).split(" ")[0].split("\t")[0].strip_edges()

	return ""


# Find the range of a function starting after the given line index
func _find_function_range(lines: Array, start_idx: int) -> Dictionary:
	var func_start := -1
	var func_end := -1

	# Find the next func declaration after the ignore comment
	for i in range(start_idx + 1, lines.size()):
		var trimmed: String = lines[i].strip_edges()
		if trimmed.begins_with("func "):
			func_start = i + 1  # Convert to 1-based line number
			break

	if func_start < 0:
		return {"start": -1, "end": -1}

	# Find where the function ends (next func or end of file)
	for i in range(func_start, lines.size()):
		var trimmed: String = lines[i].strip_edges()
		if trimmed.begins_with("func "):
			func_end = i  # Line before next func (0-based, so already correct as 1-based end)
			break

	# If no next function found, function extends to end of file
	if func_end < 0:
		func_end = lines.size()

	return {"start": func_start, "end": func_end}
