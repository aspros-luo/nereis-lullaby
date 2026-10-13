class_name RecipeData
extends Resource

## Cooking recipe definition.
## Recipes describe process, not simple item crafting.

@export var id: String
@export var display_name: String
@export var ingredient_ids: Array[String] = []
@export var cooking_steps: Array[String] = []
@export var result_food_id: String
