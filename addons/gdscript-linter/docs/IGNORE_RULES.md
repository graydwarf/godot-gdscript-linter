# GDScript Linter - Ignore Rules

Suppress specific warnings when code is intentionally written a certain way.

## File Ignores

Place within the first 10 lines of the file.

```gdscript
# gdlint:ignore-file
extends Node
# This file will have ALL checks ignored

# Or ignore specific checks for the entire file:
# gdlint:ignore-file:file-length,long-function
extends Node
```

## Below Ignores

Ignore from this line to end of file. Useful for generated code, data tables, or legacy sections.

```gdscript
# ... maintained code above ...

# gdlint:ignore-below
# Everything below this line is ignored

var GENERATED_DATA = [1, 2, 3, 4, 5]  # No magic-number warnings
func _legacy_code(): pass            # No long-function warnings

# Or ignore specific checks only:
# gdlint:ignore-below:magic-number,missing-type
```

## Line Ignores

```gdscript
# Ignore all checks on next line
# gdlint:ignore-next-line
var magic = 42

# Ignore all checks on same line
var another_magic = 100  # gdlint:ignore-line

# Ignore specific check (or comma-separated list)
var debug_print = true  # gdlint:ignore-line:magic-number
var config = 255  # gdlint:ignore-line:magic-number,missing-type
```

## Function Ignores

Place the comment directly above the `func` declaration.

```gdscript
# Ignore ALL checks in function
# gdlint:ignore-function
func _print_help() -> void:
    print("Usage: ...")
    print("Options:")
    print("  --help  Show this message")

# Ignore specific checks (comma-separated)
# gdlint:ignore-function:print-statement,long-function
func _output_results() -> void:
    print("Results:")
    # ... many lines of output formatting ...
```

## Block Ignores

```gdscript
# Ignore all checks in block
# gdlint:ignore-block-start
var magic1 = 42
var magic2 = 100
# gdlint:ignore-block-end

# Ignore specific check in block
# gdlint:ignore-block-start:magic-number
var threshold = 1000
var limit = 5000
# gdlint:ignore-block-end
```

## Pinned Exceptions

Track technical debt regression by pinning a value. If the actual value exceeds the pinned value, you'll get a warning about the regression.

```gdscript
# Pin function at 35 lines - warns if it grows beyond 35
# gdlint:ignore-function:long-function=35
func my_complex_function() -> void:
    # ... 35 lines of code ...

# Pin file at 400 lines
# gdlint:ignore-file:file-length=400

# Pin complexity at 12
# gdlint:ignore-next-line:high-complexity=12
func branchy_logic() -> void:
    # ...
```

**Behavior:**

| Scenario | Result |
|----------|--------|
| Actual = Pinned (35 = 35) | Silently ignored |
| Actual > Pinned (35 → 40) | Warning: "exceeded pinned limit (35 → 40, limit is 30)" |
| Actual < Pinned but > limit (40 → 35, limit 30) | Info: "now 35 (was pinned at 40) - consider tightening" |
| Actual < limit (35 → 25, limit 30) | Info: "pinned ignore is now unnecessary" |

This helps you catch regressions while still allowing intentional exceptions to your normal limits.

## Defensive Attributes

### `#@ascii_only` — ASCII Enforcement

Place `#@ascii_only` in the first 10 lines of a file to enforce ASCII-only characters throughout the entire file (including strings and comments).

```gdscript
#@ascii_only
class_name MyScript
extends Node

var name := "hello"  # OK
var label := "héllo"  # WARNING: ascii-violation
```

Enable project-wide ASCII enforcement via config: `ascii_only_project_wide = true`. Individual files can opt out with `# gdlint:ignore-file:ascii-violation`.

### `# gdlint:strict` — Tighter Per-Scope Limits

Override global thresholds with stricter limits. Issues fire at CRITICAL severity. When a strict directive exists for a rule, the normal threshold check is suppressed.

**File-scoped** (first 10 lines):
```gdscript
# gdlint:strict-file:file-length=200
# gdlint:strict-file:god-class-functions=10
extends Node
```

**Function-scoped** (above func declaration):
```gdscript
# gdlint:strict-function:long-function=25
# gdlint:strict-function:high-complexity=8
func critical_function():
    pass
```

**Supported rules:** `long-function`, `file-length`, `high-complexity`, `deep-nesting`, `too-many-params`, `god-class-functions`, `god-class-signals`

### `#@Sealed` — Prevent Class Inheritance

Mark a class as sealed to prevent other files from extending it. Requires `class_name` on the next line. Only works with directory-wide analysis (not single-file).

```gdscript
#@Sealed
class_name CoreAPI
extends RefCounted
# Other files that try "extends CoreAPI" will get a CRITICAL sealed-violation
```

Place `#@Sealed` in the first 10 lines, immediately before `class_name`. Path-based extends (`extends "res://..."`) is not checked in v1.

## Common Rule Names

| Rule ID | Description |
|---------|-------------|
| `long-function` | Function exceeds line limit |
| `file-length` | File exceeds line limit |
| `print-statement` | Print statement detected |
| `magic-number` | Unexplained numeric literal |
| `cyclomatic-complexity` | High branching complexity |
| `too-many-parameters` | Function has too many params |
| `deep-nesting` | Excessive indentation depth |
| `missing-type` | Missing type annotation |
| `unused-variable` | Variable declared but never used |
| `unused-parameter` | Parameter declared but never used |
| `ascii-violation` | Non-ASCII character in #@ascii_only file |
| `strict-limit` | Value exceeds gdlint:strict limit |
| `sealed-violation` | Extends a #@Sealed class |

