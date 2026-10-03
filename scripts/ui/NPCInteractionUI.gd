extends Control

const TEXT_PRIMARY := Color("e8dcc7")
const TEXT_MUTED := Color("a99b86")
const TEXT_ACCENT := Color("d9b56d")
const TEXT_ACCENT_HOVER := Color("fff0c8")
const PANEL_TINT := Color("2a2020")
const HOVER_SCALE := Vector2(1.015, 1.015)

var current_npc_id:String = ""
var choice_buttons:Array[Button] = []
var choice_button_ids:Array[String] = ["", ""]
var panel_base_position := Vector2.ZERO
var portrait:TextureRect

var portrait_hunter = preload("res://assets/npc/hunter.svg")
var portrait_merchant = preload("res://assets/npc/merchant.svg")
var portrait_hero = preload("res://assets/npc/hero.svg")

@onready var panel:Panel = $Panel
@onready var name_label:Label = $Panel/VBoxContainer/NameLabel
@onready var talk_button:Button = $Panel/VBoxContainer/TalkButton
@onready var normal_drink_button:Button = $Panel/VBoxContainer/NormalDrinkButton
@onready var special_drink_button:Button = $Panel/VBoxContainer/SpecialDrinkButton
@onready var status_button:Button = $Panel/VBoxContainer/StatusButton
@onready var choice_button_1:Button = $Panel/VBoxContainer/ChoiceButton1
@onready var choice_button_2:Button = $Panel/VBoxContainer/ChoiceButton2
@onready var close_button:Button = $Panel/VBoxContainer/CloseButton
@onready var vbox:VBoxContainer = $Panel/VBoxContainer

func _ready():
	panel_base_position = panel.position
	hide()

	choice_buttons = [choice_button_1, choice_button_2]

	portrait = TextureRect.new()
	portrait.name = "Portrait"
	portrait.custom_minimum_size = Vector2(0, 122)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(portrait)
	vbox.move_child(portrait, 0)

	talk_button.pressed.connect(_on_talk_pressed)
	normal_drink_button.pressed.connect(_on_normal_drink_pressed)
	special_drink_button.pressed.connect(_on_special_drink_pressed)
	status_button.pressed.connect(_on_status_pressed)
	choice_button_1.pressed.connect(_on_choice_button_1_pressed)
	choice_button_2.pressed.connect(_on_choice_button_2_pressed)
	close_button.pressed.connect(close)

	NarrativeManager.dialogue_started.connect(_on_story_dialogue_started)
	NarrativeManager.dialogue_finished.connect(_on_story_dialogue_finished)
	StoryManager.choice_available.connect(_on_story_choice_available)
	StoryManager.choice_completed.connect(_on_story_choice_completed)

	_apply_visual_language()
	_apply_button_feedback()
	_refresh_choice_ui()
	_update_interaction_buttons()

func _apply_visual_language():
	name_label.add_theme_color_override("font_color", TEXT_ACCENT)
	name_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	name_label.add_theme_constant_override("shadow_offset_x", 1)
	name_label.add_theme_constant_override("shadow_offset_y", 1)
	panel.modulate = PANEL_TINT

func _set_portrait(id:String):
	if not is_instance_valid(portrait):
		return
	match id:
		"hunter": portrait.texture = portrait_hunter
		"merchant": portrait.texture = portrait_merchant
		"hero": portrait.texture = portrait_hero
		_: portrait.texture = null

func open(id:String):
	current_npc_id = id
	var npc = NPCManager.get_npc(id)
	if npc:
		name_label.text = npc.npc_name

	_set_portrait(id)
	show()

	panel.position = panel_base_position + Vector2(32.0, 0.0)
	panel.modulate.a = 0.0

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
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
		_update_interaction_buttons()
		return

	print("Talk:", current_npc_id)
	var result = NPCInteractionSystem.talk()
	print("Result:", result)

func _on_normal_drink_pressed():
	if NarrativeManager.is_playing 	or not StoryManager.get_npc_choices(current_npc_id).is_empty() 	or StoryManager.has_npc_dialogue(current_npc_id):
		return

	print("Serve normal drink:", current_npc_id)
	var result = NPCInteractionSystem.drink("normal")
	print("Result:", result)

func _on_special_drink_pressed():
	if NarrativeManager.is_playing 	or not StoryManager.get_npc_choices(current_npc_id).is_empty() 	or StoryManager.has_npc_dialogue(current_npc_id):
		return

	print("Serve special drink:", current_npc_id)
	var result = NPCInteractionSystem.drink("special")
	print("Result:", result)

func _on_status_pressed():
	if NarrativeManager.is_playing 	or not StoryManager.get_npc_choices(current_npc_id).is_empty() 	or StoryManager.has_npc_dialogue(current_npc_id):
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
	var choices:Array = StoryManager.get_npc_choices(current_npc_id)

	for index in range(choice_buttons.size()):
		var button:Button = choice_buttons[index]

		if index < choices.size():
			var choice:Dictionary = choices[index]
			var choice_id:String = str(choice.get("id", ""))

			choice_button_ids[index] = choice_id
			button.text = str(choice.get("label", choice_id if not choice_id.is_empty() else "选择"))
			button.visible = true
		else:
			choice_button_ids[index] = ""
			button.text = ""
			button.visible = false

func _on_choice_button_1_pressed():
	_on_choice_pressed(choice_button_ids[0])

func _on_choice_button_2_pressed():
	_on_choice_pressed(choice_button_ids[1])

func _on_choice_pressed(choice_id:String):
	if NarrativeManager.is_playing or choice_id.is_empty():
		return

	if StoryManager.choose_npc_choice(current_npc_id, choice_id):
		_refresh_choice_ui()
		_update_interaction_buttons()

func _update_interaction_buttons():
	var locked:bool = NarrativeManager.is_playing
	var has_choices:bool = not StoryManager.get_npc_choices(current_npc_id).is_empty()
	var has_story_dialogue:bool = StoryManager.has_npc_dialogue(current_npc_id)
	var has_been_served:bool = TavernSession.has_served(current_npc_id)

	if has_been_served:
		normal_drink_button.text = "今晚已招待"
		special_drink_button.text = "今晚已招待"
	else:
		normal_drink_button.text = "端上麦酒"
		special_drink_button.text = "端上月影"

	talk_button.disabled = locked
	normal_drink_button.disabled = locked or has_choices or has_story_dialogue or has_been_served
	special_drink_button.disabled = locked or has_choices or has_story_dialogue or has_been_served
	status_button.disabled = locked or has_choices or has_story_dialogue
	close_button.disabled = locked

	for button in choice_buttons:
		button.disabled = locked or has_story_dialogue

func _apply_button_feedback():
	var buttons:Array[Button] = [
		talk_button,
		normal_drink_button,
		special_drink_button,
		status_button,
		choice_button_1,
		choice_button_2,
		close_button
	]

	for button in buttons:
		button.focus_mode = Control.FOCUS_NONE
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.pivot_offset = button.size / 2.0
		button.mouse_entered.connect(_on_button_hover.bind(button))
		button.mouse_exited.connect(_on_button_exit.bind(button))

func _on_button_hover(button:Button):
	if button.disabled or not button.visible:
		return

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	tween.tween_property(button, "position:x", 4.0, 0.08)
	tween.tween_property(button, "scale", HOVER_SCALE, 0.08)

func _on_button_exit(button:Button):
	if not is_instance_valid(button):
		return

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	tween.tween_property(button, "position:x", 0.0, 0.08)
	tween.tween_property(button, "scale", Vector2.ONE, 0.08)

func close():
	if NarrativeManager.is_playing:
		return

	NPCInteractionSystem.end()

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.set_parallel(true)
	tween.tween_property(panel, "modulate:a", 0.0, 0.12)
	tween.tween_property(panel, "position", panel_base_position + Vector2(24.0, 0.0), 0.12)
	tween.finished.connect(hide)
