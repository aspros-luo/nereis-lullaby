extends Node

var failures:int = 0
var root_node:Node

func _ready():
	call_deferred("_run")

func expect(condition:bool, message:String):
	if condition:
		print("PASS: ", message)
	else:
		failures += 1
		push_error("FAIL: " + message)

func node(name:String)->Node:
	return root_node.get_node_or_null(name)

func reset_runtime():
	node("StoryState").call("reset")
	node("StoryManager").call("reset_runtime_state")
	node("WorldState").call("reset")
	node("ResourceManager").call("reset")
	node("ActionManager").call("reset")
	node("TavernSession").call("reset_session")
	node("NPCManager").call("reset_runtime_state")
	node("GameManager").set("current_day", 1)
	node("GameManager").set("run_cycle", 1)
	node("GameManager").set("is_new_game_plus", false)
	node("DayManager").set("current_day", 1)
	node("DayManager").set("flow", 0)
	node("DayManager").set("scene_transitioning", false)
	node("EndingManager").set("current_ending", "")
	node("EndingManager").set("_ending_started", false)
	node("NarrativeManager").set("is_playing", false)
	node("NarrativeManager").set("current_timeline", "")

func set_day(day:int):
	node("GameManager").set("current_day", day)
	node("DayManager").set("current_day", day)

func phase_dialogue(expected:String, message:String):
	var actual:String = str(node("StoryManager").call("consume_phase_dialogue", "MORNING"))
	expect(actual == expected, message + " (" + actual + ")")

func npc_dialogue(npc_id:String, expected:String, message:String):
	var actual:String = str(node("StoryManager").call("consume_npc_dialogue", npc_id))
	expect(actual == expected, message + " (" + actual + ")")

func choose_phase(choice_id:String, message:String):
	expect(bool(node("StoryManager").call("choose_phase_choice", "MORNING", choice_id)), message)

func _run():
	root_node = get_tree().root
	await get_tree().process_frame
	await get_tree().process_frame

	expect(node("SaveManager") != null, "SaveManager autoload is available")
	expect(node("GameMenu") != null, "GameMenu autoload is available")
	expect(ResourceLoader.exists("res://scenes/MainMenu.tscn"), "MainMenu scene exists")
	expect(ResourceLoader.exists("res://data/game/campaign.json"), "40-hour campaign manifest exists")

	reset_runtime()

	# Act I through the original D6 problem point.
	set_day(1)
	expect(int(node("StoryManager").call("evaluate_events")) >= 1, "D1 opening executes")
	set_day(2)
	expect(int(node("StoryManager").call("evaluate_events")) >= 1, "D2 hunter event executes")
	npc_dialogue("hunter", "hunter_trust_reveal", "D2 hunter dialogue queued")
	set_day(3)
	expect(int(node("StoryManager").call("evaluate_events")) >= 1, "D3 route commit executes")
	expect(bool(node("StoryManager").call("execute_manual_event_by_id", "forest_investigation_event")), "D3 forest investigation executes")
	phase_dialogue("forest_entry", "D3 forest entry dialogue")
	choose_phase("leave_mark_alone", "D3 untouched-mark choice")
	set_day(4)
	expect(int(node("StoryManager").call("evaluate_events")) >= 2, "D4 dual consequence events execute")
	phase_dialogue("forest_mark_untouched_consequence", "D4 forest consequence")
	phase_dialogue("hero_mark_anomaly_untouched", "D4 hero anomaly")
	set_day(5)
	expect(int(node("StoryManager").call("evaluate_events")) >= 1, "D5 hero follow-up executes")
	npc_dialogue("hero", "hero_notices_mark_untouched", "D5 hero notice")
	set_day(6)
	expect(int(node("StoryManager").call("evaluate_events")) >= 1, "D6 hero question executes")
	npc_dialogue("hero", "hero_anomaly_question_untouched", "D6 hero question")
	expect((node("StoryManager").call("get_npc_choices","hero") as Array).size() == 2, "D6 two choices are available")
	expect(bool(node("StoryManager").call("choose_npc_choice","hero","tell_hero_about_mark")), "D6 truth sharing resolves")
	set_day(7)
	expect(int(node("StoryManager").call("evaluate_events")) >= 1, "D7 church shadow executes")
	phase_dialogue("church_shadow_shared", "D7 church shadow")
	set_day(8)
	expect(int(node("StoryManager").call("evaluate_events")) == 0, "D8 has no surprise story event")
	set_day(9)
	expect(int(node("StoryManager").call("evaluate_events")) >= 1, "D9 church choice executes")
	expect((node("StoryManager").call("get_phase_choices","MORNING") as Array).size() == 2, "D9 two patrol choices")
	choose_phase("follow_church_patrol", "D9 patrol choice")
	phase_dialogue("church_patrol_follow", "D9 patrol consequence")
	set_day(10)
	expect(int(node("StoryManager").call("evaluate_events")) == 0, "D10 has no surprise story event")

	# D11 is now the Act I route split, not a premature end-of-game.
	set_day(11)
	expect(int(node("StoryManager").call("evaluate_events")) >= 1, "D11 act-one finale executes")
	phase_dialogue("demo_final_choice_intro", "D11 final-intro dialogue")
	expect((node("StoryManager").call("get_phase_choices","MORNING") as Array).size() == 3, "D11 exposes three route choices")
	choose_phase("answer_forest_voice", "D11 forest route selection")
	expect(not bool(node("EndingManager").get("current_ending")), "D11 does not end the full campaign")
	phase_dialogue("act2_forest_call", "D11 forest route call")

	# Act II+ longform route: key days through Day 120.
	set_day(12)
	expect(int(node("StoryManager").call("evaluate_events")) >= 1, "D12 longform forest event executes")
	npc_dialogue("hero", "longform_d12_forest_hero", "D12 forest hero dialogue")
	set_day(13)
	expect(int(node("StoryManager").call("evaluate_events")) >= 1, "D13 longform forest event executes")
	npc_dialogue("hunter", "longform_d13_forest_hunter", "D13 forest hunter dialogue")
	set_day(14)
	expect(int(node("StoryManager").call("evaluate_events")) >= 1, "D14 longform forest event executes")
	npc_dialogue("merchant", "longform_d14_forest_merchant", "D14 forest merchant dialogue")

	set_day(16)
	expect(int(node("StoryManager").call("evaluate_events")) >= 1, "D16 forest sub-route decision executes")
	phase_dialogue("longform_d16_forest_decision", "D16 forest decision intro")
	expect((node("StoryManager").call("get_phase_choices","MORNING") as Array).size() == 2, "D16 exposes two forest sub-route choices")
	choose_phase("follow_tide", "D16 deep forest choice")

	set_day(18)
	expect(int(node("StoryManager").call("evaluate_events")) >= 1, "D18 forest milestone executes")
	npc_dialogue("hero", "longform_d18_forest_hero", "D18 forest milestone dialogue")
	set_day(25)
	expect(int(node("StoryManager").call("evaluate_events")) >= 1, "D25 chapter III begins")
	phase_dialogue("longform_d25_chapter3", "D25 chapter III intro")
	set_day(32)
	expect(int(node("StoryManager").call("evaluate_events")) >= 1, "D32 forest milestone executes")
	npc_dialogue("hunter", "longform_d32_forest_hunter", "D32 forest milestone dialogue")

	set_day(40)
	expect(int(node("StoryManager").call("evaluate_events")) >= 1, "D40 forest decision executes")
	phase_dialogue("longform_d40_forest_choice", "D40 forest decision intro")
	choose_phase("accept", "D40 forest commitment")

	set_day(41)
	expect(int(node("StoryManager").call("evaluate_events")) >= 1, "D41 chapter IV begins")
	phase_dialogue("longform_d41_chapter4", "D41 chapter IV intro")
	set_day(50)
	expect(int(node("StoryManager").call("evaluate_events")) >= 1, "D50 forest milestone executes")
	npc_dialogue("merchant", "longform_d50_forest_merchant", "D50 forest milestone dialogue")

	set_day(58)
	expect(int(node("StoryManager").call("evaluate_events")) >= 1, "D58 forest decision executes")
	phase_dialogue("longform_d58_forest_choice", "D58 forest decision intro")
	choose_phase("accept", "D58 forest name choice")
	set_day(59)
	expect(int(node("StoryManager").call("evaluate_events")) >= 1, "D59 chapter V begins")
	phase_dialogue("longform_d59_chapter5", "D59 chapter V intro")

	set_day(70)
	expect(int(node("StoryManager").call("evaluate_events")) >= 1, "D70 forest milestone executes")
	npc_dialogue("hero", "longform_d70_forest_hero", "D70 forest milestone dialogue")
	set_day(78)
	expect(int(node("StoryManager").call("evaluate_events")) >= 1, "D78 forest decision executes")
	phase_dialogue("longform_d78_forest_choice", "D78 forest decision intro")
	choose_phase("accept", "D78 true-name choice")
	set_day(79)
	expect(int(node("StoryManager").call("evaluate_events")) >= 1, "D79 chapter VI begins")
	phase_dialogue("longform_d79_chapter6", "D79 chapter VI intro")

	set_day(90)
	expect(int(node("StoryManager").call("evaluate_events")) >= 1, "D90 forest milestone executes")
	npc_dialogue("hunter", "longform_d90_forest_hunter", "D90 forest milestone dialogue")
	set_day(98)
	expect(int(node("StoryManager").call("evaluate_events")) >= 1, "D98 forest decision executes")
	phase_dialogue("longform_d98_forest_choice", "D98 forest decision intro")
	choose_phase("accept", "D98 dream crossing")
	set_day(99)
	expect(int(node("StoryManager").call("evaluate_events")) >= 1, "D99 chapter VII begins")
	phase_dialogue("longform_d99_chapter7", "D99 chapter VII intro")
	set_day(110)
	expect(int(node("StoryManager").call("evaluate_events")) >= 1, "D110 forest milestone executes")
	npc_dialogue("hero", "longform_d110_forest_hero", "D110 forest milestone dialogue")

	set_day(119)
	expect(int(node("StoryManager").call("evaluate_events")) >= 1, "D119 finale preparation executes")
	phase_dialogue("longform_d119_final_prep", "D119 finale preparation")
	set_day(120)
	expect(int(node("StoryManager").call("evaluate_events")) >= 1, "D120 true finale executes")
	phase_dialogue("longform_d120_finale", "D120 finale dialogue")
	expect((node("StoryManager").call("get_phase_choices","MORNING") as Array).size() == 3, "D120 exposes three actual endings")
	choose_phase("answer_forest_voice", "D120 ending choice resolves")
	expect(str(node("EndingManager").get("current_ending")) == "outer_god", "D120 routes into actual ending manager")

	# Save system sanity check.
	set_day(120)
	expect(bool(node("SaveManager").call("save_game", 0)), "SaveManager can write a full campaign state")
	expect(bool(node("SaveManager").call("has_save", 0)), "SaveManager reports the save slot")
	node("SaveManager").call("delete_save", 0)

	print("PASS: v0.4 full longform route D1-D120 complete")
	get_tree().quit(0 if failures == 0 else 1)
