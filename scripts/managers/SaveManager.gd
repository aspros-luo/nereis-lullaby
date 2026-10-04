extends Node

const SAVE_DIR := "user://saves"
const SAVE_PATH := SAVE_DIR + "/slot_%d.json"
const META_PATH := SAVE_DIR + "/meta.json"

signal save_completed(slot:int)
signal load_completed(slot:int)
signal save_failed(message:String)
signal load_failed(message:String)

func _ready():
	var root_dir := DirAccess.open("user://")
	if root_dir and not root_dir.dir_exists("saves"):
		root_dir.make_dir("saves")
	print("SaveManager Ready")

func has_save(slot:int = 0)->bool:
	return FileAccess.file_exists(SAVE_PATH % slot)

func has_completed_run()->bool:
	return bool(load_meta().get("completed_run", false))

func get_discovered_endings()->Array[String]:
	var raw:Array = load_meta().get("discovered_endings", [])
	var result:Array[String] = []
	for ending_id in raw:
		var value := str(ending_id)
		if not value.is_empty() and not result.has(value):
			result.append(value)
	return result

func has_discovered_ending(ending_id:String)->bool:
	return get_discovered_endings().has(ending_id)

func has_true_ending_unlocked()->bool:
	return get_discovered_endings().size() >= 3

func get_meta_value(key:String, default_value = null):
	return load_meta().get(key, default_value)

func mark_run_completed(ending_id:String):
	var meta := load_meta()
	meta["completed_run"] = true
	meta["last_ending"] = ending_id
	meta["unlocked_new_game_plus"] = true
	var endings:Array = []
	var existing:Array = meta.get("discovered_endings", [])
	for value in existing:
		var id := str(value)
		if not id.is_empty() and not endings.has(id):
			endings.append(id)
	if not ending_id.is_empty() and not endings.has(ending_id):
		endings.append(ending_id)
	meta["discovered_endings"] = endings
	meta["run_count"] = int(meta.get("run_count", 0)) + 1
	meta["timestamp"] = Time.get_datetime_string_from_system(true)
	_write_json(META_PATH, meta)

func save_game(slot:int = 0)->bool:
	if NarrativeManager.is_playing:
		save_failed.emit("剧情播放中，暂时不能保存")
		return false

	if StoryManager.has_pending_npc_choices() or not StoryManager.get_phase_choices("MORNING").is_empty():
		save_failed.emit("剧情选择尚未完成")
		return false

	var data := {
		"version": 2,
		"saved_at": Time.get_datetime_string_from_system(true),
		"day": GameManager.current_day,
		"run_cycle": GameManager.run_cycle,
		"ng_plus": GameManager.is_new_game_plus,
		"scene": get_tree().current_scene.scene_file_path if get_tree().current_scene else "",
		"story_flags": StoryState.flags.duplicate(true),
		"world_values": WorldState.values.duplicate(true),
		"action": int(ActionManager.today_action),
		"npcs": _capture_npcs()
	}

	if not _write_json(SAVE_PATH % slot, data):
		save_failed.emit("保存失败")
		return false

	save_completed.emit(slot)
	return true

func load_game(slot:int = 0)->bool:
	if not has_save(slot):
		load_failed.emit("没有可读取的存档")
		return false

	var data := _read_json(SAVE_PATH % slot)
	if data.is_empty():
		load_failed.emit("存档数据损坏")
		return false

	_apply_state(data)
	load_completed.emit(slot)
	return true

func delete_save(slot:int = 0)->void:
	var path := SAVE_PATH % slot
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)

func reset_all()->void:
	for slot in range(3):
		delete_save(slot)

func load_meta()->Dictionary:
	if not FileAccess.file_exists(META_PATH):
		return {}
	return _read_json(META_PATH)

func _apply_state(data:Dictionary)->void:
	StoryState.reset()
	WorldState.reset()
	ResourceManager.reset()
	ActionManager.reset()
	TavernSession.reset_session()
	NPCManager.reset_runtime_state()
	StoryManager.reset_runtime_state()

	GameManager.current_day = int(data.get("day", 1))
	GameManager.run_cycle = max(1, int(data.get("run_cycle", 1)))
	GameManager.is_new_game_plus = bool(data.get("ng_plus", false))
	DayManager.current_day = GameManager.current_day
	DayManager.flow = DayManager.DayFlow.IDLE
	DayManager.scene_transitioning = false

	for key in (data.get("story_flags", {}) as Dictionary):
		StoryState.set_flag(str(key), (data.get("story_flags", {}) as Dictionary)[key])

	for key in (data.get("world_values", {}) as Dictionary):
		WorldState.set_value(str(key), (data.get("world_values", {}) as Dictionary)[key])

	ActionManager.today_action = int(data.get("action", 0))
	_apply_npcs(data.get("npcs", {}))

func _capture_npcs()->Dictionary:
	var result := {}
	for npc_id in ["hunter", "merchant", "hero"]:
		var npc = NPCManager.get_npc(npc_id)
		if npc == null:
			continue
		result[npc_id] = {
			"permanent": npc.state.permanent.duplicate(true),
			"temporary": npc.state.temporary.duplicate(true)
		}
	return result

func _apply_npcs(data:Dictionary)->void:
	for npc_id in data.keys():
		var npc = NPCManager.get_npc(str(npc_id))
		if npc == null:
			continue
		var npc_data:Dictionary = data[npc_id]
		for key in (npc_data.get("permanent", {}) as Dictionary):
			npc.set_permanent(str(key), (npc_data.get("permanent", {}) as Dictionary)[key])
		for key in (npc_data.get("temporary", {}) as Dictionary):
			npc.set_temporary(str(key), (npc_data.get("temporary", {}) as Dictionary)[key])

	call_deferred("_resume_loaded_scene")

func _resume_loaded_scene()->void:
	if GameManager.current_day < 1:
		GameManager.current_day = 1
	DayManager.start_day()

func _write_json(path:String, data:Dictionary)->bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	return true

func _read_json(path:String)->Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var value = JSON.parse_string(file.get_as_text())
	file.close()
	return value if value is Dictionary else {}
