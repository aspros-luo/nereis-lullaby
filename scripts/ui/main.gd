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

var observe_home_count: int = 0

func _ready() -> void:
	pass
