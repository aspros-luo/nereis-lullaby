extends Node


var current_day:int = 1



func _ready():

	print(
		"DayManager Ready"
	)



func start_day():


	current_day = GameManager.current_day


	print(
		"Day %s Start"
		% current_day
	)


	start_morning()



func start_morning():


	PhaseManager.change_phase(
		PhaseManager.Phase.MORNING
	)


	print(
		"Morning Start"
	)


	get_tree().change_scene_to_file(
		"res://scenes/Morning.tscn"
	)



func start_tavern():


	PhaseManager.change_phase(
		PhaseManager.Phase.TAVERN
	)


	print(
		"Tavern Start"
	)


	get_tree().change_scene_to_file(
		"res://scenes/Tavern.tscn"
	)



func start_night():


	PhaseManager.change_phase(
		PhaseManager.Phase.NIGHT
	)


	print(
		"Night Start"
	)


	await get_tree().create_timer(1.0).timeout


	end_day()



func end_day():


	print(
		"Day End"
	)


	GameManager.current_day += 1


	start_day()
