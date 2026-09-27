extends Control


var current_npc_id:String = ""


@onready var name_label=$Panel/VBoxContainer/NameLabel
@onready var talk_button=$Panel/VBoxContainer/TalkButton
@onready var normal_drink_button=$Panel/VBoxContainer/NormalDrinkButton
@onready var special_drink_button=$Panel/VBoxContainer/SpecialDrinkButton
@onready var status_button=$Panel/VBoxContainer/StatusButton
@onready var close_button=$Panel/VBoxContainer/CloseButton


func _ready():

	hide()

	talk_button.pressed.connect(
		_on_talk_pressed
	)

	normal_drink_button.pressed.connect(
		_on_normal_drink_pressed
	)

	special_drink_button.pressed.connect(
		_on_special_drink_pressed
	)

	status_button.pressed.connect(
		_on_status_pressed
	)

	close_button.pressed.connect(
		close
	)

	NarrativeManager.dialogue_started.connect(
		_on_story_dialogue_started
	)

	NarrativeManager.dialogue_finished.connect(
		_on_story_dialogue_finished
	)

	_update_interaction_buttons()


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

	_update_interaction_buttons()


func _on_talk_pressed():

	if NarrativeManager.is_playing:
		return

	print(
		"Talk:",
		current_npc_id
	)

	var story_timeline:String = StoryManager.consume_npc_dialogue(
		current_npc_id
	)

	if not story_timeline.is_empty():
		print(
			"Story Dialogue:",
			current_npc_id,
			"->",
			story_timeline
		)
		NarrativeManager.play_timeline(story_timeline)
		return

	var result = NPCInteractionSystem.talk()

	print(
		"Result:",
		result
	)


func _on_normal_drink_pressed():

	if NarrativeManager.is_playing:
		return

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

	if NarrativeManager.is_playing:
		return

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

	if NarrativeManager.is_playing:
		return

	print(
		"Check NPC:",
		current_npc_id
	)

	NPCInteractionSystem.debug()


func _on_story_dialogue_started(_timeline:String):
	_update_interaction_buttons()


func _on_story_dialogue_finished(_timeline:String):
	_update_interaction_buttons()


func _update_interaction_buttons():

	var locked:bool = NarrativeManager.is_playing

	talk_button.disabled = locked
	normal_drink_button.disabled = locked
	special_drink_button.disabled = locked
	status_button.disabled = locked

	# 对话进行中不能关闭 NPC 交互窗口，避免剧情状态被玩家打断。
	close_button.disabled = locked


func close():

	if NarrativeManager.is_playing:
		return

	hide()

	NPCInteractionSystem.end()
