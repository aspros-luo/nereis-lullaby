extends RefCounted
## Data-driven behavior cards for the current three village NPCs.
## 当前三名村民的数据化行为卡；内容描述原型表现，不锁定最终世界观。

const PROFILES: Dictionary = {
	"caregiver": {
		"role": "household_caregiver",
		"goals": ["keep Mite safe", "maintain ordinary daily routines"],
		"motives": ["care", "stability", "familiarity"],
		"action_preferences": ["care", "stability"],
		"knowledge_boundaries": [
			"knows household routines and Mite's childhood habits",
			"does not automatically know the cause of villagers' sleep problems",
			"does not know the Church's hidden research from current prototype evidence"
		],
		"memory_dimensions": ["shared household moments", "Mite's preferences", "promises and practical help"],
		"relationship_dimensions": ["trust", "warmth", "perceived safety"],
		"stress_response": "minimize alarm, offer practical care, and avoid claiming an explanation without evidence",
		"fallback_action": "continue household care"
	},
	"worship_leader": {
		"role": "local_community_ritual_coordinator",
		"goals": ["keep public routines orderly", "help villagers cooperate"],
		"motives": ["community cohesion", "tradition", "responsibility"],
		"action_preferences": ["community", "coordination", "tradition"],
		"knowledge_boundaries": [
			"knows public customs and the preparations he personally coordinates",
			"does not automatically know private medical records",
			"public explanations are not proof of either innocence or deception"
		],
		"memory_dimensions": ["shared preparations", "public commitments", "help offered"],
		"relationship_dimensions": ["trust", "cooperation", "respect for community roles"],
		"stress_response": "preserve routine, give a socially acceptable explanation, and avoid revealing information he does not possess",
		"fallback_action": "continue public preparations"
	},
	"doctor": {
		"role": "village_practitioner",
		"goals": ["care for patients", "keep records usable and consistent"],
		"motives": ["duty of care", "evidence", "professional caution"],
		"action_preferences": ["evidence", "care", "caution"],
		"knowledge_boundaries": [
			"knows only patients and records he has personally encountered",
			"date discrepancies do not establish a supernatural cause",
			"cannot infer a shared cause from similar symptoms alone"
		],
		"memory_dimensions": ["patient reports", "record discrepancies", "care already provided"],
		"relationship_dimensions": ["trust", "reliability", "willingness to share observations"],
		"stress_response": "recheck records, state uncertainty, and avoid premature diagnosis",
		"fallback_action": "review patient notes"
	}
}

static func get_profile(npc_id: String) -> Dictionary:
	var profile: Variant = PROFILES.get(npc_id, {})
	if not (profile is Dictionary):
		return {}
	return profile.duplicate(true)

static func get_all_profiles() -> Dictionary:
	return PROFILES.duplicate(true)

static func has_required_fields(profile: Dictionary) -> bool:
	for key in ["role", "goals", "motives", "action_preferences", "knowledge_boundaries", "memory_dimensions", "relationship_dimensions", "stress_response", "fallback_action"]:
		if not profile.has(key):
			return false
	if str(profile["role"]).is_empty() or str(profile["stress_response"]).is_empty():
		return false
	for key in ["goals", "motives", "action_preferences", "knowledge_boundaries", "memory_dimensions", "relationship_dimensions"]:
		if not (profile[key] is Array) or profile[key].is_empty():
			return false
	return true
