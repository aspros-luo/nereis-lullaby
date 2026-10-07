class_name HeroNPC
extends NPCBase


func initialize(data:Dictionary):

	super.initialize(data)



func talk()->String:

	state.temporary["talk_count"] = int(
		state.temporary.get(
			"talk_count",
			0
		)
	) + 1

	if state.permanent.get(
		"memory",
		0
	) < 100:

		state.permanent["memory"] = int(
			state.permanent.get(
				"memory",
				0
			)
		) + 1

		WorldState.set_value(
			"hero_memory",
			state.permanent["memory"]
		)

		return "hero_memory_fragment"

	return "hero_normal"



func drink(type:String)->String:

	state.temporary["drink_count"] = int(
		state.temporary.get(
			"drink_count",
			0
		)
	) + 1

	return "hero_drink"
