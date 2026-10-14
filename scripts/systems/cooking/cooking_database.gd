class_name CookingDatabase
extends Node

## Initial cooking content registry.

func create_default_recipes() -> Array[CookingRecipe]:
	var honey_bread := CookingRecipe.new()
	honey_bread.id = "honey_bread"
	honey_bread.display_name = "Honey Bread"
	honey_bread.ingredients = {
		"flour": 1,
		"honey": 1,
		"egg": 1
	}
	honey_bread.result_item_id = "honey_bread"

	return [honey_bread]
