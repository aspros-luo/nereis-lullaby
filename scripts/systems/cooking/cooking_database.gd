class_name CookingDatabase
extends Node

var recipes: Dictionary = {}

func add(recipe: CookingRecipe) -> void:
	recipes[recipe.id] = recipe

func get_recipe(recipe_id: String) -> CookingRecipe:
	return recipes.get(recipe_id)

func load_default_recipes() -> void:
	var honey_bread := CookingRecipe.new()
	honey_bread.id = "honey_bread"
	honey_bread.display_name = "Honey Bread"
	honey_bread.ingredients = ["flour", "honey", "egg"]
	honey_bread.result_item_id = "honey_bread"
	add(honey_bread)
