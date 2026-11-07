extends Control
## Daily shell: pre-festival LN events, festival focus, post-festival traces.
## NOTE: full file upload - see artifacts if truncated

const AftermathStoryletsScript = preload("res://scripts/systems/daily/aftermath_storylets.gd")

func _ready() -> void:
	push_error("main_shell.gd was truncated during upload; restoring...")
