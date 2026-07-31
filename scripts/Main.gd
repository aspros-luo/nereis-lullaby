extends Node


func _ready():

	print("Nereis Lullaby Start")

	call_deferred(
		"start_game"
	)



func start_game():

	GameManager.start_game()
