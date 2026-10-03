extends Control

var day_end_clicked := false

@onready var end_day_button:Button = $Panel/VBox/EndDayButton
@onready var status_label:Label = $Panel/VBox/StatusLabel


func _ready():
	print("TavernUI Ready")
	if ChapterBanner:
		ChapterBanner.show_chapter(_chapter_title(), "第 %d 天 · 夜色正在变深" % DayManager.current_day)

	end_day_button.pressed.connect(_on_end_day_pressed)

	NarrativeManager.dialogue_started.connect(_on_story_dialogue_started)
	NarrativeManager.dialogue_finished.connect(_on_story_dialogue_finished)
	StoryManager.choice_available.connect(_on_story_choice_available)
	StoryManager.choice_completed.connect(_on_story_choice_completed)
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

	if StoryManager.has_pending_npc_choices():
		print("End Day blocked: pending story choice")
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


func _on_story_choice_available(_npc_id:String, _event_id:String):
	_update_status()
	_update_day_end_button()


func _on_story_choice_completed(_event_id:String, _choice_id:String):
	_update_status()
	_update_day_end_button()


func _update_status():
	if not is_instance_valid(status_label):
		return

	var phase_text := "营业中"
	if NarrativeManager.is_playing:
		phase_text = "剧情进行中 · 请稍候"
	elif StoryManager.has_pending_npc_choices():
		phase_text = "请先完成剧情选择"
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
		or StoryManager.has_pending_npc_choices()
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

func _chapter_title()->String:
	var day := DayManager.current_day
	if day <= 11:
		return "第一章 · 酒馆的灯"
	if day <= 24:
		return "第二章 · 潮痕"
	if day <= 40:
		return "第三章 · 深井之下"
	if day <= 58:
		return "第四章 · 无月森林"
	if day <= 78:
		return "第五章 · 盐海圣堂"
	if day <= 98:
		return "第六章 · 梦境王座"
	return "第七章 · 蜜忒之歌"
