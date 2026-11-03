class_name CookingMenuController
extends Node

signal recipe_selected(recipe_id)
signal cooking_requested(recipe_id)

var available_recipes: Array = []

func set_recipes(recipes: Array) -> void:
	available_recipes.clear()
	for recipe_id in recipes:
		available_recipes.append(str(recipe_id))

func select_recipe(recipe_id: String) -> void:
	if recipe_id in available_recipes:
		recipe_selected.emit(recipe_id)

func request_cooking(recipe_id: String) -> void:
	if recipe_id in available_recipes:
		cooking_requested.emit(recipe_id)
