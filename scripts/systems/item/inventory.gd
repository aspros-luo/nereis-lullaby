class_name Inventory
extends Node

## Lightweight inventory core.
## Stores item id and quantity. Presentation is handled separately.

var items: Dictionary = {}

func add_item(item_id: String, amount: int = 1) -> void:
	items[item_id] = int(items.get(item_id, 0)) + amount

func remove_item(item_id: String, amount: int = 1) -> bool:
	if not has_item(item_id, amount):
		return false
	items[item_id] = int(items.get(item_id, 0)) - amount
	return true

func has_item(item_id: String, amount: int = 1) -> bool:
	return int(items.get(item_id, 0)) >= amount

func get_count(item_id: String) -> int:
	return int(items.get(item_id, 0))
