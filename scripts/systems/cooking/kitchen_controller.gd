class_name KitchenController
extends Node2D

## Root controller for the formal kitchen scene.
## Keeps visual nodes free of cooking business logic.

const CookingManagerScript = preload("res://scripts/systems/cooking/cooking_manager.gd")
const CookingMenuControllerScript = preload("res://scripts/systems/cooking/cooking_menu_controller.gd")
const CookingFlowControllerScript = preload("res://scripts/systems/cooking/cooking_flow_controller.gd")
const CookingDatabaseScript = preload("res://scripts/systems/cooking/cooking_database.gd")
const CookingResourceLoaderScript = preload("res://scripts/systems/cooking/cooking_resource_loader.gd")
const CookingMenuUIScript = preload("res://scripts/ui/cooking_menu_ui.gd")
const InventoryScript = preload("res://scripts/systems/item/inventory.gd")

@onready var cooking_station = $CookingStation
@onready var player_spawn = $PlayerSpawn

var flow_controller
var cooking_manager
var menu_controller
var inventory
var menu_ui

signal kitchen_opened
signal kitchen_closed
signal cooking_completed(result)

func _ready() -> void:
	_ensure_runtime()
	if cooking_station != null and cooking_station.has_signal("cooking_requested"):
		if not cooking_station.cooking_requested.is_connected(_on_station_interact):
			cooking_station.cooking_requested.connect(_on_station_interact)

func bootstrap_with(inv = null) -> void:
	_ensure_runtime()
	if inv != null:
		inventory = inv
		flow_controller.setup(cooking_manager, menu_controller, inventory)

func open() -> void:
	_ensure_runtime()
	flow_controller.open_kitchen()
	if menu_ui != null:
		var recipe_ids: Array = cooking_manager.list_recipe_ids()
		menu_ui.open_menu(recipe_ids, cooking_manager, inventory)
	kitchen_opened.emit()

func close() -> void:
	if flow_controller != null:
		flow_controller.cancel_flow()
	if menu_ui != null:
		menu_ui.close_menu()
	kitchen_closed.emit()

func interact_station() -> void:
	if cooking_station != null and cooking_station.has_method("interact"):
		cooking_station.interact()

func request_recipe(recipe_id: String) -> void:
	if flow_controller != null:
		flow_controller.request_cook(recipe_id)

func advance_step() -> void:
	if flow_controller != null:
		flow_controller.advance_current_step()

func _ensure_runtime() -> void:
	if cooking_manager == null:
		cooking_manager = CookingManagerScript.new()
		_load_default_content()

	if menu_controller == null:
		menu_controller = CookingMenuControllerScript.new()
		add_child(menu_controller)

	if inventory == null:
		inventory = InventoryScript.new()
		inventory.add_item("flour", 2)
		inventory.add_item("honey", 2)
		inventory.add_item("egg", 2)

	if flow_controller == null:
		flow_controller = CookingFlowControllerScript.new()
		add_child(flow_controller)
		flow_controller.setup(cooking_manager, menu_controller, inventory)
		if not flow_controller.cooking_finished.is_connected(_on_cooking_finished):
			flow_controller.cooking_finished.connect(_on_cooking_finished)
		if not flow_controller.step_changed.is_connected(_on_step_changed):
			flow_controller.step_changed.connect(_on_step_changed)

	if menu_ui == null:
		menu_ui = CookingMenuUIScript.new()
		var layer := CanvasLayer.new()
		layer.layer = 10
		add_child(layer)
		layer.add_child(menu_ui)
		if not menu_ui.recipe_cook_requested.is_connected(_on_ui_recipe_requested):
			menu_ui.recipe_cook_requested.connect(_on_ui_recipe_requested)
		if not menu_ui.step_continue_requested.is_connected(_on_ui_step_continue):
			menu_ui.step_continue_requested.connect(_on_ui_step_continue)
		if not menu_ui.close_requested.is_connected(close):
			menu_ui.close_requested.connect(close)

func _load_default_content() -> void:
	var database = CookingDatabaseScript.new()
	var recipes = database.create_default_recipes()
	for recipe in recipes:
		cooking_manager.register_recipe(recipe)

	var resource_loader = CookingResourceLoaderScript.new()
	resource_loader.load_from_directories(
		"res://resources/cooking/ingredients/",
		"res://resources/cooking/recipes/"
	)
	for recipe_id in resource_loader.recipes.keys():
		var recipe = resource_loader.recipes[recipe_id]
		if recipe == null:
			continue
		if "steps" in recipe and recipe.steps.is_empty() and cooking_manager.get_recipe(str(recipe.id)) != null:
			continue
		cooking_manager.register_recipe(recipe)

func _on_station_interact() -> void:
	open()

func _on_ui_recipe_requested(recipe_id: String) -> void:
	request_recipe(recipe_id)

func _on_ui_step_continue() -> void:
	advance_step()

func _on_step_changed(_recipe_id: String, _step_index: int, step_text: String, progress_label: String, is_last: bool) -> void:
	if menu_ui != null:
		menu_ui.show_step(progress_label, step_text, is_last)

func _on_cooking_finished(result) -> void:
	if menu_ui != null:
		var recipe_ids: Array = cooking_manager.list_recipe_ids()
		menu_ui.open_menu(recipe_ids, cooking_manager, inventory)
		menu_ui.show_result(result, inventory)
	cooking_completed.emit(result)
