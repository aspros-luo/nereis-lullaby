extends Node

signal ending_started(ending_id:String)

var current_ending:String = ""
var _ending_started:bool = false

func _ready():
	print("EndingManager Ready")

func request_ending(ending_id:String):
	if ending_id.is_empty() or _ending_started:
		return
	print("Ending Requested:", ending_id)
	start_ending(ending_id)

func start_ending(ending_id:String):
	if ending_id.is_empty() or _ending_started:
		return
	_ending_started = true
	current_ending = ending_id
	StoryState.set_flag("demo_ending", ending_id)
	StoryState.remove_flag("demo_ending_request")
	GameManager.complete_run(ending_id)
	ending_started.emit(ending_id)
	print("Demo Ending:", ending_id)
	call_deferred("_change_to_ending")

func _change_to_ending():
	var result := get_tree().change_scene_to_file("res://scenes/Ending.tscn")
	if result != OK:
		_ending_started = false
		push_error("Failed to load Ending scene. Error code: %s" % result)
