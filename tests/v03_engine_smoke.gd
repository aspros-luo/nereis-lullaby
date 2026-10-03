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


func _run():
	root_node = get_tree().root
	await get_tree().process_frame
	await get_tree().process_frame

	expect(node("StoryManager") != null, "StoryManager autoload is available")
	expect(node("NPCManager") != null, "NPCManager autoload is available")
	expect(node("EndingManager") != null, "EndingManager autoload is available")

	var dialogic:Node = node("Dialogic")
	expect(dialogic != null, "Dialogic autoload is available")
	if dialogic != null:
		expect(bool(dialogic.call("timeline_exists", "hunter_trust_reveal")), "hunter_trust_reveal is registered with Dialogic")
		expect(bool(dialogic.call("timeline_exists", "hero_anomaly_question_untouched")), "hero_anomaly_question_untouched is registered with Dialogic")

	reset_runtime()

	# Verify the real StoryManager preserves both D4 morning dialogues.
	node("GameManager").set("current_day", 4)
	node("DayManager").set("current_day", 4)
	node("StoryState").call("set_flag", "forest_investigation_started", true)
	node("StoryState").call("set_flag", "forest_mark_untouched", true)
	var executed_d4:int = int(node("StoryManager").call("evaluate_events"))
	expect(executed_d4 >= 2, "D4 executes both untouched consequence and hero anomaly events")
	var d4_first:String = str(node("StoryManager").call("consume_phase_dialogue", "MORNING"))
	var d4_second:String = str(node("StoryManager").call("consume_phase_dialogue", "MORNING"))
	expect(d4_first == "forest_mark_untouched_consequence", "D4 first morning dialogue is the forest consequence")
	expect(d4_second == "hero_mark_anomaly_untouched", "D4 second morning dialogue is preserved")
	expect(str(node("StoryManager").call("consume_phase_dialogue", "MORNING")).is_empty(), "D4 morning dialogue queue is fully drained")

	reset_runtime()

	# Reproduce the D6 state using the actual StoryManager, then exercise the actual Tavern NPC/UI objects.
	node("GameManager").set("current_day", 6)
	node("DayManager").set("current_day", 6)
	node("StoryState").call("set_flag", "hero_anomaly_followup_queued", true)
	node("StoryState").call("set_flag", "forest_mark_untouched", true)
	var executed_d6:int = int(node("StoryManager").call("evaluate_events"))
	expect(executed_d6 >= 1, "D6 hero question event executes")
	expect(bool(node("StoryManager").call("has_npc_dialogue", "hero")), "D6 hero dialogue is queued")
	expect((node("StoryManager").call("get_npc_choices", "hero") as Array).size() == 2, "D6 hero exposes two choices")

	var tavern_scene := load("res://scenes/Tavern.tscn") as PackedScene
	expect(tavern_scene != null, "Tavern scene resource loads")
	if tavern_scene == null:
		get_tree().quit(1)
		return

	var tavern := tavern_scene.instantiate()
	root_node.add_child(tavern)
	await get_tree().process_frame
	await get_tree().process_frame

	var ui:Control = tavern.get_node_or_null("NPCInteractionUI")
	var tavern_ui:Control = tavern.get_node_or_null("TavernUI")
	expect(ui != null, "NPCInteractionUI exists in Tavern")
	expect(tavern_ui != null, "TavernUI exists in Tavern")
	if ui == null or tavern_ui == null:
		tavern.queue_free()
		get_tree().quit(1)
		return

	expect(ui.mouse_filter == Control.MOUSE_FILTER_IGNORE, "NPCInteractionUI overlay does not block NPC clicks")

	var hero:Area2D = null
	var merchant:Area2D = null
	var npc_count:int = 0
	for child in tavern.get_children():
		if child is Area2D:
			npc_count += 1
			var node_id:String = str(child.get("npc_id"))
			if node_id == "hero":
				hero = child
			elif node_id == "merchant":
				merchant = child

	expect(npc_count == 3, "Tavern spawns exactly three guests")
	expect(hero != null, "Hero guest is spawned")
	expect(merchant != null, "Merchant guest is spawned")

	if hero != null and merchant != null:
		hero.call("interact")
		await get_tree().process_frame
		expect(ui.visible, "Hero interaction opens NPC panel")
		expect(str(ui.get("current_npc_id")) == "hero", "NPC panel targets hero")
		expect((ui.get("choice_buttons") as Array).size() == 2, "Hero D6 choice buttons are rendered")

		merchant.call("interact")
		await get_tree().process_frame
		expect(str(ui.get("current_npc_id")) == "merchant", "Open NPC panel can switch to another guest")
		hero.call("interact")
		await get_tree().process_frame
		expect(str(ui.get("current_npc_id")) == "hero", "Hero can be reopened after switching guests")

		var pending_timeline:String = str(node("StoryManager").call("consume_npc_dialogue", "hero"))
		expect(pending_timeline == "hero_anomaly_question_untouched", "D6 hero timeline is consumed from the pending dialogue")
		ui.call("_on_story_dialogue_finished", pending_timeline)
		await get_tree().process_frame

		var buttons:Array = ui.get("choice_buttons")
		expect(buttons.size() == 2, "D6 choices remain after story dialogue finishes")
		if buttons.size() == 2:
			expect(not buttons[0].disabled and not buttons[1].disabled, "D6 choices are enabled after dialogue")

		var day_before:int = int(node("GameManager").get("current_day"))
		tavern_ui.call("_on_end_day_pressed")
		expect(int(node("GameManager").get("current_day")) == day_before, "End Day is blocked while an NPC story choice is pending")

		ui.call("_on_choice_pressed", "tell_hero_about_mark")
		await get_tree().process_frame
		expect(bool(node("StoryState").call("get_flag", "hero_truth_shared", false)), "Selecting D6 choice applies hero_truth_shared")
		expect(not bool(node("StoryManager").call("has_pending_npc_choices")), "Selecting D6 choice clears pending NPC choices")

	ui.call("close")
	tavern.queue_free()
	await get_tree().process_frame

	get_tree().quit(0 if failures == 0 else 1)
