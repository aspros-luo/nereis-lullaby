class_name CookingResourceLoader
extends Node

## Loads cooking resources and registers them into the cooking runtime.
## Keeps recipes data-driven instead of hard-coded.

var recipes: Dictionary = {}
var ingredients: Dictionary = {}

func register_ingredient(ingredient) -> void:
	if ingredient == null:
		return
	if "id" in ingredient and str(ingredient.id) != "":
		ingredients[str(ingredient.id)] = ingredient

func register_recipe(recipe) -> void:
	if recipe == null:
		return
	if "id" in recipe and str(recipe.id) != "":
		recipes[str(recipe.id)] = recipe

func get_recipe(recipe_id: String):
	return recipes.get(recipe_id)

func get_ingredient(ingredient_id: String):
	return ingredients.get(ingredient_id)

func clear() -> void:
	recipes.clear()
	ingredients.clear()

func load_from_directories(ingredient_dir: String, recipe_dir: String) -> void:
	_load_dir(ingredient_dir, true)
	_load_dir(recipe_dir, false)

func _load_dir(dir_path: String, as_ingredient: bool) -> void:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var full_path := dir_path.path_join(file_name)
			var res = load(full_path)
			if res == null:
				file_name = dir.get_next()
				continue

			if as_ingredient:
				register_ingredient(res)
			else:
				# Accept CookingRecipe resources, or adapt plain Resource-like data.
				if res is CookingRecipe:
					register_recipe(res)
				elif "id" in res:
					var adapted := _adapt_recipe_resource(res)
					if adapted != null:
						register_recipe(adapted)
		file_name = dir.get_next()
	dir.list_dir_end()

func _adapt_recipe_resource(res) -> CookingRecipe:
	var recipe := CookingRecipe.new()
	recipe.id = str(res.id)
	if "display_name" in res:
		recipe.display_name = str(res.display_name)
	else:
		recipe.display_name = recipe.id

	if "result_item_id" in res:
		recipe.result_item_id = str(res.result_item_id)
	elif "result" in res:
		recipe.result_item_id = str(res.result)
	else:
		recipe.result_item_id = recipe.id

	recipe.ingredients = {}
	if "ingredients" in res:
		var raw = res.ingredients
		if typeof(raw) == TYPE_DICTIONARY:
			for key in raw.keys():
				recipe.ingredients[str(key)] = int(raw[key])
		elif typeof(raw) == TYPE_ARRAY:
			for item in raw:
				recipe.ingredients[str(item)] = 1

	return recipe
