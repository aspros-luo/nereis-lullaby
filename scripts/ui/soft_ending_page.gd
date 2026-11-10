class_name SoftEndingPage
extends Control
## Formal soft-ending overlay for demo (not a full ending scene).
## Open with result dict from EndingResolver.resolve / AF11 beat fields.

signal continued
signal back_to_title
signal tie_chosen(choice_id: String)

var _dim: ColorRect
var _panel: PanelContainer
var _title: Label
var _subtitle: Label
var _body: Label
var _btn_row: HBoxContainer
var _btn_continue: Button
var _btn_title: Button
var _btn_stay: Button
var _btn_blaze: Button
var _current: Dictionary = {}

func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_dim = ColorRect.new()
	_dim.color = Color(0.04, 0.03, 0.06, 0.88)
	_dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_dim)
	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_CENTER)
	_panel.offset_left = -280
	_panel.offset_right = 280
	_panel.offset_top = -220
	_panel.offset_bottom = 220
	var ps := StyleBoxFlat.new()
	ps.bg_color = Color("#16121c")
	ps.border_color = Color("#c09a6a")
	ps.set_border_width_all(1)
	ps.set_corner_radius_all(10)
	ps.content_margin_left = 22
	ps.content_margin_right = 22
	ps.content_margin_top = 18
	ps.content_margin_bottom = 18
	_panel.add_theme_stylebox_override("panel", ps)
	add_child(_panel)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	_panel.add_child(v)
	var eyebrow := Label.new()
	eyebrow.text = "这一段日子的落点"
	eyebrow.add_theme_color_override("font_color", Color("#8a8070"))
	eyebrow.add_theme_font_size_override("font_size", 13)
	v.add_child(eyebrow)
	_title = Label.new()
	_title.add_theme_font_size_override("font_size", 28)
	_title.add_theme_color_override("font_color", Color("#f0e6d8"))
	v.add_child(_title)
	_subtitle = Label.new()
	_subtitle.add_theme_color_override("font_color", Color("#c8bfa8"))
	_subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(_subtitle)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 180)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	v.add_child(scroll)
	_body = Label.new()
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body.add_theme_font_size_override("font_size", 16)
	_body.add_theme_color_override("font_color", Color("#e8dfd2"))
	scroll.add_child(_body)
	_btn_row = HBoxContainer.new()
	_btn_row.add_theme_constant_override("separation", 10)
	_btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_child(_btn_row)
	_btn_stay = _make_btn("留下（灯侧）")
	_btn_stay.pressed.connect(_on_tie_paradise)
	_btn_row.add_child(_btn_stay)
	_btn_blaze = _make_btn("看穿（缝侧）")
	_btn_blaze.pressed.connect(_on_tie_blaze)
	_btn_row.add_child(_btn_blaze)
	_btn_continue = _make_btn("继续过日子")
	_btn_continue.pressed.connect(_on_continue)
	_btn_row.add_child(_btn_continue)
	_btn_title = _make_btn("回到标题")
	_btn_title.pressed.connect(_on_title)
	_btn_row.add_child(_btn_title)

func _make_btn(text: String) -> Button:
	var b := Button.new()
	b.text = text
	var n := StyleBoxFlat.new()
	n.bg_color = Color("#2a2430")
	n.set_corner_radius_all(4)
	n.content_margin_left = 12
	n.content_margin_right = 12
	n.content_margin_top = 8
	n.content_margin_bottom = 8
	b.add_theme_stylebox_override("normal", n)
	return b

## result: {id, label, text, ...} from EndingResolver; optional preview line.
func open_ending(result: Dictionary, preview: String = "") -> void:
	_current = result.duplicate(true)
	var eid: String = str(result.get("id", ""))
	_title.text = str(result.get("label", "软结局"))
	if preview != "":
		_subtitle.text = "—— " + preview
	else:
		_subtitle.text = ""
	_body.text = str(result.get("text", ""))
	var is_tie: bool = eid == "tie"
	_btn_stay.visible = is_tie
	_btn_blaze.visible = is_tie
	_btn_continue.visible = not is_tie
	visible = true
	move_to_front()

func close_page() -> void:
	visible = false

func _on_continue() -> void:
	close_page()
	continued.emit()

func _on_title() -> void:
	close_page()
	back_to_title.emit()

func _on_tie_paradise() -> void:
	tie_chosen.emit("paradise")

func _on_tie_blaze() -> void:
	tie_chosen.emit("blaze")
