extends Node

func _ready():

	print(
		"DayManager Ready"
	)



func start_day():

	print(
		"Day %s Start"
		% GameManager.current_day
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



func end_day():


	GameManager.current_day += 1


	start_day()
