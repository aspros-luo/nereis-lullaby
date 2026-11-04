class_name NpcIntentScheduler
extends RefCounted

## Minimal passive intents: NPC may talk or gift ingredients after rest.

var _gifted_once: Dictionary = {}

func on_rest(segment_index: int, inventory, location_id: String) -> Dictionary:
	## Returns empty dict if nothing happens.
	if inventory == null:
		return {}
	# Sample: after first rest, if at HOME and not yet gifted, 老婆婆 leaves herbs.
	if segment_index >= 1 and location_id == "HOME" and not bool(_gifted_once.get("婆婆_herb", false)):
		_gifted_once["婆婆_herb"] = true
		inventory.add_item("herb", 1)
		return {
			"kind": "gift_ingredient",
			"npc_label": "老婆婆",
			"message": "老婆婆把一小把洗好的草叶塞进我手里，说夜里煮水喝刚好。",
			"item_id": "herb",
			"amount": 1,
		}
	# Sample: later segment at COMMONS, a villager chats.
	if segment_index >= 2 and location_id == "COMMONS" and not bool(_gifted_once.get("commons_talk", false)):
		_gifted_once["commons_talk"] = true
		return {
			"kind": "talk",
			"npc_label": "过路的村民",
			"message": "有人笑着说丰收节快到了，让我记得去公共场帮忙尝尝新酿。",
		}
	return {}
