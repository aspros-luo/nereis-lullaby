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
		hide
	)




func open(npc_id:String):


	current_npc_id=npc_id


	var npc=NpcManager.get_npc(
		npc_id
	)


	if npc:

		name_label.text=npc["name"]


	show()




func _on_talk_pressed():

	print(
		"Talk:",
		current_npc_id
	)


	hide()




func _on_normal_drink_pressed():

	print(
		"Serve normal drink:",
		current_npc_id
	)


	hide()




func _on_special_drink_pressed():

	print(
		"Serve special drink:",
		current_npc_id
	)


	hide()




func _on_status_pressed():

	print(
		"Check NPC:",
		current_npc_id
	)


	hide()
