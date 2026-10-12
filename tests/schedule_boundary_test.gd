extends SceneTree
## Run with: godot --headless --path . -s res://tests/schedule_boundary_test.gd
## Boundary regression tests for NPC schedule lookup inputs.

const ScheduleManagerScript = preload("res://scripts/managers/npc_schedule_manager.gd")

func _initialize() -> void:
	var schedules = ScheduleManagerScript.new()

	# Valid coordinates preserve the authored schedule.
	assert(schedules.get_location("caregiver", 1, 0) == "HOME")
	assert(schedules.get_location("doctor", 2, 1) == "PATH")
	assert(schedules.get_npcs_at("CLINIC", 1, 0) == ["doctor"])

	# Unknown actors, days, slots, and places fail closed instead of indexing arrays.
	assert(schedules.get_location("unknown_npc", 1, 0).is_empty())
	assert(schedules.get_location("doctor", 0, 0).is_empty())
	assert(schedules.get_location("doctor", 8, 0).is_empty())
	assert(schedules.get_location("doctor", 1, -1).is_empty())
	assert(schedules.get_location("doctor", 1, 3).is_empty())
	assert(schedules.get_npcs_at("UNKNOWN", 1, 0).is_empty())
	assert(schedules.get_npcs_at("HOME", 1, -1).is_empty())
	assert(schedules.get_npcs_at("HOME", 8, 0).is_empty())

	# Overrides must point to a known location and can be removed cleanly.
	schedules.set_schedule_override("doctor", "FOREST", "boundary test")
	assert(schedules.get_location("doctor", 1, 0) == "FOREST")
	schedules.set_schedule_override("doctor", "UNKNOWN", "invalid override")
	assert(schedules.get_location("doctor", 1, 0).is_empty())
	schedules.clear_schedule_override("doctor")
	assert(schedules.get_location("doctor", 1, 0) == "CLINIC")

	print("NPC schedule boundary tests passed.")
	quit()
