extends RefCounted
## Discrete information travel. Receiving a claim is not the same as knowing or believing it.
## 离散信息传播：收到消息不等于掌握事实，也不等于相信消息。

var messages: Array[Dictionary] = []
var message_ids: Dictionary = {}
var inboxes: Dictionary = {}
var beliefs: Dictionary = {}

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
	if travel_slots < 0 or credibility < 0.0 or credibility > 1.0:
		return false
	if ledger == null or not ledger.has_fact(fact_id) or not ledger.event_ids.has(source_event_id):
		return false
	# A sender must have explicit knowledge, or be the actor in the source event.
	var source_event: Dictionary = {}
	for event in ledger.events:
		if str(event.get("event_id", "")) == source_event_id:
			source_event = event
			break
	if not ledger.character_knows(sender_id, fact_id) and str(source_event.get("actor_id", "")) != sender_id:
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
	messages.append(message)
	message_ids[message_id] = true
	return true

## Delivers all due messages in send order; repeated calls are safe.
func advance_to(tick: int) -> int:
	var delivered_count := 0
	for index in range(messages.size()):
		var message: Dictionary = messages[index]
		if str(message.get("status", "")) != "pending" or int(message.get("arrival_tick", -1)) > tick:
			continue
		var receiver_id: String = str(message["receiver_id"])
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
	}

func load_save_data(data: Dictionary) -> bool:
	var raw_messages: Variant = data.get("messages", [])
	var raw_inboxes: Variant = data.get("inboxes", {})
	var raw_beliefs: Variant = data.get("beliefs", {})
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
		if str(message.get("fact_id", "")).is_empty() or str(message.get("receiver_id", "")).is_empty():
			return false
		if float(message.get("credibility", -1.0)) < 0.0 or float(message.get("credibility", 2.0)) > 1.0:
			return false
		rebuilt_messages.append(message.duplicate(true))
		rebuilt_ids[message_id] = true
	for character_id in raw_inboxes:
		if not (raw_inboxes[character_id] is Array):
			return false
		for entry in raw_inboxes[character_id]:
			if not (entry is Dictionary) or not rebuilt_ids.has(str(entry.get("message_id", ""))):
				return false
	for character_id in raw_beliefs:
		if not (raw_beliefs[character_id] is Dictionary):
			return false
		for fact_id in raw_beliefs[character_id]:
			var confidence := float(raw_beliefs[character_id][fact_id])
			if confidence < 0.0 or confidence > 0.95:
				return false
	messages = rebuilt_messages
	message_ids = rebuilt_ids
	inboxes = raw_inboxes.duplicate(true)
	beliefs = raw_beliefs.duplicate(true)
	return true
