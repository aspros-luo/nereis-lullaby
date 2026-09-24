class_name HeroNPC
extends NPCBase



func initialize(data:Dictionary):

	super.initialize(data)




func talk()->String:


	state.temporary["talk_count"] += 1


	if state.permanent.has("memory"):


		if state.permanent["memory"] < 100:


			state.permanent["memory"] += 1


			return "hero_memory_fragment"



	return "hero_normal"





func drink(type:String)->String:


	state.temporary["drink_count"] += 1


	return "hero_drink"


	state.temporary["drink_count"] += 1


	return "hero_drink"
