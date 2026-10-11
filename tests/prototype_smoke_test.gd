extends SceneTree
## Run with: godot --headless --path . -s res://tests/prototype_smoke_test.gd
## This checks core data logic; it does not replace an in-engine UI/playtest.

const GameStateScript = preload("res://scripts/core/game_state.gd")
const ScheduleManagerScript = preload("res://scripts/managers/npc_schedule_manager.gd")
const ClueJournalScript = preload("res://scripts/managers/clue_journal.gd")

func _initialize() -> void:
	_test_time_progression()
	_test_npc_schedules()
	_test_clue_deduplication()
	print("Prototype smoke tests passed.")
	quit()

func _test_time_progression() -> void:
	var state = GameStateScript.new()
	assert(state.day_index == 1)
	assert(state.get_slot_key() == "morning")
	for _step in range(21):
		state.advance_time()
	assert(state.day_index == 7)
	assert(state.slot_index == 0)
	assert(state.world_state["phase"] == "after_week")

func _test_npc_schedules() -> void:
	var schedules = ScheduleManagerScript.new()
	var npc_ids: Array[String] = ["caregiver", "worship_leader", "doctor"]
	for day in range(1, 8):
		for slot in range(3):
			for npc_id in npc_ids:
				var location_id: String = schedules.get_location(npc_id, day, slot)
				assert(not location_id.is_empty())
				assert(not schedules.get_location_name(location_id).is_empty())

func _test_clue_deduplication() -> void:
	var journal = ClueJournalScript.new()
	assert(journal.add_fact("smoke_test_fact", "Test", "Observed fact", 1, "早晨", "测试地点"))
	assert(not journal.add_fact("smoke_test_fact", "Test", "Duplicate", 1, "早晨", "测试地点"))
	var entries: Array[Dictionary] = journal.get_entries()
	assert(entries.size() == 1)
	assert(entries[0]["detail"] == "Observed fact")
