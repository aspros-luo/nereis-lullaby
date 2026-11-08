extends Control
## Daily shell: pre-festival LN events, festival focus, post-festival traces.
## RESTORED playable shell — do not empty this file.

const GameStateScript = preload("res://scripts/core/game_state.gd")
const InventoryScript = preload("res://scripts/systems/item/inventory.gd")
const KitchenControllerScript = preload("res://scripts/systems/cooking/kitchen_controller.gd")
const CookingGiftServiceScript = preload("res://scripts/systems/cooking/cooking_gift_service.gd")
const GameModeControllerScript = preload("res://scripts/systems/daily/game_mode_controller.gd")
const DailyActionEconomyScript = preload("res://scripts/systems/daily/daily_action_economy.gd")
const IngredientKnowledgeScript = preload("res://scripts/systems/daily/ingredient_knowledge.gd")
const GatherSystemScript = preload("res://scripts/systems/daily/gather_system.gd")
const NpcIntentSchedulerScript = preload("res://scripts/systems/daily/npc_intent_scheduler.gd")
const TradeSystemScript = preload("res://scripts/systems/daily/trade_system.gd")
const WorldSampleFlagsScript = preload("res://scripts/systems/daily/world_sample_flags.gd")
const PreFestivalEventsScript = preload("res://scripts/systems/daily/pre_festival_events.gd")
const PostFestivalTracesScript = preload("res://scripts/systems/daily/post_festival_traces.gd")
const SaveManagerScript = preload("res://scripts/systems/save/save_manager.gd")
const AftermathStoryletsScript = preload("res://scripts/systems/daily/aftermath_storylets.gd")

const LOCATION_ORDER: Array[String] = ["HOME", "COMMONS", "PATH", "SHRINE", "CLINIC", "FOREST", "GROVE"]
const LOCATION_NAMES: Dictionary = {
	"HOME": "家附近", "COMMONS": "公共场", "SHRINE": "礼拜场所", "CLINIC": "诊疗处",
	"PATH": "村庄通路", "FOREST": "林间", "GROVE": "林中空地",
}
const LOCATION_DESCRIPTIONS: Dictionary = {
	"HOME": "熟悉的屋子和门前小路。老婆婆总把日子安排得妥妥当当。",
	"COMMONS": "村民交换食物与闲聊的地方。外地商贩偶尔停脚。",
	"SHRINE": "节庆与祈祷准备的地方。木头和花束很整齐。",
	"CLINIC": "草药与药瓶摆在架子上。空气里有干净的苦味。",
	"PATH": "连接各处的小路。有人把篮子放在路边。",
	"FOREST": "林子比村庄安静。风穿过叶子，像有人在远处说话。",
	"GROVE": "树木围出的空地。适合坐一会儿。",
}
const STAGE_COLORS: Dictionary = {
	"HOME": Color("#2a2430"), "COMMONS": Color("#2c2832"), "SHRINE": Color("#24262e"),
	"CLINIC": Color("#1f2a2c"), "PATH": Color("#2a2824"), "FOREST": Color("#1a2420"),
	"GROVE": Color("#22281e"),
}

var game_state
var mode_controller
var economy
var knowledge
var gather_system
var intent_scheduler
var trade_system
var world_flags
var pre_events
var traces
var aftermath
var player_inventory
var kitchen_controller
var gift_service
var festival_helped: bool = false
var festival_offered_food: bool = false
var observe_home_count: int = 0
var hud_status: Label
var stage_bg: ColorRect
var stage_title: Label
var stage_hint: Label
var portrait_label: Label
var action_list: VBoxContainer
var dialogue_text: Label
var map_overlay: Control
var bag_overlay: Control
var bag_body: Label
var map_btn: Button
var system_btn: Button
var system_overlay: Control
var save_panel: Control
var load_panel: Control
var play_seconds: float = 0.0
var last_save_msg: String = ""

func _ready() -> void:
	game_state = GameStateScript.new()
	mode_controller = GameModeControllerScript.new()
	economy = DailyActionEconomyScript.new()
	knowledge = IngredientKnowledgeScript.new()
	gather_system = GatherSystemScript.new()
	gather_system.setup_sample_spots()
	intent_scheduler = NpcIntentSchedulerScript.new()
	trade_system = TradeSystemScript.new()
	trade_system.setup_sample_offers()
	world_flags = WorldSampleFlagsScript.new()
	pre_events = PreFestivalEventsScript.new()
	traces = PostFestivalTracesScript.new()
	aftermath = AftermathStoryletsScript.new()
	_setup_kitchen()
	_build_shell()
	_build_system_overlay()
	var pending: int = SaveManagerScript.pending_load_slot
	SaveManagerScript.pending_load_slot = -1
	if pending >= 0:
		var data: Dictionary = SaveManagerScript.load_game(pending)
		if not data.is_empty() and _apply_save_payload(data):
			last_save_msg = "已读取槽位 %d" % (pending + 1)
			_set_dialogue("已从槽位 %d 继续。" % (pending + 1))
		else:
			_set_dialogue("存档读取失败，从新的一天开始。")
			_refresh_ui()
	else:
		# Day-1：默认知道门前有草药，避免采集永久锁死
		if knowledge != null and not knowledge.has("know_home_herb_patch"):
			knowledge.learn("know_home_herb_patch", "门前园子里有些草药可以摘。")
		_set_dialogue("我在村子里住了很久。今天想做点平常的事。")
		_refresh_ui()

func _setup_kitchen() -> void:
	player_inventory = InventoryScript.new()
	player_inventory.add_item("flour", 2)
	player_inventory.add_item("honey", 2)
	player_inventory.add_item("egg", 2)
	gift_service = CookingGiftServiceScript.new()
	kitchen_controller = KitchenControllerScript.new()
	add_child(kitchen_controller)
	kitchen_controller.bootstrap_with(player_inventory, game_state, null)
	if not kitchen_controller.cooking_completed.is_connected(_on_kitchen_cooking_completed):
		kitchen_controller.cooking_completed.connect(_on_kitchen_cooking_completed)
	if not kitchen_controller.kitchen_closed.is_connected(_on_kitchen_closed):
		kitchen_controller.kitchen_closed.connect(_on_kitchen_closed)

func _process(delta: float) -> void:
	play_seconds += delta

func _set_dialogue(text: String) -> void:
	if dialogue_text:
		dialogue_text.text = text

func _style_button(b: Button) -> void:
	var n := StyleBoxFlat.new()
	n.bg_color = Color("#2a2430")
	n.set_corner_radius_all(4)
	n.content_margin_left = 8
	n.content_margin_right = 8
	n.content_margin_top = 6
	n.content_margin_bottom = 6
	b.add_theme_stylebox_override("normal", n)

func _add_action(label: String, cb: Callable, enabled: bool = true) -> void:
	var b := Button.new()
	b.text = label
	b.disabled = not enabled
	b.pressed.connect(cb)
	_style_button(b)
	action_list.add_child(b)

# Minimal shell build (playable)
func _build_shell() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var root_bg := ColorRect.new()
	root_bg.color = Color("#121018")
	root_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root_bg)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for k in [["margin_left", 16], ["margin_right", 16], ["margin_top", 12], ["margin_bottom", 12]]:
		margin.add_theme_constant_override(k[0], int(k[1]))
	add_child(margin)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)
	var hud := HBoxContainer.new()
	hud.add_theme_constant_override("separation", 10)
	vbox.add_child(hud)
	hud_status = Label.new()
	hud_status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hud_status.add_theme_font_size_override("font_size", 16)
	hud_status.add_theme_color_override("font_color", Color("#e8dfd2"))
	hud.add_child(hud_status)
	map_btn = Button.new()
	map_btn.text = "地图"
	map_btn.pressed.connect(_toggle_map)
	_style_button(map_btn)
	hud.add_child(map_btn)
	var bag_btn := Button.new()
	bag_btn.text = "背包/线索"
	bag_btn.pressed.connect(_toggle_bag)
	_style_button(bag_btn)
	hud.add_child(bag_btn)
	system_btn = Button.new()
	system_btn.text = "系统"
	system_btn.pressed.connect(_toggle_system)
	_style_button(system_btn)
	hud.add_child(system_btn)
	var mid := HBoxContainer.new()
	mid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mid.add_theme_constant_override("separation", 12)
	vbox.add_child(mid)
	var stage_wrap := Control.new()
	stage_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stage_wrap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stage_wrap.custom_minimum_size = Vector2(0, 280)
	mid.add_child(stage_wrap)
	stage_bg = ColorRect.new()
	stage_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	stage_wrap.add_child(stage_bg)
	var sm := MarginContainer.new()
	sm.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for k in [["margin_left", 16], ["margin_right", 16], ["margin_top", 14], ["margin_bottom", 14]]:
		sm.add_theme_constant_override(k[0], int(k[1]))
	stage_wrap.add_child(sm)
	var sc := VBoxContainer.new()
	sc.add_theme_constant_override("separation", 8)
	sm.add_child(sc)
	stage_title = Label.new()
	stage_title.add_theme_font_size_override("font_size", 26)
	stage_title.add_theme_color_override("font_color", Color("#f0e6d8"))
	sc.add_child(stage_title)
	stage_hint = Label.new()
	stage_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stage_hint.add_theme_color_override("font_color", Color("#c8bfa8"))
	sc.add_child(stage_hint)
	portrait_label = Label.new()
	portrait_label.add_theme_color_override("font_color", Color("#77717b"))
	sc.add_child(portrait_label)
	var rail := PanelContainer.new()
	rail.custom_minimum_size = Vector2(230, 0)
	rail.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var rs := StyleBoxFlat.new()
	rs.bg_color = Color("#1a1820")
	rs.border_color = Color("#3a3544")
	rs.set_border_width_all(1)
	rs.set_corner_radius_all(6)
	rs.content_margin_left = 10
	rs.content_margin_right = 10
	rs.content_margin_top = 10
	rs.content_margin_bottom = 10
	rail.add_theme_stylebox_override("panel", rs)
	mid.add_child(rail)
	var rv := VBoxContainer.new()
	rv.add_theme_constant_override("separation", 8)
	rail.add_child(rv)
	var rt := Label.new()
	rt.text = "此刻可做"
	rt.add_theme_color_override("font_color", Color("#e8dfd2"))
	rv.add_child(rt)
	var action_scroll := ScrollContainer.new()
	action_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	action_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rv.add_child(action_scroll)
	action_list = VBoxContainer.new()
	action_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_list.add_theme_constant_override("separation", 6)
	action_scroll.add_child(action_list)
	var dialogue_panel := PanelContainer.new()
	dialogue_panel.custom_minimum_size = Vector2(0, 140)
	var ds := StyleBoxFlat.new()
	ds.bg_color = Color("#1c1822")
	ds.border_color = Color("#c09a6a")
	ds.set_border_width_all(1)
	ds.set_corner_radius_all(6)
	ds.content_margin_left = 16
	ds.content_margin_right = 16
	ds.content_margin_top = 12
	ds.content_margin_bottom = 12
	dialogue_panel.add_theme_stylebox_override("panel", ds)
	vbox.add_child(dialogue_panel)
	var dscroll := ScrollContainer.new()
	dscroll.custom_minimum_size = Vector2(0, 120)
	dialogue_panel.add_child(dscroll)
	dialogue_text = Label.new()
	dialogue_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dialogue_text.add_theme_font_size_override("font_size", 16)
	dialogue_text.add_theme_color_override("font_color", Color("#f0e6d8"))
	dscroll.add_child(dialogue_text)
	_build_map_overlay()
	_build_bag_overlay()

func _panel_style() -> StyleBoxFlat:
	var ps := StyleBoxFlat.new()
	ps.bg_color = Color("#1a1820")
	ps.border_color = Color("#c09a6a")
	ps.set_border_width_all(1)
	ps.set_corner_radius_all(8)
	ps.content_margin_left = 16
	ps.content_margin_right = 16
	ps.content_margin_top = 14
	ps.content_margin_bottom = 14
	return ps

func _build_map_overlay() -> void:
	map_overlay = Control.new()
	map_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	map_overlay.visible = false
	add_child(map_overlay)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.72)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.gui_input.connect(func(e):
		if e is InputEventMouseButton and e.pressed:
			map_overlay.visible = false
	)
	map_overlay.add_child(dim)
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -200
	panel.offset_right = 200
	panel.offset_top = -160
	panel.offset_bottom = 160
	panel.add_theme_stylebox_override("panel", _panel_style())
	map_overlay.add_child(panel)
	var mv := VBoxContainer.new()
	mv.add_theme_constant_override("separation", 8)
	panel.add_child(mv)
	var mt := Label.new()
	mt.text = "前往哪里？"
	mt.add_theme_font_size_override("font_size", 18)
	mt.add_theme_color_override("font_color", Color("#e8dfd2"))
	mv.add_child(mt)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	mv.add_child(grid)
	for location_id in LOCATION_ORDER:
		var b := Button.new()
		b.text = str(LOCATION_NAMES.get(location_id, location_id))
		b.custom_minimum_size = Vector2(150, 36)
		b.pressed.connect(_on_location_selected.bind(location_id))
		_style_button(b)
		grid.add_child(b)
	var close_b := Button.new()
	close_b.text = "关闭"
	close_b.pressed.connect(func(): map_overlay.visible = false)
	_style_button(close_b)
	mv.add_child(close_b)

func _build_bag_overlay() -> void:
	bag_overlay = Control.new()
	bag_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bag_overlay.visible = false
	add_child(bag_overlay)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.72)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.gui_input.connect(func(e):
		if e is InputEventMouseButton and e.pressed:
			bag_overlay.visible = false
	)
	bag_overlay.add_child(dim)
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -220
	panel.offset_right = 220
	panel.offset_top = -150
	panel.offset_bottom = 150
	panel.add_theme_stylebox_override("panel", _panel_style())
	bag_overlay.add_child(panel)
	var bv := VBoxContainer.new()
	bv.add_theme_constant_override("separation", 8)
	panel.add_child(bv)
	var bt := Label.new()
	bt.text = "背包与线索"
	bt.add_theme_font_size_override("font_size", 18)
	bt.add_theme_color_override("font_color", Color("#e8dfd2"))
	bv.add_child(bt)
	bag_body = Label.new()
	bag_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bag_body.add_theme_color_override("font_color", Color("#c8bfa8"))
	bv.add_child(bag_body)
	var close_b := Button.new()
	close_b.text = "关闭"
	close_b.pressed.connect(func(): bag_overlay.visible = false)
	_style_button(close_b)
	bv.add_child(close_b)

func _build_system_overlay() -> void:
	system_overlay = Control.new()
	system_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	system_overlay.visible = false
	add_child(system_overlay)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.75)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	system_overlay.add_child(dim)
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -180
	panel.offset_right = 180
	panel.offset_top = -120
	panel.offset_bottom = 120
	panel.add_theme_stylebox_override("panel", _panel_style())
	system_overlay.add_child(panel)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	panel.add_child(v)
	var t := Label.new()
	t.text = "系统"
	t.add_theme_color_override("font_color", Color("#e8dfd2"))
	v.add_child(t)
	for i in range(3):
		var sb := Button.new()
		sb.text = "存档槽 %d" % (i + 1)
		sb.pressed.connect(_save_slot.bind(i))
		_style_button(sb)
		v.add_child(sb)
		var lb := Button.new()
		lb.text = "读档槽 %d" % (i + 1)
		lb.pressed.connect(_load_slot.bind(i))
		_style_button(lb)
		v.add_child(lb)
	var close_b := Button.new()
	close_b.text = "关闭"
	close_b.pressed.connect(func(): system_overlay.visible = false)
	_style_button(close_b)
	v.add_child(close_b)

func _toggle_map() -> void:
	if mode_controller.is_event_focus():
		_set_dialogue("节庆还没散，现在不宜走开。")
		return
	map_overlay.visible = not map_overlay.visible
	if map_overlay.visible:
		bag_overlay.visible = false

func _toggle_bag() -> void:
	_refresh_bag_body()
	bag_overlay.visible = not bag_overlay.visible

func _toggle_system() -> void:
	system_overlay.visible = not system_overlay.visible

func _on_location_selected(location_id: String) -> void:
	game_state.current_location = location_id
	map_overlay.visible = false
	_set_dialogue("来到了%s。" % LOCATION_NAMES.get(location_id, location_id))
	_refresh_ui()

func _location_desc(loc: String) -> String:
	if loc == "HOME" and world_flags.has_flag("festival_done"):
		return "屋子还是老样子，可窗边多了一点没扫尽的花瓣。"
	return str(LOCATION_DESCRIPTIONS.get(loc, ""))

func _soft_tendency_label() -> String:
	var p: bool = world_flags.has_flag("tendency_p_soft")
	var t: bool = world_flags.has_flag("tendency_t_soft")
	if p and not t:
		return "风里仍有一点甜"
	if t and not p:
		return "风很干净"
	if p and t:
		return "味道分不清"
	return ""

func _refresh_ui() -> void:
	var mode_text: String = "日常" if mode_controller.is_daily() else "丰收节"
	hud_status.text = "%s · %s" % [mode_text, economy.status_text()]
	if mode_controller.is_event_focus():
		hud_status.text = "丰收节 · 先把眼前的事做完"
		map_btn.disabled = true
	else:
		map_btn.disabled = false
		if world_flags.has_flag("festival_done"):
			var tone: String = _soft_tendency_label()
			if tone != "":
				hud_status.text = "%s · %s · %s" % [mode_text, economy.status_text(), tone]
	var loc: String = str(game_state.current_location)
	if mode_controller.is_event_focus():
		stage_title.text = "丰收节 · 公共场"
		stage_hint.text = "鼓声与笑声叠在一起。"
		stage_bg.color = Color("#3a2e28")
		portrait_label.text = "节庆"
	else:
		stage_title.text = str(LOCATION_NAMES.get(loc, loc))
		stage_hint.text = _location_desc(loc)
		stage_bg.color = STAGE_COLORS.get(loc, Color("#2a2430"))
		portrait_label.text = "立绘占位"
	_rebuild_actions()
	_refresh_bag_body()

func _refresh_bag_body() -> void:
	var parts: Array = []
	for item_id in player_inventory.items.keys():
		var count: int = int(player_inventory.items[item_id])
		if count > 0:
			parts.append("%s ×%d" % [str(item_id), count])
	var inv_line: String = "（空）" if parts.is_empty() else "、".join(parts)
	var notes: Array = knowledge.list_notes()
	var know_line: String = "（还没有）" if notes.is_empty() else "\n".join(notes)
	bag_body.text = "物品：\n%s\n\n线索：\n%s" % [inv_line, know_line]

func _rebuild_actions() -> void:
	for child in action_list.get_children():
		action_list.remove_child(child)
		child.queue_free()
	if mode_controller.is_event_focus():
		_add_action("帮忙布置桌台", _festival_help, true)
		_add_action("安静地看着", _festival_watch, true)
		if not world_flags.has_flag("festival_refused"):
			_add_action("今天先回去，不参与安排", _festival_refuse, true)
		_add_action("节庆散了，回家去", _festival_end, true)
		return
	var can_heavy: bool = bool(economy.can_spend_heavy())
	_add_action("看看周围", _observe_location, true)
	_add_action("休息", _rest, true)
	var loc: String = str(game_state.current_location)
	if world_flags.has_flag("festival_done"):
		if loc == "HOME" and not world_flags.has_flag("trace_home_bowl"):
			_add_action("查看窗边空碗", _observe_location, true)
		if loc == "COMMONS" and not world_flags.has_flag("trace_commons_seat"):
			_add_action("留意长桌边的留白", _observe_location, true)
		if loc == "SHRINE" and not world_flags.has_flag("trace_shrine_flowers"):
			_add_action("看看角落的旧花束", _observe_location, true)
		if loc == "PATH" and not world_flags.has_flag("trace_path_scrap"):
			_add_action("看看告示板边角", _observe_location, true)
		var af_label: String = aftermath.available_action_label(loc, world_flags.flags)
		if af_label != "":
			_add_action(af_label, _aftermath_location_beat, true)
	if loc == "HOME":
		_add_action("和老婆婆聊聊", _talk_popo, can_heavy)
		_add_action("做饭", _open_kitchen, can_heavy)
		_add_action("收取园里的草药", _gather_home_herbs, can_heavy)
	if loc == "COMMONS":
		_add_action("和外地商人聊聊", _talk_merchant, can_heavy)
		_add_action("用草药换面粉", _trade_herb_flour, can_heavy)
	if loc == "PATH" and int(economy.segment_index) >= 2:
		_add_action("帮铁匠打下手", _help_smith, can_heavy)
	if not world_flags.has_flag("festival_done") and economy.segment_index >= 4:
		_add_action("前往丰收节（公共场）", _enter_festival, true)

func _observe_location() -> void:
	var loc: String = str(game_state.current_location)
	if world_flags.has_flag("festival_done"):
		if loc == "HOME" and not world_flags.has_flag("trace_home_bowl"):
			world_flags.set_flag("trace_home_bowl")
			_set_dialogue(traces.text_home_object_petals())
			_refresh_ui()
			return
		if loc == "COMMONS" and not world_flags.has_flag("trace_commons_seat"):
			world_flags.set_flag("trace_commons_seat")
			_set_dialogue(traces.text_commons_place())
			_refresh_ui()
			return
		if loc == "SHRINE" and not world_flags.has_flag("trace_shrine_flowers"):
			world_flags.set_flag("trace_shrine_flowers")
			_set_dialogue(traces.text_shrine_place())
			_refresh_ui()
			return
		if loc == "PATH" and not world_flags.has_flag("trace_path_scrap"):
			world_flags.set_flag("trace_path_scrap")
			_set_dialogue(traces.text_faceless_path_scrap())
			_refresh_ui()
			return
	_set_dialogue("我看了看周围。没什么特别的。")
	_refresh_ui()

func _rest() -> void:
	var info = economy.rest()
	if world_flags.has_flag("festival_done"):
		var beat: Dictionary = aftermath.on_rest(int(info.get("segment_index", 0)), world_flags.flags)
		if not beat.is_empty():
			_apply_storylet_learn(beat)
			_set_dialogue(str(beat.get("text", "")))
		else:
			_set_dialogue("我休息了一会儿。节后的夜里，鼓声已经听不见了。")
	else:
		_set_dialogue("我休息了一会儿。")
		if int(info.get("segment_index", 0)) >= 4 and not mode_controller.is_event_focus():
			_set_dialogue("休息之后，远处隐约有鼓声。或许该去公共场看看丰收节。")
	_refresh_ui()

func _apply_storylet_learn(beat: Dictionary) -> void:
	var learn = beat.get("learn", null)
	if learn is Dictionary:
		var lid: String = str(learn.get("id", ""))
		var note: String = str(learn.get("note", ""))
		if lid != "":
			knowledge.learn(lid, note)
			if lid in ["hero_face", "hero_spoken", "hero_second", "hero_second_choice", "visitor_rumor", "hero_tracks"]:
				world_flags.set_flag(lid)
	var flag_key = beat.get("set_flag", "")
	if str(flag_key) != "":
		world_flags.set_flag(str(flag_key))
	if str(beat.get("ending", "")) != "":
		world_flags.set_flag("ending_soft_" + str(beat.get("ending")))

func _aftermath_location_beat() -> void:
	var beat: Dictionary = aftermath.beat_at_location(str(game_state.current_location), world_flags.flags)
	if beat.is_empty():
		_set_dialogue("没有更多可听的了。")
		return
	_apply_storylet_learn(beat)
	_set_dialogue(str(beat.get("text", "")))
	_refresh_ui()
	if beat.has("portrait"):
		portrait_label.text = str(beat.get("portrait"))

func _talk_popo() -> void:
	if not economy.spend_heavy():
		return
	if world_flags.has_flag("festival_done"):
		_set_dialogue("老婆婆：「办完就好，别想太多。」她的手很稳，笑却浅了一点。")
	else:
		_set_dialogue("老婆婆说灶还热着。若要出门，记得天黑前回来。")
	_refresh_ui()

func _enter_festival() -> void:
	mode_controller.enter_event("harvest_festival")
	game_state.current_location = "COMMONS"
	_set_dialogue("鼓声近了。公共场已经摆好了长桌。")
	_refresh_ui()

func _festival_help() -> void:
	festival_helped = true
	_set_dialogue("我帮忙把桌台摆正。有人对我点了点头。")
	_refresh_ui()

func _festival_watch() -> void:
	_set_dialogue("我站在边上看着。笑与鼓声叠在一起。")
	_refresh_ui()

func _festival_refuse() -> void:
	world_flags.set_flag("festival_refused")
	_set_dialogue("我退到更外面一点。有人看了我一眼，又转回去。")
	_refresh_ui()

func _festival_end() -> void:
	mode_controller.enter_daily()
	var refused: bool = world_flags.has_flag("festival_refused")
	world_flags.after_festival(festival_helped, festival_offered_food, refused)
	game_state.current_location = "HOME"
	_set_dialogue(traces.text_festival_end_summary(festival_helped, festival_offered_food, refused))
	_refresh_ui()

func _save_slot(slot: int) -> void:
	var payload := {
		"location": game_state.current_location,
		"flags": world_flags.flags.duplicate(true),
		"aftermath_seen": aftermath.seen.duplicate(true),
		"knowledge": knowledge.known.duplicate(true),
		"notes": knowledge.notes.duplicate(true),
		"segment": economy.segment_index,
		"festival_helped": festival_helped,
		"festival_offered_food": festival_offered_food,
	}
	if SaveManagerScript.save_game(slot, payload):
		last_save_msg = "已写入槽位 %d" % (slot + 1)
		_set_dialogue(last_save_msg)
	else:
		_set_dialogue("存档失败。")

func _load_slot(slot: int) -> void:
	var data: Dictionary = SaveManagerScript.load_game(slot)
	if data.is_empty():
		_set_dialogue("该槽位没有存档。")
		return
	if _apply_save_payload(data):
		_set_dialogue("已从槽位 %d 继续。" % (slot + 1))
	else:
		_set_dialogue("读取不完整。")
	_refresh_ui()

func _apply_save_payload(data: Dictionary) -> bool:
	if data.is_empty():
		return false
	game_state.current_location = str(data.get("location", "HOME"))
	var fl = data.get("flags", {})
	if fl is Dictionary:
		world_flags.flags = fl.duplicate(true)
	var seen = data.get("aftermath_seen", {})
	if seen is Dictionary:
		aftermath.seen = seen.duplicate(true)
	var kn = data.get("knowledge", {})
	if kn is Dictionary:
		knowledge.known = kn.duplicate(true)
	var notes = data.get("notes", {})
	if notes is Dictionary:
		knowledge.notes = notes.duplicate(true)
	festival_helped = bool(data.get("festival_helped", false))
	festival_offered_food = bool(data.get("festival_offered_food", false))
	return true


func _open_kitchen() -> void:
	if not economy.spend_heavy():
		_set_dialogue("今天已经做了不少事，先休息一下再进厨房吧。")
		_refresh_ui()
		return
	if kitchen_controller == null:
		_set_dialogue("灶台还没准备好。")
		return
	kitchen_controller.open()
	_set_dialogue("我卷起袖子，开始准备食材。")

func _gather_home_herbs() -> void:
	if not economy.spend_heavy():
		_set_dialogue("手有点酸。改天再采吧。")
		_refresh_ui()
		return
	var spots: Array = gather_system.spots_at("HOME")
	if spots.is_empty():
		_set_dialogue("园里一时没什么可摘的。")
		return
	var result: Dictionary = gather_system.try_gather(spots[0], knowledge, player_inventory, true)
	_set_dialogue(str(result.get("message", "")))
	_refresh_ui()

func _talk_merchant() -> void:
	if not economy.spend_heavy():
		_set_dialogue("懒得再开口了。")
		_refresh_ui()
		return
	_set_dialogue(
		"外地商人把布摊掀开一角，说：\n"
		+ "「草叶新鲜的话，可以换面粉。村里节前都这样换。」\n\n"
		+ "他看了看我的手：\n「有就拿来。没有也无，我在这儿停到鼓响。」"
	)
	if knowledge != null and not knowledge.has("know_home_herb_patch"):
		knowledge.learn("know_home_herb_patch", "商人说门前园子的草也能换东西。")
	_refresh_ui()

func _trade_herb_flour() -> void:
	if not economy.spend_heavy():
		_set_dialogue("今天先不换了。")
		_refresh_ui()
		return
	var offers: Array = trade_system.offers_at("COMMONS")
	if offers.is_empty():
		_set_dialogue("商人这会儿不在。")
		return
	var result: Dictionary = trade_system.try_trade(offers[0], player_inventory)
	_set_dialogue(str(result.get("message", "")))
	_refresh_ui()

func _help_smith() -> void:
	if not economy.spend_heavy():
		_set_dialogue("臂膀还酸着，改天再帮吧。")
		_refresh_ui()
		return
	_set_dialogue(
		"铁匠把一根还烫的铁条丢进水桶，蒸汽直冒。\n"
		+ "「扶一下风箱。对，就这样。」\n\n"
		+ "忙完他丢给我一块干饼：\n「手还行。节前要是闲，再来。」"
	)
	_refresh_ui()

func _on_kitchen_cooking_completed(_result) -> void:
	_refresh_ui()

func _on_kitchen_closed() -> void:
	_refresh_ui()
