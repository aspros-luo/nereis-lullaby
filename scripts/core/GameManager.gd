extends Node

var current_day:int = 1
var run_cycle:int = 1
var is_new_game_plus:bool = false

func _ready():
	print("Nereis Lullaby GameManager Ready")

func start_game():
	start_new_game(false)

func start_new_game(ng_plus:bool = false):
	is_new_game_plus = ng_plus
	run_cycle = max(1, run_cycle + (1 if ng_plus else 0)) if ng_plus else 1
	StoryState.reset()
	WorldState.reset()
	ResourceManager.reset()
	ActionManager.reset()
	TavernSession.reset_session()
	NPCManager.reset_runtime_state()
	StoryManager.reset_runtime_state()
	DayManager.current_day = 1
	DayManager.flow = DayManager.DayFlow.IDLE
	DayManager.scene_transitioning = false
	current_day = 1

	if ng_plus:
		StoryState.set_flag("ng_plus", true)
		StoryState.set_flag("ng_plus_cycle", run_cycle)
		WorldState.set_value("hero_memory", 2)
		WorldState.set_value("mite_humanity", 98)

	call_deferred("_start_first_day")

func _start_first_day():
	DayManager.start_day()

func next_day():
	current_day += 1
	DayManager.start_day()

func complete_run(ending_id:String):
	SaveManager.mark_run_completed(ending_id)
