extends Control
## Daily shell: pre-festival LN events, festival focus, post-festival traces.

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
	_setup_kitchen()
	_build_shell()
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
	if bag_overlay.visible:
		map_overlay.visible = false

func _set_dialogue(text: String) -> void:
	dialogue_text.text = text

func _location_desc(loc: String) -> String:
	if loc == "HOME" and world_flags.has_flag("festival_done"):
		return "屋子还是老样子，可窗边多了一点没扫尽的花瓣。空气里像还留着节庆的甜味，又有点沉。"
	if loc == "COMMONS" and world_flags.has_flag("festival_done"):
		return "公共场已经收拾过一轮。木桌空了，却像有人刻意把某个位置留得很干净。"
	return str(LOCATION_DESCRIPTIONS.get(loc, ""))

func _refresh_ui() -> void:
	var mode_text: String = "日常" if mode_controller.is_daily() else "丰收节"
	hud_status.text = "%s · %s" % [mode_text, economy.status_text()]
	if mode_controller.is_event_focus():
		hud_status.text = "丰收节 · 先把眼前的事做完"
		map_btn.disabled = true
	else:
		map_btn.disabled = false
	var loc: String = str(game_state.current_location)
	if mode_controller.is_event_focus():
		stage_title.text = "丰收节 · 公共场"
		stage_hint.text = "鼓声与笑声叠在一起。有人递花束，有人核对名单。"
		stage_bg.color = Color("#3a2e28")
		portrait_label.text = "节庆占位"
	else:
		stage_title.text = str(LOCATION_NAMES.get(loc, loc))
		stage_hint.text = _location_desc(loc)
		stage_bg.color = STAGE_COLORS.get(loc, Color("#2a2430"))
		if loc == "HOME":
			portrait_label.text = "老婆婆占位"
		elif loc == "PATH":
			portrait_label.text = "铁匠占位"
		elif loc == "COMMONS":
			portrait_label.text = "商人占位"
		else:
			portrait_label.text = "立绘占位"
	_rebuild_actions()
	_refresh_bag_body()

func _refresh_bag_body() -> void:
	var parts: Array = []
	for item_id in player_inventory.items.keys():
		var count: int = int(player_inventory.items[item_id])
		if count > 0:
			parts.append("%s ×%d" % [_item_display_name(str(item_id)), count])
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
		var food_id: String = _first_giftable_food()
		if food_id != "":
			_add_action("把%s端上长桌" % _item_display_name(food_id), _festival_offer_food.bind(food_id), true)
		_add_action("安静地看着", _festival_watch, true)
		if not world_flags.has_flag("festival_refused"):
			_add_action("今天先回去，不参与安排", _festival_refuse, true)
		_add_action("节庆散了，回家去", _festival_end, true)
		return
	var can_heavy: bool = bool(economy.can_spend_heavy())
	_add_action("看看周围", _observe_location, true)
	_add_action("休息", _rest, true)
	var loc: String = str(game_state.current_location)
	if loc == "HOME":
		_add_action("和老婆婆聊聊", _talk_popo, can_heavy)
		_add_action("去做点吃的", _open_kitchen, can_heavy)
		var food_home: String = _first_giftable_food()
		if food_home != "":
			_add_action("把%s送给老婆婆" % _item_display_name(food_home), _gift_to_popo.bind(food_home), can_heavy)
	if loc == "HOME" or loc == "PATH":
		if economy.segment_index >= 2:
			var smith_label: String = "帮铁匠提一桶水" if not pre_events.has_seen("PF09") else "看看铁匠那边"
			_add_action(smith_label, _smith_water, can_heavy or pre_events.has_seen("PF09"))
	if loc == "COMMONS":
		_add_action("和外地商人聊两句", _talk_merchant, can_heavy)
		_add_action("和村民闲聊", _talk_villager, can_heavy)
		for offer in trade_system.offers_at("COMMONS"):
			_add_action(str(offer.get("label", "交换")), _do_trade.bind(offer), can_heavy)
		if economy.is_festival_ready() and not world_flags.has_flag("festival_done"):
			_add_action("参加丰收节", _start_festival, true)
	for spot in gather_system.spots_at(loc):
		var label: String = str(spot.get("label", "采集"))
		var known: bool = true
		var kid: String = str(spot.get("requires_knowledge_id", ""))
		if kid != "" and not knowledge.has(kid):
			label = label + "（？）"
			known = false
		_add_action(label, _gather_spot.bind(spot), can_heavy or not known)

func _add_action(text: String, callable: Callable, enabled: bool) -> void:
	var button := Button.new()
	button.text = text
	button.disabled = not enabled
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(callable)
	_style_button(button)
	action_list.add_child(button)

func _on_location_selected(location_id: String) -> void:
	if mode_controller.is_event_focus():
		_set_dialogue("节庆还没散，现在不宜走开。")
		return
	game_state.current_location = location_id
	map_overlay.visible = false
	_set_dialogue("来到了%s。" % LOCATION_NAMES.get(location_id, location_id))
	_refresh_ui()

func _observe_location() -> void:
	var loc: String = str(game_state.current_location)
	if loc == "HOME":
		observe_home_count += 1
		if observe_home_count == 1:
			_set_dialogue("窗边的花瓣还没扫干净。老婆婆说节庆后总要多花一天收拾。")
		elif observe_home_count >= 2:
			_set_dialogue("屋子里安静得过分。锅还挂在原处，却像有人刚用过又仔细擦过。")
		else:
			_set_dialogue("家附近没什么特别。")
	elif loc == "COMMONS":
		_set_dialogue("公共场的木桌空了，却像有人刻意把某个位置留得很干净。")
	else:
		_set_dialogue("四周平静。")
	_refresh_ui()

func _rest() -> void:
	economy.rest()
	_set_dialogue("休息了一会儿，时间往前走了一点。")
	_refresh_ui()

func _talk_popo() -> void:
	if not economy.spend_heavy():
		_set_dialogue("今天已经做了不少事，先休息吧。")
		return
	var result = pre_events.try_trigger("PF01", knowledge, world_flags)
	if result:
		_set_dialogue(str(result.get("text", "")))
	else:
		_set_dialogue("老婆婆说：天气不错，适合做点吃的。")
	_refresh_ui()

func _open_kitchen() -> void:
	if not economy.spend_heavy():
		_set_dialogue("今天已经做了不少事，先休息吧。")
		return
	kitchen_controller.open_kitchen()
	_set_dialogue("开始准备食材。")

func _gift_to_popo(food_id: String) -> void:
	if not economy.spend_heavy():
		_set_dialogue("今天已经做了不少事，先休息吧。")
		return
	var result = gift_service.gift_food(player_inventory, food_id, "popo")
	_set_dialogue(str(result.get("message", "送出了。")))
	_refresh_ui()

func _smith_water() -> void:
	if not economy.spend_heavy() and not pre_events.has_seen("PF09"):
		_set_dialogue("今天已经做了不少事，先休息吧。")
		return
	var result = pre_events.try_trigger("PF09", knowledge, world_flags)
	if result:
		_set_dialogue(str(result.get("text", "")))
	else:
		_set_dialogue("铁匠点了点头。")
	_refresh_ui()

func _talk_merchant() -> void:
	if not economy.spend_heavy():
		_set_dialogue("今天已经做了不少事，先休息吧。")
		return
	var result = pre_events.try_trigger("PF03", knowledge, world_flags)
	if result:
		_set_dialogue(str(result.get("text", "")))
	else:
		_set_dialogue("商人说路上的货有点不一样。")
	_refresh_ui()

func _talk_villager() -> void:
	if not economy.spend_heavy():
		_set_dialogue("今天已经做了不少事，先休息吧。")
		return
	_set_dialogue("村民说节庆快到了，大家都在准备。")
	_refresh_ui()

func _do_trade(offer: Dictionary) -> void:
	if not economy.spend_heavy():
		_set_dialogue("今天已经做了不少事，先休息吧。")
		return
	var result = trade_system.try_trade(offer, player_inventory, knowledge)
	_set_dialogue(str(result.get("message", "交换完成。")))
	_refresh_ui()

func _gather_spot(spot: Dictionary) -> void:
	var kid: String = str(spot.get("requires_knowledge_id", ""))
	if kid != "" and not knowledge.has(kid):
		_set_dialogue("还不知道这里有什么。")
		return
	if not economy.spend_heavy():
		_set_dialogue("今天已经做了不少事，先休息吧。")
		return
	var result = gather_system.gather(spot, player_inventory, knowledge)
	_set_dialogue(str(result.get("message", "采集到了。")))
	_refresh_ui()

func _start_festival() -> void:
	mode_controller.enter_event_focus()
	_set_dialogue("鼓声响起。丰收节开始了。")
	_refresh_ui()

func _festival_help() -> void:
	festival_helped = true
	_set_dialogue("帮忙布置了桌台。有人点头致谢。")
	_refresh_ui()

func _festival_offer_food(food_id: String) -> void:
	festival_offered_food = true
	player_inventory.remove_item(food_id, 1)
	_set_dialogue("把食物端上了长桌。")
	_refresh_ui()

func _festival_watch() -> void:
	_set_dialogue("安静地看着节庆进行。")
	_refresh_ui()

func _festival_refuse() -> void:
	world_flags.set_flag("festival_refused")
	_set_dialogue("今天先回去，不参与安排。")
	_refresh_ui()

func _festival_end() -> void:
	mode_controller.exit_event_focus()
	world_flags.set_flag("festival_done")
	_set_dialogue("节庆散了。")
	_refresh_ui()

func _first_giftable_food() -> String:
	for item_id in player_inventory.items.keys():
		if str(item_id).begins_with("food_") or item_id in ["honey_cake", "simple_bread"]:
			if int(player_inventory.items[item_id]) > 0:
				return str(item_id)
	return ""

func _item_display_name(item_id: String) -> String:
	var names = {"flour": "面粉", "honey": "蜂蜜", "egg": "鸡蛋", "honey_cake": "蜂蜜蛋糕", "simple_bread": "简单面包"}
	return str(names.get(item_id, item_id))

func _on_kitchen_cooking_completed(result: Dictionary) -> void:
	_set_dialogue(str(result.get("message", "做好了。")))
	_refresh_ui()

func _on_kitchen_closed() -> void:
	_set_dialogue("厨房关上了。")
	_refresh_ui()

func _style_button(button: Button) -> void:
	var normal = _make_style(Color("#2a2430"), Color("#3a3544"))
	var hover = _make_style(Color("#3a3544"), Color("#c09a6a"))
	var pressed = _make_style(Color("#c09a6a"), Color("#c09a6a"))
	var disabled = _make_style(Color("#1a1820"), Color("#2a2430"))
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_color_override("font_color", Color("#e8dfd2"))
	button.add_theme_color_override("font_hover_color", Color("#f0e6d8"))
	button.add_theme_color_override("font_pressed_color", Color("#ffffff"))
	button.add_theme_color_override("font_disabled_color", Color("#77717b"))

func _make_style(fill_color: Color, edge_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_color = edge_color
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 10.0
	style.content_margin_right = 10.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	return style
