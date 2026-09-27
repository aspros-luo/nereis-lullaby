extends Node

signal event_executed(event_id:String)
signal event_expired(event_id:String)
signal choice_available(npc_id:String, event_id:String)
signal choice_completed(event_id:String, choice_id:String)


const EVENTS_DIRECTORY:String = "res://data/game/events"


var events:Dictionary = {}
var pending_npc_dialogues:Dictionary = {}
var pending_phase_dialogues:Dictionary = {}
var pending_npc_choices:Dictionary = {}


func _ready():

	print("StoryManager Ready")
	load_default_events()


func load_default_events():

	events.clear()
	load_event_directory(EVENTS_DIRECTORY)


func load_event_directory(path:String):

	var directory = DirAccess.open(path)

	if directory == null:
		print("Story Event Directory Missing:", path)
		return

	var files:Array[String] = []

	directory.list_dir_begin()

	while true:

		var entry:String = directory.get_next()

		if entry.is_empty():
			break

		if directory.current_is_dir():
			continue

		if entry.ends_with(".json"):
			files.append(entry)

	directory.list_dir_end()
	files.sort()

	for file_name in files:
		load_event(path.path_join(file_name))


func load_event(path:String):

	var file = FileAccess.open(path, FileAccess.READ)

	if file == null:
		print("Story Event Load Failed:", path)
		return

	var data = JSON.parse_string(file.get_as_text())

	if data == null or not data is Dictionary:
		print("Story Event JSON Error:", path)
		return

	var event = StoryEvent.new()
	event.initialize(data)
	register_event(event)


func register_event(event:StoryEvent):

	if event == null or event.id.is_empty():
		return

	events[event.id] = event

	print("Story Event Registered:", event.id)


func get_event(id:String)->StoryEvent:

	return events.get(id)


func get_event_status(event_id:String)->String:

	return str(StoryState.get_flag(
		"event_status:" + event_id,
		"PENDING"
	))


func set_event_status(event_id:String, status:String):

	StoryState.set_flag(
		"event_status:" + event_id,
		status
	)


func evaluate_events()->int:

	_resolve_expired_events()

	var candidates:Array = []

	for event in events.values():

		if can_trigger(event):
			candidates.append(event)

	candidates.sort_custom(
		func(a,b):
			return a.priority > b.priority
	)

	var executed_count:int = 0

	for event in candidates:

		if execute_event(event):
			executed_count += 1

	return executed_count


func _resolve_expired_events():

	var current_day:int = GameManager.current_day

	for event in events.values():

		if event.end_day < 0:
			continue

		var status:String = get_event_status(event.id)

		if status == "COMPLETED" or status == "EXPIRED":
			continue

		if current_day <= event.end_day:
			continue

		if not check_conditions(event.conditions):
			continue

		print("Story Event Expired:", event.id)

		for action in event.expire_actions:
			_execute_action(action)

		set_event_status(event.id, "EXPIRED")
		event_expired.emit(event.id)


func check_conditions(conditions:Array)->bool:

	for condition in conditions:

		if not _check_condition(condition):
			return false

	return true


func _check_condition(condition:Dictionary)->bool:

	var type:String = condition.get("type", "")
	var operator:String = condition.get("operator", "==")
	var expected = condition.get("value", null)
	var actual = null

	match type:

		"day":
			actual = GameManager.current_day

		"story_flag":
			actual = StoryState.get_flag(
				condition.get("key", ""),
				null
			)

		"world_value":
			actual = WorldState.get_value(
				condition.get("key", "")
			)

		"resource":
			actual = ResourceManager.get_resource(
				condition.get("key", "")
			)

		"npc_permanent":
			actual = _get_npc_state_value(
				condition,
				true
			)

		"npc_temporary":
			actual = _get_npc_state_value(
				condition,
				false
			)

		_:
			print("Unknown Story Condition:", type)
			return false

	return _compare(actual, operator, expected)


func _get_npc_state_value(
	condition:Dictionary,
	permanent:bool
):

	var npc_id:String = condition.get("npc_id", "")
	var key:String = condition.get("key", "")
	var npc = NPCManager.get_npc(npc_id)

	if npc == null:
		return null

	if permanent:
		return npc.get_permanent(key)

	return npc.get_temporary(key)


func _compare(actual, operator:String, expected)->bool:

	if actual == null:

		match operator:
			"==":
				return expected == null
			"!=":
				return expected != null
			_:
				return false

	match operator:
		"==":
			return actual == expected
		"!=":
			return actual != expected
		">":
			return actual > expected
		">=":
			return actual >= expected
		"<":
			return actual < expected
		"<=":
			return actual <= expected
		_:
			return false


func can_trigger(event:StoryEvent)->bool:

	if event == null:
		return false

	var status:String = get_event_status(event.id)

	if status == "ACTIVE" or status == "COMPLETED" or status == "EXPIRED":
		return false

	if event.once and StoryState.has_flag(
		"event:" + event.id
	):
		return false

	var current_day:int = GameManager.current_day

	if event.start_day >= 0 and current_day < event.start_day:
		return false

	if event.end_day >= 0 and current_day > event.end_day:
		return false

	return check_conditions(event.conditions)


func execute_event(event:StoryEvent)->bool:

	if not can_trigger(event):
		return false

	print("Story Event Execute:", event.id)

	for action in event.actions:
		_execute_action(action)

	if not event.choices.is_empty():
		set_event_status(event.id, "ACTIVE")
		_queue_event_choices(event)
	else:
		_complete_event(event)

	event_executed.emit(event.id)

	return true


func _complete_event(event:StoryEvent):

	set_event_status(event.id, "COMPLETED")

	if event.once:
		StoryState.set_flag(
			"event:" + event.id,
			true
		)


func _queue_event_choices(event:StoryEvent):

	var npc_id:String = ""

	if not event.choices.is_empty():
		npc_id = str(event.choices[0].get("npc_id", ""))

	if npc_id.is_empty():
		print("Story Event Choice NPC Missing:", event.id)
		return

	pending_npc_choices[npc_id] = {
		"event_id": event.id,
		"choices": event.choices
	}

	print("Story Choices Available:", npc_id, "->", event.id)
	choice_available.emit(npc_id, event.id)


func get_npc_choices(npc_id:String)->Array:

	var data:Dictionary = pending_npc_choices.get(npc_id, {})

	if data.is_empty():
		return []

	return data.get("choices", [])


func consume_npc_choices(npc_id:String)->Array:

	var choices:Array = get_npc_choices(npc_id)

	if choices.is_empty():
		return []

	return choices


func choose_npc_choice(npc_id:String, choice_id:String)->bool:

	var data:Dictionary = pending_npc_choices.get(npc_id, {})

	if data.is_empty():
		return false

	var event_id:String = data.get("event_id", "")
	var event = get_event(event_id)

	if event == null or get_event_status(event_id) != "ACTIVE":
		pending_npc_choices.erase(npc_id)
		return false

	var selected:Dictionary = {}

	for choice in data.get("choices", []):
		if str(choice.get("id", "")) == choice_id:
			selected = choice
			break

	if selected.is_empty():
		return false

	var conditions:Array = selected.get("conditions", [])

	if not conditions.is_empty() and not check_conditions(conditions):
		return false

	print("Story Choice Selected:", event_id, "->", choice_id)

	for action in selected.get("actions", []):
		_execute_action(action)

	pending_npc_choices.erase(npc_id)
	_complete_event(event)
	choice_completed.emit(event_id, choice_id)

	return true


func execute_event_by_id(id:String)->bool:

	var event = get_event(id)

	if event == null:
		print("Story Event Missing:", id)
		return false

	return execute_event(event)


func consume_npc_dialogue(npc_id:String)->String:

	var timeline:String = pending_npc_dialogues.get(npc_id, "")

	if timeline.is_empty():
		return ""

	pending_npc_dialogues.erase(npc_id)

	print("Story NPC Dialogue Consumed:", npc_id, "->", timeline)

	return timeline


func consume_phase_dialogue(phase:String)->String:

	var timeline:String = pending_phase_dialogues.get(phase, "")

	if timeline.is_empty():
		return ""

	pending_phase_dialogues.erase(phase)

	print("Story Phase Dialogue Consumed:", phase, "->", timeline)

	return timeline


func _execute_action(action:Dictionary):

	var type:String = action.get("type", "")

	match type:

		"set_story_flag":
			StoryState.set_flag(
				action.get("key", ""),
				action.get("value", null)
			)

		"set_world_value":
			WorldState.set_value(
				action.get("key", ""),
				action.get("value", 0)
			)

		"add_world_value":
			WorldState.add_value(
				action.get("key", ""),
				int(action.get("value", 0))
			)

		"add_resource":
			ResourceManager.add_resource(
				action.get("key", ""),
				int(action.get("value", 0))
			)

		"queue_npc_dialogue":
			var npc_id:String = action.get("npc_id", "")
			var timeline:String = action.get("timeline", "")

			if not npc_id.is_empty() and not timeline.is_empty():
				pending_npc_dialogues[npc_id] = timeline
				print("Story NPC Dialogue Queued:", npc_id, "->", timeline)

		"queue_phase_dialogue":
			var phase:String = action.get("phase", "")
			var phase_timeline:String = action.get("timeline", "")

			if not phase.is_empty() and not phase_timeline.is_empty():
				pending_phase_dialogues[phase] = phase_timeline
				print("Story Phase Dialogue Queued:", phase, "->", phase_timeline)

		"play_timeline":
			var direct_timeline:String = action.get("timeline", "")

			if not direct_timeline.is_empty():
				NarrativeManager.play_timeline(direct_timeline)

		"set_npc_permanent":
			_set_npc_state_value(action, true, false)

		"add_npc_permanent":
			_set_npc_state_value(action, true, true)

		"set_npc_temporary":
			_set_npc_state_value(action, false, false)

		"add_npc_temporary":
			_set_npc_state_value(action, false, true)

		_:
			print("Unknown Story Action:", type)


func _set_npc_state_value(
	action:Dictionary,
	permanent:bool,
	additive:bool
):

	var npc_id:String = action.get("npc_id", "")
	var key:String = action.get("key", "")
	var value = action.get("value", 0)
	var npc = NPCManager.get_npc(npc_id)

	if npc == null:
		print("Story Action NPC Missing:", npc_id)
		return

	if permanent:

		if additive:
			npc.add_permanent(key, int(value))
		else:
			npc.set_permanent(key, value)

		return

	if additive:
		npc.add_temporary(key, int(value))
	else:
		npc.set_temporary(key, value)
