extends Node



func _ready():

	print(
		"TavernManager Ready"
	)



func open_tavern():


	print(
		"Tavern Open"
	)


	TavernSession.start_session()
