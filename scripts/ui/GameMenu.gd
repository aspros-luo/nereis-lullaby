extends CanvasLayer

var menu_root:Control
var dimmer:ColorRect
var panel:Panel
var journal_panel:Panel
var status_label:Label
var journal_label:Label
var save_button:Button
var load_button:Button
var new_game_button:Button
var ng_plus_button:Button
var main_menu_button:Button
var archive_button:Button
var chapter_label:Label

const BG := Color("090a0e")
const PANEL := Color("16151a")
const PANEL_EDGE := Color("6f5a43")
const TEXT := Color("e7dcc8")
const MUTED := Color("998f83")
const ACCENT := Color("d8b36a")

func _ready():
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	hide_menu()

func _unhandled_input(event:InputEvent):
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		toggle_menu()

func toggle_menu():
	if visible:
		hide_menu()
	else:
		if NarrativeManager.is_playing:
			return
		show_menu()

func show_menu():
	_update_state()
	show()
	menu_root.visible = true
	dimmer.modulate.a = 0.0
	panel.position = Vector2(470, 110)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(dimmer, "modulate:a", 1.0, 0.14)
	tween.tween_property(panel, "position", Vector2(450, 110), 0.18)

func hide_menu():
	menu_root.visible = false

func _build_ui():
	menu_root = Control.new()
	menu_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(menu_root)

	dimmer = ColorRect.new()
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(BG, 0.72)
	dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
	menu_root.add_child(dimmer)

	panel = Panel.new()
	panel.position = Vector2(450, 110)
	panel.size = Vector2(380, 500)
	panel.add_theme_stylebox_override("panel", _panel_style())
	menu_root.add_child(panel)

	var title := Label.new()
	title.text = "NEREIS' LULLABY"
	title.position = Vector2(28, 24)
	title.size = Vector2(324, 36)
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", ACCENT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "旅途记录"
	subtitle.position = Vector2(28, 58)
	subtitle.size = Vector2(324, 24)
	subtitle.add_theme_font_size_override("font_size", 13)
	subtitle.add_theme_color_override("font_color", MUTED)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(subtitle)

	chapter_label = Label.new()
	chapter_label.position = Vector2(28, 88)
	chapter_label.size = Vector2(324, 24)
	chapter_label.add_theme_font_size_override("font_size", 15)
	chapter_label.add_theme_color_override("font_color", ACCENT)
	chapter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(chapter_label)

	status_label = Label.new()
	status_label.position = Vector2(28, 114)
	status_label.size = Vector2(324, 38)
	status_label.add_theme_font_size_override("font_size", 13)
	status_label.add_theme_color_override("font_color", TEXT)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(status_label)

	var box := VBoxContainer.new()
	box.position = Vector2(44, 156)
	box.size = Vector2(292, 290)
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)

	var resume := _button("继续")
	resume.pressed.connect(hide_menu)
	box.add_child(resume)

	save_button = _button("保存游戏")
	save_button.pressed.connect(_save)
	box.add_child(save_button)

	load_button = _button("读取游戏")
	load_button.pressed.connect(_load)
	box.add_child(load_button)

	var journal := _button("旅途记录")
	journal.pressed.connect(_show_journal)
	box.add_child(journal)

	archive_button = _button("结局图鉴")
	archive_button.pressed.connect(_show_archive)
	box.add_child(archive_button)

	ng_plus_button = _button("新游戏+")
	ng_plus_button.pressed.connect(_start_ng_plus)
	box.add_child(ng_plus_button)

	main_menu_button = _button("返回主菜单")
	main_menu_button.pressed.connect(_main_menu)
	box.add_child(main_menu_button)

	var close := _button("关闭")
	close.pressed.connect(hide_menu)
	box.add_child(close)

	journal_panel = Panel.new()
	journal_panel.position = Vector2(870, 110)
	journal_panel.size = Vector2(340, 500)
	journal_panel.add_theme_stylebox_override("panel", _panel_style())
	journal_panel.visible = false
	menu_root.add_child(journal_panel)

	journal_label = Label.new()
	journal_label.position = Vector2(22, 22)
	journal_label.size = Vector2(296, 420)
	journal_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	journal_label.add_theme_font_size_override("font_size", 13)
	journal_label.add_theme_color_override("font_color", TEXT)
	journal_panel.add_child(journal_label)

	var back := _button("返回")
	back.position = Vector2(22, 450)
	back.size = Vector2(296, 38)
	back.pressed.connect(func(): journal_panel.visible = false)
	journal_panel.add_child(back)

func _button(text_value:String)->Button:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(0, 38)
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_size_override("font_size", 15)
	button.add_theme_color_override("font_color", TEXT)
	button.add_theme_color_override("font_hover_color", ACCENT)
	button.add_theme_stylebox_override("normal", _button_style(Color("151419")))
	button.add_theme_stylebox_override("hover", _button_style(Color("222027")))
	button.add_theme_stylebox_override("pressed", _button_style(Color("2c2823")))
	return button

func _panel_style()->StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL
	style.border_color = PANEL_EDGE
	style.set_border_width_all(2)
	style.corner_radius_top_left = 14
	style.corner_radius_top_right = 14
	style.corner_radius_bottom_left = 14
	style.corner_radius_bottom_right = 14
	return style

func _button_style(bg:Color)->StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = Color("3c3530")
	style.set_border_width_all(1)
	style.corner_radius_top_left = 7
	style.corner_radius_top_right = 7
	style.corner_radius_bottom_left = 7
	style.corner_radius_bottom_right = 7
	return style

func _update_state():
	status_label.text = "第 %d 天  ·  第 %d 周目" % [GameManager.current_day, GameManager.run_cycle]
	chapter_label.text = _chapter_title()
	ng_plus_button.disabled = not SaveManager.has_completed_run()
	archive_button.text = "结局图鉴 · %d/4" % SaveManager.get_discovered_endings().size()

func _save():
	SaveManager.save_game(0)
	status_label.text = "保存完成 · 第 %d 天" % GameManager.current_day

func _load():
	if SaveManager.load_game(0):
		hide_menu()
	else:
		status_label.text = "读取失败"

func _show_journal():
	journal_panel.visible = true
	journal_label.text = _journal_text()

func _show_archive():
	journal_panel.visible = true
	var endings := SaveManager.get_discovered_endings()
	var labels := {"outer_god":"潮声","church":"圣火之下","human":"留下来","true":"潮声之心"}
	var lines:Array[String] = ["结局图鉴", "", "已发现：%d / 4" % endings.size(), ""]
	for id in ["outer_god", "church", "human", "true"]:
		lines.append(("◆ " if endings.has(id) else "◇ ") + labels[id])
	journal_label.text = "\n".join(lines)

func _chapter_title()->String:
	var day := GameManager.current_day
	if day <= 11: return "第一章 · 酒馆的灯"
	if day <= 24: return "第二章 · 潮痕"
	if day <= 40: return "第三章 · 深井之下"
	if day <= 58: return "第四章 · 无月森林"
	if day <= 78: return "第五章 · 盐海圣堂"
	if day <= 98: return "第六章 · 梦境王座"
	return "第七章 · 蜜忒之歌"

func _journal_text()->String:
	var stage := StoryManager.get_mainline_stage()
	var lines:Array[String] = [
		"旅途记录",
		"",
		"主线进度：阶段 %d" % stage,
		"当前周目：%d" % GameManager.run_cycle,
		"",
		"已知章节："
	]
	if stage >= 1:
		lines.append("I  酒馆的灯")
	if stage >= 3:
		lines.append("II 森林刻痕")
	if stage >= 7:
		lines.append("III 失忆者")
	if stage >= 9:
		lines.append("IV 教会阴影")
	if stage >= 11:
		lines.append("V  第一幕终曲")
	if stage >= 12:
		lines.append("VI 潮痕")
	if stage >= 20:
		lines.append("VII 深井之下")
	if stage >= 40:
		lines.append("VIII 无月森林")
	if stage >= 59:
		lines.append("IX 盐海圣堂")
	if stage >= 79:
		lines.append("X  梦境王座")
	if stage >= 99:
		lines.append("XI 蜜忒之歌")
	if stage >= 120:
		lines.append("最终章 · 灯下终曲")
	return "\n".join(lines)

func _start_ng_plus():
	if not SaveManager.has_completed_run():
		return
	GameManager.start_new_game(true)
	hide_menu()

func _main_menu():
	hide_menu()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
