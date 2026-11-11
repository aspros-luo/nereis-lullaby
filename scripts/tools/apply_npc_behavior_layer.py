#!/usr/bin/env python3
"""Wire NPC behavior layer + PF07/PF08 gift actions into main_shell (idempotent)."""
from pathlib import Path
import re

path = Path("scripts/ui/main_shell.gd")
if not path.exists():
    path = Path(__file__).resolve().parents[2] / "scripts/ui/main_shell.gd"
t = path.read_text(encoding="utf-8")
if "NpcShellBridgeScript" in t and "func _gift_smith" in t:
    print("already applied")
    raise SystemExit(0)

a = 'const SoftEndingPageScript = preload("res://scripts/ui/soft_ending_page.gd")\n'
b = a + 'const NpcShellBridgeScript = preload("res://scripts/systems/daily/npc_shell_bridge.gd")\n'
if "NpcShellBridgeScript" not in t:
    if a not in t:
        raise SystemExit("SoftEnding preload missing")
    t = t.replace(a, b, 1)

if "var npc_bridge" not in t:
    a = "var ending_page\n"
    b = "var ending_page\nvar npc_bridge\nvar smith_helped_segment: bool = false\n"
    if a not in t:
        raise SystemExit("ending_page var missing")
    t = t.replace(a, b, 1)

if "npc_bridge =" not in t:
    a = "\taftermath = AftermathStoryletsScript.new()\n"
    b = "\taftermath = AftermathStoryletsScript.new()\n\tnpc_bridge = NpcShellBridgeScript.new()\n"
    if a not in t:
        raise SystemExit("aftermath init missing")
    t = t.replace(a, b, 1)

if "smith_helped_segment = false" not in t:
    a = "func _rest() -> void:\n\tvar info = economy.rest()\n"
    b = "func _rest() -> void:\n\tvar info = economy.rest()\n\tsmith_helped_segment = false\n"
    if a not in t:
        raise SystemExit("rest anchor missing")
    t = t.replace(a, b, 1)

a = '''\tif loc == "PATH" and int(economy.segment_index) >= 2:
\t\t_add_action("帮铁匠打下手", _help_smith, can_heavy)
'''
b = '''\tif loc == "PATH" and int(economy.segment_index) >= 2:
\t\t_add_action("帮铁匠打下手", _help_smith, can_heavy)
\t\t_add_action("把食物留给铁匠", _gift_smith, can_heavy)
'''
if "_gift_smith" not in t:
    if a not in t:
        raise SystemExit("PATH actions missing")
    t = t.replace(a, b, 1)

a = '''\tif loc == "COMMONS":
\t\t_add_action("和外地商人聊聊", _talk_merchant, can_heavy)
\t\t_add_action("用草药换面粉", _trade_herb_flour, can_heavy)
'''
b = '''\tif loc == "COMMONS":
\t\t_add_action("和外地商人聊聊", _talk_merchant, can_heavy)
\t\t_add_action("用草药换面粉", _trade_herb_flour, can_heavy)
\t\t_add_action("把食物分给过路人", _share_food_commons, can_heavy)
'''
if "_share_food_commons" not in t:
    if a not in t:
        raise SystemExit("COMMONS actions missing")
    t = t.replace(a, b, 1)

helpers = r'''
func _npc_ctx(authored_active: bool = false) -> Dictionary:
	return npc_bridge.make_ctx(
		str(game_state.current_location),
		world_flags.has_flag("festival_done"),
		mode_controller.is_event_focus(),
		world_flags.flags,
		int(economy.segment_index),
		authored_active,
		smith_helped_segment
	)

func _apply_portrait_key(key: String) -> void:
	if portrait_image != null and portrait_label != null:
		VisualLibraryScript.apply_portrait(portrait_image, portrait_label, key)

'''

if "npc_bridge.talk_line(\"popo\"" not in t:
    new_popo = '''func _talk_popo() -> void:
	if not economy.spend_heavy():
		return
	_apply_portrait_key("popo")
	var festival_done: bool = world_flags.has_flag("festival_done")
	if not festival_done:
		var beat: Dictionary = pre_events.resolve_popo_talk(int(economy.segment_index), false)
		var text: String = str(beat.get("text", "老婆婆看了看我，没多说。"))
		if bool(beat.get("learn_herb", false)) and knowledge != null:
			knowledge.learn("know_home_herb_patch", "老婆婆说门前园子里的草可以摘来用。")
		_set_dialogue(text)
	else:
		var line: String = npc_bridge.talk_line("popo", _npc_ctx())
		if line == "":
			line = "老婆婆把我头发上一点碎花瓣拈掉，说：办完就好，别想太多。她的手很稳，笑却浅了一点。"
		var note: String = npc_bridge.presence_note("popo", "HOME", true, false)
		if note != "":
			line = note + "\\n\\n" + line
		_set_dialogue(line)
	_refresh_ui()

'''
    start = t.find("func _talk_popo()")
    end = t.find("\nfunc ", start + 5)
    t = t[:start] + new_popo + t[end+1:]

if "npc_bridge.talk_line(\"merchant\"" not in t:
    new_mer = '''func _talk_merchant() -> void:
	if not economy.spend_heavy():
		_set_dialogue("懒得再开口了。")
		_refresh_ui()
		return
	_apply_portrait_key("merchant")
	var line: String = npc_bridge.talk_line("merchant", _npc_ctx())
	if line == "":
		line = (
			"外地商人把布摊掀开一角，说：\\n"
			+ "「草叶新鲜的话，可以换面粉。村里节前都这样换。」\\n\\n"
			+ "他看了看我的手：\\n「有就拿来。没有也行，我在这儿停到鼓响。」"
		)
	if knowledge != null and not knowledge.has("know_home_herb_patch"):
		knowledge.learn("know_home_herb_patch", "商人说门前园子的草也能换东西。")
	var note: String = npc_bridge.presence_note("merchant", "COMMONS", world_flags.has_flag("festival_done"), false)
	if note != "":
		line = note + "\\n\\n" + line
	_set_dialogue(line)
	_refresh_ui()

'''
    start = t.find("func _talk_merchant()")
    end = t.find("\nfunc ", start + 5)
    t = t[:start] + new_mer + t[end+1:]

if "smith_helped_segment = true" not in t:
    new_smith = '''func _help_smith() -> void:
	if not economy.spend_heavy():
		_set_dialogue("臂膀还酸着，改天再帮吧。")
		_refresh_ui()
		return
	_apply_portrait_key("smith")
	smith_helped_segment = true
	if not world_flags.has_flag("festival_done") and not pre_events.has_seen("PF09"):
		pre_events.mark("PF09")
		_set_dialogue(pre_events.text_pf09_smith_water())
	else:
		var line: String = npc_bridge.talk_line("smith", _npc_ctx())
		if line == "":
			line = (
				"铁匠把一根还烫的铁条丢进水桶，蒸汽直冒。\\n"
				+ "「扶一下风箱。对，就这样。」\\n\\n"
				+ "忙完他丢给我一块干饼：\\n「手还行。节前要是闲，再来。」"
			)
		_set_dialogue(line)
	_refresh_ui()

'''
    start = t.find("func _help_smith()")
    end = t.find("\nfunc ", start + 5)
    t = t[:start] + new_smith + t[end+1:]

if "func _gift_smith" not in t:
    gifts = r'''
func _pick_giftable_food() -> String:
	for id in ["honey_bread", "herb_porridge", "stew", "bread", "honey"]:
		if player_inventory != null and player_inventory.has_item(str(id), 1):
			return str(id)
	return ""

func _gift_smith() -> void:
	if not economy.spend_heavy():
		_set_dialogue("手空着，改天再带一份。")
		_refresh_ui()
		return
	_apply_portrait_key("smith")
	var food_id := _pick_giftable_food()
	if food_id == "":
		_set_dialogue("没有能留下的食物。先做一份，或带一点蜂蜜。")
		_refresh_ui()
		return
	player_inventory.remove_item(food_id, 1)
	world_flags.set_flag("gifted_smith")
	if not pre_events.has_seen("PF07"):
		pre_events.mark("PF07")
		_set_dialogue(pre_events.text_pf07_gift_smith())
	else:
		_set_dialogue("铁匠接过去，锤声只乱了一拍，又稳回去。")
	_refresh_ui()

func _share_food_commons() -> void:
	if not economy.spend_heavy():
		_set_dialogue("今天已经分过一次了。")
		_refresh_ui()
		return
	var food_id := _pick_giftable_food()
	if food_id == "":
		_set_dialogue("手里没有能分出去的东西。")
		_refresh_ui()
		return
	player_inventory.remove_item(food_id, 1)
	world_flags.set_flag("shared_food_commons")
	if not pre_events.has_seen("PF08"):
		pre_events.mark("PF08")
		_set_dialogue(pre_events.text_pf08_share_commons())
	else:
		_set_dialogue("又一份热气融进公共场的噪声里。有人点头，有人只是笑。")
	_refresh_ui()

'''
    if "func _gift_popo" in t:
        t = t.replace("func _gift_popo", gifts + "func _gift_popo", 1)
    else:
        raise SystemExit("gift_popo missing")

if "func _npc_ctx" not in t:
    if "func _setup_ending_page" in t:
        t = t.replace("func _setup_ending_page", helpers + "func _setup_ending_page", 1)
    else:
        t = t.replace("func _gift_popo", helpers + "func _gift_popo", 1)

path.write_text(t, encoding="utf-8")
print("applied", path, "lines", t.count("\n") + 1)
