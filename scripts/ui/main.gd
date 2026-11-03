extends Control
## 一周生活原型：地点探索、日常行动、关键 NPC、线索与阶段异变。

const GameStateScript = preload("res://scripts/core/game_state.gd")
const ScheduleManagerScript = preload("res://scripts/managers/npc_schedule_manager.gd")
const ClueJournalScript = preload("res://scripts/managers/clue_journal.gd")
const WorldlineLedgerScript = preload("res://scripts/core/worldline_event_ledger.gd")
const InformationNetworkScript = preload("res://scripts/managers/worldline_information_network.gd")
const NPCBehaviorProfilesScript = preload("res://scripts/data/npc_behavior_profiles.gd")
const NPCBehaviorSimulatorScript = preload("res://scripts/managers/npc_behavior_simulator.gd")

const LOCATION_ORDER: Array[String] = [
	"FOREST", "GROVE", "PATH", "COMMONS", "SHRINE", "HOME", "CLINIC"
]
const ACTIVITY_LABELS: Dictionary = {
	"HOME": "整理家里",
	"COMMONS": "帮忙做些杂事",
	"SHRINE": "整理礼拜用品",
	"CLINIC": "分拣草药",
	"PATH": "采些常见草叶",
	"FOREST": "采摘野花",
	"GROVE": "坐下休息",
}
