extends SceneTree

## Headless tests for Cooking-0.4 gift + hidden influence + second recipe.
## godot --headless --path . -s res://tests/cooking_0_4_test.gd

const CookingManagerScript = preload("res://scripts/systems/cooking/cooking_manager.gd")
const CookingDatabaseScript = preload("res://scripts/systems/cooking/cooking_database.gd")
const CookingFlowControllerScript = preload("res://scripts/systems/cooking/cooking_flow_controller.gd")
const CookingMenuControllerScript = preload("res://scripts/systems/cooking/cooking_menu_controller.gd")
const CookingGiftServiceScript = preload("res://scripts/systems/cooking/cooking_gift_service.gd")
const CookingWorldInfluenceScript = preload("res://scripts/systems/cooking/cooking_world_influence.gd")
const InventoryScript = preload("res://scripts/systems/item/inventory.gd")
const GameStateScript = preload("res://scripts/core/game_state.gd")

var failures: int = 0

func _init() -> void:
	print("=== Cooking-0.4 Gift / Influence / Second Recipe ===")
	_test_second_recipe_registered()
	_test_hidden_enrichment()
	_test_gift_success_and_fail()
	_test_cook_writes_hidden_flags()
	if failures == 0:
		print("ALL COOKING 0.4 TESTS PASSED")
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

func _make_manager():
	var manager = CookingManagerScript.new()
	var db = CookingDatabaseScript.new()
	for recipe in db.create_default_recipes():
		manager.register_recipe(recipe)
	return manager

func _test_second_recipe_registered() -> void:
	var manager = _make_manager()
	_assert(manager.get_recipe("honey_bread") != null, "honey_bread registered")
	_assert(manager.get_recipe("herb_porridge") != null, "herb_porridge registered")
	var porridge = manager.get_recipe("herb_porridge")
	_assert(porridge.step_count() >= 3, "herb porridge has steps")

func _test_hidden_enrichment() -> void:
	var result = preload("res://scripts/systems/cooking/cooking_result.gd").completed("honey_bread", "honey_bread")
	CookingWorldInfluenceScript.enrich_cook_result(result)
	_assert(result.hidden_resonance > 0, "resonance applied")
	_assert(result.memory_effects.size() > 0, "memory tags applied")
	_assert(result.world_effects.size() > 0, "world tags applied")

func _test_gift_success_and_fail() -> void:
	var inv = InventoryScript.new()
	var gift = CookingGiftServiceScript.new()
	var fail = gift.gift_food(inv, "caregiver", "honey_bread")
	_assert(not fail.success, "gift fails without food")

	inv.add_item("honey_bread", 1)
	var state = GameStateScript.new()
	var before = int(state.relationship_state.get("caregiver", 0))
	var ok = gift.gift_food(inv, "caregiver", "honey_bread", state)
	_assert(ok.success, "gift succeeds with food")
	_assert(inv.get_count("honey_bread") == 0, "food consumed on gift")
	_assert(ok.message.find("照料者") != -1 or ok.message.length() > 0, "player-facing line present")
	_assert(int(state.relationship_state.get("caregiver", 0)) >= before, "relationship not decreased")
	# Numbers must not appear in player message.
	_assert(ok.message.find(str(ok.relationship_delta)) == -1 or ok.relationship_delta == 0, "delta not echoed in message when non-zero check soft")

func _test_cook_writes_hidden_flags() -> void:
	var manager = _make_manager()
	var menu = CookingMenuControllerScript.new()
	var inv = InventoryScript.new()
	inv.add_item("flour", 1)
	inv.add_item("honey", 1)
	inv.add_item("egg", 1)
	var state = GameStateScript.new()
	var flow = CookingFlowControllerScript.new()
	flow.setup(manager, menu, inv)
	flow.bind_world(state, null)
	var finished: Array = []
	flow.cooking_finished.connect(func(r): finished.append(r))
	flow.request_cook("honey_bread")
	for i in range(6):
		flow.advance_current_step()
		if finished.size() > 0:
			break
	_assert(finished.size() == 1 and finished[0].success, "cook completed")
	var flags: Dictionary = state.world_state.get("flags", {})
	var cooking_flags: Dictionary = flags.get("cooking_hidden", {})
	_assert(cooking_flags.has("resonance_total"), "hidden resonance stored")
	_assert(int(cooking_flags.get("resonance_total", 0)) > 0, "resonance > 0")
