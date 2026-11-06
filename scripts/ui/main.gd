extends Control
## Daily shell + pre-festival LN events + harvest festival focus + post-festival traces.

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

func _set_dialogue(text: String) -> void:
	dialogue_text.text = text

func _location_desc(loc: String) -> String:
	if loc == "HOME" and world_flags.has_flag("festival_done"):
		return "屋子还是老样子，可窗边多了一点没扫尽的花瓣。空气里像还留着节庆的甜味，又有点沉。"
	if loc == "COMMONS" and world_flags.has_flag("festival_done"):
		return "公共场已经收拾过一轮。木桌空了，却像有人刻意把某个位置留得很干净。"
	return str(LOCATION_DESCRIPTIONS.get(loc, ""))

func _observe_location() -> void:
	var loc: String = str(game_state.current_location)
	var text: String = _location_desc(loc)
	if world_flags.has_flag("festival_done"):
		if loc == "HOME":
			if not world_flags.has_flag("seen_home_petals"):
				world_flags.set_flag("seen_home_petals")
				knowledge.learn("trace_home_petals", "窗下有只空碗，沾着干花瓣碎屑。")
				text = traces.text_home_object_petals()
			else:
				text = traces.text_home_object_seen()
		elif loc == "COMMONS":
			if not world_flags.has_flag("seen_commons_seat"):
				world_flags.set_flag("seen_commons_seat")
				knowledge.learn("trace_commons_seat", "公共场有一处地面被刻意留白。")
			text = traces.text_commons_place()
		elif loc == "SHRINE":
			if not world_flags.has_flag("seen_shrine_flowers"):
				world_flags.set_flag("seen_shrine_flowers")
				knowledge.learn("trace_shrine_old_flowers", "旧花被捆得很紧，名单不在桌上。")
			text = traces.text_shrine_place()
		elif loc == "PATH":
			if not world_flags.has_flag("seen_path_scrap"):
				world_flags.set_flag("seen_path_scrap")
				knowledge.learn("trace_path_scrap", "路旁告示板只剩一条撕破的纸须。")
			text = traces.text_faceless_path_scrap()
		_set_dialogue(text)
		_refresh_ui()
		return
	if loc == "HOME":
		obsave_home_count += 1
		if observe_home_count == 1:
			text = pre_events.text_observe_home_vase()
		elif observe_home_count >= 2:
			text = pre_events.text_observe_home_hammer()
	elif loc == "COMMONS" and not pre_events.has_seen("obs_commons"):
		pre_events.mark("obs_commons")
		text = pre_events.text_observe_commons_basket()
	elif loc == "SHRINE" and economy.segment_index >= 3:
		text = pre_events.text_observe_shrine_paper()
	elif loc == "COMMONS" and economy.is_festival_ready() and not world_flags.has_flag("festival_done"):
		text = pre_events.text_pf20_drum()
	_set_dialogue(text)
	_refresh_ui()

func _festival_refuse() -> void:
	world_flags.set_flag("festival_refused")
	_set_dialogue(traces.text_festival_refuse())
	_refresh_ui()

# NOTE: Full UI shell continues in same file — if this partial write is applied alone it will break.
# See repo history for complete main; this message must not be used alone.
