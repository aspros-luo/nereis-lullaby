extends Node


var current_npc:NPCBase = null

signal interaction_result(result)


func start_interaction(id:String):
	current_npc = NPCManager.get_npc(id)

	if current_npc == null:
		print("NPC Missing:", id)
		return

	print("Start Interaction:", current_npc.npc_name)
	show_options()


func show_options():
	if current_npc == null:
		return

	print("Interaction Options:")
	print("1. Talk")
	print("2. Drink")
	print("3. Special")


func talk():
	if current_npc == null:
		return

	var npc_id:String = current_npc.id

	if StoryManager.has_npc_dialogue(npc_id):
		var timeline:String = StoryManager.consume_npc_dialogue(npc_id)
		print("Story NPC Dialogue:", npc_id, "->", timeline)
		NarrativeManager.play_timeline(timeline)
		interaction_result.emit("story:" + timeline)
		return timeline

	var result = current_npc.talk()
	print("Talk Result:", result)
	interaction_result.emit(result)
	return result


func drink(type:String="normal"):
	if current_npc == null:
		return

	var npc_id:String = current_npc.id

	if TavernSession.has_served(npc_id):
		print("Guest already served tonight:", npc_id)
		return "already_served"

	var result = current_npc.drink(type)

	if type == "special":
		WorldState.add_value("village_corruption", 1)
		WorldState.add_value("outer_god_progress", 1)
		print("Special drink influence applied:", npc_id)

	TavernSession.mark_served(npc_id)

	print("Drink Result:", result)
	interaction_result.emit(result)
	return result


func special():
	if current_npc == null:
		return

	var result = current_npc.trade()
	print("Special Result:", result)
	interaction_result.emit(result)
	return result


func debug():
	if current_npc == null:
		return

	print("================")
	print(current_npc.npc_name)
	print("Permanent:", current_npc.state.permanent)
	print("Temporary:", current_npc.state.temporary)
	print("================")


func end():
	current_npc = null
