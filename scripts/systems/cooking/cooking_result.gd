class_name CookingResult
extends RefCounted

## Result of a cooking attempt.
## Workflow fields drive UI; hidden fields are for future world reactions.

var success: bool = false
var recipe_id: String = ""
var output_item_id: String = ""
var message: String = ""
var result_image_path: String = ""

var food_id: String = ""
var quality: int = 0
var taste_score: int = 0
var hidden_resonance: int = 0
var memory_effects: Array = []
var world_effects: Array = []

static func completed(recipe: String, output: String, image_path: String = "") -> CookingResult:
	var result := CookingResult.new()
	result.success = true
	result.recipe_id = recipe
	result.output_item_id = output
	result.food_id = output
	result.result_image_path = image_path
	result.message = "Cooking completed"
	return result

static func failed(reason: String) -> CookingResult:
	var result := CookingResult.new()
	result.success = false
	result.message = reason
	return result
