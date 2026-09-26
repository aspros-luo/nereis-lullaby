extends Node


enum DayFlow {
	IDLE,
	MORNING,
	TAVERN,
	ENDING
}


var current_day:int = 1
var flow:DayFlow = DayFlow.IDLE


func _ready():

	print("DayManager Ready")


func start_day():

	current_day = GameManager.current_day
	flow = DayFlow.MORNING

	print("Day %s Start" % current_day)

	start_morning()


func start_morning():

	if flow == DayFlow.ENDING:
		return

	flow = DayFlow.MORNING

	PhaseManager.change_phase(
		PhaseManager.Phase.MORNING
	)

	print("Morning Start")

	get_tree().change_scene_to_file(
		"res://scenes/Morning.tscn"
	)


func start_tavern():

	if flow == DayFlow.ENDING:
		print("Tavern start blocked: day is ending")
		return

	flow = DayFlow.TAVERN

	PhaseManager.change_phase(
		PhaseManager.Phase.TAVERN
	)

	print("Tavern Start")

	get_tree().change_scene_to_file(
		"res://scenes/Tavern.tscn"
	)


func start_night():

	if flow == DayFlow.ENDING:
		return

	PhaseManager.change_phase(
		PhaseManager.Phase.NIGHT
	)

	print("Night Start")

	end_day()


func end_day():

	if flow == DayFlow.ENDING:
		print("Day ending blocked")
		return

	flow = DayFlow.ENDING

	print("Day End")

	NPCManager.daily_resolve()
	NPCManager.reset_daily()

	GameManager.current_day += 1

	print(
		"Next Day:",
		GameManager.current_day
	)

	start_day()
