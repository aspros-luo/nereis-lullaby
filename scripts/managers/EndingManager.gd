extends Node

signal ending_started(ending_id:String)

var current_ending:String = ""


func start_ending(ending_id:String):
	if ending_id.is_empty():
		return

	current_ending = ending_id
	StoryState.set_flag("demo_ending", ending_id)
	ending_started.emit(ending_id)

	print("Demo Ending:", ending_id)

	get_tree().change_scene_to_file("res://scenes/Ending.tscn")
