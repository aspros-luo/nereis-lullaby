extends Node


var npcs:Dictionary = {}


var factory:NPCFactory



func _ready():

	print(
		"NPCManager Ready"
	)

	factory = NPCFactory.new()

	load_default_npcs()



func load_default_npcs():

	load_npc(
		"res://data/game/npc/hunter.json"
	)

	load_npc(
		"res://data/game/npc/merchant.json"
	)

	load_npc(
		"res://data/game/npc/hero.json"
	)



func load_npc(path:String):

	var file = FileAccess.open(
		path,
		FileAccess.READ
	)

	if file == null:
		print(
			"NPC Load Failed:",
			path
		)
		return

	var data = JSON.parse_string(
		file.get_as_text()
	)

	if data == null:
		print(
			"JSON Error:",
			path
		)
		return

	var npc = factory.create_npc(
		data
	)

	npcs[npc.id] = npc

	print(
		"Loaded NPC Object:",
		npc.npc_name
	)



func get_npc(
	id:String
)->NPCBase:

	return npcs.get(
		id
	)



# ==========================
# 玩家交互接口
# ==========================


func talk(
	id:String
):

	var npc = get_npc(id)

	if npc == null:
		return null

	return npc.talk()



func drink(
	id:String,
	type:String
):

	var npc = get_npc(id)

	if npc == null:
		return null

	return npc.drink(
		type
	)



# ==========================
# NPC 状态接口
# ==========================


func change_trust(
	id:String,
	amount:int
):

	var npc = get_npc(id)

	if npc == null:
		return null

	if npc.state == null:
		return null

	var current = int(
		npc.state.permanent.get(
			"trust",
			0
		)
	)

	var value = current + amount

	npc.state.permanent["trust"] = value

	return value



func add_corruption(
	id:String,
	amount:int
):

	# NPC 当前没有独立 corruption 状态。
	# 腐化属于世界状态，因此由 WorldState 统一承载。
	WorldState.add_value(
		"village_corruption",
		amount
	)

	return WorldState.get_value(
		"village_corruption"
	)



# ==========================
# 每日结算
# ==========================


func daily_resolve():

	print(
		"NPC Daily Resolve Start"
	)

	for npc in npcs.values():
		npc.daily_resolve()

	print(
		"NPC Daily Resolve End"
	)



func reset_daily():

	print(
		"NPC Daily Reset Start"
	)

	for npc in npcs.values():
		npc.reset_daily()

	print(
		"NPC Daily Reset End"
	)



# ==========================
# Debug
# ==========================


func debug_npc(
	id:String
):

	var npc = get_npc(id)

	if npc == null:
		return

	print("================")
	print(
		npc.npc_name
	)
	print(
		"Permanent:",
		npc.state.permanent
	)
	print(
		"Temporary:",
		npc.state.temporary
	)
	print("================")
