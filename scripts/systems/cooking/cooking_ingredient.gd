class_name CookingIngredient
extends Resource

@export var id: String
@export var display_name: String

func _init(ingredient_id: String = "", name: String = ""):
	id = ingredient_id
	display_name = name
