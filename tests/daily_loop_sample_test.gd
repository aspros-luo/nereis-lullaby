extends SceneTree

## godot --headless --path . -s res://tests/daily_loop_sample_test.gd

const DailyActionEconomyScript = preload("res://scripts/systems/daily/daily_action_economy.gd")
const IngredientKnowledgeScript = preload("res://scripts/systems/daily/ingredient_knowledge.gd")
const GatherSystemScript = preload("res://scripts/systems/daily/gather_system.gd")
const GameModeControllerScript = preload("res://scripts/systems/daily/game_mode_controller.gd")
const InventoryScript = preload("res://scripts/systems/item/inventory.gd")
const NpcIntentSchedulerScript = preload("res://scripts/systems/daily/npc_intent_scheduler.gd")

var failures: int = 0

func _init() -> void:
	print("=== Daily Loop Sample Test ===")
	_test_economy()
	_test_knowledge_gate()
	_test_mode_blocks_gather()
	_test_passive_gift()
	if failures == 0:
		print("ALL DAILY LOOP SAMPLE TESTS PASSED")
		quit(0)
	else:
		print("FAILEDS: %d" % failures)
		quit(1)

func _assert(cond: bool, msg: String) -> void:
	if not cond:
		failures += 1
		print("FAIL: ", msg)
	else:
		print("OK: ", msg)

func _test_economy() -> void:
	var eco = DailyActionEconomyScript.new()
	_assert(eco.spend_heavy(), "spend 1")
	_assert(eco.spend_heavy(), "spend 2")
	_assert(eco.spend_heavy(), "spend 3")
	_assert(not eco.spend_heavy(), "4th blocked")
	var info: Dictionary = eco.rest()
	_assert(int(info.get("segment_index", 0)) == 1, "segment advanced")
	_assert(eco.can_spend_heavy(), "refreshed after rest")

func _test_knowledge_gate() -> void:
	var knowledge = IngredientKnowledgeScript.new()
	var gather = GatherSystemScript.new()
	gather.setup_sample_spots()
	var inv = InventoryScript.new()
	var spot: Dictionary = gather.spots_at("HOME")[0]
	var locked: Dictionary = gather.try_gather(spot, knowledge, inv, true)
	_assert(not bool(locked.get("ok", true)), "gather locked without knowledge")
	knowledge.learn("know_home_herb_patch", "家门前小园的草可以收。")
	var ok: Dictionary = gather.try_gather(spot, knowledge, inv, true)
	_assert(bool(ok.get("ok", false)), "gather ok with knowledge")
	_assert(inv.get_count("herb") == 2, "herbs added")

func _test_mode_blocks_gather() -> void:
	var mode = GameModeControllerScript.new()
	var knowledge = IngredientKnowledgeScript.new()
	knowledge.learn("know_home_herb_patch")
	var gather = GatherSystemScript.new()
	gather.setup_sample_spots()
	var inv = InventoryScript.new()
	mode.enter_event("harvest_festival")
	var spot: Dictionary = gather.spots_at("HOME")[0]
	var res: Dictionary = gather.try_gather(spot, knowledge, inv, mode.allows_free_gather())
	_assert(not bool(res.get("ok", true)), "event focus blocks free gather")

func _test_passive_gift() -> void:
	var sched = NpcIntentSchedulerScript.new()
	var inv = InventoryScript.new()
	var res: Dictionary = sched.on_rest(1, inv, "HOME")
	_assert(res.has("message"), "passive gift message")
	_assert(inv.get_count("herb") >= 1, "passive herb granted")
