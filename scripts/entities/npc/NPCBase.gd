class_name NPCBase
extends Node


# =========================
# 基础信息
# =========================

var id:String = ""
var npc_name:String = ""
var state:NPCState


# =========================
# 初始化
# =========================


func initialize(data:Dictionary):

	state = NPCState.new()

	id = data.get(
		"id",
		""
	)

	npc_name = data.get(
		"name",
		"Unknown"
	)

	# NPCState 是唯一状态来源。
	# JSON 只负责提供初始值。
	state.permanent = data.get(
		"permanent_state",
		{}
	).duplicate(true)

	state.temporary = data.get(
		"temporary_state",
		{}
	).duplicate(true)

	print(
		"NPC Initialized:",
		npc_name
	)



# =========================
# 玩家行为
# =========================


func talk()->String:

	state.temporary["talk_count"] = int(
		state.temporary.get(
			"talk_count",
			0
		)
	) + 1

	return "normal_talk"



func drink(type:String)->String:

	state.temporary["drink_count"] = int(
		state.temporary.get(
			"drink_count",
			0
		)
	) + 1

	if state.temporary["drink_count"] >= 3:
		state.temporary["drunk"] = true

	return "drink"



func trade()->String:

	return "trade"



# =========================
# 状态修改
# =========================


func add_permanent(
	key:String,
	value:int
):

	state.permanent[key] = int(
		state.permanent.get(
			key,
			0
		)
	) + value



func set_permanent(
	key:String,
	value
):

	state.permanent[key] = value



func add_temporary(
	key:String,
	value:int
):

	state.temporary[key] = int(
		state.temporary.get(
			key,
			0
		)
	) + value



func set_temporary(
	key:String,
	value
):

	state.temporary[key] = value



func get_permanent(
	key:String
):

	return state.permanent.get(
		key,
		null
	)



func get_temporary(
	key:String
):

	return state.temporary.get(
		key,
		null
	)



# =========================
# 每日结算
# =========================


func daily_resolve():

	print(
		npc_name,
		" resolving..."
	)

	if state.temporary.get(
		"talk_count",
		0
	) >= 2:

		add_permanent(
			"trust",
			1
		)

	if state.temporary.get(
		"drink_count",
		0
	) >= 3:

		add_permanent(
			"fear",
			1
		)



func reset_daily():

	state.reset_daily()

	print(
		npc_name,
		" daily reset"
	)
