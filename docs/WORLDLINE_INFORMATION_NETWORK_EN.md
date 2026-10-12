# Worldline Information Propagation Model (Prototype)

## Purpose

Information must travel through people, channels, and time. A world fact must not become globally visible merely because it happened. This system is testable infrastructure for future cross-region events; it does not mean that merchants, junior Church clerks, or Restoration Army quartermasters have been added to the current game.

## Four separate layers

1. **World facts:** Recorded by the worldline ledger and linked to the event where each fact first appeared.
2. **Character knowledge:** Information personally witnessed or acquired through an explicitly recorded channel. Merely receiving a rumor does not automatically grant this.
3. **Received messages:** A sender communicates a claim about a fact to a receiver through a specific channel; messages may have travel delay and credibility.
4. **Character beliefs:** The receiver's confidence in a claim based on incoming messages. Belief is not truth and never modifies the world fact itself.

## Time and delivery

- Each game period maps to a discrete tick: `(day_index - 1) * 3 + slot_index`.
- Sending records `sent_tick` and `arrival_tick = sent_tick + travel_slots`.
- A message enters its recipient's inbox only when the timeline advances to its arrival period.
- A message ID can be sent only once; repeating a tick does not redeliver it, and time cannot move backwards.
- Belief confidence uses a conservative combination rule. One message cannot directly make a belief fully certain. This is a prototype algorithm and may change after gameplay validation.

## API and persistence

File: `scripts/managers/worldline_information_network.gd`

- `publish_message(...)`: Validates the fact, source event, sender, and channel before registering a message.
- `advance_to(tick)`: Delivers messages whose arrival time has passed.
- `get_inbox(character_id)`: Returns a copy of a character's inbox.
- `get_belief_confidence(character_id, fact_id)`: Reads confidence, not objective knowledge.
- `to_save_data()` / `load_save_data(data)`: Serialize messages, inboxes, beliefs, and timeline; reject duplicate IDs, malformed structures, invalid confidence, and inconsistent delivery records.

The main scene now advances delivery with the game timeline and includes network state in save/load. Older saves without this field restore an empty network.

## Current boundaries

- The system is committed to the main loop and smoke-test code, but **has not been run by Godot**.
- Cross-region characters such as merchants, junior Church clerks, and Restoration Army quartermasters are not yet integrated, and no unapproved story messages have been hardcoded for demonstration.
- Next, explicit conversations/actions should create messages, and the UI should show who told whom, when the information arrived, and whether the recipient believes it—without violating character permissions or knowledge boundaries.
