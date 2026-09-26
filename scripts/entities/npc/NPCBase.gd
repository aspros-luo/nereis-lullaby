class_name NPCBase
extends Node


# ==================================================
# 基础信息
# ==================================================

var id:String = ""
var npc_name:String = ""


# NPC 唯一状态对象。
# 永久状态与每日临时状态全部通过 state 管理。
var state:NPCState


# ==================================================
# 初始化
# ==================================================

func initialize(data:Dictionary):

	state = NPCState.new()

	id = data.get("id", "")
	npc_name = data.get("name", "Unknown")

	# JSON 只负责提供初始值，NPCState 负责运行时状态。
	var permanent_data:Dictionary = data.get("permanent_state", {})
	var temporary_data:Dictionary = data.get("temporary_state", {})

	state.permanent.merge(permanent_data, true)
	state.temporary.merge(temporary_data, true)

	print("NPC Initialized:", npc_name)


# ==================================================
# 玩家行为
# ==================================================

func talk()->String:

	state.temporary["talk_count"] = state.temporary.get("talk_count", 0) + 1

	return "normal_talk"


func drink(type:String)->String:

	state.temporary["drink_count"] = state.temporary.get("drink_count", 0) + 1

	if state.temporary["drink_count"] >= 3:
		state.temporary["drunk"] = true

	return "drink"


func trade()->String:

	return "trade"


# ==================================================
# 永久状态修改
# ==================================================

func add_permanent(
	key:String,
	value:int
):

	state.permanent[key] = state.permanent.get(key, 0) + value


func set_permanent(
	key:String,
	value
):

	state.permanent[key] = value


func get_permanent(
	key:String
):

	return state.permanent.get(key, null)


# ==================================================
# 临时状态修改
# ==================================================

func add_temporary(
	key:String,
	value:int
):

	state.temporary[key] = state.temporary.get(key, 0) + value


func set_temporary(
	key:String,
	value
):

	state.temporary[key] = value


func get_temporary(
	key:String
):

	return state.temporary.get(key, null)


# ==================================================
# 每日结算
# ==================================================

func daily_resolve():

	print(
		npc_name,
		" resolving..."
	)

	if state.temporary.get("talk_count", 0) >= 2:
		add_permanent("trust", 1)

	if state.temporary.get("drink_count", 0) >= 3:
		add_permanent("fear", 1)


# ==================================================
# 每日结束
# ==================================================

func reset_daily():

	state.reset_daily()

	print(
		npc_name,
		" daily reset"
	)
