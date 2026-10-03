extends SceneTree

var failures:int = 0


func _init():
	call_deferred("_run")


func expect(condition:bool, message:String):
	if condition:
		print("PASS: ", message)
	else:
		failures += 1
		push_error("FAIL: " + message)


func reset_runtime():
	StoryState.reset()
	StoryManager.reset_runtime_state()
	WorldState.reset()
	ResourceManager.reset()
	ActionManager.reset()
	TavernSession.reset_session()
	NPCManager.reset_runtime_state()
	GameManager.current_day = 1
	DayManager.current_day = 1
	DayManager.flow = DayManager.DayFlow.IDLE
	DayManager.scene_transitioning = false
	EndingManager.current_ending = ""
	EndingManager._ending_started = false
	NarrativeManager.is_playing = false
	NarrativeManager.current_timeline = ""


func _run():
	await process_frame
	await process_frame

	expect(get_root().get_node_or_null("StoryManager") != null, "StoryManager autoload is available")
	expect(get_root().get_node_or_null("NPCManager") != null, "NPCManager autoload is available")
	expect(get_root().get_node_or_null("EndingManager") != null, "EndingManager autoload is available")
	expect(Dialogic.timeline_exists("hunter_trust_reveal"), "hunter_trust_reveal is registered with Dialogic")
	expect(Dialogic.timeline_exists("hero_anomaly_question_untouched"), "hero_anomaly_question_untouched is registered with Dialogic")

	reset_runtime()

	# Verify the real StoryManager preserves both D4 morning dialogues.
	GameManager.current_day = 4
	DayManager.current_day = 4
	StoryState.set_flag("forest_investigation_started", true)
	StoryState.set_flag("forest_mark_untouched", true)
	var executed_d4:int = StoryManager.evaluate_events()
	expect(executed_d4 >= 2, "D4 executes both untouched consequence and hero anomaly events")
	var d4_first:String = StoryManager.consume_phase_dialogue("MORNING")
	var d4_second:String = StoryManager.consume_phase_dialogue("MORNING")
	expect(d4_first == "forest_mark_untouched_consequence", "D4 first morning dialogue is the forest consequence")
	expect(d4_second == "hero_mark_anomaly_untouched", "D4 second morning dialogue is preserved")
	expect(StoryManager.consume_phase_dialogue("MORNING").is_empty(), "D4 morning dialogue queue is fully drained")

	reset_runtime()

	# Reproduce the D6 state using the actual StoryManager, then exercise the actual Tavern NPC/UI objects.
	GameManager.current_day = 6
	DayManager.current_day = 6
	StoryState.set_flag("hero_anomaly_followup_queued", true)
	StoryState.set_flag("forest_mark_untouched", true)
	var executed_d6:int = StoryManager.evaluate_events()
	expect(executed_d6 >= 1, "D6 hero question event executes")
	expect(StoryManager.has_npc_dialogue("hero"), "D6 hero dialogue is queued")
	expect(StoryManager.get_npc_choices("hero").size() == 2, "D6 hero exposes two choices")

	var tavern_scene := load("res://scenes/Tavern.tscn") as PackedScene
	expect(tavern_scene != null, "Tavern scene resource loads")
	if tavern_scene == null:
		quit(1)
		return

	var tavern := tavern_scene.instantiate()
	get_root().add_child(tavern)
	await process_frame
	await process_frame

	var ui:Control = tavern.get_node("NPCInteractionUI")
	var tavern_ui:Control = tavern.get_node("TavernUI")
	expect(ui != null, "NPCInteractionUI exists in Tavern")
	expect(tavern_ui != null, "TavernUI exists in Tavern")
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
		hero.interact()
		await process_frame
		expect(ui.visible, "Hero interaction opens NPC panel")
		expect(str(ui.get("current_npc_id")) == "hero", "NPC panel targets hero")
		expect((ui.get("choice_buttons") as Array).size() == 2, "Hero D6 choice buttons are rendered")

		# Switching to another NPC and back must remain possible while the panel is open.
		merchant.interact()
		await process_frame
		expect(str(ui.get("current_npc_id")) == "merchant", "Open NPC panel can switch to another guest")
		hero.interact()
		await process_frame
		expect(str(ui.get("current_npc_id")) == "hero", "Hero can be reopened after switching guests")

		var pending_timeline:String = StoryManager.consume_npc_dialogue("hero")
		expect(pending_timeline == "hero_anomaly_question_untouched", "D6 hero timeline is consumed from the pending dialogue")
		ui.call("_on_story_dialogue_finished", pending_timeline)
		await process_frame
		var buttons:Array = ui.get("choice_buttons")
		expect(buttons.size() == 2, "D6 choices remain after story dialogue finishes")
		if buttons.size() == 2:
			expect(not buttons[0].disabled and not buttons[1].disabled, "D6 choices are enabled after dialogue")

		var day_before:int = GameManager.current_day
		tavern_ui.call("_on_end_day_pressed")
		expect(GameManager.current_day == day_before, "End Day is blocked while an NPC story choice is pending")

		ui.call("_on_choice_pressed", "tell_hero_about_mark")
		await process_frame
		expect(StoryState.get_flag("hero_truth_shared", false) == true, "Selecting D6 choice applies hero_truth_shared")
		expect(not StoryManager.has_pending_npc_choices(), "Selecting D6 choice clears pending NPC choices")

	ui.call("close")
	tavern.queue_free()
	await process_frame

	quit(0 if failures == 0 else 1)
