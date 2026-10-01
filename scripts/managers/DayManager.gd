extends Node


enum DayFlow {
	IDLE,
	MORNING,
	TAVERN,
	ENDING
}


var current_day:int = 1
var flow:DayFlow = DayFlow.IDLE
var scene_transitioning:bool = false


func _ready():
	print("DayManager Ready")


func start_day():
	if scene_transitioning:
		print("Day start blocked: scene transition running")
		return

	current_day = GameManager.current_day
	flow = DayFlow.MORNING

	print("Day %s Start" % current_day)

	StoryManager.evaluate_events()

	start_morning()


func start_morning():
	if flow == DayFlow.ENDING:
		return

	flow = DayFlow.MORNING

	PhaseManager.change_phase(
		PhaseManager.Phase.MORNING
	)

	print("Morning Start")

	var result := get_tree().change_scene_to_file(
		"res://scenes/Morning.tscn"
	)

	if result != OK:
		push_error("Failed to load Morning scene. Error code: %s" % result)
	else:
		print("Morning Scene Change Requested")


func start_tavern():
	if scene_transitioning:
		print("Tavern start blocked: scene transition running")
		return

	if flow == DayFlow.ENDING:
		print("Tavern start blocked: day is ending")
		return

	if flow == DayFlow.TAVERN:
		print("Tavern start ignored: already entering or inside tavern")
		return

	scene_transitioning = true
	flow = DayFlow.TAVERN

	PhaseManager.change_phase(
		PhaseManager.Phase.TAVERN
	)

	print("Tavern Start")

	call_deferred("_change_to_tavern")


func _change_to_tavern():
	var result := get_tree().change_scene_to_file(
		"res://scenes/Tavern.tscn"
	)

	if result != OK:
		flow = DayFlow.MORNING
		scene_transitioning = false
		PhaseManager.change_phase(
			PhaseManager.Phase.MORNING
		)
		push_error("Failed to load Tavern scene. Error code: %s" % result)
	else:
		print("Tavern Scene Change Requested")


func finish_scene_transition():
	scene_transitioning = false
	print("Scene Transition Finished")


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
