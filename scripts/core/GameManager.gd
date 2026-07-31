extends Node

var current_day:int = 1



func _ready():

	print(
		"Nereis Lullaby GameManager Ready"
	)



func start_game():

	current_day = 1


	call_deferred(
		"_start_first_day"
	)


func _start_first_day():

	DayManager.start_day()


func next_day():

	current_day += 1

	DayManager.start_day()
