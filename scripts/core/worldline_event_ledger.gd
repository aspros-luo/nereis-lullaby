extends RefCounted
## 可追溯的世界线事件台账。
## Records causal events without equating world facts, character knowledge, and opportunities.

var events: Array[Dictionary] = []
var event_ids: Dictionary = {}
var world_facts: Dictionary = {}
var character_knowledge: Dictionary = {}
var opportunities: Dictionary = {}

func record_event(event_id: String, source_game: String, actor_id: String, action_id: String, location_id: String, fact_ids: Array = []) -> bool:
	if event_id.strip_edges().is_empty() or event_ids.has(event_id):
		return false
	if source_game.strip_edges().is_empty() or actor_id.strip_edges().is_empty() or action_id.strip_edges().is_empty():
		return false
	var event := {
		"event_id": event_id,
		"source_game": source_game,
		"actor_id": actor_id,
		"action_id": action_id,
		"location_id": location_id,
		"fact_ids": [],
	}
	for value in fact_ids:
		if not (value is String) or value.strip_edges().is_empty():
			continue
		var fact_id: String = value
		if not event["fact_ids"].has(fact_id):
			event["fact_ids"].append(fact_id)
		if not world_facts.has(fact_id):
			world_facts[fact_id] = {"first_event_id": event_id}
	events.append(event)
	event_ids[event_id] = true
	return true

## A character only learns a fact through an explicitly recorded channel/source event.
func grant_knowledge(character_id: String, fact_id: String, source_event_id: String, channel: String) -> bool:
	if character_id.strip_edges().is_empty() or not world_facts.has(fact_id):
		return false
	if not event_ids.has(source_event_id) or channel.strip_edges().is_empty():
		return false
	# Knowledge must be supported by the cited event, not merely by any existing event.
	# 角色获得事实必须由来源事件明确支持，不能只引用任意存在的事件。
	var source_event_supports_fact := false
	for event in events:
		if str(event.get("event_id", "")) != source_event_id:
			continue
		var source_fact_ids: Variant = event.get("fact_ids", [])
		source_event_supports_fact = source_fact_ids is Array and source_fact_ids.has(fact_id)
		break
	if not source_event_supports_fact:
		return false
	if not character_knowledge.has(character_id):
		character_knowledge[character_id] = {}
	var known: Dictionary = character_knowledge[character_id]
	if known.has(fact_id):
		return false
	known[fact_id] = {"source_event_id": source_event_id, "channel": channel}
	character_knowledge[character_id] = known
	return true

## Opportunities are affordances, not guaranteed actions or ending switches.
func set_opportunity(opportunity_id: String, is_open: bool, source_event_id: String) -> bool:
	if opportunity_id.strip_edges().is_empty() or not event_ids.has(source_event_id):
		return false
	opportunities[opportunity_id] = {
		"is_open": is_open,
		"source_event_id": source_event_id,
	}
	return true

func has_fact(fact_id: String) -> bool:
	return world_facts.has(fact_id)

func character_knows(character_id: String, fact_id: String) -> bool:
	if not character_knowledge.has(character_id):
		return false
	return character_knowledge[character_id].has(fact_id)

func is_opportunity_open(opportunity_id: String) -> bool:
	if not opportunities.has(opportunity_id):
		return false
	return bool(opportunities[opportunity_id].get("is_open", false))

func to_save_data() -> Dictionary:
	return {
		"events": events.duplicate(true),
		"world_facts": world_facts.duplicate(true),
		"character_knowledge": character_knowledge.duplicate(true),
		"opportunities": opportunities.duplicate(true),
	}

func load_save_data(data: Dictionary) -> bool:
	var raw_events: Variant = data.get("events", [])
	var raw_facts: Variant = data.get("world_facts", {})
	var raw_knowledge: Variant = data.get("character_knowledge", {})
	var raw_opportunities: Variant = data.get("opportunities", {})
	if not (raw_events is Array) or not (raw_facts is Dictionary):
		return false
	if not (raw_knowledge is Dictionary) or not (raw_opportunities is Dictionary):
		return false

	var rebuilt_events: Array[Dictionary] = []
	var rebuilt_ids: Dictionary = {}
	var event_facts: Dictionary = {}
	for raw_event in raw_events:
		if not (raw_event is Dictionary):
			return false
		var event: Dictionary = raw_event
		for text_field in ["event_id", "source_game", "actor_id", "action_id", "location_id"]:
			if not (event.get(text_field, null) is String):
				return false
		var event_id: String = event["event_id"]
		if event_id.strip_edges().is_empty() or rebuilt_ids.has(event_id):
			return false
		for required_text in ["source_game", "actor_id", "action_id"]:
			if event[required_text].strip_edges().is_empty():
				return false
		var raw_event_facts: Variant = event.get("fact_ids", [])
		if not (raw_event_facts is Array):
			return false
		var normalized_event_facts: Array[String] = []
		for raw_fact_id in raw_event_facts:
			if not (raw_fact_id is String) or raw_fact_id.strip_edges().is_empty():
				return false
			if not normalized_event_facts.has(raw_fact_id):
				normalized_event_facts.append(raw_fact_id)
		var normalized_event: Dictionary = event.duplicate(true)
		normalized_event["fact_ids"] = normalized_event_facts
		rebuilt_events.append(normalized_event)
		rebuilt_ids[event_id] = true
		event_facts[event_id] = normalized_event_facts

	for fact_key in raw_facts.keys():
		if not (fact_key is String) or not (raw_facts[fact_key] is Dictionary):
			return false
		var fact_id: String = fact_key
		if fact_id.strip_edges().is_empty():
			return false
		var first_event_value: Variant = raw_facts[fact_key].get("first_event_id", null)
		if not (first_event_value is String):
			return false
		var first_event_id: String = first_event_value
		if not rebuilt_ids.has(first_event_id):
			return false
		if not event_facts[first_event_id].has(fact_id):
			return false

	# Every event-referenced fact must have a matching world-fact record.
	for event_id in event_facts:
		for fact_id in event_facts[event_id]:
			if not raw_facts.has(fact_id):
				return false

	for character_id in raw_knowledge.keys():
		if not (character_id is String) or not (raw_knowledge[character_id] is Dictionary):
			return false
		for fact_id in raw_knowledge[character_id].keys():
			if not (fact_id is String) or not raw_facts.has(fact_id) or not (raw_knowledge[character_id][fact_id] is Dictionary):
				return false
			var knowledge: Dictionary = raw_knowledge[character_id][fact_id]
			var source_value: Variant = knowledge.get("source_event_id", null)
			var channel_value: Variant = knowledge.get("channel", null)
			if not (source_value is String) or not (channel_value is String):
				return false
			var source_id: String = source_value
			if source_id.is_empty() or not rebuilt_ids.has(source_id) or channel_value.strip_edges().is_empty():
				return false
			# The referenced source event must list the same fact.
			# 来源事件必须明确包含角色声称获知的事实。
			if not event_facts[source_id].has(fact_id):
				return false
			# The referenced source event must list the same fact.
			# 来源事件必须明确包含角色声称获知的事实。
			if not event_facts[source_id].has(fact_id):
				return false

	for opportunity_id in raw_opportunities.keys():
		if not (opportunity_id is String) or opportunity_id.strip_edges().is_empty() or not (raw_opportunities[opportunity_id] is Dictionary):
			return false
		var source_value: Variant = raw_opportunities[opportunity_id].get("source_event_id", null)
		var open_value: Variant = raw_opportunities[opportunity_id].get("is_open", null)
		if not (source_value is String) or not (open_value is bool):
			return false
		var source_id: String = source_value
		if source_id.is_empty() or not rebuilt_ids.has(source_id):
			return false

	# Mutate only after all sections validate, so a failed load preserves the current ledger.
	events = rebuilt_events
	event_ids = rebuilt_ids
	world_facts = raw_facts.duplicate(true)
	character_knowledge = raw_knowledge.duplicate(true)
	opportunities = raw_opportunities.duplicate(true)
	return true
