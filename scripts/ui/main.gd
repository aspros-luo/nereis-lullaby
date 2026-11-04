extends Control
## Daily-loop sample (plan C): freedom + heavy-action cap + knowledge gather.
## Festival event_focus is stubbed; kitchen retained.

const GameStateScript = preload("res://scripts/core/game_state.gd")
const ScheduleManagerScript = preload("res://scripts/managers/npc_schedule_manager.gd")
const InventoryScript = preload("res://scripts/systems/item/inventory.gd")
const KitchenControllerScript = preload("res://scripts/systems/cooking/kitchen_controller.gd")
const CookingGiftServiceScript = preload("res://scripts/systems/cooking/cooking_gift_service.gd")
const GameModeControllerScript = preload("res://scripts/systems/daily/game_mode_controller.gd")
const DailyActionEconomyScript = preload("res://scripts/systems/daily/daily_action_economy.gd")
const IngredientKnowledgeScript = preload("res://scripts/systems/daily/ingredient_knowledge.gd")
const GatherSystemScript = preload("res://scripts/systems/daily/gather_system.gd")
const NpcIntentSchedulerScript = preload("res://scripts/systems/daily/npc_intent_scheduler.gd")

const LOCATION_ORDER: Array[String] = [
	"FOREST", "GROVE", "PATH", "COMMONS", "SHRINE", "HOME", "CLINIC"
]
const LOCATION_NAMES: Dictionary = {
	"HOME": "家附近",
	"COMMONS": "公共场",
	"SHRINE": "礼拜场所",
	"CLINIC": "诊疗处",
	"PATH": "村庄通路",
	"FOREST": "林间",
	"GROVE": "林中空地",
}
const LOCATION_DESCRIPTIONS: Dictionary = {
	"HOME": "熟悉的屋子和门前小路。老婆婆总把日子安排得妥妥当当。铁匠的锤声有时从棚后传来。",
	"COMMONS": "村民交换食物、闲聊和帮忙的地方。也有外地来的商贩偶尔停脚。",
	"SHRINE": "公开举行节庆与祈祷准备的地方。木头和花束都收拾得很整齐。",
	"CLINIC": "草药与药瓶摆在架子上。空气里有干净的苦味。",
	"PATH": "连接村庄各处的小路。有人把篮子放在路边。",
	"FOREST": "林子比村庄安静。风穿过叶子时，像有人在远处说话。",
	"GROVE": "树木围出的空地。适合坐一会儿。",
}

var game_state
var mode_controller
var economy
var knowledge
var gather_system
var intent_scheduler
var player_inventory
var kitchen_controller
var gift_service

var status_label: Label
var location_label: Label
var description_label: Label
var action_state_label: Label
var message_label: Label
var inventory_label: Label
var knowledge_label: Label
var dynamic_actions: VBoxContainer
var location_buttons: Array[Button] = []

func _ready() -> void:
	game_state = GameStateScript.new()
	mode_controller = GameModeControllerScript.new()
	economy = DailyActionEconomyScript.new()
	knowledge = IngredientKnowledgeScript.new()
	gather_system = GatherSystemScript.new()
	gather_system.setup_sample_spots()
	intent_scheduler = NpcIntentSchedulerScript.new()
	_setup_kitchen()
	_apply_visual_style()
	_build_ui()
	message_label.text = "我在村子里住了很久。今天想做点平常的事。"
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
	title.text = "蜜忒之歌｜日常样板"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color("#e8dfd2"))
	root.add_child(title)

	status_label = Label.new()
	status_label.add_theme_font_size_override("font_size", 18)
	status_label.add_theme_color_override("font_color", Color("#e8dfd2"))
	root.add_child(status_label)

	var map_title := Label.new()
	map_title.text = "地点"
	map_title.add_theme_color_override("font_color", Color("#e8dfd2"))
	root.add_child(map_title)

	var map_grid := GridContainer.new()
	map_grid.columns = 3
	map_grid.add_theme_constant_override("h_separation", 8)
	map_grid.add_theme_constant_override("v_separation", 8)
	root.add_child(map_grid)
	for location_id in LOCATION_ORDER:
		var button := Button.new()
		button.text = str(LOCATION_NAMES.get(location_id, location_id))
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

	action_state_label = Label.new()
	action_state_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	action_state_label.add_theme_color_override("font_color", Color("#c8bfa8"))
	root.add_child(action_state_label)

	var act_title := Label.new()
	act_title.text = "可以做的事"
	act_title.add_theme_color_override("font_color", Color("#e8dfd2"))
	root.add_child(act_title)

	dynamic_actions = VBoxContainer.new()
	dynamic_actions.add_theme_constant_override("separation", 6)
	root.add_child(dynamic_actions)

	var inv_title := Label.new()
	inv_title.text = "带着的东西"
	inv_title.add_theme_color_override("font_color", Color("#e8dfd2"))
	root.add_child(inv_title)

	inventory_label = Label.new()
	inventory_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inventory_label.add_theme_color_override("font_color", Color("#c8bfa8"))
	root.add_child(inventory_label)

	var know_title := Label.new()
	know_title.text = "听来的事（线索）"
	know_title.add_theme_color_override("font_color", Color("#e8dfd2"))
	root.add_child(know_title)

	knowledge_label = Label.new()
	knowledge_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	knowledge_label.add_theme_color_override("font_color", Color("#c8bfa8"))
	root.add_child(knowledge_label)

	message_label = Label.new()
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.add_theme_color_override("font_color", Color("#e8dfd2"))
	root.add_child(message_label)

func _refresh_ui() -> void:
	var mode_text := "日常" if mode_controller.is_daily() else "事件中"
	status_label.text = "%s · %s" % [mode_text, economy.status_text()]
	location_label.text = "我现在在：%s" % str(LOCATION_NAMES.get(game_state.current_location, game_state.current_location))
	description_label.text = str(LOCATION_DESCRIPTIONS.get(game_state.current_location, ""))
	action_state_label.text = (
		"还可以做有重量的事。" if economy.can_spend_heavy() else "有点累了，也许该休息，让日子往前走一点。"
	)
	_refresh_inventory_label()
	_refresh_knowledge_label()
	_rebuild_dynamic_actions()

func _refresh_inventory_label() -> void:
	var parts: Array = []
	for item_id in player_inventory.items.keys():
		var count := int(player_inventory.items[item_id])
		if count > 0:
			parts.append("%s ×%d" % [_item_display_name(str(item_id)), count])
	inventory_label.text = "（空）" if parts.is_empty() else "、".join(parts)

func _refresh_knowledge_label() -> void:
	var notes: Array = knowledge.list_notes()
	knowledge_label.text = "（还没有特别记住的事）" if notes.is_empty() else "\n".join(notes)

func _rebuild_dynamic_actions() -> void:
	for child in dynamic_actions.get_children():
		dynamic_actions.remove_child(child)
		child.queue_free()

	var daily := mode_controller.is_daily()
	var can_heavy := economy.can_spend_heavy()

	_add_action_button("看看周围", _observe_location, true)
	_add_action_button("休息，让日子往前走", _rest, true)

	if daily and str(game_state.current_location) == "HOME":
		_add_action_button("和老婆婆聊聊", _talk_popo, can_heavy)
		_add_action_button("去做点吃的", _open_kitchen, can_heavy)

	if daily and str(game_state.current_location) == "COMMONS":
		_add_action_button("和外地商人聊两句", _talk_merchant, can_heavy)
		_add_action_button("和路过的村民闲聊", _talk_villager, can_heavy)

	if daily:
		for spot in gather_system.spots_at(str(game_state.current_location)):
			var label := str(spot.get("label", "采集"))
			var known := true
			var kid := str(spot.get("requires_knowledge_id", ""))
			if kid != "" and not knowledge.has(kid):
				label = label + "（还不知道）"
				known = false
			# Allow click even if unknown to show locked text; still costs heavy only on success path handled inside.
			_add_action_button(label, _gather_spot.bind(spot), can_heavy or not known)

	var food_id := _first_giftable_food()
	if daily and food_id != "" and str(game_state.current_location) == "HOME":
		_add_action_button("把%s送给老婆婆" % _item_display_name(food_id), _gift_to_popo.bind(food_id), can_heavy)

func _add_action_button(text: String, callable: Callable, enabled: bool) -> void:
	var button := Button.new()
	button.text = text
	button.disabled = not enabled
	button.pressed.connect(callable)
	_style_button(button)
	dynamic_actions.add_child(button)

func _on_location_selected(location_id: String) -> void:
	if mode_controller.is_event_focus():
		message_label.text = "现在心里有别的事，走不开。"
		return
	game_state.current_location = location_id
	message_label.text = "我来到了%s。" % str(LOCATION_NAMES.get(location_id, location_id))
	_refresh_ui()

func _observe_location() -> void:
	message_label.text = str(LOCATION_DESCRIPTIONS.get(game_state.current_location, "我看了看周围。"))
	_refresh_ui()

func _rest() -> void:
	var info: Dictionary = economy.rest()
	var msg := "我休息了一会儿。日子悄悄往前走了一点。"
	var passive: Dictionary = intent_scheduler.on_rest(int(info.get("segment_index", 0)), player_inventory, str(game_state.current_location))
	if not passive.is_empty():
		msg += "\n" + str(passive.get("message", ""))
	if bool(info.get("festival_hint", false)):
		msg += "\n空气里开始有节庆前的忙乱——丰收节快到了。"
	message_label.text = msg
	_refresh_ui()

func _talk_popo() -> void:
	if not economy.spend_heavy():
		message_label.text = "有点累了，先休息吧。"
		_refresh_ui()
		return
	var msg := "老婆婆问我有没有好好吃饭，又把窗边的花瓶摆正。"
	if knowledge.learn("know_home_herb_patch", "家门前小园里的草药可以收取。"):
		msg += "她说门前园子里的叶子可以摘一些回来备用。"
	else:
		msg += "我们又说了些家常。"
	message_label.text = msg
	_refresh_ui()

func _talk_merchant() -> void:
	if not economy.spend_heavy():
		message_label.text = "有点累了，先休息吧。"
		_refresh_ui()
		return
	var msg := "外地商人正在收摊，语气很快。"
	if knowledge.learn("know_moonleaf", "林间有一种清香的叶子，可以当香料。"):
		msg += "他随口说林子里有种叶子带清香，懂的人会采一点调味。"
	else:
		msg += "他没有多说什么新的。"
	message_label.text = msg
	_refresh_ui()

func _talk_villager() -> void:
	if not economy.spend_heavy():
		message_label.text = "有点累了，先休息吧。"
		_refresh_ui()
		return
	message_label.text = "村民笑着说今年的丰收节会比往年更热闹，让我记得去公共场。"
	_refresh_ui()

func _gather_spot(spot: Dictionary) -> void:
	var result: Dictionary = gather_system.try_gather(
		spot, knowledge, player_inventory, mode_controller.allows_free_gather()
	)
	if bool(result.get("locked", false)):
		message_label.text = str(result.get("message", ""))
		_refresh_ui()
		return
	if not bool(result.get("ok", false)):
		message_label.text = str(result.get("message", "没能采集。"))
		_refresh_ui()
		return
	if not economy.spend_heavy():
		# Refund items if we cannot spend (edge case).
		player_inventory.remove_item(str(result.get("item_id", "")), int(result.get("amount", 1)))
		message_label.text = "有点累了，没能继续。"
		_refresh_ui()
		return
	message_label.text = str(result.get("message", ""))
	_refresh_ui()

func _open_kitchen() -> void:
	if not mode_controller.is_daily():
		message_label.text = "现在不适合进厨房。"
		return
	if str(game_state.current_location) != "HOME":
		return
	if not economy.can_spend_heavy():
		message_label.text = "有点累了，先休息吧。"
		return
	kitchen_controller.bootstrap_with(player_inventory, game_state, null)
	kitchen_controller.open()
	message_label.text = "我走进厨房。"

func _on_kitchen_cooking_completed(result) -> void:
	if result == null:
		return
	if not result.success:
		message_label.text = "厨房：%s" % result.message
		_refresh_ui()
		return
	if economy.spend_heavy():
		message_label.text = "我做了%s。" % _item_display_name(str(result.output_item_id))
	else:
		message_label.text = "料理好了，可人已经很累了。"
	_refresh_ui()

func _on_kitchen_closed() -> void:
	_refresh_ui()

func _gift_to_popo(food_id: String) -> void:
	if not economy.spend_heavy():
		message_label.text = "有点累了，先休息吧。"
		_refresh_ui()
		return
	var gift_result = gift_service.gift_food(player_inventory, "caregiver", food_id, game_state)
	message_label.text = gift_result.message
	_refresh_ui()

func _first_giftable_food() -> String:
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
		"spice_moonleaf":
			return "清香叶"
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
