extends Control


var day_end_clicked := false


@onready var end_day_button=$Panel/VBox/EndDayButton


func _ready():

	print(
		"TavernUI Ready"
	)


	end_day_button.pressed.connect(
		_on_end_day_pressed
	)

	NarrativeManager.dialogue_started.connect(
		_on_story_dialogue_started
	)

	NarrativeManager.dialogue_finished.connect(
		_on_story_dialogue_finished
	)

	_update_day_end_button()


func _on_end_day_pressed():


	if NarrativeManager.is_playing:
		print(
			"End Day blocked: story dialogue is playing"
		)
		return


	if day_end_clicked:

		print(
			"End Day already clicked"
		)

		return


	day_end_clicked=true


	print(
		"Player Leave Tavern"
	)


	_update_day_end_button()

	DayManager.end_day()


func _on_story_dialogue_started(_timeline:String):
	_update_day_end_button()


func _on_story_dialogue_finished(_timeline:String):
	_update_day_end_button()


func _update_day_end_button():

	end_day_button.disabled = (
		day_end_clicked
		or NarrativeManager.is_playing
	)
