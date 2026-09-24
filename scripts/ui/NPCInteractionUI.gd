extends Control


var current_npc_id:String = ""


@onready var name_label=$Panel/VBoxContainer/NameLabel



func _ready():


	hide()


	$Panel/VBoxContainer/TalkButton.pressed.connect(
		_on_talk_pressed
	)


	$Panel/VBoxContainer/NormalDrinkButton.pressed.connect(
		_on_normal_drink_pressed
	)


	$Panel/VBoxContainer/SpecialDrinkButton.pressed.connect(
		_on_special_drink_pressed
	)


	$Panel/VBoxContainer/StatusButton.pressed.connect(
		_on_status_pressed
	)


	$Panel/VBoxContainer/CloseButton.pressed.connect(
		close
	)





func open(id:String):


	current_npc_id=id


	var npc = NPCManager.get_npc(id)


	if npc:


		name_label.text = npc.npc_name



	show()

	print(
		"NPC UI SHOW",
		visible
	)

	NPCInteractionSystem.start_interaction(
		id
	)





func _on_talk_pressed():


	print(
		"Talk:",
		current_npc_id
	)


	var result = NPCInteractionSystem.talk()


	print(
		"Result:",
		result
	)





func _on_normal_drink_pressed():


	print(
		"Serve normal drink:",
		current_npc_id
	)


	var result = NPCInteractionSystem.drink(
		"normal"
	)


	print(
		"Result:",
		result
	)





func _on_special_drink_pressed():


	print(
		"Serve special drink:",
		current_npc_id
	)


	var result = NPCInteractionSystem.drink(
		"special"
	)


	print(
		"Result:",
		result
	)





func _on_status_pressed():


	print(
		"Check NPC:",
		current_npc_id
	)

	NPCInteractionSystem.debug()

	#NPCManager.debug_npc(
		#current_npc_id
	#)





func close():


	hide()


	NPCInteractionSystem.end()
