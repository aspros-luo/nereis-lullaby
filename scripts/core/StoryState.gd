class_name StoryState
extends Node


# ==================================================
# StoryState
#
# 只保存剧情层状态。
#
# WorldState 负责世界数值。
# NPCState 负责 NPC 状态。
# StoryState 负责跨事件的剧情 Flag。
# ==================================================

var flags:Dictionary = {}


func set_flag(
	key:String,
	value
):

	flags[key] = value


func get_flag(
	key:String,
	default_value = null
):

	return flags.get(
		key,
		default_value
	)


func has_flag(
	key:String
)->bool:

	return flags.has(key)


func remove_flag(
	key:String
):

	flags.erase(key)


func reset():

	flags.clear()


func debug_print():

	print("================")
	print("Story Flags:", flags)
	print("================")
