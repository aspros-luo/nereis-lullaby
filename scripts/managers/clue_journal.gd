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
	var copied_entries: Array[Dictionary] = []
	for entry in entries:
		copied_entries.append(entry.duplicate(true))
	return copied_entries


func load_entries(saved_entries: Array) -> void:
	entries.clear()
	_seen_ids.clear()
	for entry_variant in saved_entries:
		if not (entry_variant is Dictionary):
			continue
		var entry: Dictionary = entry_variant
		add_fact(
			str(entry.get("id", "")),
			str(entry.get("title", "")),
			str(entry.get("detail", "")),
			int(entry.get("day", 1)),
			str(entry.get("slot", "早晨")),
			str(entry.get("location", "未知地点"))
		)
