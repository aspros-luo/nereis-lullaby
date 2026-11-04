class_name GameModeController
extends RefCounted

## daily = free village loop; event_focus = anchor day (harvest etc.)

enum Mode { DAILY, EVENT_FOCUS }

var mode: int = Mode.DAILY
var active_event_id: String = ""

signal mode_changed(new_mode: int, event_id: String)

func is_daily() -> bool:
	return mode == Mode.DAILY

func is_event_focus() -> bool:
	return mode == Mode.EVENT_FOCUS

func enter_daily() -> void:
	mode = Mode.DAILY
	active_event_id = ""
	mode_changed.emit(mode, active_event_id)

func enter_event(event_id: String) -> void:
	mode = Mode.EVENT_FOCUS
	active_event_id = event_id
	mode_changed.emit(mode, active_event_id)

func allows_free_gather() -> bool:
	return is_daily()

func allows_free_trade() -> bool:
	return is_daily()

func allows_idle_wander_actions() -> bool:
	return is_daily()
