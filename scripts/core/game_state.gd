extends RefCounted
## 最小游戏状态：时间、地点、关系、调查和世界阶段彼此分离。

const SLOT_KEYS: Array[String] = ["morning", "daytime", "evening"]
const SLOT_LABELS: Array[String] = ["早晨", "白天", "傍晚"]

var day_index: int = 1
var slot_index: int = 0
var current_location: String = "HOME"

var relationship_state: Dictionary = {
	"caregiver": 0,
	"worship_leader": 0,
	"doctor": 0,
}
var investigation_state: Dictionary = {
	"observed_fact_ids": [],
}
var world_state: Dictionary = {
	"phase": "ordinary",
}

func get_slot_key() -> String:
	return SLOT_KEYS[slot_index]

func get_slot_label() -> String:
	return SLOT_LABELS[slot_index]

func advance_time() -> void:
	slot_index += 1
	if slot_index >= SLOT_KEYS.size():
		slot_index = 0
		if day_index < 7:
			day_index += 1
		else:
			world_state["phase"] = "after_week"

func register_fact(fact_id: String) -> void:
	var facts: Array = investigation_state["observed_fact_ids"]
	if not facts.has(fact_id):
		facts.append(fact_id)
		investigation_state["observed_fact_ids"] = facts
