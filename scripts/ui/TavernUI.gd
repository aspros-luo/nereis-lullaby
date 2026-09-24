extends Control


var day_end_clicked := false



func _ready():

	print(
		"TavernUI Ready"
	)


	$Panel/VBox/EndDayButton.pressed.connect(
		_on_end_day_pressed
	)





func _on_end_day_pressed():


	if day_end_clicked:

		print(
			"End Day already clicked"
		)

		return



	day_end_clicked=true


	print(
		"Player Leave Tavern"
	)


	DayManager.end_day()
