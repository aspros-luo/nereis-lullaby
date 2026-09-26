class_name HunterNPC
extends NPCBase


func initialize(data:Dictionary):

	super.initialize(data)


func talk()->String:

	state.temporary["talk_count"] = state.temporary.get("talk_count", 0) + 1

	print(
		npc_name,
		" talk count:",
		state.temporary["talk_count"]
	)

	return "hunter_talk"


func drink(type:String)->String:

	state.temporary["drink_count"] = state.temporary.get("drink_count", 0) + 1

	if state.temporary["drink_count"] >= 3:
		state.temporary["drunk"] = true

	print(
		npc_name,
		" drink count:",
		state.temporary["drink_count"]
	)

	return "hunter_drink"


func daily_resolve():

	if state.temporary.get("drunk", false):
		add_permanent("trust", -1)
		return

	if state.temporary.get("talk_count", 0) > 0:
		add_permanent("trust", 1)
