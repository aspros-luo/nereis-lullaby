class_name CookingManager
extends Node

## Core cooking service.
## Inventory is passed in externally to avoid coupling at this stage.

var recipes: Dictionary = {}

func register_recipe(recipe) -> void:
	if recipe == null:
		return
	if not ("id" in recipe):
		return
	if str(recipe.id) == "":
		return
	recipes[str(recipe.id)] = recipe

func get_recipe(recipe_id: String):
	return recipes.get(recipe_id)

func list_recipe_ids() -> Array:
	var ids: Array = []
	for key in recipes.keys():
		ids.append(str(key))
	return ids

func cook(recipe_id: String, inventory: Dictionary) -> String:
	var recipe = get_recipe(recipe_id)
	if recipe == null:
		return ""

	if not recipe.can_cook(inventory):
		return ""

	recipe.consume_ingredients(inventory)
	return str(recipe.result_item_id)
