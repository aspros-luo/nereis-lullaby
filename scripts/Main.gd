extends Node

@onready var main_menu:Control = $MainMenu

func _ready():
	print("Nereis Lullaby Start")
	if main_menu:
		main_menu.show()
