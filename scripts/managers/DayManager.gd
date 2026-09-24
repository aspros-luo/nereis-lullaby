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

var ending_day=false



func end_day():


	if ending_day:

		print(
			"Day ending blocked"
		)

		return



	ending_day=true


	print(
		"Day End"
	)


	NPCManager.daily_resolve()

	NPCManager.reset_daily()


	GameManager.current_day +=1


	await get_tree().create_timer(0.2).timeout


	ending_day=false


	start_day()
