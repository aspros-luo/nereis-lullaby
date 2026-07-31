extends Node


var npcs:Dictionary = {}


func _ready():

	print("NPCManager Ready")

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

		print("NPC load failed:", path)

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



func change_relation(
	id:String,
	value:int
):

	if not npcs.has(id):
		return


	npcs[id]["relation"] += value



func add_corruption(
	id:String,
	value:int
):

	if not npcs.has(id):
		return


	npcs[id]["corruption"] += value
