extends Node


# ==================================================
# StoryManager
#
# v0.3 第一阶段：剧情运行时骨架。
#
# 当前只负责：
# 1. 注册 StoryEvent
# 2. 检查基础 Conditions
# 3. 执行基础 Actions
#
# 当前不负责：
# - 具体剧情内容
# - Dialogic
# - NPC 对话
# - Ending
# - 场景切换
#
# 这些会在后续阶段接入。
# ==================================================

var events:Dictionary = {}


func _ready():

	print("StoryManager Ready")


# ==================================================
# Event Registry
# ==================================================

func register_event(
	event:StoryEvent
):

	if event == null:
		return

	if event.id.is_empty():
		print("Story Event Missing ID")
		return

	events[event.id] = event

	print(
		"Story Event Registered:",
		event.id
	)


func unregister_event(
	id:String
):

	events.erase(id)


func get_event(
	id:String
)->StoryEvent:

	return events.get(id)


# ==================================================
# Condition Evaluation
# ==================================================

func check_conditions(
	conditions:Array
)->bool:

	for condition in conditions:

		if not _check_condition(condition):
			return false

	return true


func _check_condition(
	condition:Dictionary
)->bool:

	var type:String = condition.get(
		"type",
		""
	)

	var operator:String = condition.get(
		"operator",
		"=="
	)

	var expected = condition.get(
		"value",
		null
	)

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


		_:

			print(
				"Unknown Story Condition:",
				type
			)

			return false

	return _compare(
		actual,
		operator,
		expected
	)


func _compare(
	actual,
	operator:String,
	expected
)->bool:

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
			print(
				"Unknown Story Operator:",
				operator
			)
			return false


# ==================================================
# Event Execution
# ==================================================

func can_trigger(
	event:StoryEvent
)->bool:

	if event == null:
		return false

	if event.once and StoryState.has_flag(
		"event:" + event.id
	):
		return false

	return check_conditions(
		event.conditions
	)


func execute_event(
	event:StoryEvent
):

	if not can_trigger(event):
		return false

	print(
		"Story Event Execute:",
		event.id
	)

	for action in event.actions:

		_execute_action(action)

	if event.once:

		StoryState.set_flag(
			"event:" + event.id,
			true
		)

	return true


func execute_event_by_id(
	id:String
)->bool:

	var event = get_event(id)

	if event == null:

		print(
			"Story Event Missing:",
			id
		)

		return false

	return execute_event(event)


# ==================================================
# Action Execution
# ==================================================

func _execute_action(
	action:Dictionary
):

	var type:String = action.get(
		"type",
		""
	)

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


		_:

			print(
				"Unknown Story Action:",
				type
			)
