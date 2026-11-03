class_name CookingWorldInfluence
extends RefCounted

## Hidden world reactions from cooking / gifting.
## Never expose numeric values or internal tags to player-facing UI.

const CookingResultScript = preload("res://scripts/systems/cooking/cooking_result.gd")

## recipe_id -> default hidden profile applied on successful cook
const COOK_PROFILES := {
	"honey_bread": {
		"quality": 2,
		"taste_score": 3,
		"hidden_resonance": 1,
		"memory_effects": ["warm_kitchen", "sweet_aftertaste"],
		"world_effects": ["home_comfort_soft"],
	},
	"herb_porridge": {
		"quality": 2,
		"taste_score": 2,
		"hidden_resonance": 2,
		"memory_effects": ["herbal_calm"],
		"world_effects": ["body_ease_soft", "clinic_affinity_soft"],
	},
}

## food_id -> preferred NPC affinity for gift reactions
const GIFT_AFFINITY := {
	"honey_bread": {
		"caregiver": 2,
		"worship_leader": 1,
		"doctor": 1,
	},
	"herb_porridge": {
		"doctor": 2,
		"caregiver": 1,
		"worship_leader": 0,
	},
}

static func enrich_cook_result(result) -> void:
	if result == null or not result.success:
		return
	var profile: Dictionary = COOK_PROFILES.get(str(result.recipe_id), {})
	if profile.is_empty():
		profile = COOK_PROFILES.get(str(result.output_item_id), {})
	if profile.is_empty():
		return
	result.quality = int(profile.get("quality", result.quality))
	result.taste_score = int(profile.get("taste_score", result.taste_score))
	result.hidden_resonance = int(profile.get("hidden_resonance", result.hidden_resonance))
	result.memory_effects = profile.get("memory_effects", []).duplicate()
	result.world_effects = profile.get("world_effects", []).duplicate()
	result.food_id = str(result.output_item_id)

## Apply cook-side hidden flags into game_state.world_state if available.
## Silent: no player message, no numbers.
static func apply_cook_to_world(result, game_state = null, ledger = null) -> void:
	enrich_cook_result(result)
	if result == null or not result.success:
		return
	if game_state == null:
		return
	if not ("world_state" in game_state):
		return
	var flags: Dictionary = game_state.world_state.get("flags", {})
	var cooking_flags: Dictionary = flags.get("cooking_hidden", {})
	if not (cooking_flags is Dictionary):
		cooking_flags = {}

	var resonance: int = int(cooking_flags.get("resonance_total", 0))
	resonance += int(result.hidden_resonance)
	cooking_flags["resonance_total"] = resonance

	var seen_effects: Dictionary = cooking_flags.get("world_effects_seen", {})
	if not (seen_effects is Dictionary):
		seen_effects = {}
	for effect_id in result.world_effects:
		seen_effects[str(effect_id)] = true
	cooking_flags["world_effects_seen"] = seen_effects

	var memory_seen: Dictionary = cooking_flags.get("memory_effects_seen", {})
	if not (memory_seen is Dictionary):
		memory_seen = {}
	for mem_id in result.memory_effects:
		memory_seen[str(mem_id)] = true
	cooking_flags["memory_effects_seen"] = memory_seen

	cooking_flags["last_food_id"] = str(result.output_item_id)
	flags["cooking_hidden"] = cooking_flags
	game_state.world_state["flags"] = flags

	if ledger != null and ledger.has_method("record_event"):
		var event_id := "lullaby.cooking.hidden.%s" % str(result.output_item_id)
		ledger.record_event(event_id, "lullaby", "mite", "cook_hidden", "HOME", result.world_effects)

static func gift_affinity_bonus(food_id: String, npc_id: String) -> int:
	var table: Dictionary = GIFT_AFFINITY.get(food_id, {})
	return int(table.get(npc_id, 1))
