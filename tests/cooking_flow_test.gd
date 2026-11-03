extends SceneTree

## Headless smoke test for Cooking-0.3 multi-step kitchen flow.
## Run with:
##   godot --headless --path . -s res://tests/cooking_flow_test.gd

var failures: int = 0

func _init() -> void:
	print("=== Cooking-0.3 Multi-Step Flow Test ===")
	_test_manager_cook()
	_test_session_states()
	_test_multi_step_success()
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
	recipe.display_name = "蜂蜜面包"
	recipe.ingredients = {"flour": 1, "honey": 1, "egg": 1}
	recipe.result_item_id = "honey_bread"
	recipe.steps = ["准备", "揉面", "烘烤", "完成"]
	manager.register_recipe(recipe)
	return manager

func _test_manager_cook() -> void:
	var manager := _make_manager()
	var inv := {"flour": 1, "honey": 1, "egg": 1}
	var result := manager.cook("honey_bread", inv)
	_assert(result == "honey_bread", "manager returns cooked item")
	_assert(int(inv.get("flour", 0)) == 0, "flour consumed")

func _test_session_states() -> void:
	var session := CookingSession.new()
	var steps: Array[String] = ["准备", "揉面", "烘烤", "完成"]
	session.begin("honey_bread", steps)
	_assert(session.state == CookingSession.State.SELECT_RECIPE, "begin -> SELECT_RECIPE")
	session.start_cooking()
	_assert(session.state == CookingSession.State.COOKING, "start_cooking -> COOKING")
	_assert(session.step_index == 0, "starts at first step")
	_assert(session.current_step_text() == "准备", "first step text")
	_assert(session.advance_step(), "advance to knead")
	_assert(session.current_step_text() == "揉面", "second step text")
	session.advance_step()
	session.advance_step()
	_assert(session.is_on_last_step(), "on last step")
	_assert(not session.advance_step(), "cannot advance past last")
	session.complete("honey_bread")
	_assert(session.state == CookingSession.State.COMPLETE, "complete -> COMPLETE")

func _test_multi_step_success() -> void:
	var manager := _make_manager()
	var menu := CookingMenuController.new()
	var inv := Inventory.new()
	inv.add_item("flour", 1)
	inv.add_item("honey", 1)
	inv.add_item("egg", 1)

	var flow := CookingFlowController.new()
	flow.setup(manager, menu, inv)

	var steps_seen: Array = []
	var finished: Array = []
	flow.step_changed.connect(func(rid, idx, text, prog, last): steps_seen.append({"idx": idx, "text": text, "last": last}))
	flow.cooking_finished.connect(func(r): finished.append(r))

	flow.request_cook("honey_bread")
	_assert(steps_seen.size() == 1, "first step emitted")
	_assert(inv.get_count("flour") == 1, "ingredients not consumed before finish")

	# Advance through remaining steps.
	flow.advance_current_step() # 揉面
	flow.advance_current_step() # 烘烤
	flow.advance_current_step() # 完成 (last)
	_assert(steps_seen.size() == 4, "four steps emitted")
	_assert(bool(steps_seen[3]["last"]), "fourth step marked last")

	# Finish on last step continue.
	flow.advance_current_step()
	_assert(finished.size() == 1, "finished after last continue")
	if finished.size() == 1:
		_assert(finished[0].success, "multi-step cooking succeeded")
		_assert(inv.get_count("honey_bread") == 1, "inventory gained food")
		_assert(inv.get_count("flour") == 0, "ingredients consumed at end only")

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
		_assert(not finished[0].success, "cooking fails without ingredients")

func _test_kitchen_controller_bootstrap() -> void:
	var kitchen := KitchenController.new()
	kitchen.cooking_station = CookingStation.new()
	kitchen.bootstrap_with()
	_assert(kitchen.cooking_manager != null, "manager created")
	_assert(kitchen.flow_controller != null, "flow controller created")

	var finished: Array = []
	kitchen.cooking_completed.connect(func(r): finished.append(r))
	kitchen.open()
	kitchen.request_recipe("honey_bread")
	# Multi-step: advance until complete.
	for i in range(6):
		kitchen.advance_step()
		if finished.size() > 0:
			break
	_assert(finished.size() == 1, "kitchen multi-step completes")
	if finished.size() == 1:
		_assert(finished[0].success, "kitchen demo cook succeeds")
	kitchen.close()
	_assert(not kitchen.menu_ui.visible, "menu ui hidden after close")

func _test_menu_ui_signals() -> void:
	var ui := CookingMenuUI.new()
	ui._build_ui()

	var manager := _make_manager()
	var inv := Inventory.new()
	inv.add_item("flour", 1)
	inv.add_item("honey", 1)
	inv.add_item("egg", 1)

	var requested: Array = []
	var continued: Array = []
	ui.recipe_cook_requested.connect(func(id): requested.append(id))
	ui.step_continue_requested.connect(func(): continued.append(true))

	ui.open_menu(["honey_bread"], manager, inv)
	ui._on_recipe_pressed("honey_bread")
	_assert(requested.size() == 1, "ui emits recipe request")

	ui.show_step("步骤 1 / 4", "准备", false)
	_assert(ui.continue_button.visible, "continue visible during process")
	ui.continue_button.pressed.emit()
	_assert(continued.size() == 1, "continue signal emitted")

	var ok := CookingResult.completed("honey_bread", "honey_bread")
	ui.show_result(ok, inv)
	_assert(not ui.continue_button.visible, "continue hidden after result")
