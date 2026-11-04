class_name GatherSystem
extends RefCounted

## Knowledge-gated gather/harvest spots.

const IngredientKnowledgeScript = preload("res://scripts/systems/daily/ingredient_knowledge.gd")

var spots: Array = [] ## Dictionary entries

func setup_sample_spots() -> void:
	spots.clear()
	spots.append({
		"id": "home_herb_patch",
		"location_id": "HOME",
		"item_id": "herb",
		"amount": 2,
		"requires_knowledge_id": "know_home_herb_patch",
		"label": "收取园里的草药",
		"success_text": "我在家门前的小园里采了些草药。",
		"locked_text": "门前有一小片绿意，可我还不知道哪些能用。",
	})
	spots.append({
		"id": "forest_moonleaf",
		"location_id": "FOREST",
		"item_id": "spice_moonleaf",
		"amount": 1,
		"requires_knowledge_id": "know_moonleaf",
		"label": "采集林间香料",
		"success_text": "我按听来的说法，采到一点带着清香的叶子。",
		"locked_text": "林子里气味很多，我分不清哪些能带回去。",
	})

func spots_at(location_id: String) -> Array:
	var out: Array = []
	for spot in spots:
		if str(spot.get("location_id", "")) == location_id:
			out.append(spot)
	return out

func try_gather(spot: Dictionary, knowledge, inventory, mode_allows: bool) -> Dictionary:
	if not mode_allows:
		return {"ok": false, "message": "现在不适合做这种事。"}
	var kid := str(spot.get("requires_knowledge_id", ""))
	if kid != "" and (knowledge == null or not knowledge.has(kid)):
		return {"ok": false, "message": str(spot.get("locked_text", "我还不知道怎么做。")), "locked": true}
	if inventory == null:
		return {"ok": false, "message": "拿不动东西。"}
	var item_id := str(spot.get("item_id", ""))
	var amount := int(spot.get("amount", 1))
	inventory.add_item(item_id, amount)
	return {
		"ok": true,
		"message": str(spot.get("success_text", "我采集到了一些东西。")),
		"item_id": item_id,
		"amount": amount,
	}
