class_name TradeSystem
extends RefCounted

## Simple presence trades. Sample: merchant takes herb, gives flour.

var offers: Array = []

func setup_sample_offers() -> void:
	offers.clear()
	offers.append({
		"id": "merchant_herb_flour",
		"location_id": "COMMONS",
		"npc_label": "外地商人",
		"give_item": "herb",
		"give_amount": 1,
		"receive_item": "flour",
		"receive_amount": 1,
		"label": "用草药换面粉",
		"success_text": "商人掂了掂草叶，丢给我一小袋面粉。",
		"fail_text": "他摇头：没有合适的草叶，换不了。",
	})

func offers_at(location_id: String) -> Array:
	var out: Array = []
	for offer in offers:
		if str(offer.get("location_id", "")) == location_id:
			out.append(offer)
	return out

func try_trade(offer: Dictionary, inventory) -> Dictionary:
	if inventory == null:
		return {"ok": false, "message": "拿不动东西。"}
	var give_id: String = str(offer.get("give_item", ""))
	var give_amt: int = int(offer.get("give_amount", 1))
	if not inventory.has_item(give_id, give_amt):
		return {"ok": false, "message": str(offer.get("fail_text", "东西不够。"))}
	inventory.remove_item(give_id, give_amt)
	inventory.add_item(str(offer.get("receive_item", "")), int(offer.get("receive_amount", 1)))
	return {"ok": true, "message": str(offer.get("success_text", "交换完成。"))}
