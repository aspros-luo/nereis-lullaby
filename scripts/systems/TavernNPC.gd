extends Area2D


var npc_id:String = ""


var npc_data:Dictionary = {}



func setup(
	id:String
):


	npc_id=id


	npc_data = NpcManager.get_npc(id)


	if npc_data:


		$Label.text = npc_data["name"]


	print(
		"Tavern NPC Spawn:",
		id
	)



func _ready():


	input_event.connect(
		_on_input_event
	)





func _on_input_event(
	viewport,
	event,
	shape_idx
):


	if event is InputEventMouseButton:


		if event.pressed:


			interact()





func interact():


	print(
		"Interact NPC:",
		npc_id
	)
	
	get_tree().current_scene.get_node(
		"NPCInteractionUI"
	).open(
		npc_id
	)

	#
	# 后续：
	#
	# EventManager
	# Dialogic
	#
