extends RefCounted
## 核心状态：时间、行动、关系、调查与世界阶段彼此分离。

const SLOT_KEYS: Array[String] = ["morning", "daytime", "evening"]
const SLOT_LABELS: Array[String] = ["早晨", "白天", "傍晚"]
const FINAL_DAY: int = 7
const POST_ANOMALY_LOCATIONS: Array[String] = [
	"FOREST", "GROVE", "PATH", "COMMONS", "SHRINE", "HOME", "CLINIC"
]

var day_index: int = 1
var slot_index: int = 0
var current_location: String = "HOME"
var action_used_this_slot: bool = false

var relationship_state: Dictionary = {
	"caregiver": 0,
	"worship_leader": 0,
	"doctor": 0,
}
var investigation_state: Dictionary = {
	"observed_fact_ids": [],
	"visited_after_anomaly": [],
}
var world_state: Dictionary = {
	"phase": "ordinary",
	"flags": {},
}
var action_history: Array[Dictionary] = []

func get_slot_key() -> String:
	return SLOT_KEYS[slot_index]

func get_slot_label() -> String:
	return SLOT_LABELS[slot_index]

func can_take_action() -> bool:
	if world_state["phase"] == "after_week":
		return true
	return not action_used_this_slot and world_state["phase"] == "ordinary"

func take_action(action_id: String, description: String) -> bool:
	if not can_take_action():
		return false
	if world_state["phase"] == "ordinary":
		action_used_this_slot = true
	action_history.append({
		"day": day_index,
		"slot": get_slot_label(),
		"location": current_location,
		"id": action_id,
		"description": description,
	})
	return true

func increase_relationship(npc_id: String, amount: int = 1) -> void:
	if not relationship_state.has(npc_id):
		return
	relationship_state[npc_id] = clampi(int(relationship_state[npc_id]) + amount, -5, 10)

func register_fact(fact_id: String) -> void:
	var facts: Array = investigation_state["observed_fact_ids"]
	if not facts.has(fact_id):
		facts.append(fact_id)
		investigation_state["observed_fact_ids"] = facts

func mark_post_anomaly_visit(location_id: String) -> void:
	if world_state["phase"] != "after_week" or not POST_ANOMALY_LOCATIONS.has(location_id):
		return
	var visited: Array = investigation_state["visited_after_anomaly"]
	if not visited.has(location_id):
		visited.append(location_id)
		investigation_state["visited_after_anomaly"] = visited

func advance_time() -> void:
	if world_state["phase"] != "ordinary":
		return

	action_used_this_slot = false
	if day_index == FINAL_DAY and slot_index == SLOT_KEYS.size() - 1:
		world_state["phase"] = "after_week"
		world_state["flags"]["village_anomaly"] = true
		return

	slot_index += 1
	if slot_index >= SLOT_KEYS.size():
		slot_index = 0
		day_index += 1

func can_complete_demo() -> bool:
	if world_state["phase"] != "after_week":
		return false
	return investigation_state["visited_after_anomaly"].size() >= 3

func complete_demo() -> bool:
	if not can_complete_demo():
		return false
	world_state["phase"] = "demo_complete"
	return true


func to_save_data() -> Dictionary:
	return {
		"day_index": day_index,
		"slot_index": slot_index,
		"current_location": current_location,
		"action_used_this_slot": action_used_this_slot,
		"relationship_state": relationship_state.duplicate(true),
		"investigation_state": investigation_state.duplicate(true),
		"world_state": world_state.duplicate(true),
		"action_history": action_history.duplicate(true),
	}

func load_save_data(data: Dictionary) -> bool:
	var saved_day: int = int(data.get("day_index", 0))
	var saved_slot: int = int(data.get("slot_index", -1))
	var saved_world_value: Variant = data.get("world_state", {})
	var saved_relationships_value: Variant = data.get("relationship_state", {})
	var saved_investigation_value: Variant = data.get("investigation_state", {})
	var saved_history_value: Variant = data.get("action_history", [])
	var saved_action_used_value: Variant = data.get("action_used_this_slot", false)
	if not (saved_action_used_value is bool):
		return false
	if not (saved_world_value is Dictionary):
		return false
	if not (saved_relationships_value is Dictionary):
		return false
	if not (saved_investigation_value is Dictionary):
		return false
	if not (saved_history_value is Array):
		return false

	var saved_world: Dictionary = saved_world_value
	var saved_relationships: Dictionary = saved_relationships_value
	var saved_investigation: Dictionary = saved_investigation_value
	var saved_history: Array = saved_history_value
	var saved_phase: String = str(saved_world.get("phase", ""))
	var saved_location: String = str(data.get("current_location", "HOME"))
	var saved_flags_value: Variant = saved_world.get("flags", {})
	var saved_fact_ids_value: Variant = saved_investigation.get("observed_fact_ids", [])
	var saved_visits_value: Variant = saved_investigation.get("visited_after_anomaly", [])
	if saved_day < 1 or saved_day > FINAL_DAY:
		return false
	if saved_slot < 0 or saved_slot >= SLOT_KEYS.size():
		return false
	if not ["ordinary", "after_week", "demo_complete"].has(saved_phase):
		return false
	if saved_phase != "ordinary" and (saved_day != FINAL_DAY or saved_slot != SLOT_KEYS.size() - 1):
		return false
	if not POST_ANOMALY_LOCATIONS.has(saved_location):
		return false
	if not (saved_flags_value is Dictionary):
		return false
	if not (saved_fact_ids_value is Array) or not (saved_visits_value is Array):
		return false

	var saved_flags: Dictionary = saved_flags_value
	if saved_flags.has("post_anomaly_talked"):
		if not (saved_flags["post_anomaly_talked"] is Dictionary):
			return false
		for npc_id in saved_flags["post_anomaly_talked"]:
			if not ["caregiver", "worship_leader", "doctor"].has(str(npc_id)):
				return false
			if not (saved_flags["post_anomaly_talked"][npc_id] is bool) or not saved_flags["post_anomaly_talked"][npc_id]:
				return false
	if saved_flags.has("personal_moments_seen"):
		if not (saved_flags["personal_moments_seen"] is Dictionary):
			return false
		for moment_id in saved_flags["personal_moments_seen"]:
			if not ["caregiver_memory", "worship_ribbon", "doctor_labels"].has(str(moment_id)):
				return false
			if not (saved_flags["personal_moments_seen"][moment_id] is bool) or not saved_flags["personal_moments_seen"][moment_id]:
				return false
	if saved_flags.has("npc_last_autonomous_actions"):
		if not (saved_flags["npc_last_autonomous_actions"] is Dictionary):
			return false
		for npc_id in saved_flags["npc_last_autonomous_actions"]:
			var action_value: Variant = saved_flags["npc_last_autonomous_actions"][npc_id]
			if not ["caregiver", "worship_leader", "doctor"].has(str(npc_id)) or not (action_value is Dictionary):
				return false
			var saved_action: Dictionary = action_value
			if str(saved_action.get("npc_id", "")) != str(npc_id) or str(saved_action.get("id", "")).strip_edges().is_empty():
				return false
			if not (saved_action.get("tick", null) is int) or int(saved_action["tick"]) < 0:
				return false
			if not (saved_action.get("day", null) is int) or int(saved_action["day"]) < 1 or int(saved_action["day"]) > FINAL_DAY:
				return false
			if not (saved_action.get("slot", null) is int) or int(saved_action["slot"]) < 0 or int(saved_action["slot"]) >= SLOT_KEYS.size():
				return false
	var anomaly_flag: Variant = saved_flags.get("village_anomaly", false)
	if not (anomaly_flag is bool):
		return false
	if saved_phase != "ordinary" and not anomaly_flag:
		return false
	if saved_phase == "ordinary" and anomaly_flag:
		return false
	var validated_fact_ids: Array[String] = []
	for raw_fact_id in saved_fact_ids_value:
		if not (raw_fact_id is String) or raw_fact_id.strip_edges().is_empty() or validated_fact_ids.has(raw_fact_id):
			return false
		validated_fact_ids.append(raw_fact_id)
	var validated_visits: Array[String] = []
	for visited_location in saved_visits_value:
		if not (visited_location is String) or not POST_ANOMALY_LOCATIONS.has(visited_location):
			return false
		if validated_visits.has(visited_location):
			return false
		validated_visits.append(visited_location)
	if saved_phase == "demo_complete" and validated_visits.size() < 3:
		return false
	var restored_relationships: Dictionary = {}
	for npc_id in relationship_state.keys():
		restored_relationships[npc_id] = clampi(int(saved_relationships.get(npc_id, 0)), -5, 10)
	var restored_history: Array[Dictionary] = []
	for entry in saved_history:
		if not (entry is Dictionary):
			return false
		if int(entry.get("day", 0)) < 1 or int(entry.get("day", 0)) > FINAL_DAY:
			return false
		if not SLOT_LABELS.has(str(entry.get("slot", ""))):
			return false
		if not POST_ANOMALY_LOCATIONS.has(str(entry.get("location", ""))):
			return false
		if str(entry.get("id", "")).strip_edges().is_empty() or str(entry.get("description", "")).strip_edges().is_empty():
			return false
		restored_history.append(entry.duplicate(true))

	day_index = saved_day
	slot_index = saved_slot
	current_location = saved_location
	action_used_this_slot = saved_action_used_value
	relationship_state = restored_relationships
	investigation_state = {
		"observed_fact_ids": validated_fact_ids,
		"visited_after_anomaly": saved_visits_value.duplicate(true),
	}
	world_state = {
		"phase": saved_phase,
		"flags": saved_flags.duplicate(true),
	}
	action_history = restored_history
	return true
