class_name CookingRuntime
extends Node

## Runtime facade for the cooking system.
## Keeps gameplay code independent from CookingManager implementation.

var cooking_manager: CookingManager

func initialize(manager: CookingManager) -> void:
	cooking_manager = manager

func cook(recipe_id: String, inventory: Dictionary) -> String:
	if cooking_manager == null:
		return ""

	return cooking_manager.cook(recipe_id, inventory)

func has_recipe(recipe_id: String) -> bool:
	if cooking_manager == null:
		return false

	return cooking_manager.recipes.has(recipe_id)
