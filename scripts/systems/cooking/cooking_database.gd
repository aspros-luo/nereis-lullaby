class_name CookingDatabase
extends Node

## Initial cooking content registry.

func create_default_recipes() -> Array[CookingRecipe]:
	var honey_bread := CookingRecipe.new()
	honey_bread.id = "honey_bread"
	honey_bread.display_name = "蜂蜜面包"
	honey_bread.ingredients = {
		"flour": 1,
		"honey": 1,
		"egg": 1
	}
	honey_bread.result_item_id = "honey_bread"
	honey_bread.steps = [
		"我把面粉倒进碗里，再加入蜂蜜和鸡蛋。甜味先一步钻进鼻子里。",
		"用手把面团揉到光滑。有一点黏，但并不讨厌。",
		"把面团放进炉里。外面慢慢变成金黄色，屋里也暖了起来。",
		"取出面包。热气和甜味一起散开来——可以出炉了。"
	]

	return [honey_bread]
