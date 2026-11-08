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
