class_name SaveManager
extends RefCounted
## Multi-slot JSON save for the daily shell demo.
## Slots: 0, 1, 2  →  user://saves/slot_0.json etc.

const SLOT_COUNT: int = 3
const SAVE_DIR: String = "user://saves"
const VERSION: int = 1

## Set by title screen before changing to main scene; main.gd consumes and clears.
static var pending_load_slot: int = -1

static func _slot_path(slot: int) -> String:
	return "%s/slot_%d.json" % [SAVE_DIR, slot]

static func ensure_dir() -> void:
	var dir := DirAccess.open("user://")
	if dir == null:
		return
	if not dir.dir_exists("saves"):
		dir.make_dir("saves")

static func has_save(slot: int) -> bool:
	if slot < 0 or slot >= SLOT_COUNT:
		return false
	return FileAccess.file_exists(_slot_path(slot))

static func delete_save(slot: int) -> bool:
	if not has_save(slot):
		return false
	var err := DirAccess.remove_absolute(_slot_path(slot))
	return err == OK

static func get_slot_meta(slot: int) -> Dictionary:
	if not has_save(slot):
		return {"empty": true, "slot": slot}
	var file := FileAccess.open(_slot_path(slot), FileAccess.READ)
	if file == null:
		return {"empty": true, "slot": slot, "error": true}
	var text := file.get_as_text()
	file.close()
	var data = JSON.parse_string(text)
	if not (data is Dictionary):
		return {"empty": true, "slot": slot, "error": true}
	var meta: Dictionary = data.get("meta", {})
	return {
		"empty": false,
		"slot": slot,
		"day": int(meta.get("day_index", 1)),
		"segment": int(meta.get("segment_index", 0)),
		"location": str(meta.get("location", "HOME")),
		"festival_done": bool(meta.get("festival_done", false)),
		"timestamp": str(meta.get("timestamp", "")),
		"play_seconds": int(meta.get("play_seconds", 0)),
	}

static func list_slots() -> Array:
	var out: Array = []
	for i in range(SLOT_COUNT):
		out.append(get_slot_meta(i))
	return out

static func save_game(slot: int, payload: Dictionary) -> bool:
	if slot < 0 or slot >= SLOT_COUNT:
		return false
	ensure_dir()
	var data := {
		"version": VERSION,
		"meta": {
			"day_index": int(payload.get("day_index", 1)),
			"segment_index": int(payload.get("segment_index", 0)),
			"location": str(payload.get("current_location", "HOME")),
			"festival_done": bool(payload.get("festival_done", false)),
			"timestamp": Time.get_datetime_string_from_system(false, true),
			"play_seconds": int(payload.get("play_seconds", 0)),
		},
		"payload": payload,
	}
	var json_text := JSON.stringify(data, "\t")
	var file := FileAccess.open(_slot_path(slot), FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: cannot open %s for write" % _slot_path(slot))
		return false
	file.store_string(json_text)
	file.close()
	return true

static func load_game(slot: int) -> Dictionary:
	if not has_save(slot):
		return {}
	var file := FileAccess.open(_slot_path(slot), FileAccess.READ)
	if file == null:
		return {}
	var text := file.get_as_text()
	file.close()
	var data = JSON.parse_string(text)
	if not (data is Dictionary):
		return {}
	if int(data.get("version", 0)) != VERSION:
		push_warning("SaveManager: version mismatch")
	var payload = data.get("payload", {})
	if not (payload is Dictionary):
		return {}
	return payload
