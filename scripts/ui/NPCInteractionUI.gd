extends Control


var current_npc_id:String = ""
var choice_buttons:Array[Button] = []
var panel_base_position := Vector2.ZERO


@onready var panel:Panel = $Panel
@onready var name_label:Label = $Panel/VBoxContainer/NameLabel
@onready var talk_button:Button = $Panel/VBoxContainer/TalkButton
@onready var normal_drink_button:Button = $Panel/VBoxContainer/NormalDrinkButton
@onready var special_drink_button:Button = $Panel/VBoxContainer/SpecialDrinkButton
@onready var status_button:Button = $Panel/VBoxContainer/StatusButton
@onready var close_button:Button = $Panel/VBoxContainer/CloseButton
@onready var vbox:VBoxContainer = $Panel/VBoxContainer


func _ready():
	panel_base_position = panel.position
	hide()

	talk_button.pressed.connect(_on_talk_pressed)
	normal_drink_button.pressed.connect(_on_normal_drink_pressed)
	special_drink_button.pressed.connect(_on_special_drink_pressed)
	status_button.pressed.connect(_on_status_pressed)
	close_button.pressed.connect(close)

	NarrativeManager.dialogue_started.connect(_on_story_dialogue_started)
	NarrativeManager.dialogue_finished.connect(_on_story_dialogue_finished)
	StoryManager.choice_available.connect(_on_story_choice_available)
	StoryManager.choice_completed.connect(_on_story_choice_completed)

	_apply_button_feedback()
	_update_interaction_buttons()


func open(id:String):
	current_npc_id = id

	var npc = NPCManager.get_npc(id)
	if npc:
		name_label.text = npc.npc_name

	show()
	panel.position = panel_base_position + Vector2(32.0, 0.0)
	panel.modulate.a = 0.0

	var tween := create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "position", panel_base_position, 0.18)
	tween.tween_property(panel, "modulate:a", 1.0, 0.18)

	print("NPC UI SHOW", visible)

	NPCInteractionSystem.start_interaction(id)
	_refresh_choice_ui()
	_update_interaction_buttons()


func _on_talk_pressed():
	if NarrativeManager.is_playing:
		return

	var story_timeline:String = StoryManager.consume_npc_dialogue(current_npc_id)
	if not story_timeline.is_empty():
		print("Story Dialogue:", current_npc_id, "->", story_timeline)
		NarrativeManager.play_timeline(story_timeline)
		return

	var choices:Array = StoryManager.get_npc_choices(current_npc_id)
	if not choices.is_empty():
		_refresh_choice_ui()
		return

	print("Talk:", current_npc_id)
	var result = NPCInteractionSystem.talk()
	print("Result:", result)


func _on_normal_drink_pressed():
	if NarrativeManager.is_playing:
		return
	if not StoryManager.get_npc_choices(current_npc_id).is_empty():
		return
	if StoryManager.has_npc_dialogue(current_npc_id):
		return

	print("Serve normal drink:", current_npc_id)
	var result = NPCInteractionSystem.drink("normal")
	print("Result:", result)


func _on_special_drink_pressed():
	if NarrativeManager.is_playing:
		return
	if not StoryManager.get_npc_choices(current_npc_id).is_empty():
		return
	if StoryManager.has_npc_dialogue(current_npc_id):
		return

	print("Serve special drink:", current_npc_id)
	var result = NPCInteractionSystem.drink("special")
	print("Result:", result)


func _on_status_pressed():
	if NarrativeManager.is_playing:
		return
	if not StoryManager.get_npc_choices(current_npc_id).is_empty():
		return
	if StoryManager.has_npc_dialogue(current_npc_id):
		return

	print("Check NPC:", current_npc_id)
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

	var choices:Array = StoryManager.get_npc_choices(current_npc_id)

	for choice in choices:
		var button := Button.new()
		button.text = str(choice.get("label", choice.get("id", "选择")))
		button.custom_minimum_size = Vector2(0, 34)
		button.focus_mode = Control.FOCUS_NONE
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.add_theme_color_override("font_color", Color("e4d8c1"))
		button.add_theme_color_override("font_hover_color", Color("fff0c8"))

		button.pressed.connect(_on_choice_pressed.bind(str(choice.get("id", ""))))
		button.mouse_entered.connect(_on_choice_hover.bind(button))
		button.mouse_exited.connect(_on_choice_exit.bind(button))

		vbox.add_child(button)
		choice_buttons.append(button)


func _on_choice_pressed(choice_id:String):
	if NarrativeManager.is_playing:
		return

	if StoryManager.choose_npc_choice(current_npc_id, choice_id):
		_refresh_choice_ui()
		_update_interaction_buttons()


func _update_interaction_buttons():
	var locked:bool = NarrativeManager.is_playing
	var has_choices:bool = not StoryManager.get_npc_choices(current_npc_id).is_empty()
	var has_story_dialogue:bool = StoryManager.has_npc_dialogue(current_npc_id)

	talk_button.disabled = locked
	normal_drink_button.disabled = locked or has_choices or has_story_dialogue
	special_drink_button.disabled = locked or has_choices or has_story_dialogue
	status_button.disabled = locked or has_choices or has_story_dialogue
	close_button.disabled = locked or has_choices or has_story_dialogue

	for button in choice_buttons:
		if is_instance_valid(button):
			button.disabled = locked or has_story_dialogue


func _apply_button_feedback():
	var buttons:Array[Button] = [
		talk_button,
		normal_drink_button,
		special_drink_button,
		status_button,
		close_button
	]

	for button in buttons:
		button.focus_mode = Control.FOCUS_NONE
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.mouse_entered.connect(_on_button_hover.bind(button))
		button.mouse_exited.connect(_on_button_exit.bind(button))


func _on_button_hover(button:Button):
	if button.disabled:
		return

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "position:x", 4.0, 0.08)


func _on_button_exit(button:Button):
	if not is_instance_valid(button):
		return

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "position:x", 0.0, 0.08)


func _on_choice_hover(button:Button):
	if button.disabled:
		return

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "position:x", 4.0, 0.08)


func _on_choice_exit(button:Button):
	if not is_instance_valid(button):
		return

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "position:x", 0.0, 0.08)


func close():
	if NarrativeManager.is_playing:
		return
	if not StoryManager.get_npc_choices(current_npc_id).is_empty():
		return
	if StoryManager.has_npc_dialogue(current_npc_id):
		return

	NPCInteractionSystem.end()

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(panel, "modulate:a", 0.0, 0.12)
	tween.tween_property(panel, "position", panel_base_position + Vector2(24.0, 0.0), 0.12)
	tween.finished.connect(hide)
