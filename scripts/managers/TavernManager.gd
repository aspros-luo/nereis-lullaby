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



# Dialogic / narrative compatibility API.
# Story timelines should call TavernManager rather than the session directly.


func serve_normal():

	return TavernSession.serve_normal_drink()



func serve_special():

	return TavernSession.serve_special_drink()
