extends Control
## Deprecated entry; main.tscn now uses main_shell.gd.
## Kept so old references do not hard-crash during transition.

func _ready() -> void:
	push_warning("scripts/ui/main.gd is deprecated; open scenes/main.tscn (main_shell.gd)")
