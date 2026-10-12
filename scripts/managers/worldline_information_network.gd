extends RefCounted
## Discrete information travel. Receiving a claim is not the same as knowing or believing it.
## 离散信息传播：收到消息不等于掌握事实，也不等于相信消息。

var messages: Array[Dictionary] = []
var message_ids: Dictionary = {}
var inboxes: Dictionary = {}
var beliefs: Dictionary = {}
var current_tick: int = -1

func publish_message(
	message_id: String,
	fact_id: String,
	sender_id: String,
	receiver_id: String,
	channel: String,
	travel_slots: int,
	credibility: float,
	current_tick: int,
	source_event_id: String,
	ledger
) -> bool:
	if message_id.strip_edges().is_empty() or message_ids.has(message_id):
		return false
	if fact_id.strip_edges().is_empty() or sender_id.strip_edges().is_empty() or receiver_id.strip_edges().is_empty():
		return false
	if channel.strip_edges().is_empty() or source_event_id.strip_edges().is_empty():
		return false
	if travel_slots < 0 or not is_finite(credibility) or credibility < 0.0 or credibility > 1.0 or current_tick < 0:
		return false
	if current_tick < self.current_tick:
		return false
	if ledger == null or not ledger.has_fact(fact_id) or not ledger.event_ids.has(source_event_id):
		return false
	# A sender must have explicit knowledge, or be the actor in the source event.
	var source_event: Dictionary = {}
	for event in ledger.events:
		if str(event.get("event_id", "")) == source_event_id:
			source_event = event
			break
	var source_facts: Variant = source_event.get("fact_ids", [])
	var sender_has_source: bool = str(source_event.get("actor_id", "")) == sender_id and source_facts is Array and source_facts.has(fact_id)
	if not ledger.character_knows(sender_id, fact_id) and not sender_has_source:
		return false
	var message := {
		"message_id": message_id,
		"fact_id": fact_id,
		"sender_id": sender_id,
		"receiver_id": receiver_id,
		"channel": channel,
		"credibility": credibility,
		"sent_tick": current_tick,
		"arrival_tick": current_tick + travel_slots,
		"source_event_id": source_event_id,
		"status": "pending",
	}
	self.current_tick = maxi(self.current_tick, current_tick)
	messages.append(message)
	message_ids[message_id] = true
	return true

## Delivers all due messages in send order; repeated calls are safe.
func advance_to(tick: int, ledger = null) -> int:
	if tick < current_tick:
		return 0
	current_tick = tick
	var delivered_count := 0
	for index in range(messages.size()):
		var message: Dictionary = messages[index]
		if str(message.get("status", "")) != "pending" or int(message.get("arrival_tick", -1)) > tick:
			continue
		var receiver_id: String = str(message["receiver_id"])
		var delivery_event_id := "lullaby.message.delivered." + str(message["message_id"])
		if ledger != null and not ledger.event_ids.has(delivery_event_id):
			ledger.record_event(delivery_event_id, "lullaby", receiver_id, "receive_message", "", [str(message["fact_id"])])
		if not inboxes.has(receiver_id):
			inboxes[receiver_id] = []
		var inbox: Array = inboxes[receiver_id]
		inbox.append({
			"message_id": message["message_id"],
			"fact_id": message["fact_id"],
			"sender_id": message["sender_id"],
			"channel": message["channel"],
			"credibility": message["credibility"],
			"source_event_id": message["source_event_id"],
			"delivery_event_id": delivery_event_id,
			"received_tick": tick,
		})
		inboxes[receiver_id] = inbox
		if not beliefs.has(receiver_id):
			beliefs[receiver_id] = {}
		var receiver_beliefs: Dictionary = beliefs[receiver_id]
		var fact_id: String = str(message["fact_id"])
		var previous_confidence := float(receiver_beliefs.get(fact_id, 0.0))
		var incoming_confidence := float(message["credibility"])
		# Independent reports can strengthen a belief, but never make it certain.
		receiver_beliefs[fact_id] = minf(0.95, 1.0 - ((1.0 - previous_confidence) * (1.0 - incoming_confidence * 0.5)))
		beliefs[receiver_id] = receiver_beliefs
		message["status"] = "delivered"
		message["delivered_tick"] = tick
		messages[index] = message
		delivered_count += 1
	return delivered_count

func get_inbox(character_id: String) -> Array:
	return (inboxes.get(character_id, []) as Array).duplicate(true)

func get_belief_confidence(character_id: String, fact_id: String) -> float:
	var character_beliefs: Variant = beliefs.get(character_id, {})
	if not (character_beliefs is Dictionary):
		return 0.0
	return float(character_beliefs.get(fact_id, 0.0))

func to_save_data() -> Dictionary:
	return {
		"messages": messages.duplicate(true),
		"inboxes": inboxes.duplicate(true),
		"beliefs": beliefs.duplicate(true),
		"current_tick": current_tick,
	}

func load_save_data(data: Dictionary) -> bool:
	var raw_messages: Variant = data.get("messages", [])
	var raw_inboxes: Variant = data.get("inboxes", {})
	var raw_beliefs: Variant = data.get("beliefs", {})
	var raw_current_tick_value: Variant = data.get("current_tick", null)
	if not (raw_current_tick_value is int):
		return false
	var raw_current_tick: int = int(raw_current_tick_value)
	if raw_current_tick < -1:
		return false
	if not (raw_messages is Array) or not (raw_inboxes is Dictionary) or not (raw_beliefs is Dictionary):
		return false
	var rebuilt_messages: Array[Dictionary] = []
	var rebuilt_ids: Dictionary = {}
	for raw_message in raw_messages:
		if not (raw_message is Dictionary):
			return false
		var message: Dictionary = raw_message
		var message_id := str(message.get("message_id", ""))
		if message_id.is_empty() or rebuilt_ids.has(message_id):
			return false
		if not ["pending", "delivered"].has(str(message.get("status", ""))):
			return false
		if str(message.get("fact_id", "")).is_empty() or str(message.get("sender_id", "")).is_empty() or str(message.get("receiver_id", "")).is_empty():
			return false
		if str(message.get("channel", "")).is_empty() or str(message.get("source_event_id", "")).is_empty():
			return false
		var sent_tick_value: Variant = message.get("sent_tick", null)
		var arrival_tick_value: Variant = message.get("arrival_tick", null)
		if not (sent_tick_value is int) or not (arrival_tick_value is int):
			return false
		var sent_tick: int = int(sent_tick_value)
		var arrival_tick: int = int(arrival_tick_value)
		if sent_tick < 0 or arrival_tick < sent_tick:
			return false
		# A message cannot originate after the network's own saved clock.
		if sent_tick > raw_current_tick:
			return false
		if str(message.get("status", "")) == "delivered":
			var delivered_tick_value: Variant = message.get("delivered_tick", null)
			if not (delivered_tick_value is int):
				return false
			var delivered_tick: int = int(delivered_tick_value)
			if delivered_tick < arrival_tick or delivered_tick > raw_current_tick:
				return false
		elif arrival_tick <= raw_current_tick:
			# advance_to() delivers every message due at the saved tick, including this boundary.
			return false
		var credibility_value: Variant = message.get("credibility", null)
		if not (credibility_value is int or credibility_value is float):
			return false
		var saved_credibility: float = float(credibility_value)
		if not is_finite(saved_credibility) or saved_credibility < 0.0 or saved_credibility > 1.0:
			return false
		rebuilt_messages.append(message.duplicate(true))
		rebuilt_ids[message_id] = true
	var inbox_message_ids: Dictionary = {}
	for character_id in raw_inboxes:
		if not (raw_inboxes[character_id] is Array):
			return false
		for entry in raw_inboxes[character_id]:
			if not (entry is Dictionary) or not rebuilt_ids.has(str(entry.get("message_id", ""))):
				return false
			var inbox_message_id: String = str(entry.get("message_id", ""))
			if inbox_message_ids.has(inbox_message_id):
				return false
			inbox_message_ids[inbox_message_id] = true
			var matched_message: Dictionary = {}
			for saved_message in rebuilt_messages:
				if str(saved_message.get("message_id", "")) == inbox_message_id:
					matched_message = saved_message
					break
			if str(matched_message.get("status", "")) != "delivered" or str(matched_message.get("receiver_id", "")) != str(character_id):
				return false
			# The inbox is a projection of the delivered message, not an independent source of truth.
			for field in ["fact_id", "sender_id", "channel", "source_event_id"]:
				if not entry.has(field) or str(entry[field]) != str(matched_message.get(field, "")):
					return false
			var inbox_credibility: Variant = entry.get("credibility", null)
			if not (inbox_credibility is int or inbox_credibility is float):
				return false
			if not is_equal_approx(float(inbox_credibility), float(matched_message.get("credibility", -1.0))):
				return false
			if not entry.has("delivery_event_id") or str(entry["delivery_event_id"]) != "lullaby.message.delivered." + inbox_message_id:
				return false
			var received_tick_value: Variant = entry.get("received_tick", null)
			if not (received_tick_value is int) or int(received_tick_value) != int(matched_message.get("delivered_tick", -1)):
				return false
	for character_id in raw_beliefs:
		if not (raw_beliefs[character_id] is Dictionary):
			return false
		for fact_id in raw_beliefs[character_id]:
			var confidence_value: Variant = raw_beliefs[character_id][fact_id]
			if not (confidence_value is int or confidence_value is float):
				return false
			var confidence := float(confidence_value)
			if str(fact_id).strip_edges().is_empty() or not is_finite(confidence) or confidence < 0.0 or confidence > 0.95:
				return false
			var has_delivered_evidence := false
			for inbox_entry in raw_inboxes.get(character_id, []):
				if str(inbox_entry.get("fact_id", "")) == str(fact_id):
					has_delivered_evidence = true
					break
			if not has_delivered_evidence:
				return false
	for saved_message in rebuilt_messages:
		if str(saved_message.get("status", "")) == "delivered" and not inbox_message_ids.has(str(saved_message.get("message_id", ""))):
			return false
	messages = rebuilt_messages
	message_ids = rebuilt_ids
	inboxes = raw_inboxes.duplicate(true)
	beliefs = raw_beliefs.duplicate(true)
	current_tick = raw_current_tick
	return true
