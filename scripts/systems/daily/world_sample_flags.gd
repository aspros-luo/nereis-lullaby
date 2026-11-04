class_name WorldSampleFlags
extends RefCounted

## Lightweight flags for sample dark-thread after harvest festival.

var flags: Dictionary = {}

func set_flag(key: String, value: bool = true) -> void:
	flags[key] = value

func has_flag(key: String) -> bool:
	return bool(flags.get(key, false))

func after_festival() -> void:
	set_flag("festival_done")
	set_flag("festival_public_done")
