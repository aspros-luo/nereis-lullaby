class_name KitchenController
extends Node2D

## Root controller for the formal kitchen scene.
## Keeps visual nodes free of cooking business logic.

@onready var cooking_station: CookingStation = $CookingStation
@onready var player_spawn: Marker2D = $PlayerSpawn

var flow_controller: CookingFlowController
var cooking_manager: CookingManager
var menu_controller: CookingMenuController
var inventory: Inventory
var menu_ui: CookingMenuUI

signal kitchen_opened
signal kitchen_closed
signal cooking_completed(result: CookingResult)

func _ready() -> void:
	_ensure_runtime()
	if cooking_station != null and not cooking_station.cooking_requested.is_connected(_on_station_interact):
		cooking_station.cooking_requested.connect(_on_station_interact)

func bootstrap_with(inv: Inventory = null) -> void:
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
	if cooking_station != null:
		cooking_station.interact()

func request_recipe(recipe_id: String) -> void:
	if flow_controller != null:
		flow_controller.request_cook(recipe_id)

func _ensure_runtime() -> void:
	if cooking_manager == null:
		cooking_manager = CookingManager.new()
		_load_default_content()

	if menu_controller == null:
		menu_controller = CookingMenuController.new()
		add_child(menu_controller)

	if inventory == null:
		inventory = Inventory.new()
		# Demo starter ingredients so the flow is immediately testable.
		inventory.add_item("flour", 2)
		inventory.add_item("honey", 2)
		inventory.add_item("egg", 2)

	if flow_controller == null:
		flow_controller = CookingFlowController.new()
		add_child(flow_controller)
		flow_controller.setup(cooking_manager, menu_controller, inventory)
		if not flow_controller.cooking_finished.is_connected(_on_cooking_finished):
			flow_controller.cooking_finished.connect(_on_cooking_finished)

	if menu_ui == null:
		menu_ui = CookingMenuUI.new()
		# CanvasLayer keeps text UI above the 2D kitchen placeholders.
		var layer := CanvasLayer.new()
		layer.layer = 10
		add_child(layer)
		layer.add_child(menu_ui)
		if not menu_ui.recipe_cook_requested.is_connected(_on_ui_recipe_requested):
			menu_ui.recipe_cook_requested.connect(_on_ui_recipe_requested)
		if not menu_ui.close_requested.is_connected(close):
			menu_ui.close_requested.connect(close)

func _load_default_content() -> void:
	var database := CookingDatabase.new()
	var recipes := database.create_default_recipes()
	for recipe in recipes:
		cooking_manager.register_recipe(recipe)

	var resource_loader := CookingResourceLoader.new()
	resource_loader.load_from_directories(
		"res://resources/cooking/ingredients/",
		"res://resources/cooking/recipes/"
	)
	for recipe_id in resource_loader.recipes.keys():
		var recipe = resource_loader.recipes[recipe_id]
		if recipe is CookingRecipe:
			cooking_manager.register_recipe(recipe)

func _on_station_interact() -> void:
	open()

func _on_ui_recipe_requested(recipe_id: String) -> void:
	request_recipe(recipe_id)

func _on_cooking_finished(result: CookingResult) -> void:
	if menu_ui != null:
		menu_ui.show_result(result, inventory)
		# Refresh recipe availability after inventory changes.
		var recipe_ids: Array = cooking_manager.list_recipe_ids()
		menu_ui.open_menu(recipe_ids, cooking_manager, inventory)
		menu_ui.show_result(result, inventory)
	cooking_completed.emit(result)
