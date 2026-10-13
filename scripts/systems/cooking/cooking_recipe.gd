class_name CookingRecipe
extends Resource

@export var id: String
@export var display_name: String
@export var ingredients: Array[String] = []
@export var result_item_id: String

func can_cook(available_items: Dictionary) -> bool:
	for ingredient in ingredients:
		if available_items.get(ingredient, 0) <= 0:
			return false
	return true
