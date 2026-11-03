class_name CookingDatabase
extends Node

## Initial cooking content registry.

const CookingRecipeScript = preload("res://scripts/systems/cooking/cooking_recipe.gd")

func create_default_recipes() -> Array:
	var honey_bread = CookingRecipeScript.new()
	honey_bread.id = "honey_bread"
	honey_bread.display_name = "蜂蜜面包"
	honey_bread.ingredients = {
		"flour": 1,
		"honey": 1,
		"egg": 1
	}
	honey_bread.result_item_id = "honey_bread"
	honey_bread.result_image_path = "res://assets/cooking/results/honey_bread.png"
	honey_bread.steps = [
		"我把面粉倒进碗里，再加入蜂蜜和鸡蛋。甜味先一步钻进鼻子里。",
		"用手把面团揉到光滑。有一点黏，但并不讨厌。",
		"把面团放进炉里。外面慢慢变成金黄色，屋里也暖了起来。",
		"取出面包。热气和甜味一起散开来——可以出炉了。"
	]

	var herb_porridge = CookingRecipeScript.new()
	herb_porridge.id = "herb_porridge"
	herb_porridge.display_name = "草药粥"
	herb_porridge.ingredients = {
		"flour": 1,
		"herb": 1
	}
	herb_porridge.result_item_id = "herb_porridge"
	herb_porridge.result_image_path = "res://assets/cooking/results/herb_porridge.png"
	herb_porridge.steps = [
		"我把少量面粉化开，再放入洗净的草叶。",
		"小火慢慢熬。苦香变得柔和，锅边泛起细小的泡。",
		"盛出来时热气带着草药气味——可以喝了。"
	]

	return [honey_bread, herb_porridge]
