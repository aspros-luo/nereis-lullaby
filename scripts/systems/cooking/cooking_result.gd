class_name CookingResult
extends RefCounted

var success: bool = false
var recipe_id: String = ""
var output_item_id: String = ""
var message: String = ""

static func completed(recipe: String, output: String) -> CookingResult:
	var result := CookingResult.new()
	result.success = true
	result.recipe_id = recipe
	result.output_item_id = output
	result.message = "Cooking completed"
	return result

static func failed(reason: String) -> CookingResult:
	var result := CookingResult.new()
	result.success = false
	result.message = reason
	return result
