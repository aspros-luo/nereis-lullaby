class_name CookingStation
extends Node2D

## Gameplay interaction point for kitchens.
## Visual assets should be attached through scenes, not generated in code.

signal cooking_requested

@export var station_id: String = "kitchen_main"

func interact() -> void:
    cooking_requested.emit()
