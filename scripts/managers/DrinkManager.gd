extends Node


var drinks:Dictionary = {}



func _ready():

	print("DrinkManager Ready")

	load_drinks()



func load_drinks():

	var file = FileAccess.open(
		"res://data/game/items/drinks.json",
		FileAccess.READ
	)

	if file == null:

		print("Drink data missing")

		return

	drinks = JSON.parse_string(
		file.get_as_text()
	)

	print(
		"Loaded Drinks:",
		drinks.size()
	)



func get_drink(id:String):

	return drinks.get(id)



func serve_drink(
	drink_id:String,
	npc_id:String
):

	var drink = get_drink(
		drink_id
	)

	if drink == null:

		print(
			"Drink missing:",
			drink_id
		)

		return null

	var npc = NPCManager.get_npc(npc_id)

	if npc == null:

		print(
			"NPC missing:",
			npc_id
		)

		return null

	var result = NPCManager.drink(
		npc_id,
		drink_id
	)

	WorldState.add_value(
		"village_corruption",
		int(drink.get("corruption",0))
	)

	NPCManager.change_trust(
		npc_id,
		int(drink.get("relation",0))
	)

	return result
