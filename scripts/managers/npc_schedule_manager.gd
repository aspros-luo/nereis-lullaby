extends RefCounted
## 三名关键 NPC 的原型日程。所有内容均为提案，不代表正式世界观。

const NPC_DATA: Dictionary = {
	"caregiver": {
		"name": "照料者",
		"schedules": {
			1: ["HOME", "COMMONS", "HOME"],
			2: ["HOME", "COMMONS", "HOME"],
			3: ["HOME", "COMMONS", "HOME"],
			4: ["HOME", "PATH", "HOME"],
			5: ["HOME", "COMMONS", "HOME"],
			6: ["HOME", "COMMONS", "HOME"],
			7: ["HOME", "COMMONS", "HOME"],
		},
	},
	"worship_leader": {
		"name": "礼拜主持者",
		"schedules": {
			1: ["SHRINE", "COMMONS", "SHRINE"],
			2: ["SHRINE", "COMMONS", "SHRINE"],
			3: ["SHRINE", "COMMONS", "SHRINE"],
			4: ["SHRINE", "COMMONS", "SHRINE"],
			5: ["SHRINE", "COMMONS", "SHRINE"],
			6: ["SHRINE", "COMMONS", "SHRINE"],
			7: ["SHRINE", "COMMONS", "SHRINE"],
		},
	},
	"doctor": {
		"name": "医生／药剂师",
		"schedules": {
			1: ["CLINIC", "CLINIC", "CLINIC"],
			2: ["CLINIC", "PATH", "CLINIC"],
			3: ["CLINIC", "CLINIC", "CLINIC"],
			4: ["CLINIC", "CLINIC", "CLINIC"],
			5: ["CLINIC", "CLINIC", "CLINIC"],
			6: ["CLINIC", "CLINIC", "CLINIC"],
			7: ["CLINIC", "CLINIC", "CLINIC"],
		},
	},
}

const LOCATION_NAMES: Dictionary = {
	"HOME": "我家附近",
	"COMMONS": "村庄公共空间",
	"SHRINE": "公开礼拜场所",
	"CLINIC": "诊疗处",
	"PATH": "村庄通路",
	"FOREST": "林间小径",
	"GROVE": "林中空地",
}

var schedule_overrides: Dictionary = {}

func get_npc_name(npc_id: String) -> String:
	return str(NPC_DATA.get(npc_id, {}).get("name", npc_id))

func get_location_name(location_id: String) -> String:
	return str(LOCATION_NAMES.get(location_id, location_id))

func get_location(npc_id: String, day_index: int, slot_index: int) -> String:
	# Fail closed for invalid time coordinates instead of indexing outside a schedule.
	if not NPC_DATA.has(npc_id) or day_index < 1 or day_index > 7 or slot_index < 0 or slot_index >= 3:
		return ""
	if schedule_overrides.has(npc_id):
		var override_value: Variant = schedule_overrides[npc_id]
		if not (override_value is Dictionary):
			return ""
		var override_location: String = str(override_value.get("location_id", ""))
		return override_location if LOCATION_NAMES.has(override_location) else ""
	var npc: Dictionary = NPC_DATA[npc_id]
	var schedules: Dictionary = npc.get("schedules", {})
	var day_schedule_value: Variant = schedules.get(day_index, null)
	if not (day_schedule_value is Array) or day_schedule_value.size() != 3:
		return ""
	var location_id: String = str(day_schedule_value[slot_index])
	return location_id if LOCATION_NAMES.has(location_id) else ""

func get_npcs_at(location_id: String, day_index: int, slot_index: int) -> Array:
	var present: Array = []
	if not LOCATION_NAMES.has(location_id) or day_index < 1 or day_index > 7 or slot_index < 0 or slot_index >= 3:
		return present
	for npc_id in NPC_DATA.keys():
		if get_location(str(npc_id), day_index, slot_index) == location_id:
			present.append(str(npc_id))
	return present

func set_schedule_override(npc_id: String, location_id: String, reason: String) -> void:
	schedule_overrides[npc_id] = {
		"location_id": location_id,
		"reason": reason,
	}

func clear_schedule_override(npc_id: String) -> void:
	schedule_overrides.erase(npc_id)

func get_override_reason(npc_id: String) -> String:
	if not schedule_overrides.has(npc_id):
		return ""
	return str(schedule_overrides[npc_id].get("reason", "剧情事件覆盖日程"))
