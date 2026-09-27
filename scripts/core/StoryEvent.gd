class_name StoryEvent
extends RefCounted


# ==================================================
# StoryEvent
#
# 纯数据事件定义。
#
# StoryEvent 不负责执行剧情，只描述：
# - 什么时候可以出现
# - 事件持续到什么时候
# - 事件触发时做什么
# - 玩家可以做什么选择
# - 选择之后产生什么结果
# - 是否只能由玩家主动触发
# ==================================================

var id:String = ""
var conditions:Array = []
var actions:Array = []
var expire_actions:Array = []
var choices:Array = []
var priority:int = 0
var once:bool = true
var manual:bool = false
var start_day:int = -1
var end_day:int = -1


func initialize(data:Dictionary):

	id = data.get("id", "")
	conditions = data.get("conditions", [])
	actions = data.get("actions", [])
	expire_actions = data.get("expire_actions", [])
	choices = data.get("choices", [])
	priority = int(data.get("priority", 0))
	once = bool(data.get("once", true))
	manual = bool(data.get("manual", false))
	start_day = int(data.get("start_day", -1))
	end_day = int(data.get("end_day", -1))
