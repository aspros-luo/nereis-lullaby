extends Node



func _ready():

	print(
		"Tavern Scene Loaded"
	)


	TavernManager.open_tavern()
	
	$TavernSpawner.spawn_tonight_guests()
