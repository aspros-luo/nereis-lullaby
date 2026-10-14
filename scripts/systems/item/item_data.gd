class_name ItemData
extends Resource

## Base resource for all items.
## Shared by ingredients, food, quest items and future objects.

@export var id: String
@export var display_name: String
@export_multiline var description: String
@export_enum("ingredient", "food", "quest", "material") var category: String = "material"
@export var tags: Array[String] = []
