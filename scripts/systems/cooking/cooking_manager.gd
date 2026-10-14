class_name CookingManager
extends Node

## Core cooking service.
## Inventory is passed in externally to avoid coupling at this stage.

var recipes: Dictionary = {}

func register_recipe(recipe: CookingRecipe) -> void:
	if recipe == null:
		return
	recipes[recipe.id] = recipe

func get_recipe(recipe_id: String) -> CookingRecipe:
	return recipes.get(recipe_id)

func cook(recipe_id: String, inventory: Dictionary) -> String:
	var recipe := get_recipe(recipe_id)
	if recipe == null:
		return ""

	if not recipe.can_cook(inventory):
		return ""

	recipe.consume_ingredients(inventory)
	return recipe.result_item_id
