extends Control
## Village daily prototype: locations, talk, kitchen, gift food.
## Streamlined restore focused on playable cooking + social loop.

const GameStateScript = preload("res://scripts/core/game_state.gd")
const ScheduleManagerScript = preload("res://scripts/managers/npc_schedule_manager.gd")
const ClueJournalScript = preload("res://scripts/managers/clue_journal.gd")
const WorldlineLedgerScript = preload("res://scripts/core/worldline_event_ledger.gd")
const InformationNetworkScript = preload("res://scripts/managers/worldline_information_network.gd")
const InventoryScript = preload("res://scripts/systems/item/inventory.gd")
const KitchenControllerScript = preload("res://scripts/systems/cooking/kitchen_controller.gd")
const CookingGiftServiceScript = preload("res://scripts/systems/cooking/cooking_gift_service.gd")

const LOCATION_ORDER: Array[String] = [
	"FOREST", "GROVE", "PATH", "COMMONS", "SHRINE", "HOME", "CLINIC"
]
const ACTIVITY_LABELS: Dictionary = {
	"HOME": "整理家里",
	"COMMONS": "帮忙做些杂事",
	"SHRINE": "整理礼拜用品",
	"CLINIC": "分拣草药",
	"PATH": "采些常见草叶",
	"FOREST": "采摘野花",
	"GROVE": "坐下休息",
}
const LOCATION_DESCRIPTIONS: Dictionary = {
	"HOME": "熟悉的屋子和门前小路。照料者总能把普通的一天安排得妥妥当当。",
	"COMMONS": "村民交换食物、闲聊和帮忙的地方。这里的热闹让人觉得安心。",
	"SHRINE": "村里公开举行礼拜和节庆准备的地方。木头、布料和花束都收拾得很整齐。",
	"CLINIC": "草药、干净的布和药瓶摆在架子上。医生总说，休息好比胡思乱想有用。",
	"PATH": "一条连接村庄各处的小路。有人经过，也有人把篮子暂时放在路边。",
	"FOREST": "林子比村庄安静得多。风穿过树叶时，听起来像有人在远处轻轻说话。",
	"GROVE": "树木围出一小片空地，阳光落在野花上。这里适合坐一会儿，也适合慢慢看看。",
}

var game_state
var schedule_manager
var clue_journal
var worldline_ledger
var information_network

var status_label: Label
var location_label: Label
var description_label: Label
var action_state_label: Label
var message_label: Label
var relationship_label: Label
var inventory_label: Label
var npc_container: VBoxContainer
var action_button: Button
var observe_button: Button
var advance_button: Button
var cook_button: Button
var location_buttons: Array[Button] = []

var player_inventory
var kitchen_controller
var gift_service

func _ready() -> void:
	game_state = GameStateScript.new()
	schedule_manager = ScheduleManagerScript.new()
	clue_journal = ClueJournalScript.new()
	worldline_ledger = WorldlineLedgerScript.new()
	information_network = InformationNetworkScript.new()
	_setup_kitchen()
	_apply_visual_style()
	_build_ui()
	_refresh_ui()

func _setup_kitchen() -> void:
	player_inventory = InventoryScript.new()
	player_inventory.add_item("flour", 3)
	player_inventory.add_item("honey", 3)
	player_inventory.add_item("egg", 3)
	player_inventory.add_item("herb", 2)
	gift_service = CookingGiftServiceScript.new()
	kitchen_controller = KitchenControllerScript.new()
	add_child(kitchen_controller)
	kitchen_controller.bootstrap_with(player_inventory, game_state, worldline_ledger)
	if not kitchen_controller.cooking_completed.is_connected(_on_kitchen_cooking_completed):
		kitchen_controller.cooking_completed.connect(_on_kitchen_cooking_completed)
	if not kitchen_controller.kitchen_closed.is_connected(_on_kitchen_closed):
		kitchen_controller.kitchen_closed.connect(_on_kitchen_closed)

func _apply_visual_style() -> void:
	var backdrop := ColorRect.new()
	backdrop.color = Color("#15141b")
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)
	move_child(backdrop, 0)

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	add_child(margin)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_child(scroll)

	var root := VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 10)
	scroll.add_child(root)

	var title := Label.new()
	title.text = "蜜忒之歌｜村庄日常"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color("#e8dfd2"))
	root.add_child(title)

	status_label = Label.new()
	status_label.add_theme_font_size_override("font_size", 18)
	status_label.add_theme_color_override("font_color", Color("#e8dfd2"))
	root.add_child(status_label)

	var map_title := Label.new()
	map_title.text = "村庄与林地地图 · 选择一个地点"
	map_title.add_theme_color_override("font_color", Color("#e8dfd2"))
	root.add_child(map_title)

	var map_grid := GridContainer.new()
	map_grid.columns = 3
	map_grid.add_theme_constant_override("h_separation", 8)
	map_grid.add_theme_constant_override("v_separation", 8)
	root.add_child(map_grid)
	for location_id in LOCATION_ORDER:
		var button := Button.new()
		button.text = schedule_manager.get_location_name(location_id)
		button.custom_minimum_size = Vector2(150, 38)
		button.pressed.connect(_on_location_selected.bind(location_id))
		_style_button(button)
		map_grid.add_child(button)
		location_buttons.append(button)

	location_label = Label.new()
	location_label.add_theme_font_size_override("font_size", 20)
	location_label.add_theme_color_override("font_color", Color("#e8dfd2"))
	root.add_child(location_label)

	description_label = Label.new()
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.add_theme_color_override("font_color", Color("#c8bfa8"))
	root.add_child(description_label)

	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 8)
	root.add_child(action_row)

	observe_button = Button.new()
	observe_button.text = "看看周围"
	observe_button.pressed.connect(_observe_location)
	_style_button(observe_button)
	action_row.add_child(observe_button)

	action_button = Button.new()
	action_button.pressed.connect(_do_daily_activity)
	_style_button(action_button)
	action_row.add_child(action_button)

	cook_button = Button.new()
	cook_button.text = "去做点吃的"
	cook_button.visible = false
	cook_button.pressed.connect(_open_kitchen)
	_style_button(cook_button)
	action_row.add_child(cook_button)

	advance_button = Button.new()
	advance_button.text = "等到下一个时段"
	advance_button.pressed.connect(_advance_time)
	_style_button(advance_button)
	action_row.add_child(advance_button)

	action_state_label = Label.new()
	action_state_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	action_state_label.add_theme_color_override("font_color", Color("#c8bfa8"))
	root.add_child(action_state_label)

	var inv_title := Label.new()
	inv_title.text = "带着的东西"
	inv_title.add_theme_color_override("font_color", Color("#e8dfd2"))
	root.add_child(inv_title)

	inventory_label = Label.new()
	inventory_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inventory_label.add_theme_color_override("font_color", Color("#c8bfa8"))
	root.add_child(inventory_label)

	var npc_title := Label.new()
	npc_title.text = "现在在这里的人"
	npc_title.add_theme_color_override("font_color", Color("#e8dfd2"))
	root.add_child(npc_title)

	npc_container = VBoxContainer.new()
	npc_container.add_theme_constant_override("separation", 6)
	root.add_child(npc_container)

	message_label = Label.new()
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.add_theme_color_override("font_color", Color("#e8dfd2"))
	message_label.text = "我想先在村子里走走。"
	root.add_child(message_label)

	var rel_title := Label.new()
	rel_title.text = "我和熟人的关系"
	rel_title.add_theme_color_override("font_color", Color("#e8dfd2"))
	root.add_child(rel_title)

	relationship_label = Label.new()
	relationship_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	relationship_label.add_theme_color_override("font_color", Color("#c8bfa8"))
	root.add_child(relationship_label)

func _refresh_ui() -> void:
	var phase_label := "日常" if game_state.world_state["phase"] == "ordinary" else "村庄发生了变化"
	if game_state.world_state["phase"] == "demo_complete":
		phase_label = "序章结束"
	status_label.text = "第 %d 天 · %s · %s" % [
		game_state.day_index, game_state.get_slot_label(), phase_label
	]
	location_label.text = "我现在在：%s" % schedule_manager.get_location_name(game_state.current_location)
	description_label.text = str(LOCATION_DESCRIPTIONS.get(game_state.current_location, ""))
	action_button.text = str(ACTIVITY_LABELS.get(game_state.current_location, "做点日常的事"))

	var can_act := game_state.can_take_action()
	action_button.disabled = not can_act
	observe_button.disabled = not can_act and game_state.world_state["phase"] == "ordinary"
	action_state_label.text = (
		"这个时段还可以做一件事。" if can_act else "这个时段我已经忙完了。"
	)

	if cook_button != null:
		var can_cook := (
			str(game_state.current_location) == "HOME"
			and game_state.world_state["phase"] == "ordinary"
			and can_act
		)
		cook_button.visible = can_cook
		cook_button.disabled = not can_cook

	_refresh_inventory_label()
	_refresh_npc_list()
	_refresh_relationship_label()

func _refresh_inventory_label() -> void:
	if player_inventory == null:
		inventory_label.text = "（空）"
		return
	var parts: Array = []
	for item_id in player_inventory.items.keys():
		var count := int(player_inventory.items[item_id])
		if count > 0:
			parts.append("%s ×%d" % [_item_display_name(str(item_id)), count])
	inventory_label.text = "（空）" if parts.is_empty() else "、".join(parts)

func _refresh_npc_list() -> void:
	for child in npc_container.get_children():
		npc_container.remove_child(child)
		child.queue_free()

	var present: Array = schedule_manager.get_npcs_at(
		game_state.current_location, game_state.day_index, game_state.slot_index
	)
	if present.is_empty():
		var empty := Label.new()
		empty.text = "这里暂时没有熟悉的村民。"
		empty.add_theme_color_override("font_color", Color("#c8bfa8"))
		npc_container.add_child(empty)
		return

	for npc_id in present:
		var npc_button := Button.new()
		npc_button.text = "和%s聊聊" % schedule_manager.get_npc_name(npc_id)
		npc_button.disabled = not game_state.can_take_action()
		npc_button.pressed.connect(_talk_to_npc.bind(str(npc_id)))
		_style_button(npc_button)
		npc_container.add_child(npc_button)

		var food_id := _first_giftable_food()
		if food_id != "":
			var gift_button := Button.new()
			gift_button.text = "把%s送给%s" % [_item_display_name(food_id), schedule_manager.get_npc_name(npc_id)]
			gift_button.disabled = not game_state.can_take_action()
			gift_button.pressed.connect(_gift_food_to_npc.bind(str(npc_id), food_id))
			_style_button(gift_button)
			npc_container.add_child(gift_button)

func _refresh_relationship_label() -> void:
	var parts: Array = []
	for npc_id in ["caregiver", "worship_leader", "doctor"]:
		var value: int = int(game_state.relationship_state.get(npc_id, 0))
		var tone := "平常"
		if value >= 3:
			tone = "更亲近些"
		elif value <= -1:
			tone = "有些疏远"
		parts.append("%s：%s" % [schedule_manager.get_npc_name(npc_id), tone])
	relationship_label.text = "\n".join(parts)

func _on_location_selected(location_id: String) -> void:
	game_state.current_location = location_id
	message_label.text = "我来到了%s。" % schedule_manager.get_location_name(location_id)
	_refresh_ui()

func _observe_location() -> void:
	if game_state.world_state["phase"] == "ordinary" and not game_state.can_take_action():
		message_label.text = "这个时段我已经忙完了。"
		return
	message_label.text = str(LOCATION_DESCRIPTIONS.get(game_state.current_location, "我看了看周围。"))
	_refresh_ui()

func _do_daily_activity() -> void:
	if not game_state.can_take_action():
		message_label.text = "这个时段我已经忙完了。"
		return
	var action_id: String = "activity_" + str(game_state.current_location).to_lower()
	var text := "我在%s%s。" % [
		schedule_manager.get_location_name(game_state.current_location),
		str(ACTIVITY_LABELS.get(game_state.current_location, "做了些琐事")),
	]
	if game_state.take_action(action_id, text):
		message_label.text = text
		# Soft material reward for path/forest chores.
		if str(game_state.current_location) == "PATH":
			player_inventory.add_item("herb", 1)
			message_label.text += " 路上采到一点草叶。"
		elif str(game_state.current_location) == "CLINIC":
			player_inventory.add_item("herb", 1)
			message_label.text += " 分拣时留下一小把可用的草药。"
	_refresh_ui()

func _advance_time() -> void:
	if game_state.world_state["phase"] != "ordinary":
		message_label.text = "时间已经不太一样了。"
		_refresh_ui()
		return
	game_state.advance_time()
	message_label.text = "时间往前走了一点。现在是第 %d 天的%s。" % [
		game_state.day_index, game_state.get_slot_label()
	]
	_refresh_ui()

func _talk_to_npc(npc_id: String) -> void:
	if not game_state.can_take_action():
		return
	var reply := "%s和我随意聊了几句日常的事。" % schedule_manager.get_npc_name(npc_id)
	match npc_id:
		"caregiver":
			reply = "照料者问我有没有好好吃饭，又把窗边的花瓶摆正了一点。"
		"worship_leader":
			reply = "礼拜主持者说最近大家都在为公共事务忙碌，语气很平稳。"
		"doctor":
			reply = "医生让我别想太多，说休息比胡思乱想有用。"
	if game_state.take_action("talk_" + npc_id, reply):
		game_state.increase_relationship(npc_id, 1)
		message_label.text = reply
	_refresh_ui()

func _open_kitchen() -> void:
	if kitchen_controller == null:
		return
	if str(game_state.current_location) != "HOME":
		message_label.text = "只有回到家里才能进厨房。"
		return
	if not game_state.can_take_action():
		message_label.text = "这个时段我已经忙完了。"
		return
	kitchen_controller.bootstrap_with(player_inventory, game_state, worldline_ledger)
	kitchen_controller.open()
	message_label.text = "我走进厨房，准备做一点简单的食物。"

func _on_kitchen_cooking_completed(result) -> void:
	if result == null:
		return
	if not result.success:
		message_label.text = "厨房：%s" % result.message
		return
	var action_id: String = "activity_home_cooking"
	var activity_text: String = "我在厨房做了%s。" % _item_display_name(str(result.output_item_id))
	if game_state.take_action(action_id, activity_text):
		message_label.text = activity_text + "（获得 %s）" % _item_display_name(str(result.output_item_id))
	else:
		message_label.text = "料理做好了，可这个时段已经没有行动机会了。"
	_refresh_ui()

func _on_kitchen_closed() -> void:
	if str(game_state.current_location) == "HOME":
		message_label.text = "我离开厨房，回到家里熟悉的光线里。"
	_refresh_ui()

func _gift_food_to_npc(npc_id: String, food_id: String) -> void:
	if gift_service == null:
		return
	if not game_state.can_take_action():
		message_label.text = "这个时段我已经忙完了。"
		return
	var gift_result = gift_service.gift_food(player_inventory, npc_id, food_id, game_state)
	if not gift_result.success:
		message_label.text = gift_result.message
		_refresh_ui()
		return
	var action_id: String = "activity_gift_%s_%s" % [npc_id, food_id]
	if game_state.take_action(action_id, gift_result.message):
		message_label.text = gift_result.message
	else:
		# Action failed after gift consumed — restore food.
		player_inventory.add_item(food_id, 1)
		message_label.text = "想送出食物，但这个时段已经没有行动机会了。"
	_refresh_ui()

func _first_giftable_food() -> String:
	if player_inventory == null:
		return ""
	for food_id in ["honey_bread", "herb_porridge"]:
		if player_inventory.has_item(food_id, 1):
			return food_id
	return ""

func _item_display_name(item_id: String) -> String:
	match item_id:
		"honey_bread":
			return "蜂蜜面包"
		"herb_porridge":
			return "草药粥"
		"flour":
			return "面粉"
		"honey":
			return "蜂蜜"
		"egg":
			return "鸡蛋"
		"herb":
			return "草药"
		_:
			return item_id

func _style_button(button: Button) -> void:
	var normal := _make_style(Color("#29252f"), Color("#665344"))
	var hover := _make_style(Color("#3b3038"), Color("#c09a6a"))
	var pressed := _make_style(Color("#4a3540"), Color("#d0b17e"))
	var disabled := _make_style(Color("#211f26"), Color("#39343d"))
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_color_override("font_color", Color("#e8dfd2"))
	button.add_theme_color_override("font_hover_color", Color("#fff4e6"))
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
