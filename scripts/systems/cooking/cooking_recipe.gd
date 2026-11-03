class_name CookingRecipe
extends Resource

## Recipe definition for cooking system.
## Steps are player-facing process beats, not a hidden progress bar.

@export var id: String
@export var display_name: String
@export var ingredients: Dictionary = {}
@export var result_item_id: String
## Ordered step texts shown during cooking (Mite-facing narration).
## Plain Array avoids typed-array assignment friction from untyped literals.
@export var steps: Array = []

func can_cook(inventory: Dictionary) -> bool:
	for ingredient_id in ingredients.keys():
		var required_count: int = int(ingredients[ingredient_id])
		if int(inventory.get(ingredient_id, 0)) < required_count:
			return false
	return true

func consume_ingredients(inventory: Dictionary) -> void:
	for ingredient_id in ingredients.keys():
		inventory[ingredient_id] = int(inventory.get(ingredient_id, 0)) - int(ingredients[ingredient_id])

func get_steps() -> Array:
	if steps.is_empty():
		return ["开始制作。", "完成。"]
	return steps

func step_count() -> int:
	return get_steps().size()
