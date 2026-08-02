extends Node


var npcs:Dictionary = {}



func _ready():


	print(
		"NPCManager Ready"
	)


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
			"NPC load failed:",
			path
		)

		return



	var data = JSON.parse_string(
		file.get_as_text()
	)



	if data:


		npcs[data["id"]] = data


		print(
			"Loaded NPC:",
			data["name"]
		)




func get_npc(id:String):


	return npcs.get(id)




#
# 修改NPC数值
#
func change_value(
	id:String,
	key:String,
	value:int
):


	if not npcs.has(id):

		return



	if not npcs[id].has(key):

		npcs[id][key]=0



	npcs[id][key]+=value




#
# 关系
#
func change_relation(
	id:String,
	value:int
):

	change_value(
		id,
		"relation",
		value
	)




#
# 信任
#
func change_trust(
	id:String,
	value:int
):

	change_value(
		id,
		"trust",
		value
	)




#
# 腐化
#
func add_corruption(
	id:String,
	value:int
):

	change_value(
		id,
		"corruption",
		value
	)



#
# 知识
#
func add_knowledge(
	id:String,
	value:int
):

	change_value(
		id,
		"knowledge",
		value
	)




#
# 添加剧情Flag
#
func add_flag(
	id:String,
	flag:String
):


	if not npcs.has(id):

		return



	if not npcs[id]["flags"].has(flag):

		npcs[id]["flags"].append(flag)




#
# 检查Flag
#
func has_flag(
	id:String,
	flag:String
):


	if not npcs.has(id):

		return false



	return npcs[id]["flags"].has(flag)




#
# 调试
#
func debug_print():


	print("================")

	print(npcs)

	print("================")
