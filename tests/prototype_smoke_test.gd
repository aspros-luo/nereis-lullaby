extends SceneTree
## Run with: godot --headless --path . -s res://tests/prototype_smoke_test.gd
## Core logic regression tests; these do not replace an in-engine UI/playtest.

const GameStateScript = preload("res://scripts/core/game_state.gd")
const ScheduleManagerScript = preload("res://scripts/managers/npc_schedule_manager.gd")
const ClueJournalScript = preload("res://scripts/managers/clue_journal.gd")
const MainScript = preload("res://scripts/ui/main.gd")
const WorldlineLedgerScript = preload("res://scripts/core/worldline_event_ledger.gd")
const InformationNetworkScript = preload("res://scripts/managers/worldline_information_network.gd")
const NPCBehaviorProfilesScript = preload("res://scripts/data/npc_behavior_profiles.gd")
const NPCBehaviorSimulatorScript = preload("res://scripts/managers/npc_behavior_simulator.gd")

func _initialize() -> void:
	_test_time_progression_and_anomaly()
	_test_action_economy()
	_test_npc_schedules_and_locations()
	_test_location_content_coverage()
	_test_personal_moment_coverage()
	_test_clue_deduplication()
	_test_relationship_bounds()
	_test_save_roundtrip()
	_test_save_roundtrip_after_anomaly()
	_test_state_journal_consistency()
	_test_observation_and_anomaly_events()
	_test_journal_ledger_consistency()
	_test_legacy_clue_provenance_migration()
	_test_network_tick_consistency()
	_test_worldline_ledger()
	_test_worldline_ledger_rejects_inconsistent_save()
	_test_worldline_information_network()
	_test_npc_behavior_profiles()
	_test_npc_behavior_simulator()
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
	state.advance_time()
	assert(state.day_index == 7)
	assert(state.slot_index == 2)
	assert(state.world_state["phase"] == "after_week")

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

	# UI entry points must not allow conversations with an NPC at another location.
	var ui_logic = MainScript.new()
	ui_logic.game_state = GameStateScript.new()
	ui_logic.schedule_manager = ScheduleManagerScript.new()
	assert(ui_logic.game_state.current_location == "HOME")
	assert(ui_logic.schedule_manager.get_location("doctor", 1, 0) != "HOME")
	ui_logic._talk_to_npc("doctor")
	assert(ui_logic.game_state.action_history.is_empty())
	ui_logic._talk_to_npc("unknown_npc")
	assert(ui_logic.game_state.action_history.is_empty())

func _test_personal_moment_coverage() -> void:
	for moment_id in MainScript.PERSONAL_MOMENTS:
		var moment: Dictionary = MainScript.PERSONAL_MOMENTS[moment_id]
		assert(["caregiver", "worship_leader", "doctor"].has(str(moment["npc_id"])))
		assert(["HOME", "SHRINE", "CLINIC"].has(str(moment["location_id"])))
		assert(int(moment["minimum_day"]) >= 1 and int(moment["minimum_day"]) <= 7)
		assert(not str(moment["dialogue"]).is_empty())
	assert(MainScript.PERSONAL_MOMENTS.size() >= 3)

	var ui_logic = MainScript.new()
	ui_logic.game_state = GameStateScript.new()
	ui_logic.game_state.day_index = 2
	ui_logic.game_state.current_location = "HOME"
	var available: Dictionary = ui_logic._get_available_personal_moment("caregiver")
	assert(available.get("id", "") == "caregiver_memory")
	ui_logic.game_state.world_state["flags"]["personal_moments_seen"] = {"caregiver_memory": true}
	assert(ui_logic._get_available_personal_moment("caregiver").is_empty())
	ui_logic.game_state.current_location = "CLINIC"
	ui_logic.game_state.day_index = 5
	assert(ui_logic._get_available_personal_moment("doctor").is_empty())
	ui_logic.game_state.day_index = 6
	assert(ui_logic._get_available_personal_moment("doctor").get("id", "") == "doctor_labels")


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
	original.world_state["flags"]["personal_moments_seen"] = {"caregiver_memory": true}
	original.world_state["flags"]["npc_last_autonomous_actions"] = {
		"caregiver": {
			"npc_id": "caregiver",
			"id": "tend_home",
			"tick": 1,
			"day": 1,
			"slot": 1,
			"label": "整理家中",
			"line": "照料者整理了门边的花束。",
			"goal": "stability",
			"relationship_at_choice": 0,
			"decision_basis": "routine_goals_and_local_state",
		},
	}
	var restored = GameStateScript.new()
	assert(restored.load_save_data(original.to_save_data()))
	assert(restored.day_index == original.day_index)
	assert(restored.slot_index == original.slot_index)
	assert(restored.action_used_this_slot == original.action_used_this_slot)
	assert(restored.relationship_state["caregiver"] == 3)
	assert(restored.investigation_state["observed_fact_ids"].has("save_test_fact"))
	assert(restored.action_history.size() == 1)
	assert(restored.world_state["flags"]["personal_moments_seen"]["caregiver_memory"])
	assert(restored.world_state["flags"]["npc_last_autonomous_actions"]["caregiver"]["id"] == "tend_home")
	var protected_state = GameStateScript.new()
	protected_state.day_index = 4
	var invalid_data: Dictionary = original.to_save_data()
	invalid_data["world_state"] = "corrupt"
	assert(not protected_state.load_save_data(invalid_data))
	assert(protected_state.day_index == 4)
	invalid_data = original.to_save_data()
	invalid_data["world_state"] = {"phase": "after_week", "flags": {}}
	assert(not protected_state.load_save_data(invalid_data))
	assert(protected_state.day_index == 4)
	invalid_data = original.to_save_data()
	invalid_data["world_state"]["flags"]["personal_moments_seen"] = "corrupt"
	assert(not protected_state.load_save_data(invalid_data))
	assert(protected_state.day_index == 4)
	invalid_data = original.to_save_data()
	invalid_data["day_index"] = 7
	invalid_data["slot_index"] = 2
	invalid_data["world_state"] = {"phase": "after_week", "flags": {}}
	assert(not protected_state.load_save_data(invalid_data))
	assert(protected_state.day_index == 4)
	invalid_data = original.to_save_data()
	invalid_data["current_location"] = "UNKNOWN"
	assert(not protected_state.load_save_data(invalid_data))
	assert(protected_state.day_index == 4)
	invalid_data = original.to_save_data()
	invalid_data["day_index"] = "4"
	assert(not protected_state.load_save_data(invalid_data))
	assert(protected_state.day_index == 4)
	invalid_data = original.to_save_data()
	invalid_data["slot_index"] = 1.5
	assert(not protected_state.load_save_data(invalid_data))
	assert(protected_state.day_index == 4)
	invalid_data = original.to_save_data()
	invalid_data["action_history"] = ["corrupt"]
	assert(not protected_state.load_save_data(invalid_data))
	assert(protected_state.day_index == 4)
	invalid_data = original.to_save_data()
	invalid_data["action_history"].append(invalid_data["action_history"][0].duplicate(true))
	assert(not protected_state.load_save_data(invalid_data))
	assert(protected_state.day_index == 4)
	invalid_data = original.to_save_data()
	invalid_data["action_used_this_slot"] = false
	assert(not protected_state.load_save_data(invalid_data))
	assert(protected_state.day_index == 4)
	invalid_data = original.to_save_data()
	invalid_data["relationship_state"]["caregiver"] = "corrupt"
	assert(not protected_state.load_save_data(invalid_data))
	assert(protected_state.day_index == 4)
	invalid_data = original.to_save_data()
	invalid_data["relationship_state"].erase("doctor")
	assert(not protected_state.load_save_data(invalid_data))
	assert(protected_state.day_index == 4)
	invalid_data = original.to_save_data()
	invalid_data["action_history"][0]["day"] = 7
	assert(not protected_state.load_save_data(invalid_data))
	assert(protected_state.day_index == 4)
	invalid_data = original.to_save_data()
	invalid_data["world_state"]["flags"]["npc_last_autonomous_actions"] = "corrupt"
	assert(not protected_state.load_save_data(invalid_data))
	assert(protected_state.day_index == 4)
	invalid_data = original.to_save_data()
	invalid_data["world_state"]["flags"]["personal_moments_seen"] = {"unknown_moment": true}
	assert(not protected_state.load_save_data(invalid_data))
	assert(protected_state.day_index == 4)
	invalid_data = original.to_save_data()
	invalid_data["world_state"]["flags"]["npc_last_autonomous_actions"]["caregiver"]["npc_id"] = "doctor"
	assert(not protected_state.load_save_data(invalid_data))
	assert(protected_state.day_index == 4)
	invalid_data = original.to_save_data()
	invalid_data["world_state"]["flags"]["npc_last_autonomous_actions"]["caregiver"]["tick"] = 2
	assert(not protected_state.load_save_data(invalid_data)) # Tick must match day and slot.
	assert(protected_state.day_index == 4)
	invalid_data = original.to_save_data()
	invalid_data["world_state"]["flags"]["npc_last_autonomous_actions"]["caregiver"]["day"] = 2
	invalid_data["world_state"]["flags"]["npc_last_autonomous_actions"]["caregiver"]["slot"] = 0
	invalid_data["world_state"]["flags"]["npc_last_autonomous_actions"]["caregiver"]["tick"] = 3
	assert(not protected_state.load_save_data(invalid_data)) # Future autonomous actions are invalid.
	assert(protected_state.day_index == 4)

	var journal = ClueJournalScript.new()
	assert(journal.add_fact("save_clue", "Saved clue", "Clue details", 2, "白天", "林间小径"))
	var restored_journal = ClueJournalScript.new()
	assert(restored_journal.load_entries(journal.get_entries()))
	assert(restored_journal.get_entries().size() == 1)
	assert(not restored_journal.add_fact("save_clue", "Duplicate", "Duplicate", 2, "白天", "林间小径"))
	var invalid_clues: Array = journal.get_entries()
	invalid_clues.append({"id": "save_clue", "title": "Duplicate ID", "detail": "Invalid duplicate", "day": 2, "slot": "白天", "location": "林间小径"})
	assert(not restored_journal.load_entries(invalid_clues))
	assert(restored_journal.get_entries().size() == 1) # Failed restore preserves existing journal.
	assert(not restored_journal.load_entries([{"id": "broken"}]))
	assert(restored_journal.get_entries().size() == 1)


func _test_save_roundtrip_after_anomaly() -> void:
	var state = GameStateScript.new()
	for _step in range(21):
		state.advance_time()
	assert(state.world_state["phase"] == "after_week")
	state.mark_post_anomaly_visit("HOME")
	state.mark_post_anomaly_visit("SHRINE")
	assert(not state.can_complete_demo())
	assert(not state.complete_demo())
	state.mark_post_anomaly_visit("HOME") # Revisiting does not count as a third location.
	assert(not state.can_complete_demo())
	state.mark_post_anomaly_visit("FOREST")
	assert(state.can_complete_demo())
	var restored = GameStateScript.new()
	assert(restored.load_save_data(state.to_save_data()))
	assert(restored.world_state["phase"] == "after_week")
	assert(restored.world_state["flags"]["village_anomaly"])
	assert(restored.investigation_state["visited_after_anomaly"].size() == 3)
	assert(restored.complete_demo())
	var completed = GameStateScript.new()
	assert(completed.load_save_data(restored.to_save_data()))
	assert(completed.world_state["phase"] == "demo_complete")
	var invalid_visits: Dictionary = state.to_save_data()
	invalid_visits["investigation_state"]["visited_after_anomaly"] = ["HOME", "HOME", "UNKNOWN"]
	var protected_visits = GameStateScript.new()
	protected_visits.day_index = 4
	assert(not protected_visits.load_save_data(invalid_visits))
	assert(protected_visits.day_index == 4)
	var impossible_completion: Dictionary = restored.to_save_data()
	impossible_completion["investigation_state"]["visited_after_anomaly"] = ["HOME", "SHRINE"]
	var protected_completion = GameStateScript.new()
	protected_completion.day_index = 3
	assert(not protected_completion.load_save_data(impossible_completion))
	assert(protected_completion.day_index == 3)


func _test_state_journal_consistency() -> void:
	var state = GameStateScript.new()
	var journal = ClueJournalScript.new()
	var ui_logic = MainScript.new()
	assert(ui_logic._state_journal_are_consistent(state, journal))
	assert(journal.add_fact("clue_a", "Clue A", "Observed detail", 1, "早晨", "家"))
	assert(not ui_logic._state_journal_are_consistent(state, journal))
	state.register_fact("clue_a")
	assert(ui_logic._state_journal_are_consistent(state, journal))
	var inconsistent_state = GameStateScript.new()
	inconsistent_state.register_fact("orphan_fact")
	assert(not ui_logic._state_journal_are_consistent(inconsistent_state, journal))
	var duplicate_state = GameStateScript.new()
	duplicate_state.investigation_state["observed_fact_ids"] = ["clue_a", "clue_a"]
	assert(not ui_logic._state_journal_are_consistent(duplicate_state, journal))


func _test_observation_and_anomaly_events() -> void:
	var ui_logic = MainScript.new()
	ui_logic.game_state = GameStateScript.new()
	ui_logic.schedule_manager = ScheduleManagerScript.new()
	ui_logic.clue_journal = ClueJournalScript.new()
	ui_logic.worldline_ledger = WorldlineLedgerScript.new()
	ui_logic.game_state.current_location = "FOREST"
	ui_logic._add_fact("forest_flower_observation", "林间的野花", "观察到的事实")
	ui_logic._record_observation_event("forest_flower_observation")
	assert(ui_logic.worldline_ledger.has_fact("forest_flower_observation"))
	assert(ui_logic.worldline_ledger.event_ids.has("lullaby.observation.day1.slot0.forest.forest_flower_observation"))
	ui_logic.game_state.day_index = 7
	ui_logic.game_state.slot_index = 2
	ui_logic._record_village_anomaly()
	assert(ui_logic.game_state.investigation_state["observed_fact_ids"].has("day7_village_change"))
	assert(ui_logic.clue_journal.get_entries().size() == 2)
	assert(ui_logic.worldline_ledger.has_fact("day7_village_change"))
	assert(ui_logic.worldline_ledger.event_ids.has("lullaby.anomaly.day7.evening"))
	assert(ui_logic._state_journal_are_consistent(ui_logic.game_state, ui_logic.clue_journal))


func _test_journal_ledger_consistency() -> void:
	var ui_logic = MainScript.new()
	ui_logic.game_state = GameStateScript.new()
	ui_logic.schedule_manager = ScheduleManagerScript.new()
	ui_logic.clue_journal = ClueJournalScript.new()
	ui_logic.worldline_ledger = WorldlineLedgerScript.new()
	assert(ui_logic.clue_journal.add_fact("orphan_clue", "Orphan", "No event source", 1, "早晨", "家"))
	assert(not ui_logic._journal_references_are_valid(ui_logic.clue_journal, ui_logic.worldline_ledger))
	ui_logic.worldline_ledger.record_event("source_for_clue", "lullaby", "mite", "observe", "HOME", ["orphan_clue"])
	assert(ui_logic._journal_references_are_valid(ui_logic.clue_journal, ui_logic.worldline_ledger))


func _test_legacy_clue_provenance_migration() -> void:
	var ui_logic = MainScript.new()
	var journal = ClueJournalScript.new()
	var ledger = WorldlineLedgerScript.new()
	assert(journal.add_fact("legacy_clue", "Legacy clue", "Preserved from an older save", 7, "傍晚", "家"))
	assert(ui_logic._migrate_legacy_clue_provenance(journal, ledger))
	assert(ledger.has_fact("legacy_clue"))
	assert(ledger.event_ids.has("lullaby.migration.v1.clue.legacy_clue"))
	assert(ui_logic._journal_references_are_valid(journal, ledger))


func _test_network_tick_consistency() -> void:
	var ui_logic = MainScript.new()
	var state = GameStateScript.new()
	var network = InformationNetworkScript.new()
	state.day_index = 2
	state.slot_index = 0
	network.current_tick = -1
	assert(ui_logic._network_tick_is_valid(state, network))
	network.current_tick = 3
	assert(ui_logic._network_tick_is_valid(state, network))
	network.current_tick = 4
	assert(not ui_logic._network_tick_is_valid(state, network))


func _test_location_content_coverage() -> void:
	assert(MainScript.LOCATION_ORDER.size() == 7)
	for location_id in MainScript.LOCATION_ORDER:
		assert(MainScript.LOCATION_DESCRIPTIONS.has(location_id))
		assert(MainScript.OBSERVATION_TEXT.has(location_id))
		assert(MainScript.ANOMALY_OBSERVATION_TEXT.has(location_id))
		assert(MainScript.ACTIVITY_LABELS.has(location_id))
	for day in range(2, 8):
		assert(MainScript.DAY_OPENING_TEXT.has(day))


func _test_worldline_ledger() -> void:
	var ledger = WorldlineLedgerScript.new()
	assert(ledger.record_event(
		"lullaby.activity.day5.slot1.activity_forest",
		"lullaby",
		"mite",
		"activity_forest",
		"FOREST",
		["forest_flower_picked"]
	))
	assert(not ledger.record_event(
		"lullaby.activity.day5.slot1.activity_forest",
		"lullaby",
		"mite",
		"activity_forest",
		"FOREST",
		["forest_flower_picked"]
	))
	assert(ledger.has_fact("forest_flower_picked"))
	assert(not ledger.character_knows("hero", "forest_flower_picked"))
	assert(ledger.grant_knowledge(
		"hero",
		"forest_flower_picked",
		"lullaby.activity.day5.slot1.activity_forest",
		"direct_observation"
	))
	assert(ledger.character_knows("hero", "forest_flower_picked"))
	assert(ledger.set_opportunity(
		"forest_investigation",
		true,
		"lullaby.activity.day5.slot1.activity_forest"
	))
	assert(ledger.is_opportunity_open("forest_investigation"))

	var restored = WorldlineLedgerScript.new()
	assert(restored.load_save_data(ledger.to_save_data()))
	assert(restored.has_fact("forest_flower_picked"))
	assert(restored.character_knows("hero", "forest_flower_picked"))
	assert(restored.is_opportunity_open("forest_investigation"))

	var protected_ledger = WorldlineLedgerScript.new()
	assert(protected_ledger.record_event("existing", "lullaby", "mite", "observe", "HOME"))
	var invalid_data: Dictionary = ledger.to_save_data()
	invalid_data["character_knowledge"] = "corrupt"
	assert(not protected_ledger.load_save_data(invalid_data))
	assert(protected_ledger.event_ids.has("existing"))


func _test_worldline_ledger_rejects_inconsistent_save() -> void:
	var source = WorldlineLedgerScript.new()
	assert(source.record_event("observation", "lullaby", "mite", "observe", "FOREST", ["forest_oddity"]))
	assert(source.record_event("unrelated_event", "lullaby", "doctor", "review_records", "CLINIC"))
	var protected = WorldlineLedgerScript.new()
	assert(protected.record_event("existing", "lullaby", "mite", "observe", "HOME"))

	var invalid_data: Dictionary = source.to_save_data()
	invalid_data["world_facts"]["forest_oddity"]["first_event_id"] = "unrelated_event"
	assert(not protected.load_save_data(invalid_data))
	assert(protected.event_ids.has("existing"))

	invalid_data = source.to_save_data()
	invalid_data["events"][0]["actor_id"] = ""
	assert(not protected.load_save_data(invalid_data))
	assert(protected.event_ids.has("existing"))

	invalid_data = source.to_save_data()
	invalid_data["events"][0]["fact_ids"] = ["missing_fact"]
	assert(not protected.load_save_data(invalid_data))
	assert(protected.event_ids.has("existing"))


func _test_worldline_information_network() -> void:
	var ledger = WorldlineLedgerScript.new()
	assert(ledger.record_event("source_observation", "lullaby", "mite", "observe_forest", "FOREST", ["forest_oddity"]))
	assert(ledger.record_event("merchant_hears", "lullaby", "merchant", "hear_report", "COMMONS"))
	var network = InformationNetworkScript.new()
	assert(network.publish_message("rumor_1", "forest_oddity", "mite", "merchant", "conversation", 2, 0.8, 3, "source_observation", ledger))
	assert(not network.publish_message("rumor_1", "forest_oddity", "mite", "merchant", "conversation", 2, 0.8, 3, "source_observation", ledger))
	assert(not network.publish_message("forged_rumor", "forest_oddity", "merchant", "doctor", "conversation", 1, 0.5, 3, "merchant_hears", ledger))
	assert(ledger.record_event("source_observation_2", "lullaby", "doctor", "review_records", "CLINIC", ["forest_oddity"]))
	assert(network.publish_message("rumor_2", "forest_oddity", "doctor", "merchant", "conversation", 1, 0.6, 4, "source_observation_2", ledger))
	assert(network.advance_to(4, ledger) == 0)
	assert(network.get_inbox("merchant").is_empty())
	assert(not ledger.character_knows("merchant", "forest_oddity"))
	assert(network.advance_to(5, ledger) == 2)
	assert(network.get_inbox("merchant").size() == 2)
	assert(ledger.event_ids.has("lullaby.message.delivered.rumor_1"))
	assert(ledger.event_ids.has("lullaby.message.delivered.rumor_2"))
	assert(network.get_belief_confidence("merchant", "forest_oddity") > 0.0)
	assert(network.get_belief_confidence("merchant", "forest_oddity") < 0.8)
	# Receipt creates a report and tentative belief, not objective knowledge.
	assert(not ledger.character_knows("merchant", "forest_oddity"))
	assert(network.advance_to(5, ledger) == 0)
	assert(network.advance_to(4, ledger) == 0) # Time cannot move backwards.
	var restored = InformationNetworkScript.new()
	assert(restored.load_save_data(network.to_save_data()))
	assert(restored.get_inbox("merchant").size() == 2)
	assert(is_equal_approx(restored.get_belief_confidence("merchant", "forest_oddity"), network.get_belief_confidence("merchant", "forest_oddity")))
	var ui_logic = MainScript.new()
	assert(ui_logic._network_references_are_valid(restored, ledger))
	var broken_ledger = WorldlineLedgerScript.new()
	assert(broken_ledger.load_save_data(ledger.to_save_data()))
	broken_ledger.event_ids.erase("lullaby.message.delivered.rumor_1")
	assert(not ui_logic._network_references_are_valid(restored, broken_ledger))
	var protected_network = InformationNetworkScript.new()
	assert(protected_network.load_save_data(network.to_save_data()))
	var invalid_data: Dictionary = network.to_save_data()
	invalid_data["messages"] = "corrupt"
	assert(not protected_network.load_save_data(invalid_data))
	assert(protected_network.get_inbox("merchant").size() == 2)
	invalid_data = network.to_save_data()
	invalid_data["current_tick"] = -2
	assert(not protected_network.load_save_data(invalid_data))
	assert(protected_network.get_inbox("merchant").size() == 2)
	invalid_data = network.to_save_data()
	invalid_data["inboxes"]["merchant"][0]["fact_id"] = "forged_fact"
	assert(not protected_network.load_save_data(invalid_data))
	assert(protected_network.get_inbox("merchant").size() == 2)
	invalid_data = network.to_save_data()
	invalid_data["beliefs"]["merchant"]["unsupported_fact"] = 0.4
	assert(not protected_network.load_save_data(invalid_data))
	assert(protected_network.get_inbox("merchant").size() == 2)

	# A pending message may arrive in the future, but cannot be sent after the saved clock.
	var pending_network = InformationNetworkScript.new()
	assert(pending_network.publish_message("future_send_test", "forest_oddity", "mite", "doctor", "conversation", 4, 0.5, 2, "source_observation", ledger))
	var future_send_data: Dictionary = pending_network.to_save_data()
	future_send_data["messages"][0]["sent_tick"] = 3
	future_send_data["messages"][0]["arrival_tick"] = 7
	var protected_pending_network = InformationNetworkScript.new()
	assert(not protected_pending_network.load_save_data(future_send_data))
	assert(protected_pending_network.current_tick == -1)

	# A pending message due exactly at the saved clock should already have been delivered.
	var due_data: Dictionary = pending_network.to_save_data()
	due_data["current_tick"] = 2
	due_data["messages"][0]["arrival_tick"] = 2
	var protected_due_network = InformationNetworkScript.new()
	assert(not protected_due_network.load_save_data(due_data))
	assert(protected_due_network.current_tick == -1)


func _test_npc_behavior_profiles() -> void:
	var profiles: Dictionary = NPCBehaviorProfilesScript.get_all_profiles()
	assert(profiles.size() == 3)
	for npc_id in ["caregiver", "worship_leader", "doctor"]:
		var profile: Dictionary = NPCBehaviorProfilesScript.get_profile(npc_id)
		assert(NPCBehaviorProfilesScript.has_required_fields(profile))
		assert(profile["action_preferences"].size() >= 2)
		assert(profile["knowledge_boundaries"].size() >= 3)
		assert(profile["relationship_dimensions"].size() >= 2)
	assert(NPCBehaviorProfilesScript.get_profile("unknown_npc").is_empty())
	var copy: Dictionary = NPCBehaviorProfilesScript.get_profile("doctor")
	copy["goals"].clear()
	assert(not NPCBehaviorProfilesScript.get_profile("doctor")["goals"].is_empty())


func _test_npc_behavior_simulator() -> void:
	var profile: Dictionary = NPCBehaviorProfilesScript.get_profile("caregiver")
	var action_a: Dictionary = NPCBehaviorSimulatorScript.choose_action("caregiver", profile, 3, 2, 0, 0, false)
	var action_b: Dictionary = NPCBehaviorSimulatorScript.choose_action("caregiver", profile, 3, 2, 0, 0, false)
	assert(NPCBehaviorSimulatorScript.validate_action(action_a))
	assert(action_a == action_b) # Same inputs must yield the same choice.
	assert(action_a["npc_id"] == "caregiver")
	assert(action_a["tick"] == 3)
	var close_relationship: Dictionary = NPCBehaviorSimulatorScript.choose_action("caregiver", profile, 3, 2, 0, 4, false)
	assert(close_relationship["id"] == "check_on_mite")
	var remembered_action: Dictionary = NPCBehaviorSimulatorScript.choose_action("caregiver", profile, 4, 2, 1, 0, false, 0, str(action_a["id"]))
	assert(remembered_action["id"] != action_a["id"])
	var high_trust_after_check: Dictionary = NPCBehaviorSimulatorScript.choose_action("caregiver", profile, 4, 2, 1, 4, false, 0, "check_on_mite")
	assert(high_trust_after_check["id"] != "check_on_mite")
	assert(NPCBehaviorSimulatorScript.choose_action("doctor", NPCBehaviorProfilesScript.get_profile("doctor"), 3, 2, 0, 0, false, 1)["id"] == "review_records")
	assert(NPCBehaviorSimulatorScript.choose_action("doctor", NPCBehaviorProfilesScript.get_profile("doctor"), 3, 2, 0, 0, true).is_empty())
	assert(NPCBehaviorSimulatorScript.choose_action("unknown_npc", {}, 3, 2, 0, 0, false).is_empty())
	assert(not NPCBehaviorSimulatorScript.validate_action({"id": "incomplete"}))
