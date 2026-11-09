#!/usr/bin/env python3
"""Wire popo food gift + persist segment/inventory/pre_events (idempotent)."""
from pathlib import Path

path = Path("scripts/ui/main_shell.gd")
if not path.exists():
    path = Path(__file__).resolve().parents[2] / "scripts/ui/main_shell.gd"
if not path.exists():
    raise SystemExit("main_shell.gd not found")

t = path.read_text(encoding="utf-8")
if "func _gift_popo" in t and 'data.get("inventory"' in t:
    print("already applied")
    raise SystemExit(0)

# 1) HOME action: gift popo
a = (
    '\t\t_add_action("做饭", _open_kitchen, can_heavy)\n'
    '\t\t_add_action("收取园里的草药", _gather_home_herbs, can_heavy)\n'
)
b = (
    '\t\t_add_action("做饭", _open_kitchen, can_heavy)\n'
    '\t\t_add_action("收取园里的草药", _gather_home_herbs, can_heavy)\n'
    '\t\t_add_action("把食物给老婆婆", _gift_popo, can_heavy)\n'
)
if a not in t:
    raise SystemExit("HOME actions anchor missing")
t = t.replace(a, b, 1)

# 2) item display names expand
a = '''\tvar names := {
\t\t"flour": "面粉", "honey": "蜂蜜", "egg": "鸡蛋", "herb": "草药",
\t\t"spice_moonleaf": "月叶香料", "bread": "面包", "stew": "炖菜",
\t}'''
b = '''\tvar names := {
\t\t"flour": "面粉", "honey": "蜂蜜", "egg": "鸡蛋", "herb": "草药",
\t\t"spice_moonleaf": "月叶香料", "bread": "面包", "stew": "炖菜",
\t\t"honey_bread": "蜂蜜面包", "herb_porridge": "药草粥",
\t}'''
if a in t:
    t = t.replace(a, b, 1)
else:
    print("warn: item names block skipped")

# 3) save payload
a = '''\tvar payload := {
\t\t"location": game_state.current_location,
\t\t"flags": world_flags.flags.duplicate(true),
\t\t"aftermath_seen": aftermath.seen.duplicate(true),
\t\t"knowledge": knowledge.known.duplicate(true),
\t\t"notes": knowledge.notes.duplicate(true),
\t\t"segment": economy.segment_index,
\t\t"festival_helped": festival_helped,
\t\t"festival_offered_food": festival_offered_food,
\t}'''
b = '''\tvar payload := {
\t\t"location": game_state.current_location,
\t\t"flags": world_flags.flags.duplicate(true),
\t\t"aftermath_seen": aftermath.seen.duplicate(true),
\t\t"pre_events_seen": pre_events.seen.duplicate(true),
\t\t"knowledge": knowledge.known.duplicate(true),
\t\t"notes": knowledge.notes.duplicate(true),
\t\t"segment": economy.segment_index,
\t\t"heavy_remaining": economy.heavy_remaining,
\t\t"inventory": player_inventory.items.duplicate(true),
\t\t"festival_helped": festival_helped,
\t\t"festival_offered_food": festival_offered_food,
\t}'''
if a not in t:
    raise SystemExit("save payload anchor missing")
t = t.replace(a, b, 1)

# 4) apply save payload
a = '''\tfestival_helped = bool(data.get("festival_helped", false))
\tfestival_offered_food = bool(data.get("festival_offered_food", false))
\treturn true'''
b = '''\tfestival_helped = bool(data.get("festival_helped", false))
\tfestival_offered_food = bool(data.get("festival_offered_food", false))
\tif data.has("segment"):
\t\teconomy.segment_index = int(data.get("segment", 0))
\tif data.has("heavy_remaining"):
\t\teconomy.heavy_remaining = int(data.get("heavy_remaining", economy.heavy_remaining))
\tvar inv = data.get("inventory", {})
\tif inv is Dictionary and player_inventory != null:
\t\tplayer_inventory.items = inv.duplicate(true)
\tvar pre_seen = data.get("pre_events_seen", {})
\tif pre_seen is Dictionary:
\t\tpre_events.seen = pre_seen.duplicate(true)
\treturn true'''
if a not in t:
    raise SystemExit("apply save anchor missing")
t = t.replace(a, b, 1)

# 5) gift handler
if "func _gift_popo" not in t:
    gift = r'''
func _gift_popo() -> void:
	if not economy.spend_heavy():
		_set_dialogue("今天已经送过一次了，先歇歇。")
		_refresh_ui()
		return
	var food_id := ""
	for id in ["honey_bread", "herb_porridge", "stew", "bread", "honey"]:
		if player_inventory != null and player_inventory.has_item(str(id), 1):
			food_id = str(id)
			break
	if food_id == "":
		_set_dialogue("手里没什么能拿得出手的。先做点吃的，或带一点蜂蜜。")
		_refresh_ui()
		return
	player_inventory.remove_item(food_id, 1)
	world_flags.set_flag("gifted_popo")
	if not pre_events.has_seen("PF06"):
		pre_events.mark("PF06")
		_set_dialogue(pre_events.text_pf06_gift_popo())
	else:
		_set_dialogue(
			"老婆婆接过去，吹了吹：\n"
			+ "「还热。」\n\n"
			+ "她没再多说。碗沿的温度却像一句夸奖。"
		)
	_refresh_ui()

'''
    t = t.replace("func _open_kitchen", gift + "func _open_kitchen", 1)

# 6) kitchen cooking completed message
a = '''func _on_kitchen_cooking_completed(_result) -> void:
	_refresh_ui()'''
b = '''func _on_kitchen_cooking_completed(_result) -> void:
	_set_dialogue("炉火歇了。做好的东西可以放进背包，也可以拿去给老婆婆。")
	_refresh_ui()'''
if a in t:
    t = t.replace(a, b, 1)

path.write_text(t, encoding="utf-8")
print("applied", path, "lines", t.count("\n") + 1)
