extends RefCounted
## Deterministic, discrete NPC choices. Authored story beats always take priority.
## 离散、可复现的 NPC 选择；作者安排的关键剧情始终优先。

const ACTIONS: Dictionary = {
	"caregiver": [
		{"id": "prepare_meal", "label": "准备餐食", "line": "照料者把餐桌收拾好，又确认厨房里还有足够的食物。", "goal": "care"},
		{"id": "tend_home", "label": "整理家中", "line": "照料者整理了门边的花束，把散落的东西放回原处。", "goal": "stability"},
		{"id": "check_on_mite", "label": "留意蜜忒", "line": "照料者路过时问了一句蜜忒是否需要帮忙，随后继续手头的事。", "goal": "care"},
	],
	"worship_leader": [
		{"id": "prepare_public_space", "label": "整理公共场所", "line": "礼拜主持者检查了公共场所的布置，提醒帮忙的人把通道留出来。", "goal": "community"},
		{"id": "coordinate_helpers", "label": "协调帮手", "line": "礼拜主持者把几项杂事分给在场的村民，自己留下来核对清单。", "goal": "coordination"},
		{"id": "preserve_routine", "label": "维持日常安排", "line": "礼拜主持者照常完成了例行准备，没有额外解释这些安排的缘由。", "goal": "tradition"},
	],
	"doctor": [
		{"id": "review_records", "label": "核对记录", "line": "医生趁空档核对了几份记录，把尚不确定的日期标了出来。", "goal": "evidence"},
		{"id": "organize_supplies", "label": "整理药草", "line": "医生补齐了常用药草的标签，又把需要复查的记录放在一旁。", "goal": "care"},
		{"id": "check_patient_notes", "label": "检查病患备注", "line": "医生重新读了一遍病患的陈述，没有急着把相似症状归为同一种原因。", "goal": "caution"},
	],
}

static func choose_action(
	npc_id: String,
	profile: Dictionary,
	tick: int,
	day: int,
	slot: int,
	relationship: int,
	authored_override: bool,
	received_message_count: int = 0
) -> Dictionary:
	if authored_override or not ACTIONS.has(npc_id) or profile.is_empty() or tick < 0:
		return {}
	var options: Array = ACTIONS[npc_id]
	var index: int = posmod(tick + day + maxi(0, relationship + 5) + received_message_count, options.size())
	if npc_id == "doctor" and received_message_count > 0:
		for candidate_index in range(options.size()):
			if str(options[candidate_index]["id"]) == "review_records":
				index = candidate_index
				break
	if npc_id == "caregiver" and relationship >= 4:
		for candidate_index in range(options.size()):
			if str(options[candidate_index]["id"]) == "check_on_mite":
				index = candidate_index
				break
	var selected: Dictionary = options[index].duplicate(true)
	selected["npc_id"] = npc_id
	selected["tick"] = tick
	selected["day"] = day
	selected["slot"] = slot
	selected["relationship_at_choice"] = relationship
	selected["decision_basis"] = "routine_goals_and_local_state"
	return selected

static func validate_action(action: Dictionary) -> bool:
	for key in ["id", "label", "line", "goal", "npc_id", "tick", "day", "slot", "decision_basis"]:
		if not action.has(key):
			return false
	return not str(action["id"]).is_empty() and not str(action["line"]).is_empty()
