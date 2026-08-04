extends Area2D


var npc_id:String = ""


var npc:NPCBase





func setup(
	id:String
):


	npc_id = id


	npc = NPCManager.get_npc(
		id
	)


	if npc:


		$Label.text = npc.npc_name


	else:


		print(
			"NPC Not Found:",
			id
		)



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


	var ui = get_tree().current_scene.get_node(
		"NPCInteractionUI"
	)


	if ui:

		ui.open(
			npc_id
		)

	else:

		print(
			"NPCInteractionUI Missing"
		)
