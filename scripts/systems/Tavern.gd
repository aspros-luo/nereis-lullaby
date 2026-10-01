extends Node


func _ready():
	print("Tavern Scene Loaded")

	TavernManager.open_tavern()
	$TavernSpawner.spawn_tonight_guests()

	if DayManager.has_method("finish_scene_transition"):
		DayManager.finish_scene_transition()
