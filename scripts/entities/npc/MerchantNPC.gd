class_name MerchantNPC
extends NPCBase



func initialize(data:Dictionary):

	super.initialize(data)



func talk()->String:


	state.temporary["talk_count"] += 1


	return "merchant_talk"




func drink(type:String)->String:


	state.temporary["drink_count"] += 1


	return "merchant_drink"




func trade()->String:


	return "merchant_trade"
