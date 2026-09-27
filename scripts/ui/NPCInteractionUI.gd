extends Control


var current_npc_id:String = ""
var choice_buttons:Array[Button] = []


@onready var name_label=$Panel/VBoxContainer/NameLabel
@onready var talk_button=$Panel/VBoxContainer/TalkButton
@onready var normal_drink_button=$Panel/VBoxContainer/NormalDrinkButton
@onready var special_drink_button=$Panel/VBoxContainer/SpecialDrinkButton
@onready var status_button=$Panel/VBoxContainer/StatusButton
@onready var close_button=$Panel/VBoxContainer/CloseButton
@onready var vbox=$Panel/VBoxContainer


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

	StoryManager.choice_available.connect(
		_on_story_choice_available
	)

	StoryManager.choice_completed.connect(
		_on_story_choice_completed
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

	_refresh_choice_ui()
	_update_interaction_buttons()


func _on_talk_pressed():

	if NarrativeManager.is_playing:
		return

	var choices:Array = StoryManager.get_npc_choices(
		current_npc_id
	)

	if not choices.is_empty():
		_refresh_choice_ui()
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

	if not StoryManager.get_npc_choices(current_npc_id).is_empty():
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

	if not StoryManager.get_npc_choices(current_npc_id).is_empty():
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

	if not StoryManager.get_npc_choices(current_npc_id).is_empty():
		return

	print(
		"Check NPC:",
		current_npc_id
	)

	NPCInteractionSystem.debug()


func _on_story_dialogue_started(_timeline:String):
	_update_interaction_buttons()


func _on_story_dialogue_finished(_timeline:String):
	_refresh_choice_ui()
	_update_interaction_buttons()


func _on_story_choice_available(npc_id:String, _event_id:String):

	if npc_id != current_npc_id:
		return

	_refresh_choice_ui()
	_update_interaction_buttons()


func _on_story_choice_completed(_event_id:String, _choice_id:String):
	_refresh_choice_ui()
	_update_interaction_buttons()


func _refresh_choice_ui():

	for button in choice_buttons:
		if is_instance_valid(button):
			button.queue_free()

	choice_buttons.clear()

	var choices:Array = StoryManager.get_npc_choices(
		current_npc_id
	)

	for choice in choices:

		var button := Button.new()
		button.text = str(
			choice.get("label", choice.get("id", "选择"))
		)

		button.pressed.connect(
			_on_choice_pressed.bind(
				str(choice.get("id", ""))
			)
		)

		vbox.add_child(button)
		choice_buttons.append(button)


func _on_choice_pressed(choice_id:String):

	if NarrativeManager.is_playing:
		return

	if StoryManager.choose_npc_choice(
		current_npc_id,
		choice_id
	):
		_refresh_choice_ui()
		_update_interaction_buttons()


func _update_interaction_buttons():

	var locked:bool = NarrativeManager.is_playing
	var has_choices:bool = not StoryManager.get_npc_choices(
		current_npc_id
	).is_empty()

	talk_button.disabled = locked or has_choices
	normal_drink_button.disabled = locked or has_choices
	special_drink_button.disabled = locked or has_choices
	status_button.disabled = locked or has_choices

	# 对话或剧情选择进行中不能关闭 NPC 交互窗口。
	close_button.disabled = locked or has_choices

	for button in choice_buttons:
		if is_instance_valid(button):
			button.disabled = locked


func close():

	if NarrativeManager.is_playing:
		return

	if not StoryManager.get_npc_choices(current_npc_id).is_empty():
		return

	hide()

	NPCInteractionSystem.end()
