class_name CookingFlowController
extends Node

## Orchestrates the full kitchen cooking flow.
## Visual nodes stay thin; all business state lives here or in CookingSession.

signal flow_started
signal recipe_list_ready(recipe_ids: Array)
signal cooking_started(recipe_id: String)
signal cooking_finished(result: CookingResult)
signal flow_cancelled

var cooking_manager: CookingManager
var menu_controller: CookingMenuController
var session: CookingSession
var inventory: Inventory

func setup(manager: CookingManager, menu: CookingMenuController, inv: Inventory) -> void:
	cooking_manager = manager
	menu_controller = menu
	inventory = inv
	session = CookingSession.new()

	if menu_controller != null and not menu_controller.cooking_requested.is_connected(_on_cooking_requested):
		menu_controller.cooking_requested.connect(_on_cooking_requested)

func open_kitchen() -> void:
	if cooking_manager == null:
		return

	var recipe_ids: Array[String] = []
	for recipe_id in cooking_manager.recipes.keys():
		recipe_ids.append(str(recipe_id))

	if menu_controller != null:
		menu_controller.set_recipes(recipe_ids)

	session.reset()
	flow_started.emit()
	recipe_list_ready.emit(recipe_ids)

func request_cook(recipe_id: String) -> void:
	_on_cooking_requested(recipe_id)

func cancel_flow() -> void:
	if session != null:
		session.reset()
	flow_cancelled.emit()

func _on_cooking_requested(recipe_id: String) -> void:
	if cooking_manager == null or session == null:
		return

	if inventory == null:
		var failed := CookingResult.failed("No inventory available")
		cooking_finished.emit(failed)
		return

	var recipe := cooking_manager.get_recipe(recipe_id)
	if recipe == null:
		var failed := CookingResult.failed("Unknown recipe: %s" % recipe_id)
		cooking_finished.emit(failed)
		return

	session.begin(recipe_id)

	var inv_snapshot: Dictionary = inventory.items.duplicate()
	if not recipe.can_cook(inv_snapshot):
		session.reset()
		var failed := CookingResult.failed("Missing ingredients for %s" % recipe_id)
		cooking_finished.emit(failed)
		return

	session.start_cooking()
	cooking_started.emit(recipe_id)

	var output_id := cooking_manager.cook(recipe_id, inv_snapshot)
	if output_id == "":
		session.reset()
		var failed := CookingResult.failed("Cooking failed for %s" % recipe_id)
		cooking_finished.emit(failed)
		return

	# Apply consumption and grant result through the real inventory.
	inventory.items = inv_snapshot
	inventory.add_item(output_id, 1)

	session.complete(output_id)
	var result := CookingResult.completed(recipe_id, output_id)
	cooking_finished.emit(result)
