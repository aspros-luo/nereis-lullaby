class_name CookingResult
extends RefCounted

## Result generated after cooking process.
## Hidden values are kept internal for world reactions.

var food_id: String = ""
var quality: int = 0
var taste_score: int = 0

# Hidden system values.
var hidden_resonance: int = 0
var memory_effects: Array[String] = []
var world_effects: Array[String] = []
