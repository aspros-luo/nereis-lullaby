class_name NpcShellBridge
extends RefCounted
## Thin bridge: build ctx for NpcBehaviorLogic from the daily shell.

const NpcBehaviorLogicScript = preload("res://scripts/systems/daily/npc_behavior_logic.gd")

var logic

func _init() -> void:
	logic = NpcBehaviorLogicScript.new()

func make_ctx(
	location: String,
	festival_done: bool,
	event_focus: bool,
	flags: Dictionary,
	segment_index: int,
	authored_active: bool = false,
	smith_helped: bool = false
) -> Dictionary:
	return {
		"location": location,
		"festival_done": festival_done,
		"event_focus": event_focus,
		"flags": flags,
		"segment_index": segment_index,
		"authored_active": authored_active,
		"smith_helped": smith_helped,
	}

func decide(npc_id: String, ctx: Dictionary) -> Dictionary:
	return logic.decide(npc_id, ctx)

func talk_line(npc_id: String, ctx: Dictionary) -> String:
	return str(logic.talk_line(npc_id, ctx))

func presence_note(npc_id: String, location: String, festival_done: bool, event_focus: bool) -> String:
	return str(logic.presence_note(npc_id, location, festival_done, event_focus))

func routine_line(npc_id: String, ctx: Dictionary) -> String:
	var r: Dictionary = logic.choose_routine(npc_id, ctx)
	return str(r.get("line", ""))
