class_name NPCBase
extends Node


# =========================
# 基础信息
# =========================

var id:String = ""

var npc_name:String = ""

var state:NPCState


# =========================
# 状态系统
# =========================


# 永久状态
# 影响剧情、支线、结局

var permanent_state:Dictionary = {}



# 临时状态
# 每日重置

var temporary_state:Dictionary = {}




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


	permanent_state = data.get(
		"permanent_state",
		{}
	)


	temporary_state = data.get(
		"temporary_state",
		{}
	)


	print(
		"NPC Initialized:",
		npc_name
	)




# =========================
# 玩家行为
# =========================


func talk()->String:


	if not state.temporary.has("talk_count"):

		state.temporary["talk_count"]=0


	state.temporary["talk_count"] += 1


	return "normal_talk"



func drink(type:String)->String:


	if not state.temporary.has("drink_count"):

		state.temporary["drink_count"]=0


	state.temporary["drink_count"] += 1



	if state.temporary["drink_count"] >= 3:


		state.temporary["drunk"]=true



	return "drink"

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


	if permanent_state.has(key):

		permanent_state[key]+=value




func set_permanent(
	key:String,
	value
):

	permanent_state[key]=value





func add_temporary(
	key:String,
	value:int
):


	if temporary_state.has(key):

		temporary_state[key]+=value





func set_temporary(
	key:String,
	value
):

	temporary_state[key]=value





func get_permanent(
	key:String
):

	return permanent_state.get(
		key,
		null
	)




func get_temporary(
	key:String
):

	return temporary_state.get(
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

	pass




func reset_daily():


	if temporary_state.has(
		"talk_count"
	):

		temporary_state["talk_count"]=0



	if temporary_state.has(
		"drink_count"
	):

		temporary_state["drink_count"]=0



	if temporary_state.has(
		"drunk"
	):

		temporary_state["drunk"]=false



	print(
		npc_name,
		" daily reset"
	)
