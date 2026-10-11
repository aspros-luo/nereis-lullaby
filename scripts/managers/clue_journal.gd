extends RefCounted
## 只记录玩家实际观察到的事实；不自动推断隐藏真相。

var entries: Array[Dictionary] = []
var _seen_ids: Dictionary = {}

func add_fact(
	fact_id: String,
	title: String,
	detail: String,
	day_index: int,
	slot_label: String,
	location_name: String
) -> bool:
	if _seen_ids.has(fact_id):
		return false

	_seen_ids[fact_id] = true
	entries.append({
		"id": fact_id,
		"title": title,
		"detail": detail,
		"day": day_index,
		"slot": slot_label,
		"location": location_name,
	})
	return true

func get_entries() -> Array[Dictionary]:
	return entries.duplicate(true)
