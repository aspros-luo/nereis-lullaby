extends Node


var opening_timeline_played:Dictionary = {}



func _ready():

	print(
		"TavernManager Ready"
	)



func open_tavern():

	print(
		"Tavern Open"
	)

	TavernSession.start_session()

	_play_day_opening()



func _play_day_opening():

	var day = GameManager.current_day

	if opening_timeline_played.has(day):

		return

	opening_timeline_played[day] = true

	if day == 1:

		NarrativeManager.play_timeline(
			"day01_tavern_start"
		)



# Dialogic narrative API.
# The first-day timeline uses these methods for the opening guest.


func serve_normal():

	var result = TavernSession.serve_normal_drink()

	TavernSession.next_guest()

	return result



func serve_special():

	var result = TavernSession.serve_special_drink()

	TavernSession.next_guest()

	return result
