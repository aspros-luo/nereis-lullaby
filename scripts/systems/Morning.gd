extends Node


var story_dialogue_played:bool = false
var forest_investigation_started:bool = false
var phase_choice_buttons:Array[Button] = []


func _ready():

	print(
		"Morning Scene Loaded"
	)

	$UI/ForestButton.pressed.connect(
		_on_forest_pressed
	)

	$UI/FarmButton.pressed.connect(
		_on_farm_pressed
	)

	$UI/LivestockButton.pressed.connect(
		_on_livestock_pressed
	)

	$UI/TavernButton.pressed.connect(
		_on_tavern_pressed
	)

	$UI/ForestInvestigationButton.pressed.connect(
		_on_forest_investigation_pressed
	)

	NarrativeManager.dialogue_started.connect(
		_on_story_dialogue_started
	)

	NarrativeManager.dialogue_finished.connect(
		_on_story_dialogue_finished
	)

	StoryManager.phase_choice_available.connect(
		_on_phase_choice_available
	)

	StoryManager.phase_choice_completed.connect(
		_on_phase_choice_completed
	)

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

	print(
		"Story Morning Dialogue:",
		timeline
	)

	NarrativeManager.play_timeline(timeline)


func _on_story_dialogue_started(_timeline:String):
	_update_action_buttons()
	_refresh_phase_choice_ui()


func _on_story_dialogue_finished(_timeline:String):
	_update_action_buttons()
	_refresh_phase_choice_ui()


func _on_phase_choice_available(phase:String, _event_id:String):

	if phase != "MORNING":
		return

	_refresh_phase_choice_ui()
	_update_action_buttons()


func _on_phase_choice_completed(
	phase:String,
	event_id:String,
	choice_id:String
):

	if phase != "MORNING":
		return

	print(
		"Morning Story Choice Completed:",
		event_id,
		"->",
		choice_id
	)

	_refresh_phase_choice_ui()
	_update_action_buttons()

	if event_id == "forest_investigation_event":
		forest_investigation_started = false
		enter_tavern()


func _refresh_phase_choice_ui():

	for button in phase_choice_buttons:
		if is_instance_valid(button):
			button.queue_free()

	phase_choice_buttons.clear()

	var choices:Array = StoryManager.get_phase_choices("MORNING")

	for choice in choices:

		var button := Button.new()
		button.text = str(
			choice.get("label", choice.get("id", "选择"))
		)
		button.custom_minimum_size = Vector2(220.0, 28.0)

		button.pressed.connect(
			_on_phase_choice_pressed.bind(
				str(choice.get("id", ""))
			)
		)

		$UI.add_child(button)
		phase_choice_buttons.append(button)

		var index:int = phase_choice_buttons.size() - 1
		button.position = Vector2(
			100.0,
			180.0 + index * 32.0
		)

	_update_phase_choice_buttons()


func _update_phase_choice_buttons():

	var locked:bool = NarrativeManager.is_playing

	for button in phase_choice_buttons:
		if is_instance_valid(button):
			button.disabled = locked


func _on_phase_choice_pressed(choice_id:String):

	if NarrativeManager.is_playing:
		return

	if StoryManager.choose_phase_choice(
		"MORNING",
		choice_id
	):
		_refresh_phase_choice_ui()
		_update_action_buttons()


func _update_action_buttons():

	var locked:bool = NarrativeManager.is_playing
	var has_phase_choices:bool = not StoryManager.get_phase_choices(
		"MORNING"
	).is_empty()

	$UI/ForestButton.disabled = locked or has_phase_choices
	$UI/FarmButton.disabled = locked or has_phase_choices
	$UI/LivestockButton.disabled = locked or has_phase_choices
	$UI/TavernButton.disabled = locked or has_phase_choices

	$UI/ForestInvestigationButton.visible = (
		StoryState.get_flag(
			"forest_investigation_result_pending",
			false
		)
	)

	$UI/ForestInvestigationButton.disabled = (
		locked
		or has_phase_choices
		or not $UI/ForestInvestigationButton.visible
	)

	_update_phase_choice_buttons()


func _on_forest_pressed():

	if NarrativeManager.is_playing:
		return

	if not StoryManager.get_phase_choices("MORNING").is_empty():
		return

	ActionManager.execute_action(
		ActionManager.Action.FOREST
	)

	enter_tavern()


func _on_farm_pressed():

	if NarrativeManager.is_playing:
		return

	if not StoryManager.get_phase_choices("MORNING").is_empty():
		return

	ActionManager.execute_action(
		ActionManager.Action.FARM
	)

	enter_tavern()


func _on_livestock_pressed():

	if NarrativeManager.is_playing:
		return

	if not StoryManager.get_phase_choices("MORNING").is_empty():
		return

	ActionManager.execute_action(
		ActionManager.Action.LIVESTOCK
	)

	enter_tavern()


func _on_tavern_pressed():

	if NarrativeManager.is_playing:
		return

	if not StoryManager.get_phase_choices("MORNING").is_empty():
		return

	enter_tavern()


func _on_forest_investigation_pressed():

	if NarrativeManager.is_playing:
		return

	if not StoryManager.execute_manual_event_by_id(
		"forest_investigation_event"
	):
		print("Forest Investigation unavailable")
		_update_action_buttons()
		return

	forest_investigation_started = true
	_update_action_buttons()
	_refresh_phase_choice_ui()


func enter_tavern():

	ResourceManager.print_resources()

	DayManager.start_tavern()
