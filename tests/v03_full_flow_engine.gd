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

func _run():
	root_node = get_tree().root
	await get_tree().process_frame
	await get_tree().process_frame

	expect(node("StoryManager") != null, "Full-flow StoryManager is available")
	expect(node("NPCManager") != null, "Full-flow NPCManager is available")
	expect(node("EndingManager") != null, "Full-flow EndingManager is available")

	reset_runtime()

	set_day(1)
	expect(int(node("StoryManager").call("evaluate_events")) >= 1, "D1 opening executes")
	expect(int(node("StoryManager").call("get_mainline_stage")) == 1, "D1 stage is 1")
	expect(bool(node("StoryState").call("get_flag", "mainline_facade_active", false)), "D1 facade is active")

	set_day(2)
	expect(int(node("StoryManager").call("evaluate_events")) >= 1, "D2 hunter event executes")
	expect(bool(node("StoryState").call("get_flag", "hunter_forest_route_unlocked", false)), "D2 forest route unlocks")
	npc_dialogue("hunter", "hunter_trust_reveal", "D2 hunter reveal is queued")

	set_day(3)
	expect(int(node("StoryManager").call("evaluate_events")) >= 1, "D3 forest route commit executes")
	expect(bool(node("StoryState").call("get_flag", "forest_investigation_committed", false)), "D3 forest investigation commits")
	expect(bool(node("StoryManager").call("execute_manual_event_by_id", "forest_investigation_event")), "D3 manual investigation starts")
	phase_dialogue("forest_entry", "D3 forest entry dialogue is queued")
	expect((node("StoryManager").call("get_phase_choices", "MORNING") as Array).size() == 2, "D3 has two forest choices")
	expect(bool(node("StoryManager").call("choose_phase_choice", "MORNING", "leave_mark_alone")), "D3 untouched choice succeeds")
	expect(bool(node("StoryState").call("get_flag", "forest_mark_untouched", false)), "D3 untouched branch recorded")
	expect(int(node("StoryManager").call("get_mainline_stage")) == 5, "D3 stage is 5")

	set_day(4)
	expect(int(node("StoryManager").call("evaluate_events")) >= 2, "D4 executes both morning branch events")
	phase_dialogue("forest_mark_untouched_consequence", "D4 forest consequence is first")
	phase_dialogue("hero_mark_anomaly_untouched", "D4 hero anomaly is second")
	expect(int(node("StoryManager").call("get_mainline_stage")) == 6, "D4 stage is 6")

	set_day(5)
	expect(int(node("StoryManager").call("evaluate_events")) >= 1, "D5 hero follow-up executes")
	npc_dialogue("hero", "hero_notices_mark_untouched", "D5 hero notice is queued")
	expect(bool(node("StoryState").call("get_flag", "hero_anomaly_followup_queued", false)), "D5 hero follow-up recorded")

	set_day(6)
	expect(int(node("StoryManager").call("evaluate_events")) >= 1, "D6 hero question executes")
	npc_dialogue("hero", "hero_anomaly_question_untouched", "D6 hero question is queued")
	var d6_choices:Array = node("StoryManager").call("get_npc_choices", "hero")
	expect(d6_choices.size() == 2, "D6 has two hero choices")
	expect(bool(node("StoryManager").call("choose_npc_choice", "hero", "tell_hero_about_mark")), "D6 hero truth choice succeeds")
	expect(bool(node("StoryState").call("get_flag", "hero_truth_shared", false)), "D6 truth-shared branch recorded")
	expect(not bool(node("StoryManager").call("has_pending_npc_choices")), "D6 pending choice is cleared")
	expect(int(node("StoryManager").call("get_mainline_stage")) == 8, "D6 stage is 8")

	set_day(7)
	expect(int(node("StoryManager").call("evaluate_events")) >= 1, "D7 church shadow executes")
	phase_dialogue("church_shadow_shared", "D7 church shadow is queued")
	expect(bool(node("StoryState").call("get_flag", "church_shadow_started", false)), "D7 church shadow starts")
	expect(int(node("StoryManager").call("get_mainline_stage")) == 9, "D7 stage is 9")

	set_day(8)
	expect(int(node("StoryManager").call("evaluate_events")) == 0, "D8 has no unexpected story event")

	set_day(9)
	expect(int(node("StoryManager").call("evaluate_events")) >= 1, "D9 church encounter executes")
	var d9_choices:Array = node("StoryManager").call("get_phase_choices", "MORNING")
	expect(d9_choices.size() == 2, "D9 has two patrol choices")
	expect(bool(node("StoryManager").call("choose_phase_choice", "MORNING", "follow_church_patrol")), "D9 follow-patrol choice succeeds")
	expect(bool(node("StoryState").call("get_flag", "followed_church_patrol", false)), "D9 followed-patrol branch recorded")
	phase_dialogue("church_patrol_follow", "D9 patrol consequence is queued")
	expect(int(node("WorldState").call("get_value", "church_truth")) == 1, "D9 church truth becomes 1")
	expect(int(node("StoryManager").call("get_mainline_stage")) == 10, "D9 stage is 10")

	set_day(10)
	expect(int(node("StoryManager").call("evaluate_events")) == 0, "D10 has no unexpected story event")

	set_day(11)
	expect(int(node("StoryManager").call("evaluate_events")) >= 1, "D11 final event executes")
	phase_dialogue("demo_final_choice_intro", "D11 final intro is queued")
	var final_choices:Array = node("StoryManager").call("get_phase_choices", "MORNING")
	expect(final_choices.size() == 3, "D11 exposes all three ending choices")
	expect(bool(node("StoryManager").call("choose_phase_choice", "MORNING", "stay_with_village")), "D11 human ending choice succeeds")
	expect(str(node("EndingManager").get("current_ending")) == "human", "D11 requests human ending")
	expect(int(node("StoryManager").call("get_mainline_stage")) == 11, "D11 stage is 11")
	expect(not bool(node("StoryManager").call("has_pending_npc_choices")), "D11 has no pending NPC choices")

	print("PASS: v0.3 full story engine flow D1-D11 complete")
	get_tree().quit(0 if failures == 0 else 1)
