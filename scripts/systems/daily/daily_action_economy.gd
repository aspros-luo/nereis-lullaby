class_name DailyActionEconomy
extends RefCounted

## Soft daily pressure: limited heavy actions, then rest advances the world.

const HEAVY_PER_SEGMENT: int = 3

var heavy_remaining: int = HEAVY_PER_SEGMENT
var segment_index: int = 0
## After this many rests, player can enter harvest festival anchor.
var segments_until_festival_ready: int = 3

signal segment_advanced(segment_index: int)
signal exhausted

func can_spend_heavy() -> bool:
	return heavy_remaining > 0

func spend_heavy() -> bool:
	if heavy_remaining <= 0:
		exhausted.emit()
		return false
	heavy_remaining -= 1
	return true

func rest() -> Dictionary:
	segment_index += 1
	heavy_remaining = HEAVY_PER_SEGMENT
	var info := {
		"segment_index": segment_index,
		"festival_hint": segment_index >= 2,
		"festival_ready": segment_index >= segments_until_festival_ready,
	}
	segment_advanced.emit(segment_index)
	return info

func is_festival_ready() -> bool:
	return segment_index >= segments_until_festival_ready

func status_text() -> String:
	return "还能认真做 %d 件事 · 日常第 %d 段" % [heavy_remaining, segment_index]
