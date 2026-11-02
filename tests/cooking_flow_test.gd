extends SceneTree

## Headless smoke test for Cooking-0.3 kitchen flow + UI path.
## Run with:
##   godot --headless --path . -s res://tests/cooking_flow_test.gd

var failures: int = 0

func _init() -> void:
	print("=== Cooking-0.3 Flow Test ===")
	_test_manager_cook()
	_test_session_states()
	_test_flow_controller_success()
	_test_flow_controller_missing_ingredients()
	_test_kitchen_controller_bootstrap()
	_test_menu_ui_signals()

	if failures == 0:
		print("ALL COOKING FLOW TESTS PASSED")
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

func _make_manager() -> CookingManager:
	var manager := CookingManager.new()
	var recipe := CookingRecipe.new()
	recipe.id = "honey_bread"
	recipe.display_name = "Honey Bread"
	recipe.ingredients = {"flour": 1, "honey": 1, "egg": 1}
	recipe.result_item_id = "honey_bread"
	manager.register_recipe(recipe)
	return manager

func _test_manager_cook() -> void:
	var manager := _make_manager()
	var inv := {"flour": 1, "honey": 1, "egg": 1}
	var result := manager.cook("honey_bread", inv)
	_assert(result == "honey_bread", "manager returns cooked item")
	_assert(int(inv.get("flour", 0)) == 0, "flour consumed")
	_assert(int(inv.get("honey", 0)) == 0, "honey consumed")
	_assert(int(inv.get("egg", 0)) == 0, "egg consumed")

func _test_session_states() -> void:
	var session := CookingSession.new()
	_assert(session.state == CookingSession.State.IDLE, "session starts idle")
	session.begin("honey_bread")
	_assert(session.state == CookingSession.State.SELECT_RECIPE, "begin -> SELECT_RECIPE")
	session.start_cooking()
	_assert(session.state == CookingSession.State.COOKING, "start_cooking -> COOKING")
	session.complete("honey_bread")
	_assert(session.state == CookingSession.State.COMPLETE, "complete -> COMPLETE")
	_assert(session.result_item_id == "honey_bread", "result stored")
	session.reset()
	_assert(session.state == CookingSession.State.IDLE, "reset -> IDLE")

func _test_flow_controller_success() -> void:
	var manager := _make_manager()
	var menu := CookingMenuController.new()
	var inv := Inventory.new()
	inv.add_item("flour", 1)
	inv.add_item("honey", 1)
	inv.add_item("egg", 1)

	var flow := CookingFlowController.new()
	flow.setup(manager, menu, inv)

	var finished: Array = []
	flow.cooking_finished.connect(func(r): finished.append(r))

	flow.open_kitchen()
	flow.request_cook("honey_bread")

	_assert(finished.size() == 1, "flow emits one result")
	if finished.size() == 1:
		var result: CookingResult = finished[0]
		_assert(result.success, "cooking succeeded")
		_assert(result.output_item_id == "honey_bread", "output item id correct")
		_assert(inv.get_count("honey_bread") == 1, "inventory gained food")
		_assert(inv.get_count("flour") == 0, "ingredients removed from inventory")

func _test_flow_controller_missing_ingredients() -> void:
	var manager := _make_manager()
	var menu := CookingMenuController.new()
	var inv := Inventory.new()
	inv.add_item("flour", 1)

	var flow := CookingFlowController.new()
	flow.setup(manager, menu, inv)

	var finished: Array = []
	flow.cooking_finished.connect(func(r): finished.append(r))

	flow.request_cook("honey_bread")
	_assert(finished.size() == 1, "missing ingredients still emits result")
	if finished.size() == 1:
		var result: CookingResult = finished[0]
		_assert(not result.success, "cooking fails without ingredients")
		_assert(inv.get_count("flour") == 1, "failed cook does not consume")

func _test_kitchen_controller_bootstrap() -> void:
	var kitchen := KitchenController.new()
	kitchen.cooking_station = CookingStation.new()
	kitchen.bootstrap_with()
	_assert(kitchen.cooking_manager != null, "manager created")
	_assert(kitchen.flow_controller != null, "flow controller created")
	_assert(kitchen.inventory != null, "inventory created")
	_assert(kitchen.inventory.get_count("flour") >= 1, "demo ingredients present")

	var finished: Array = []
	kitchen.cooking_completed.connect(func(r): finished.append(r))
	kitchen.open()
	_assert(kitchen.menu_ui != null, "menu ui created")
	_assert(kitchen.menu_ui.visible, "menu ui visible after open")
	kitchen.request_recipe("honey_bread")
	_assert(finished.size() == 1, "kitchen emits cooking_completed")
	if finished.size() == 1:
		_assert(finished[0].success, "kitchen demo cook succeeds")
	kitchen.close()
	_assert(not kitchen.menu_ui.visible, "menu ui hidden after close")

func _test_menu_ui_signals() -> void:
	var ui := CookingMenuUI.new()
	# Build widgets without entering a full scene tree frame.
	ui._build_ui()

	var manager := _make_manager()
	var inv := Inventory.new()
	inv.add_item("flour", 1)
	inv.add_item("honey", 1)
	inv.add_item("egg", 1)

	var requested: Array = []
	ui.recipe_cook_requested.connect(func(id): requested.append(id))

	ui.open_menu(["honey_bread"], manager, inv)
	_assert(ui.visible, "ui opens")
	_assert(ui.recipe_container.get_child_count() >= 1, "recipe rows present")

	# Simulate pressing the cook button path.
	ui._on_recipe_pressed("honey_bread")
	_assert(requested.size() == 1 and requested[0] == "honey_bread", "ui emits recipe request")

	var ok := CookingResult.completed("honey_bread", "honey_bread")
	ui.show_result(ok, inv)
	_assert(ui.message_label.text.find("honey_bread") != -1, "success message shown")

	ui.close_menu()
	_assert(not ui.visible, "ui closes")
