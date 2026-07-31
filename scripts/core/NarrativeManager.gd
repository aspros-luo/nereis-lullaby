extends Node



func _ready():

	print("NarrativeManager Ready")



func play_timeline(
	timeline_name:String
):

	print(
		"Play Timeline:",
		timeline_name
	)


	Dialogic.start(
		timeline_name
	)
