extends Node

func _ready():
	print("TavernManager Ready")

func open_tavern():
	print("Tavern Open")

func serve_normal():
	TavernSession.serve_normal_drink()


func serve_special():
	TavernSession.serve_special_drink()
