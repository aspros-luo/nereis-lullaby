extends RefCounted
## 核心状态：时间、行动、关系、调查与世界阶段彼此分离。

const SLOT_KEYS: Array[String] = ["morning", "daytime", "evening"]
const SLOT_LABELS: Array[String] = ["早晨", "白天", "傍晚"]
const FINAL_DAY: int = 7

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
	if world_state["phase"] != "after_week":
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

func complete_demo() -> void:
	if world_state["phase"] == "after_week":
		world_state["phase"] = "demo_complete"


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
	if not (saved_world_value is Dictionary):
		return false
	var saved_world_input: Dictionary = saved_world_value
	var saved_phase: String = str(saved_world_input.get("phase", ""))
	if saved_day < 1 or saved_day > FINAL_DAY:
		return false
	if saved_slot < 0 or saved_slot >= SLOT_KEYS.size():
		return false
	if not [ "ordinary", "after_week", "demo_complete" ].has(saved_phase):
		return false

	day_index = saved_day
	slot_index = saved_slot
	var saved_location: String = str(data.get("current_location", "HOME"))
	current_location = saved_location
	action_used_this_slot = bool(data.get("action_used_this_slot", false))

	var saved_relationships_value: Variant = data.get("relationship_state", {})
	if not (saved_relationships_value is Dictionary):
		return false
	var saved_relationships: Dictionary = saved_relationships_value
	var saved_investigation_value: Variant = data.get("investigation_state", {})
	if not (saved_investigation_value is Dictionary):
		return false
	var saved_investigation: Dictionary = saved_investigation_value
	var saved_fact_ids_value: Variant = saved_investigation.get("observed_fact_ids", [])
	var saved_visits_value: Variant = saved_investigation.get("visited_after_anomaly", [])
	if not (saved_fact_ids_value is Array) or not (saved_visits_value is Array):
		return false
	for npc_id in relationship_state.keys():
		relationship_state[npc_id] = clampi(int(saved_relationships.get(npc_id, 0)), -5, 10)

	var saved_fact_ids: Array = saved_fact_ids_value
	var saved_visits: Array = saved_visits_value
	investigation_state = {
		"observed_fact_ids": saved_fact_ids.duplicate(true),
		"visited_after_anomaly": saved_visits.duplicate(true),
	}

	var saved_flags_value: Variant = saved_world_input.get("flags", {})
	if not (saved_flags_value is Dictionary):
		return false
	var saved_flags: Dictionary = saved_flags_value
	world_state = {
		"phase": saved_phase,
		"flags": saved_flags.duplicate(true),
	}
	var saved_history_value: Variant = data.get("action_history", [])
	if not (saved_history_value is Array):
		return false
	var saved_history: Array = saved_history_value
	action_history.clear()
	for entry in saved_history:
		if entry is Dictionary:
			action_history.append(entry.duplicate(true))
	return true
