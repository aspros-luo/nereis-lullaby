class_name NPCFactory
extends Node



func create_npc(
	data:Dictionary
)->NPCBase:


	var npc:NPCBase



	match data["class"]:


		"HunterNPC":

			npc = HunterNPC.new()



		"MerchantNPC":

			npc = MerchantNPC.new()



		"HeroNPC":

			npc = HeroNPC.new()



		_:

			npc = NPCBase.new()



	npc.initialize(
		data
	)


	return npc
