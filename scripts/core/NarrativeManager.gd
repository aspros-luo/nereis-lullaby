extends Node


signal dialogue_started(timeline:String)
signal dialogue_finished(timeline:String)


var is_playing:bool = false
var current_timeline:String = ""


func _ready():

	print("NarrativeManager Ready")

	if not Dialogic.timeline_ended.is_connected(_on_dialogic_timeline_ended):
		Dialogic.timeline_ended.connect(_on_dialogic_timeline_ended)


func play_timeline(
	timeline_name:String
)->bool:

	if timeline_name.is_empty():
		return false

	if is_playing:
		print(
			"Narrative blocked: timeline already playing:",
			current_timeline
		)
		return false

	if not Dialogic.timeline_exists(timeline_name):
		print(
			"Narrative timeline missing:",
			timeline_name
		)
		return false

	current_timeline = timeline_name
	is_playing = true

	print(
		"Play Timeline:",
		timeline_name
	)

	dialogue_started.emit(timeline_name)

	Dialogic.start(
		timeline_name
	)

	return true


func _on_dialogic_timeline_ended():

	if not is_playing:
		return

	var finished_timeline:String = current_timeline

	current_timeline = ""
	is_playing = false

	print(
		"Timeline Finished:",
		finished_timeline
	)

	dialogue_finished.emit(finished_timeline)
