extends Node

var events:Dictionary = {}

func _ready():
	print("StoryManager Ready")
	load_default_events()

func load_default_events():
	load_event("res://data/game/events/test_event.json")

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

func evaluate_events():
	var candidates:Array = []
	for event in events.values():
		if can_trigger(event):
			candidates.append(event)
	candidates.sort_custom(func(a,b): return a.priority > b.priority)
	for event in candidates:
		execute_event(event)

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
			actual = StoryState.get_flag(condition.get("key", ""), null)
		"world_value":
			actual = WorldState.get_value(condition.get("key", ""))
		_:
			print("Unknown Story Condition:", type)
			return false
	return _compare(actual, operator, expected)

func _compare(actual, operator:String, expected)->bool:
	match operator:
		"==": return actual == expected
		"!=": return actual != expected
		">": return actual > expected
		">=": return actual >= expected
		"<": return actual < expected
		"<=": return actual <= expected
		_:
			return false

func can_trigger(event:StoryEvent)->bool:
	if event == null:
		return false
	if event.once and StoryState.has_flag("event:" + event.id):
		return false
	return check_conditions(event.conditions)

func execute_event(event:StoryEvent)->bool:
	if not can_trigger(event):
		return false
	print("Story Event Execute:", event.id)
	for action in event.actions:
		_execute_action(action)
	if event.once:
		StoryState.set_flag("event:" + event.id, true)
	return true

func execute_event_by_id(id:String)->bool:
	var event = get_event(id)
	if event == null:
		print("Story Event Missing:", id)
		return false
	return execute_event(event)

func _execute_action(action:Dictionary):
	var type:String = action.get("type", "")
	match type:
		"set_story_flag":
			StoryState.set_flag(action.get("key", ""), action.get("value", null))
		"set_world_value":
			WorldState.set_value(action.get("key", ""), action.get("value", 0))
		"add_world_value":
			WorldState.add_value(action.get("key", ""), int(action.get("value", 0)))
		_:
			print("Unknown Story Action:", type)
