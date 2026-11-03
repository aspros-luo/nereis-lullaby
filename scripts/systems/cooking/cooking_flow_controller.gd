class_name CookingFlowController
extends Node

## Orchestrates the full kitchen cooking flow.
## Multi-step recipes advance one player action at a time.

const CookingSessionScript = preload("res://scripts/systems/cooking/cooking_session.gd")
const CookingResultScript = preload("res://scripts/systems/cooking/cooking_result.gd")

signal flow_started
signal recipe_list_ready(recipe_ids: Array)
signal cooking_started(recipe_id: String)
signal step_changed(recipe_id: String, step_index: int, step_text: String, progress_label: String, is_last: bool)
signal cooking_finished(result)
signal flow_cancelled

var cooking_manager
var menu_controller
var session
var inventory

func setup(manager, menu, inv) -> void:
	cooking_manager = manager
	menu_controller = menu
	inventory = inv
	session = CookingSessionScript.new()

	if menu_controller != null and menu_controller.has_signal("cooking_requested"):
		if not menu_controller.cooking_requested.is_connected(_on_cooking_requested):
			menu_controller.cooking_requested.connect(_on_cooking_requested)

func open_kitchen() -> void:
	if cooking_manager == null:
		return

	var recipe_ids: Array = []
	for recipe_id in cooking_manager.recipes.keys():
		recipe_ids.append(str(recipe_id))

	if menu_controller != null and menu_controller.has_method("set_recipes"):
		menu_controller.set_recipes(recipe_ids)

	session.reset()
	flow_started.emit()
	recipe_list_ready.emit(recipe_ids)

func request_cook(recipe_id: String) -> void:
	_on_cooking_requested(recipe_id)

func advance_current_step() -> void:
	if session == null or session.state != CookingSessionScript.State.COOKING:
		return

	if session.is_on_last_step():
		_finish_current_recipe()
		return

	if session.advance_step():
		_emit_step()

func cancel_flow() -> void:
	if session != null:
		session.reset()
	flow_cancelled.emit()

func _on_cooking_requested(recipe_id: String) -> void:
	if cooking_manager == null or session == null:
		return

	if session.state == CookingSessionScript.State.COOKING:
		return

	if inventory == null:
		cooking_finished.emit(CookingResultScript.failed("No inventory available"))
		return

	var recipe = cooking_manager.get_recipe(recipe_id)
	if recipe == null:
		cooking_finished.emit(CookingResultScript.failed("Unknown recipe: %s" % recipe_id))
		return

	var recipe_steps: Array = []
	if recipe.has_method("get_steps"):
		recipe_steps = recipe.get_steps()
	elif "steps" in recipe:
		recipe_steps = recipe.steps

	session.begin(recipe_id, recipe_steps)
	session.mark_ingredients_checked()

	var inv_snapshot: Dictionary = inventory.items.duplicate()
	if not recipe.can_cook(inv_snapshot):
		session.reset()
		cooking_finished.emit(CookingResultScript.failed("Missing ingredients for %s" % recipe_id))
		return

	session.start_cooking()
	cooking_started.emit(recipe_id)
	_emit_step()

func _emit_step() -> void:
	step_changed.emit(
		session.current_recipe_id,
		session.step_index,
		session.current_step_text(),
		session.step_progress_label(),
		session.is_on_last_step()
	)

func _finish_current_recipe() -> void:
	var recipe_id: String = session.current_recipe_id
	var recipe = cooking_manager.get_recipe(recipe_id)
	if recipe == null:
		session.reset()
		cooking_finished.emit(CookingResultScript.failed("Unknown recipe: %s" % recipe_id))
		return

	var inv_snapshot: Dictionary = inventory.items.duplicate()
	if not recipe.can_cook(inv_snapshot):
		session.reset()
		cooking_finished.emit(CookingResultScript.failed("Missing ingredients for %s" % recipe_id))
		return

	var output_id: String = cooking_manager.cook(recipe_id, inv_snapshot)
	if output_id == "":
		session.reset()
		cooking_finished.emit(CookingResultScript.failed("Cooking failed for %s" % recipe_id))
		return

	inventory.items = inv_snapshot
	inventory.add_item(output_id, 1)

	var image_path: String = ""
	if recipe.has_method("get_result_image_path"):
		image_path = str(recipe.get_result_image_path())
	elif "result_image_path" in recipe:
		image_path = str(recipe.result_image_path)

	session.complete(output_id)
	var result = CookingResultScript.completed(recipe_id, output_id, image_path)
	result.message = "热气和甜味一起散开来。"
	cooking_finished.emit(result)
	session.reset()
