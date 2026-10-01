extends Control

var day_end_clicked := false

@onready var end_day_button:Button = $Panel/VBox/EndDayButton
@onready var status_label:Label = $Panel/VBox/StatusLabel


func _ready():
	print("TavernUI Ready")

	end_day_button.pressed.connect(_on_end_day_pressed)

	NarrativeManager.dialogue_started.connect(_on_story_dialogue_started)
	NarrativeManager.dialogue_finished.connect(_on_story_dialogue_finished)
	TavernSession.session_started.connect(_on_tavern_session_changed)
	TavernSession.guest_served.connect(_on_guest_served)

	_apply_button_feedback()
	_update_status()
	_update_day_end_button()


func _process(_delta):
	_update_status()


func _on_end_day_pressed():
	if NarrativeManager.is_playing:
		print("End Day blocked: story dialogue is playing")
		return

	if day_end_clicked:
		print("End Day already clicked")
		return

	day_end_clicked = true
	print("Player Leave Tavern")
	_update_day_end_button()
	DayManager.end_day()


func _on_story_dialogue_started(_timeline:String):
	_update_day_end_button()
	_update_status()


func _on_story_dialogue_finished(_timeline:String):
	_update_day_end_button()
	_update_status()


func _on_tavern_session_changed():
	_update_status()


func _on_guest_served(_npc_id:String):
	_update_status()


func _update_status():
	if not is_instance_valid(status_label):
		return

	var phase_text := "营业中"
	if NarrativeManager.is_playing:
		phase_text = "剧情进行中 · 请稍候"
	elif day_end_clicked:
		phase_text = "正在打烊……"

	status_label.text = "营业第 %d 天  ·  已接待 %d/%d  ·  %s" % [
		DayManager.current_day,
		TavernSession.get_served_count(),
		TavernSession.get_guest_count(),
		phase_text
	]


func _update_day_end_button():
	end_day_button.disabled = (
		day_end_clicked
		or NarrativeManager.is_playing
	)


func _apply_button_feedback():
	end_day_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	end_day_button.focus_mode = Control.FOCUS_NONE
	end_day_button.mouse_entered.connect(_on_end_day_hover)
	end_day_button.mouse_exited.connect(_on_end_day_exit)


func _on_end_day_hover():
	if end_day_button.disabled:
		return

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(end_day_button, "scale", Vector2(1.02, 1.02), 0.1)


func _on_end_day_exit():
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(end_day_button, "scale", Vector2.ONE, 0.1)
