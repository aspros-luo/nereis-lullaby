extends Node

signal ending_started(ending_id:String)

var current_ending:String = ""
var _ending_started:bool = false


func _process(_delta):
	if _ending_started:
		return

	var requested:String = str(StoryState.get_flag("demo_ending_request", ""))
	if requested.is_empty():
		return

	_ending_started = true
	start_ending(requested)


func start_ending(ending_id:String):
	if ending_id.is_empty():
		return

	current_ending = ending_id
	StoryState.set_flag("demo_ending", ending_id)
	StoryState.remove_flag("demo_ending_request")
	ending_started.emit(ending_id)

	print("Demo Ending:", ending_id)

	get_tree().change_scene_to_file("res://scenes/Ending.tscn")
