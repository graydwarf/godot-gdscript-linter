# GDScript Linter - Strict directive handler
# Handles gdlint:strict-function and gdlint:strict-file directives
# https://poplava.itch.io
class_name GDLintStrictHandler
extends RefCounted
## Parses and queries gdlint:strict-* directives for tighter per-scope limits

const STRICT_FUNCTION_PATTERN := "gdlint:strict-function"
const STRICT_FILE_PATTERN := "gdlint:strict-file"
const SCAN_LIMIT := 10  # Only scan first 10 lines for file-level directives

# Regex pattern: gdlint:strict-(function|file):check-id=value
const STRICT_REGEX_PATTERN := "gdlint:strict-(?:function|file):(\\w[\\w-]*)=(\\d+)"

# Parsed data
var _file_strict_limits: Dictionary = {}     # check_id -> limit value (file-scope)
var _function_strict_ranges: Array = []       # [{start: int, end: int, check_id: String, limit: int}]


func initialize(lines: Array) -> void:
	clear()
	_parse_file_strict(lines)
	_parse_function_strict(lines)


func clear() -> void:
	_file_strict_limits = {}
	_function_strict_ranges = []


# Returns strict limit for a check at a given line, or -1 if none
# File-scope overrides function-scope
func get_strict_limit(line_num: int, check_id: String) -> int:
	# File-scope first (higher priority)
	if _file_strict_limits.has(check_id):
		return _file_strict_limits[check_id]

	# Function-scope
	for range_entry in _function_strict_ranges:
		if line_num >= range_entry.start and line_num <= range_entry.end:
			if range_entry.check_id == check_id:
				return range_entry.limit

	return -1


# Parse file-level strict directives from first 10 lines
func _parse_file_strict(lines: Array) -> void:
	var max_lines := mini(SCAN_LIMIT, lines.size())
	for i in range(max_lines):
		var line: String = lines[i]
		if STRICT_FILE_PATTERN not in line:
			continue
		var parsed := _extract_strict_directive(line, STRICT_FILE_PATTERN)
		if parsed.check_id != "" and parsed.limit >= 0:
			_file_strict_limits[parsed.check_id] = parsed.limit


# Parse function-level strict directives for all lines
func _parse_function_strict(lines: Array) -> void:
	for i in range(lines.size()):
		var line: String = lines[i]
		if STRICT_FUNCTION_PATTERN not in line:
			continue
		var parsed := _extract_strict_directive(line, STRICT_FUNCTION_PATTERN)
		if parsed.check_id == "" or parsed.limit < 0:
			continue
		var func_range := _find_function_range(lines, i)
		if func_range.start > 0:
			_function_strict_ranges.append({
				"start": func_range.start,
				"end": func_range.end,
				"check_id": parsed.check_id,
				"limit": parsed.limit
			})


# Extract check_id and limit from a strict directive
# e.g., "# gdlint:strict-function:long-function=25" -> {check_id: "long-function", limit: 25}
func _extract_strict_directive(line: String, pattern: String) -> Dictionary:
	var pos := line.find(pattern)
	if pos < 0:
		return {"check_id": "", "limit": -1}

	var after := line.substr(pos + pattern.length())
	if not after.begins_with(":"):
		return {"check_id": "", "limit": -1}

	var directive_str := after.substr(1).split(" ")[0].split("\t")[0].strip_edges()

	var equals_pos := directive_str.find("=")
	if equals_pos <= 0:
		return {"check_id": "", "limit": -1}

	var check_id := directive_str.substr(0, equals_pos)
	var value_str := directive_str.substr(equals_pos + 1)
	var limit := value_str.to_int() if value_str.is_valid_int() else -1

	return {"check_id": check_id, "limit": limit}


# Find the range of a function starting after the given line index
# Replicates the pattern from ignore-handler.gd
func _find_function_range(lines: Array, start_idx: int) -> Dictionary:
	var func_start := -1
	var func_end := -1

	# Find the next func declaration after the strict comment
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
			func_end = i  # Line before next func
			break

	# If no next function found, function extends to end of file
	if func_end < 0:
		func_end = lines.size()

	return {"start": func_start, "end": func_end}
