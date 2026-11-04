class_name IngredientKnowledge
extends RefCounted

## Clue/knowledge unlocked by dialogue (villager, merchant, visitor).
## Separate from inventory.

var known: Dictionary = {} ## knowledge_id -> true
var notes: Dictionary = {} ## knowledge_id -> player-facing note

func has(knowledge_id: String) -> bool:
	return known.has(knowledge_id) and bool(known[knowledge_id])

func learn(knowledge_id: String, note: String = "") -> bool:
	if has(knowledge_id):
		return false
	known[knowledge_id] = true
	if note != "":
		notes[knowledge_id] = note
	return true

func get_note(knowledge_id: String) -> String:
	return str(notes.get(knowledge_id, ""))

func list_notes() -> Array:
	var out: Array = []
	for kid in notes.keys():
		if has(str(kid)):
			out.append(str(notes[kid]))
	return out
