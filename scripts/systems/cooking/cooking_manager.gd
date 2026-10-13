class_name CookingManager
extends Node

var recipes: Dictionary = {}

func register_recipe(recipe: CookingRecipe) -> void:
	recipes[recipe.id] = recipe

func can_cook(recipe_id: String, inventory: Dictionary) -> bool:
	if not recipes.has(recipe_id):
		return false
	return recipes[recipe_id].can_cook(inventory)

func cook(recipe_id: String, inventory: Dictionary) -> String:
	if not can_cook(recipe_id, inventory):
		return ""

	var recipe: CookingRecipe = recipes[recipe_id]
	for ingredient in recipe.ingredients:
		inventory[ingredient] -= 1

	return recipe.result_item_id
