class_name IngredientData
extends Resource

## Cooking ingredient definition.
## Hidden influence values are intentionally not exposed to players.

@export var id: String
@export var display_name: String
@export var tags: Array[String] = []
@export var quality: int = 1
@export var origin: String = ""

# Used internally for future world reactions.
@export var hidden_affinity: int = 0
