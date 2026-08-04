class_name HeroNPC
extends NPCBase



func initialize(data:Dictionary):

	super.initialize(data)




func talk()->String:


	state.temporary["talk_count"] += 1



	if state.permanent.get(
		"memory",
		0
	) < 100:


		add_permanent(
			"memory",
			1
		)


		return "hero_memory_fragment"



	return "hero_normal"





func drink(type:String)->String:


	state.temporary["drink_count"] += 1


	return "hero_drink"
