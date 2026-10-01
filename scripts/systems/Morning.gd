extends Node


var story_dialogue_played:bool = false
var forest_investigation_started:bool = false
var phase_choice_buttons:Array[Button] = []
var tavern_transition_started:bool = false
var tavern_after_story_pending:bool = false


func _ready():
	print("Morning Scene Loaded")

	$UI/ForestButton.pressed.connect(_on_forest_pressed)
	$UI/FarmButton.pressed.connect(_on_farm_pressed)
	$UI/LivestockButton.pressed.connect(_on_livestock_pressed)
	$UI/TavernButton.pressed.connect(_on_tavern_pressed)
	$UI/ForestInvestigationButton.pressed.connect(_on_forest_investigation_pressed)

	NarrativeManager.dialogue_started.connect(_on_story_dialogue_started)
	NarrativeManager.dialogue_finished.connect(_on_story_dialogue_finished)

	StoryManager.phase_choice_available.connect(_on_phase_choice_available)
	StoryManager.phase_choice_completed.connect(_on_phase_choice_completed)

	_apply_action_feedback()
	_update_action_buttons()
	_refresh_phase_choice_ui()
	_play_pending_story_dialogue()


func _play_pending_story_dialogue():
	if story_dialogue_played:
		return

	story_dialogue_played = true
	var timeline:String = StoryManager.consume_phase_dialogue("MORNING")

	if timeline.is_empty():
		return

	print("Story Morning Dialogue:", timeline)
	NarrativeManager.play_timeline(timeline)


func _on_story_dialogue_started(_timeline:String):
	_update_action_buttons()
	_refresh_phase_choice_ui()


func _on_story_dialogue_finished(_timeline:String):
	_update_action_buttons()
	_refresh_phase_choice_ui()

	if tavern_after_story_pending:
		tavern_after_story_pending = false
		call_deferred("enter_tavern")


func _on_phase_choice_available(phase:String, _event_id:String):
	if phase != "MORNING":
		return

	_refresh_phase_choice_ui()
	_update_action_buttons()


func _on_phase_choice_completed(phase:String, event_id:String, choice_id:String):
	if phase != "MORNING":
		return

	print("Morning Story Choice Completed:", event_id, "->", choice_id)
	_refresh_phase_choice_ui()
	_update_action_buttons()

	if event_id == "forest_investigation_event":
		forest_investigation_started = false
		tavern_after_story_pending = true

	call_deferred("_play_queued_phase_dialogue_after_choice")


func _play_queued_phase_dialogue_after_choice():
	var timeline:String = StoryManager.consume_phase_dialogue("MORNING")
	if timeline.is_empty():
		if tavern_after_story_pending:
			tavern_after_story_pending = false
			enter_tavern()
		return

	print("Story Morning Dialogue After Choice:", timeline)
	NarrativeManager.play_timeline(timeline)


func _refresh_phase_choice_ui():
	for button in phase_choice_buttons:
		if is_instance_valid(button):
			button.queue_free()

	phase_choice_buttons.clear()

	var choices:Array = StoryManager.get_phase_choices("MORNING")

	for choice in choices:
		var button := Button.new()
		button.text = str(choice.get("label", choice.get("id", "选择")))
		button.custom_minimum_size = Vector2(220.0, 32.0)
		button.focus_mode = Control.FOCUS_NONE
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.add_theme_color_override("font_color", Color("eadfc8"))
		button.add_theme_color_override("font_hover_color", Color("fff1c8"))

		button.pressed.connect(_on_phase_choice_pressed.bind(str(choice.get("id", ""))))
		button.mouse_entered.connect(_on_choice_hover.bind(button))
		button.mouse_exited.connect(_on_choice_exit.bind(button))

		$UI.add_child(button)
		phase_choice_buttons.append(button)

		var index:int = phase_choice_buttons.size() - 1
		button.position = Vector2(100.0, 180.0 + index * 38.0)

	_update_phase_choice_buttons()


func _on_choice_hover(button:Button):
	if button.disabled:
		return

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2(1.025, 1.025), 0.1)


func _on_choice_exit(button:Button):
	if not is_instance_valid(button):
		return

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2.ONE, 0.1)


func _update_phase_choice_buttons():
	var locked:bool = NarrativeManager.is_playing

	for button in phase_choice_buttons:
		if is_instance_valid(button):
			button.disabled = locked


func _on_phase_choice_pressed(choice_id:String):
	if NarrativeManager.is_playing:
		return

	if StoryManager.choose_phase_choice("MORNING", choice_id):
		_refresh_phase_choice_ui()
		_update_action_buttons()


func _update_action_buttons():
	var locked:bool = NarrativeManager.is_playing
	var has_phase_choices:bool = not StoryManager.get_phase_choices("MORNING").is_empty()

	$UI/ForestButton.disabled = locked or has_phase_choices or tavern_transition_started
	$UI/FarmButton.disabled = locked or has_phase_choices or tavern_transition_started
	$UI/LivestockButton.disabled = locked or has_phase_choices or tavern_transition_started
	$UI/TavernButton.disabled = locked or has_phase_choices or tavern_transition_started

	$UI/ForestInvestigationButton.visible = StoryState.get_flag("forest_investigation_result_pending", false)
	$UI/ForestInvestigationButton.disabled = locked or has_phase_choices or not $UI/ForestInvestigationButton.visible or tavern_transition_started

	_update_phase_choice_buttons()


func _apply_action_feedback():
	var buttons:Array[Button] = [
		$UI/ForestButton,
		$UI/FarmButton,
		$UI/LivestockButton,
		$UI/TavernButton,
		$UI/ForestInvestigationButton
	]

	for button in buttons:
		button.focus_mode = Control.FOCUS_NONE
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.mouse_entered.connect(_on_action_hover.bind(button))
		button.mouse_exited.connect(_on_action_exit.bind(button))


func _on_action_hover(button:Button):
	if button.disabled or not button.visible:
		return

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "position:x", 108.0, 0.1)


func _on_action_exit(button:Button):
	if not is_instance_valid(button):
		return

	var target_x := 104.0
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "position:x", target_x, 0.1)


func _on_forest_pressed():
	if NarrativeManager.is_playing or not StoryManager.get_phase_choices("MORNING").is_empty():
		return

	ActionManager.execute_action(ActionManager.Action.FOREST)
	enter_tavern()


func _on_farm_pressed():
	if NarrativeManager.is_playing or not StoryManager.get_phase_choices("MORNING").is_empty():
		return

	ActionManager.execute_action(ActionManager.Action.FARM)
	enter_tavern()


func _on_livestock_pressed():
	if NarrativeManager.is_playing or not StoryManager.get_phase_choices("MORNING").is_empty():
		return

	ActionManager.execute_action(ActionManager.Action.LIVESTOCK)
	enter_tavern()


func _on_tavern_pressed():
	if NarrativeManager.is_playing or not StoryManager.get_phase_choices("MORNING").is_empty():
		return

	enter_tavern()


func _on_forest_investigation_pressed():
	if NarrativeManager.is_playing:
		return

	if not StoryManager.execute_manual_event_by_id("forest_investigation_event"):
		print("Forest Investigation unavailable")
		_update_action_buttons()
		return

	forest_investigation_started = true
	_update_action_buttons()
	_refresh_phase_choice_ui()


func enter_tavern():
	if tavern_transition_started:
		print("Tavern transition already started")
		return

	tavern_transition_started = true
	_update_action_buttons()
	ResourceManager.print_resources()
	call_deferred("_start_tavern_transition")


func _start_tavern_transition():
	DayManager.start_tavern()
