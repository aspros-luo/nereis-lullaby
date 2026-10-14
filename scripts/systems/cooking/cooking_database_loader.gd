class_name CookingDatabaseLoader
extends RefCounted

## Loads cooking resources into runtime registry.
## Resource driven entry point for future kitchen gameplay.

var loader: CookingResourceLoader

func _init():
	loader = CookingResourceLoader.new()

func register_resources(ingredients: Array, recipes: Array) -> void:
	for ingredient in ingredients:
		loader.register_ingredient(ingredient)

	for recipe in recipes:
		loader.register_recipe(recipe)

func get_recipe(recipe_id: String):
	return loader.get_recipe(recipe_id)

func get_ingredient(ingredient_id: String):
	return loader.get_ingredient(ingredient_id)
