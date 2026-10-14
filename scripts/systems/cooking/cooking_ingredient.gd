class_name CookingIngredient
extends Resource

## Cooking ingredient data model.
## Used by recipes and inventory integration later.

@export var id: String
@export var display_name: String
@export var description: String = ""

func _init(ingredient_id: String = "", name: String = "") -> void:
	id = ingredient_id
	display_name = name
