class_name CookingDebugTest
extends Node

func run_test() -> void:
	var manager := CookingManager.new()
	var recipe := CookingRecipe.new()
	recipe.id = "honey_bread"
	recipe.ingredients = ["flour", "honey", "egg"]
	recipe.result_item_id = "honey_bread"
	manager.register_recipe(recipe)

	var inventory := {
		"flour": 1,
		"honey": 1,
		"egg": 1
	}

	var result := manager.cook("honey_bread", inventory)
	print("Cooking test result: ", result)
	print("Remaining inventory: ", inventory)
