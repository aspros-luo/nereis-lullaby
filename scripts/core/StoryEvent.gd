class_name StoryEvent
extends RefCounted


# ==================================================
# StoryEvent
#
# 一个纯数据事件。
#
# StoryEvent 不负责：
# - 判断当前游戏流程
# - 播放具体剧情
# - 修改场景
#
# 它只保存事件定义，具体执行由 StoryManager 负责。
# ==================================================

var id:String = ""
var conditions:Array = []
var actions:Array = []
var priority:int = 0
var once:bool = true


func initialize(data:Dictionary):

	id = data.get(
		"id",
		""
	)

	conditions = data.get(
		"conditions",
		[]
	)

	actions = data.get(
		"actions",
		[]
	)

	priority = int(data.get(
		"priority",
		0
	))

	once = bool(data.get(
		"once",
		true
	))
