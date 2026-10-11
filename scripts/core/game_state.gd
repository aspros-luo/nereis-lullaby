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
