class_name CookingSession
extends RefCounted

## Cooking workflow state container.
## Supports multi-step process without putting logic in UI nodes.

enum State {
	IDLE,
	SELECT_RECIPE,
	CHECK_INGREDIENT,
	COOKING,
	COMPLETE
}

var state: State = State.IDLE
var current_recipe_id: String = ""
var result_item_id: String = ""
var step_index: int = 0
var steps: Array[String] = []

func begin(recipe_id: String, recipe_steps: Array[String] = []) -> void:
	current_recipe_id = recipe_id
	steps = recipe_steps.duplicate()
	step_index = 0
	result_item_id = ""
	state = State.SELECT_RECIPE

func mark_ingredients_checked() -> void:
	state = State.CHECK_INGREDIENT

func start_cooking() -> void:
	state = State.COOKING
	if steps.is_empty():
		steps = ["开始制作。", "完成。"]
	step_index = 0

func current_step_text() -> String:
	if step_index < 0 or step_index >= steps.size():
		return ""
	return steps[step_index]

func step_progress_label() -> String:
	if steps.is_empty():
		return ""
	return "步骤 %d / %d" % [step_index + 1, steps.size()]

func is_on_last_step() -> bool:
	return not steps.is_empty() and step_index >= steps.size() - 1

func advance_step() -> bool:
	if state != State.COOKING:
		return false
	if is_on_last_step():
		return false
	step_index += 1
	return true

func complete(result_id: String) -> void:
	result_item_id = result_id
	state = State.COMPLETE

func reset() -> void:
	state = State.IDLE
	current_recipe_id = ""
	result_item_id = ""
	step_index = 0
	steps.clear()

func is_busy() -> bool:
	return state == State.COOKING or state == State.SELECT_RECIPE or state == State.CHECK_INGREDIENT
