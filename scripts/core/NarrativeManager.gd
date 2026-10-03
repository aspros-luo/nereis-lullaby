extends Node


var _dialogic_timeline_loader:ResourceFormatLoader
var _dialogic_character_loader:ResourceFormatLoader


signal dialogue_started(timeline:String)
signal dialogue_finished(timeline:String)


var is_playing:bool = false
var current_timeline:String = ""


func _ready():

	_register_dialogic_resource_loaders()

	print("NarrativeManager Ready")

	if not Dialogic.timeline_ended.is_connected(_on_dialogic_timeline_ended):
		Dialogic.timeline_ended.connect(_on_dialogic_timeline_ended)


func _register_dialogic_resource_loaders():

	var timeline_loader_script = preload("res://addons/dialogic/Resources/TimelineResourceLoader.gd")
	var character_loader_script = preload("res://addons/dialogic/Resources/CharacterResourceLoader.gd")

	_dialogic_timeline_loader = timeline_loader_script.new()
	_dialogic_character_loader = character_loader_script.new()

	ResourceLoader.add_resource_format_loader(
		_dialogic_timeline_loader,
		true
	)

	ResourceLoader.add_resource_format_loader(
		_dialogic_character_loader,
		true
	)


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

	var timeline_resource = _resolve_timeline(timeline_name)
	if timeline_resource == null:
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
		timeline_resource
	)

	return true


func _resolve_timeline(timeline_name:String)->DialogicTimeline:

	if Dialogic.timeline_exists(timeline_name):
		var registered_timeline = DialogicResourceUtil.get_timeline_resource(timeline_name)
		if registered_timeline != null:
			return registered_timeline

	var directory:Dictionary = ProjectSettings.get_setting(
		"dialogic/directories/dtl_directory",
		{}
	)
	var path:String = str(directory.get(timeline_name, ""))
	if path.is_empty():
		return null

	var timeline_resource = load(path)
	if timeline_resource is DialogicTimeline:
		return timeline_resource

	return null


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
