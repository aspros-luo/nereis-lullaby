extends Node



func _ready():

	print(
		"Tavern Scene Loaded"
	)


	TavernManager.open_tavern()


	start_guest()



func start_guest():


	var guest = TavernSession.get_current_guest()


	if guest != null:

		print(
			"Today guest:",
			guest
		)

	else:

		print(
			"No Guest"
		)
