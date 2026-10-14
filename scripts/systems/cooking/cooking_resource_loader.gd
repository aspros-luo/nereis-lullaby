class_name CookingResourceLoader
extends Node

## Loads cooking resources and registers them into the cooking runtime.
## This keeps recipes data-driven instead of hard-coded.

var recipes: Dictionary = {}
var ingredients: Dictionary = {}

func register_ingredient(ingredient) -> void:
	if ingredient == null:
		return
	ingredients[ingredient.id] = ingredient

func register_recipe(recipe) -> void:
	if recipe == null:
		return
	recipes[recipe.id] = recipe

func get_recipe(recipe_id: String):
	return recipes.get(recipe_id)

func get_ingredient(ingredient_id: String):
	return ingredients.get(ingredient_id)

func clear() -> void:
	recipes.clear()
	ingredients.clear()
