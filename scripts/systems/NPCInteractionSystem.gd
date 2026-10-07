extends Node


var current_npc:NPCBase = null


signal interaction_result(result)



func start_interaction(
	id:String
):

	current_npc = NPCManager.get_npc(id)

	if current_npc == null:

		print(
			"NPC Missing:",
			id
		)

		return

	print(
		"Start Interaction:",
		current_npc.npc_name
	)

	show_options()



func show_options():

	if current_npc == null:

		return

	print(
		"Interaction Options:"
	)

	print(
		"1. Talk"
	)

	print(
		"2. Drink"
	)

	print(
		"3. Special"
	)



func talk():

	if current_npc == null:

		return

	var result = current_npc.talk()

	print(
		"Talk Result:",
		result
	)

	interaction_result.emit(
		result
	)

	return result



func drink(
	type:String="normal"
):

	if current_npc == null:

		return

	var drink_id = "ale"

	if type == "special":

		drink_id = "moon_wine"

	var result = DrinkManager.serve_drink(
		drink_id,
		current_npc.id
	)

	print(
		"Drink Result:",
		result
	)

	interaction_result.emit(
		result
	)

	return result



func special():

	if current_npc == null:

		return

	var result = current_npc.trade()

	print(
		"Special Result:",
		result
	)

	interaction_result.emit(
		result
	)

	return result



func debug():

	if current_npc == null:

		return

	print("================")
	print(current_npc.npc_name)

	print(
		"Permanent:",
		current_npc.state.permanent
	)

	print(
		"Temporary:",
		current_npc.state.temporary
	)

	print("================")



func end():

	current_npc = null
