class_name CookingGiftService
extends RefCounted

## Give cooked food to an NPC.
## Player sees only dialogue / soft feedback — never affinity numbers.

const CookingWorldInfluenceScript = preload("res://scripts/systems/cooking/cooking_world_influence.gd")

class GiftResult:
	var success: bool = false
	var message: String = ""
	var npc_id: String = ""
	var food_id: String = ""
	var relationship_delta: int = 0 # hidden; do not show in UI

	static func ok(npc: String, food: String, line: String, delta: int) -> GiftResult:
		var r := GiftResult.new()
		r.success = true
		r.npc_id = npc
		r.food_id = food
		r.message = line
		r.relationship_delta = delta
		return r

	static func fail(line: String) -> GiftResult:
		var r := GiftResult.new()
		r.success = false
		r.message = line
		return r

const GIFT_LINES := {
	"caregiver": {
		"honey_bread": "照料者接过还热着的面包，笑着说家里又有了熟悉的甜味。",
		"herb_porridge": "照料者吹了吹热气，说这种温和的粥很适合夜里喝。",
		"default": "照料者收下了食物，轻轻道谢。",
	},
	"doctor": {
		"honey_bread": "医生点点头，说甜食偶尔也不错，但别一次吃太多。",
		"herb_porridge": "医生闻了闻，说草药的气味很干净，适合病人恢复时食用。",
		"default": "医生把食物放在一旁，说会记得这份心意。",
	},
	"worship_leader": {
		"honey_bread": "礼拜主持者双手接过面包，说简单的食物也值得认真对待。",
		"herb_porridge": "他接过粥，说温热的东西总能让人安静下来。",
		"default": "他郑重道谢，把食物放在木台上。",
	},
}

func can_gift(inventory, food_id: String) -> bool:
	if inventory == null:
		return false
	return inventory.has_item(food_id, 1)

func gift_food(inventory, npc_id: String, food_id: String, game_state = null) -> GiftResult:
	if inventory == null:
		return GiftResult.fail("手里没有可以送出的东西。")
	if not inventory.has_item(food_id, 1):
		return GiftResult.fail("没有可以送出的%s。" % food_id)
	if npc_id.strip_edges().is_empty():
		return GiftResult.fail("不知道该把食物交给谁。")

	if not inventory.remove_item(food_id, 1):
		return GiftResult.fail("没能把食物交出去。")

	var delta: int = CookingWorldInfluenceScript.gift_affinity_bonus(food_id, npc_id)
	if delta < 0:
		delta = 0

	# Soft relationship bump if game_state supports it (hidden magnitude).
	if game_state != null and game_state.has_method("increase_relationship") and delta > 0:
		game_state.increase_relationship(npc_id, delta)

	# Hidden gift ledger inside world flags.
	if game_state != null and ("world_state" in game_state):
		var flags: Dictionary = game_state.world_state.get("flags", {})
		var cooking_flags: Dictionary = flags.get("cooking_hidden", {})
		if not (cooking_flags is Dictionary):
			cooking_flags = {}
		var gifts: Dictionary = cooking_flags.get("gifts_given", {})
		if not (gifts is Dictionary):
			gifts = {}
		var key := "%s:%s" % [npc_id, food_id]
		gifts[key] = int(gifts.get(key, 0)) + 1
		cooking_flags["gifts_given"] = gifts
		flags["cooking_hidden"] = cooking_flags
		game_state.world_state["flags"] = flags

	var line := _line_for(npc_id, food_id)
	return GiftResult.ok(npc_id, food_id, line, delta)

func _line_for(npc_id: String, food_id: String) -> String:
	var by_npc: Dictionary = GIFT_LINES.get(npc_id, {})
	if by_npc.has(food_id):
		return str(by_npc[food_id])
	if by_npc.has("default"):
		return str(by_npc["default"])
	return "对方收下了食物，轻轻点了点头。"
