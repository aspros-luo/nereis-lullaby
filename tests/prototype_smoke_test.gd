extends SceneTree
## Run with: godot --headless --path . -s res://tests/prototype_smoke_test.gd
## Core logic regression tests; these do not replace an in-engine UI/playtest.

const GameStateScript = preload("res://scripts/core/game_state.gd")
const ScheduleManagerScript = preload("res://scripts/managers/npc_schedule_manager.gd")
const ClueJournalScript = preload("res://scripts/managers/clue_journal.gd")

func _initialize() -> void:
	_test_time_progression_and_anomaly()
	_test_action_economy()
	_test_npc_schedules_and_locations()
	_test_clue_deduplication()
	_test_relationship_bounds()
	_test_save_roundtrip()
	print("Nereis Lullaby core smoke tests passed.")
	quit()

func _test_time_progression_and_anomaly() -> void:
	var state = GameStateScript.new()
	assert(state.day_index == 1)
	assert(state.get_slot_key() == "morning")
	for _step in range(20):
		state.advance_time()
	assert(state.day_index == 7)
	assert(state.slot_index == 2)
	assert(state.world_state["phase"] == "ordinary")
	state.advance_time()
	assert(state.day_index == 7)
	assert(state.slot_index == 2)
	assert(state.world_state["phase"] == "after_week")
	assert(state.world_state["flags"]["village_anomaly"])
	assert(state.take_action("post_event_1", "first post-event activity"))
	assert(state.take_action("post_event_2", "second post-event activity"))

func _test_action_economy() -> void:
	var state = GameStateScript.new()
	assert(state.can_take_action())
	assert(state.take_action("test", "test activity"))
	assert(not state.can_take_action())
	assert(not state.take_action("second", "should be blocked"))
	state.advance_time()
	assert(state.can_take_action())
	assert(state.action_history.size() == 1)

func _test_npc_schedules_and_locations() -> void:
	var schedules = ScheduleManagerScript.new()
	var npc_ids: Array[String] = ["caregiver", "worship_leader", "doctor"]
	for day in range(1, 8):
		for slot in range(3):
			for npc_id in npc_ids:
				var location_id: String = schedules.get_location(npc_id, day, slot)
				assert(not location_id.is_empty())
				assert(not schedules.get_location_name(location_id).is_empty())
	assert(schedules.get_location_name("FOREST") == "林间小径")
	assert(schedules.get_location_name("GROVE") == "林中空地")

func _test_clue_deduplication() -> void:
	var journal = ClueJournalScript.new()
	assert(journal.add_fact("smoke_test_fact", "Test", "Observed fact", 1, "早晨", "测试地点"))
	assert(not journal.add_fact("smoke_test_fact", "Test", "Duplicate", 1, "早晨", "测试地点"))
	var entries: Array[Dictionary] = journal.get_entries()
	assert(entries.size() == 1)
	assert(entries[0]["detail"] == "Observed fact")

func _test_relationship_bounds() -> void:
	var state = GameStateScript.new()
	for _step in range(30):
		state.increase_relationship("caregiver")
	assert(state.relationship_state["caregiver"] == 10)
	state.increase_relationship("caregiver", -30)
	assert(state.relationship_state["caregiver"] == -5)


func _test_save_roundtrip() -> void:
	var original = GameStateScript.new()
	original.advance_time()
	assert(original.take_action("save_test", "save test activity"))
	original.increase_relationship("caregiver", 3)
	original.register_fact("save_test_fact")
	var restored = GameStateScript.new()
	assert(restored.load_save_data(original.to_save_data()))
	assert(restored.day_index == original.day_index)
	assert(restored.slot_index == original.slot_index)
	assert(restored.action_used_this_slot == original.action_used_this_slot)
	assert(restored.relationship_state["caregiver"] == 3)
	assert(restored.investigation_state["observed_fact_ids"].has("save_test_fact"))
	assert(restored.action_history.size() == 1)
	var protected_state = GameStateScript.new()
	protected_state.day_index = 4
	var invalid_data: Dictionary = original.to_save_data()
	invalid_data["world_state"] = "corrupt"
	assert(not protected_state.load_save_data(invalid_data))
	assert(protected_state.day_index == 4)

	var journal = ClueJournalScript.new()
	assert(journal.add_fact("save_clue", "Saved clue", "Clue details", 2, "白天", "林间小径"))
	var restored_journal = ClueJournalScript.new()
	restored_journal.load_entries(journal.get_entries())
	assert(restored_journal.get_entries().size() == 1)
	assert(not restored_journal.add_fact("save_clue", "Duplicate", "Duplicate", 2, "白天", "林间小径"))
