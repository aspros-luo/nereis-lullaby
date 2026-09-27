extends Node


var story_dialogue_played:bool = false


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

	NarrativeManager.dialogue_started.connect(
		_on_story_dialogue_started
	)

	NarrativeManager.dialogue_finished.connect(
		_on_story_dialogue_finished
	)

	_update_action_buttons()
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


func _on_story_dialogue_finished(_timeline:String):
	_update_action_buttons()


func _update_action_buttons():

	var locked:bool = NarrativeManager.is_playing

	$UI/ForestButton.disabled = locked
	$UI/FarmButton.disabled = locked
	$UI/LivestockButton.disabled = locked
	$UI/TavernButton.disabled = locked


func _on_forest_pressed():

	if NarrativeManager.is_playing:
		return

	ActionManager.execute_action(
		ActionManager.Action.FOREST
	)

	enter_tavern()


func _on_farm_pressed():

	if NarrativeManager.is_playing:
		return

	ActionManager.execute_action(
		ActionManager.Action.FARM
	)

	enter_tavern()


func _on_livestock_pressed():

	if NarrativeManager.is_playing:
		return

	ActionManager.execute_action(
		ActionManager.Action.LIVESTOCK
	)

	enter_tavern()


func _on_tavern_pressed():

	if NarrativeManager.is_playing:
		return

	enter_tavern()


func enter_tavern():

	ResourceManager.print_resources()

	DayManager.start_tavern()
