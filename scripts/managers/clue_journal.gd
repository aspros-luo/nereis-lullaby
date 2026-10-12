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
	if fact_id.strip_edges().is_empty() or _seen_ids.has(fact_id):
		return false
	if title.strip_edges().is_empty() or detail.strip_edges().is_empty():
		return false
	if day_index < 1 or day_index > 7 or slot_label.strip_edges().is_empty() or location_name.strip_edges().is_empty():
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


## Validate into temporary collections first; invalid saves must not partially replace the journal.
func load_entries(saved_entries: Array) -> bool:
	var restored_entries: Array[Dictionary] = []
	var restored_ids: Dictionary = {}
	for entry_variant in saved_entries:
		if not (entry_variant is Dictionary):
			return false
		var entry: Dictionary = entry_variant
		var fact_id_value: Variant = entry.get("id", null)
		var title_value: Variant = entry.get("title", null)
		var detail_value: Variant = entry.get("detail", null)
		var day_value: Variant = entry.get("day", null)
		var slot_value: Variant = entry.get("slot", null)
		var location_value: Variant = entry.get("location", null)
		if not (fact_id_value is String) or not (title_value is String) or not (detail_value is String):
			return false
		if not (day_value is int) or not (slot_value is String) or not (location_value is String):
			return false
		var fact_id: String = fact_id_value
		var title: String = title_value
		var detail: String = detail_value
		var day: int = int(day_value)
		var slot: String = slot_value
		var location: String = location_value
		if fact_id.strip_edges().is_empty() or restored_ids.has(fact_id):
			return false
		if title.strip_edges().is_empty() or detail.strip_edges().is_empty():
			return false
		if day < 1 or day > 7 or slot.strip_edges().is_empty() or location.strip_edges().is_empty():
			return false
		restored_ids[fact_id] = true
		restored_entries.append({
			"id": fact_id,
			"title": title,
			"detail": detail,
			"day": day,
			"slot": slot,
			"location": location,
		})
	entries = restored_entries
	_seen_ids = restored_ids
	return true
