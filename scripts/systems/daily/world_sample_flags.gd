class_name WorldSampleFlags
extends RefCounted
## Sample flags: festival branches + post-festival traces + refusals.

var flags: Dictionary = {}

func set_flag(key: String, value: bool = true) -> void:
	flags[key] = value

func has_flag(key: String) -> bool:
	return bool(flags.get(key, false))

func after_festival(helped: bool, offered_food: bool, refused: bool) -> void:
	set_flag("festival_done")
	set_flag("festival_public_done")
	if helped:
		set_flag("festival_helped")
	if offered_food:
		set_flag("festival_offered_food")
	if refused:
		set_flag("festival_refused")
	# Soft ending tendency seeds (P = paradise/belonging, T = punishment/distance)
	if helped or offered_food:
		set_flag("tendency_p_soft")
	if refused and not helped and not offered_food:
		set_flag("tendency_t_soft")
