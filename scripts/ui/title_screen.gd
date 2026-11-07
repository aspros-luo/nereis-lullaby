extends Control
## Title screen: New Game / Load from 3 slots / Quit.

const SaveManagerScript = preload("res://scripts/systems/save/save_manager.gd")
const MAIN_SCENE := "res://scenes/main.tscn"

const LOCATION_NAMES: Dictionary = {
	"HOME": "家附近", "COMMONS": "公共场", "SHRINE": "礼拜场所", "CLINIC": "诊疗处",
	"PATH": "村庄通路", "FOREST": "林间", "GROVE": "林中空地",
}

var slot_list: VBoxContainer
var status_label: Label
var load_panel: Control

func _ready() -> void:
	_build_ui()
	_refresh_slots()


func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var bg := ColorRect.new()
	bg.color = Color("#121018")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(420, 0)
	var ps := StyleBoxFlat.new()
	ps.bg_color = Color("#1a1820")
	ps.border_color = Color("#c09a6a")
	ps.set_border_width_all(1)
	ps.set_corner_radius_all(10)
	ps.content_margin_left = 28
	ps.content_margin_right = 28
	ps.content_margin_top = 24
	ps.content_margin_bottom = 24
	card.add_theme_stylebox_override("panel", ps)
	center.add_child(card)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 14)
	card.add_child(v)

	var title := Label.new()
	title.text = "蜜忒之歌"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color("#f0e6d8"))
	v.add_child(title)

	var sub := Label.new()
	sub.text = "Nereis Lullaby"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 14)
	sub.add_theme_color_override("font_color", Color("#c8bfa8"))
	v.add_child(sub)

	var hint := Label.new()
	hint.text = "村子还在。日子也还在往前走。"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_font_size_override("font_size", 13)
	hint.add_theme_color_override("font_color", Color("#77717b"))
	v.add_child(hint)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	v.add_child(spacer)

	var new_btn := Button.new()
	new_btn.text = "开始新游戏"
	new_btn.custom_minimum_size = Vector2(0, 40)
	new_btn.pressed.connect(_on_new_game)
	_style_button(new_btn)
	v.add_child(new_btn)

	var load_btn := Button.new()
	load_btn.text = "读取存档"
	load_btn.custom_minimum_size = Vector2(0, 40)
	load_btn.pressed.connect(_toggle_load_panel)
	_style_button(load_btn)
	v.add_child(load_btn)

	var quit_btn := Button.new()
	quit_btn.text = "退出"
	quit_btn.custom_minimum_size = Vector2(0, 36)
	quit_btn.pressed.connect(func(): get_tree().quit())
	_style_button(quit_btn)
	v.add_child(quit_btn)

	status_label = Label.new()
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_font_size_override("font_size", 12)
	status_label.add_theme_color_override("font_color", Color("#c09a6a"))
	v.add_child(status_label)

	load_panel = Control.new()
	load_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	load_panel.visible = false
	load_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(load_panel)

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.72)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.gui_input.connect(func(e):
		if e is InputEventMouseButton and e.pressed:
			load_panel.visible = false
	)
	load_panel.add_child(dim)

	var lp := PanelContainer.new()
	lp.set_anchors_preset(Control.PRESET_CENTER)
	lp.offset_left = -210
	lp.offset_right = 210
	lp.offset_top = -170
	lp.offset_bottom = 170
	lp.add_theme_stylebox_override("panel", ps)
	load_panel.add_child(lp)

	var lv := VBoxContainer.new()
	lv.add_theme_constant_override("separation", 10)
	lp.add_child(lv)

	var lt := Label.new()
	lt.text = "选择存档"
	lt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lt.add_theme_font_size_override("font_size", 20)
	lt.add_theme_color_override("font_color", Color("#f0e6d8"))
	lv.add_child(lt)

	slot_list = VBoxContainer.new()
	slot_list.add_theme_constant_override("separation", 8)
	lv.add_child(slot_list)

	var back := Button.new()
	back.text = "返回"
	back.pressed.connect(func(): load_panel.visible = false)
	_style_button(back)
	lv.add_child(back)


func _style_button(button: Button) -> void:
	var normal := _make_style(Color("#2a2430"), Color("#3a3544"))
	var hover := _make_style(Color("#3a3544"), Color("#c09a6a"))
	var pressed := _make_style(Color("#1a1820"), Color("#c09a6a"))
	var disabled := _make_style(Color("#1a1820"), Color("#2a2430"))
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_color_override("font_color", Color("#e8dfd2"))
	button.add_theme_color_override("font_hover_color", Color("#fff4e6"))
	button.add_theme_color_override("font_pressed_color", Color("#ffffff"))
	button.add_theme_color_override("font_disabled_color", Color("#77717b"))


func _make_style(fill: Color, edge: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = fill
	s.border_color = edge
	s.set_border_width_all(1)
	s.set_corner_radius_all(6)
	s.content_margin_left = 12
	s.content_margin_right = 12
	s.content_margin_top = 8
	s.content_margin_bottom = 8
	return s


func _refresh_slots() -> void:
	for c in slot_list.get_children():
		slot_list.remove_child(c)
		c.queue_free()
	var metas: Array = SaveManagerScript.list_slots()
	var any_save := false
	for meta in metas:
		var slot: int = int(meta.get("slot", 0))
		var b := Button.new()
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.custom_minimum_size = Vector2(0, 42)
		if bool(meta.get("empty", true)):
			b.text = "槽位 %d　（空）" % (slot + 1)
			b.disabled = true
		else:
			any_save = true
			var loc: String = str(LOCATION_NAMES.get(str(meta.get("location", "")), meta.get("location", "")))
			var fest: String = " · 节后" if bool(meta.get("festival_done", false)) else ""
			var ts: String = str(meta.get("timestamp", ""))
			var line := "槽位 %d　日常第%d段 · %s%s" % [slot + 1, int(meta.get("segment", 0)), loc, fest]
			if ts != "":
				line += "\n%s" % ts
			b.text = line
			b.pressed.connect(_on_load_slot.bind(slot))
		_style_button(b)
		slot_list.add_child(b)
	if not any_save:
		status_label.text = "还没有存档。可以从「开始新游戏」进入。"
	else:
		status_label.text = ""


func _toggle_load_panel() -> void:
	_refresh_slots()
	load_panel.visible = not load_panel.visible


func _on_new_game() -> void:
	SaveManagerScript.pending_load_slot = -1
	var err := get_tree().change_scene_to_file(MAIN_SCENE)
	if err != OK:
		status_label.text = "无法进入游戏（场景加载失败）"


func _on_load_slot(slot: int) -> void:
	if not SaveManagerScript.has_save(slot):
		status_label.text = "该槽位没有存档"
		return
	SaveManagerScript.pending_load_slot = slot
	var err := get_tree().change_scene_to_file(MAIN_SCENE)
	if err != OK:
		status_label.text = "无法进入游戏（场景加载失败）"
		SaveManagerScript.pending_load_slot = -1
