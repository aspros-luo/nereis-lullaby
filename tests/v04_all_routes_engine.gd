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

func set_day(day:int):
	node("GameManager").set("current_day", day)
	node("DayManager").set("current_day", day)

func phase(expected:String, label:String):
	var actual:String = str(node("StoryManager").call("consume_phase_dialogue","MORNING"))
	expect(actual == expected, label + " (" + actual + ")")

func npc(npc_id:String, expected:String, label:String):
	var actual:String = str(node("StoryManager").call("consume_npc_dialogue",npc_id))
	expect(actual == expected, label + " (" + actual + ")")

func choice(id:String, label:String):
	expect(bool(node("StoryManager").call("choose_phase_choice","MORNING",id)), label)

func run_route(route:String, final_choice:String, ending_id:String):
	reset_runtime()

	set_day(1)
	node("StoryManager").call("evaluate_events")
	set_day(2)
	node("StoryManager").call("evaluate_events")
	npc("hunter","hunter_trust_reveal",route + " D2 hunter")
	set_day(3)
	node("StoryManager").call("evaluate_events")
	node("StoryManager").call("execute_manual_event_by_id","forest_investigation_event")
	phase("forest_entry",route + " D3 forest entry")
	choice("touch_strange_mark" if route == "forest" else "leave_mark_alone",route + " D3 forest branch")
	set_day(4)
	node("StoryManager").call("evaluate_events")
	phase("forest_mark_touched_consequence" if route == "forest" else "forest_mark_untouched_consequence",route + " D4 forest consequence")
	phase("hero_mark_anomaly" if route == "forest" else "hero_mark_anomaly_untouched",route + " D4 hero anomaly")
	set_day(5)
	node("StoryManager").call("evaluate_events")
	npc("hero","hero_notices_mark_touched" if route == "forest" else "hero_notices_mark_untouched",route + " D5 hero notice")
	set_day(6)
	node("StoryManager").call("evaluate_events")
	npc("hero","hero_anomaly_question_touched" if route == "forest" else "hero_anomaly_question_untouched",route + " D6 hero question")
	choice("tell_hero_about_mark" if route == "forest" else "deny_everything",route + " D6 hero choice")
	set_day(7)
	node("StoryManager").call("evaluate_events")
	phase("church_shadow_shared" if route == "forest" else "church_shadow_hidden",route + " D7 shadow")
	set_day(8)
	node("StoryManager").call("evaluate_events")
	set_day(9)
	node("StoryManager").call("evaluate_events")
	choice("follow_church_patrol" if route == "forest" else "avoid_church_patrol",route + " D9 patrol choice")
	phase("church_patrol_follow" if route == "forest" else "church_patrol_avoid",route + " D9 patrol consequence")
	set_day(10)
	node("StoryManager").call("evaluate_events")

	set_day(11)
	node("StoryManager").call("evaluate_events")
	phase("demo_final_choice_intro",route + " D11 act-one intro")
	choice(final_choice,route + " D11 route selection")
	phase("act2_forest_call" if route == "forest" else ("act2_church_call" if route == "church" else "act2_village_call"),route + " D11 route call")

	var route_spec = {
		"forest": [
			[12,"hero","longform_d12_forest_hero"],[13,"hunter","longform_d13_forest_hunter"],[14,"merchant","longform_d14_forest_merchant"],
			[16,"phase","longform_d16_forest_decision","follow_tide"],[18,"hero","longform_d18_forest_hero"],
			[32,"hunter","longform_d32_forest_hunter"],[40,"phase","longform_d40_forest_choice","accept"],
			[50,"merchant","longform_d50_forest_merchant"],[58,"phase","longform_d58_forest_choice","accept"],
			[70,"hero","longform_d70_forest_hero"],[78,"phase","longform_d78_forest_choice","accept"],
			[90,"hunter","longform_d90_forest_hunter"],[98,"phase","longform_d98_forest_choice","accept"],
			[110,"hero","longform_d110_forest_hero"]
		],
		"church": [
			[12,"hero","longform_d12_church_hero"],[13,"hunter","longform_d13_church_hunter"],[14,"merchant","longform_d14_church_merchant"],
			[16,"phase","longform_d16_church_decision","open_archive"],[18,"merchant","longform_d18_church_merchant"],
			[32,"hero","longform_d32_church_hero"],[40,"phase","longform_d40_church_choice","accept"],
			[50,"hunter","longform_d50_church_hunter"],[58,"phase","longform_d58_church_choice","accept"],
			[70,"merchant","longform_d70_church_merchant"],[78,"phase","longform_d78_church_choice","accept"],
			[90,"hero","longform_d90_church_hero"],[98,"phase","longform_d98_church_choice","accept"],
			[110,"hunter","longform_d110_church_hunter"]
		],
		"village": [
			[12,"hero","longform_d12_village_hero"],[13,"hunter","longform_d13_village_hunter"],[14,"merchant","longform_d14_village_merchant"],
			[16,"phase","longform_d16_village_decision","repair_tavern"],[18,"hunter","longform_d18_village_hunter"],
			[32,"merchant","longform_d32_village_merchant"],[40,"phase","longform_d40_village_choice","accept"],
			[50,"hero","longform_d50_village_hero"],[58,"phase","longform_d58_village_choice","accept"],
			[70,"hunter","longform_d70_village_hunter"],[78,"phase","longform_d78_village_choice","accept"],
			[90,"merchant","longform_d90_village_merchant"],[98,"phase","longform_d98_village_choice","accept"],
			[110,"hero","longform_d110_village_hero"]
		]
	}[route]

	for spec in route_spec:
		if spec[1] == "phase":
			set_day(int(spec[0]))
			expect(int(node("StoryManager").call("evaluate_events")) >= 1,route + " D" + str(spec[0]) + " route decision executes")
			phase(str(spec[2]),route + " D" + str(spec[0]) + " route decision intro")
			choice(str(spec[3]),route + " D" + str(spec[0]) + " route decision")
		else:
			set_day(int(spec[0]))
			expect(int(node("StoryManager").call("evaluate_events")) >= 1,route + " D" + str(spec[0]) + " milestone executes")
			npc(str(spec[1]),str(spec[2]),route + " D" + str(spec[0]) + " milestone")

	var side_days:Array[int] = [20,23,27,35,44,54,67,85]
	for day in side_days:
		set_day(day)
		expect(int(node("StoryManager").call("evaluate_events")) >= 1,route + " supplemental D" + str(day) + " event executes")
		var side_event_id:String = "v04_" + route + "_d" + str(day)
		var side_event = node("StoryManager").call("get_event", side_event_id)
		expect(side_event != null,route + " supplemental event object exists D" + str(day))
		if side_event != null:
			var side_action:Array = side_event.get("actions", [])
			if not side_action.is_empty():
				npc_id = str(side_action[0].get("npc_id", ""))
				var timeline_id:String = str(side_action[0].get("timeline", ""))
				npc(npc_id,timeline_id,route + " supplemental D" + str(day) + " dialogue")

	set_day(25)
	node("StoryManager").call("evaluate_events")
	phase("longform_d25_chapter3",route + " D25")
	set_day(41)
	node("StoryManager").call("evaluate_events")
	phase("longform_d41_chapter4",route + " D41")
	set_day(59)
	node("StoryManager").call("evaluate_events")
	phase("longform_d59_chapter5",route + " D59")
	set_day(79)
	node("StoryManager").call("evaluate_events")
	phase("longform_d79_chapter6",route + " D79")
	set_day(99)
	node("StoryManager").call("evaluate_events")
	phase("longform_d99_chapter7",route + " D99")
	set_day(119)
	node("StoryManager").call("evaluate_events")
	phase("longform_d119_final_prep",route + " D119")
	set_day(120)
	node("StoryManager").call("evaluate_events")
	phase("longform_d120_finale",route + " D120 finale")
	expect((node("StoryManager").call("get_phase_choices","MORNING") as Array).size() == 3,route + " D120 exposes three endings")
	choice(final_choice,route + " D120 final choice")
	expect(str(node("EndingManager").get("current_ending")) == ending_id,route + " reaches " + ending_id)

func _run():
	root_node = get_tree().root
	await get_tree().process_frame
	await get_tree().process_frame

	run_route("forest","answer_forest_voice","outer_god")
	run_route("church","trust_church","church")
	run_route("village","stay_with_village","human")

	# NG+ also unlocks the hidden fourth ending after all three major endings are discovered.
	SaveManager.mark_run_completed("outer_god")
	SaveManager.mark_run_completed("church")
	SaveManager.mark_run_completed("human")
	node("GameManager").set("run_cycle",1)
	node("GameManager").call("start_new_game",true)
	expect(bool(node("StoryState").call("get_flag","true_ending_unlocked",false)),"NG+ true-ending flag unlocks")
	node("GameManager").set("current_day",120)
	node("DayManager").set("current_day",120)
	node("StoryState").call("set_flag","mainline_stage",119)
	node("StoryManager").call("evaluate_events")
	phase("longform_d120_finale","NG+ D120 finale")
	var ng_final_choices:Array = node("StoryManager").call("get_phase_choices","MORNING")
	expect(ng_final_choices.size() == 4,"NG+ exposes gated true ending choice")
	choice("awaken_complete_song","NG+ true ending choice")
	expect(str(node("EndingManager").get("current_ending")) == "true","NG+ reaches true ending")

	print("PASS: v0.4 all three routes D1-D120 complete")
	get_tree().quit(0 if failures == 0 else 1)
