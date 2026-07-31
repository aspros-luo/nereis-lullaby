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

		return


	print(
		"Serve:",
		drink["name"]
	)


	WorldState.add_value(
		"village_corruption",
		drink["corruption"]
	)


	NpcManager.change_relation(
		npc_id,
		drink["relation"]
	)


	NpcManager.add_corruption(
		npc_id,
		drink["corruption"]
	)
	
	WorldState.debug_print()
