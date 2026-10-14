class_name CookingSession
extends RefCounted

## Cooking workflow state container.
## Keeps gameplay flow separated from UI and data resources.

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

func begin(recipe_id: String) -> void:
    current_recipe_id = recipe_id
    state = State.SELECT_RECIPE

func start_cooking() -> void:
    state = State.COOKING

func complete(result_id: String) -> void:
    result_item_id = result_id
    state = State.COMPLETE

func reset() -> void:
    state = State.IDLE
    current_recipe_id = ""
    result_item_id = ""
