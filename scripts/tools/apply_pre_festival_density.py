#!/usr/bin/env python3
"""Apply pre-festival density wiring to main_shell.gd (idempotent)."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
candidates = [
    Path("scripts/ui/main_shell.gd"),
    ROOT / "scripts/ui/main_shell.gd",
    Path(__file__).resolve().parents[2] / "scripts/ui/main_shell.gd",
]
path = next((p for p in candidates if p.exists()), None)
if path is None:
    raise SystemExit("main_shell.gd not found")

t = path.read_text(encoding="utf-8")
if "func _visit_shrine_pre" in t:
    print("already applied")
    raise SystemExit(0)

# 1 location actions
a = (
    '\tif loc == "PATH" and int(economy.segment_index) >= 2:\n'
    '\t\t_add_action("帮铁匠打下手", _help_smith, can_heavy)\n'
    '\tif not world_flags.has_flag("festival_done") and economy.segment_index >= 4:\n'
    '\t\t_add_action("前往丰收节（公共场）", _enter_festival, true)'
)
b = (
    '\tif loc == "PATH" and int(economy.segment_index) >= 2:\n'
    '\t\t_add_action("帮铁匠打下手", _help_smith, can_heavy)\n'
    '\tif not world_flags.has_flag("festival_done"):\n'
    '\t\tif loc == "SHRINE":\n'
    '\t\t\t_add_action("在礼拜场所站一会儿", _visit_shrine_pre, can_heavy)\n'
    '\t\tif loc == "CLINIC":\n'
    '\t\t\t_add_action("推开诊疗处的门看看", _visit_clinic_pre, can_heavy)\n'
    '\t\tif loc == "COMMONS" and int(economy.segment_index) >= 3:\n'
    '\t\t\t_add_action("听听远处的鼓声", _listen_drum_pre, true)\n'
    '\tif not world_flags.has_flag("festival_done") and economy.segment_index >= 4:\n'
    '\t\t_add_action("前往丰收节（公共场）", _enter_festival, true)'
)
if a not in t:
    raise SystemExit("anchor loc actions missing")
t = t.replace(a, b, 1)

# 2 observe
a = (
    '\t_set_dialogue("我看了看周围。没什么特别的。")\n'
    "\t_refresh_ui()\n\n"
    "func _rest() -> void:"
)
b = '''\t# 节前观察：按地点给一次有味道的细节
\tif not world_flags.has_flag("festival_done"):
\t\tif loc == "HOME":
\t\t\tif not pre_events.has_seen("OBS_HOME_VASE"):
\t\t\t\tpre_events.mark("OBS_HOME_VASE")
\t\t\t\t_set_dialogue(pre_events.text_observe_home_vase())
\t\t\t\t_refresh_ui()
\t\t\t\treturn
\t\t\tif not pre_events.has_seen("OBS_HOME_HAMMER"):
\t\t\t\tpre_events.mark("OBS_HOME_HAMMER")
\t\t\t\t_set_dialogue(pre_events.text_observe_home_hammer())
\t\t\t\t_refresh_ui()
\t\t\t\treturn
\t\tif loc == "COMMONS" and not pre_events.has_seen("OBS_COMMONS_BASKET"):
\t\t\tpre_events.mark("OBS_COMMONS_BASKET")
\t\t\t_set_dialogue(pre_events.text_observe_commons_basket())
\t\t\t_refresh_ui()
\t\t\treturn
\t\tif loc == "SHRINE" and not pre_events.has_seen("OBS_SHRINE_PAPER"):
\t\t\tpre_events.mark("OBS_SHRINE_PAPER")
\t\t\t_set_dialogue(pre_events.text_observe_shrine_paper())
\t\t\t_refresh_ui()
\t\t\treturn
\t\tif loc == "CLINIC" and not pre_events.has_seen("OBS_CLINIC"):
\t\t\tpre_events.mark("OBS_CLINIC")
\t\t\t_set_dialogue(pre_events.text_observe_clinic())
\t\t\t_refresh_ui()
\t\t\treturn
\t\tif loc == "PATH" and not pre_events.has_seen("OBS_PATH"):
\t\t\tpre_events.mark("OBS_PATH")
\t\t\t_set_dialogue(pre_events.text_observe_path())
\t\t\t_refresh_ui()
\t\t\treturn
\t\tif loc in ["FOREST", "GROVE"] and not pre_events.has_seen("OBS_FOREST_PRE"):
\t\t\tpre_events.mark("OBS_FOREST_PRE")
\t\t\t_set_dialogue(pre_events.text_observe_forest_pre())
\t\t\t_refresh_ui()
\t\t\treturn
\t_set_dialogue("我看了看周围。没什么特别的。")
\t_refresh_ui()

func _rest() -> void:'''
if a not in t:
    raise SystemExit("anchor observe missing")
t = t.replace(a, b, 1)

# 3 rest
a = (
    "\telse:\n"
    '\t\t_set_dialogue("我休息了一会儿。")\n'
    '\t\tif int(info.get("segment_index", 0)) >= 4 and not mode_controller.is_event_focus():\n'
    '\t\t\t_set_dialogue("休息之后，远处隐约有鼓声。或许该去公共场看看丰收节。")\n'
    "\t_refresh_ui()"
)
b = (
    "\telse:\n"
    '\t\tvar seg: int = int(info.get("segment_index", 0))\n'
    "\t\tif seg >= 4 and not mode_controller.is_event_focus():\n"
    '\t\t\t_set_dialogue("休息之后，远处隐约有鼓声。或许该去公共场看看丰收节。")\n'
    '\t\telif seg >= 2 and not pre_events.has_seen("REST_SWEET"):\n'
    '\t\t\tpre_events.mark("REST_SWEET")\n'
    "\t\t\t_set_dialogue(pre_events.text_rest_sweet_night())\n"
    "\t\telse:\n"
    '\t\t\t_set_dialogue("我休息了一会儿。日子悄悄往前走了一点。")\n'
    "\t_refresh_ui()"
)
if a not in t:
    raise SystemExit("anchor rest missing")
t = t.replace(a, b, 1)

# 4 smith + handlers
idx = t.find("func _help_smith")
end = t.find("func _festival_offer_food", idx)
if idx < 0 or end < 0:
    raise SystemExit("smith/festival anchors missing")
replacement = r'''func _help_smith() -> void:
	if not economy.spend_heavy():
		_set_dialogue("臂膀还酸着，改天再帮吧。")
		_refresh_ui()
		return
	if not world_flags.has_flag("festival_done") and not pre_events.has_seen("PF09"):
		pre_events.mark("PF09")
		_set_dialogue(pre_events.text_pf09_smith_water())
	else:
		_set_dialogue(
			"铁匠把一根还烫的铁条丢进水桶，蒸汽直冒。\n"
			+ "「扶一下风箱。对，就这样。」\n\n"
			+ "忙完他丢给我一块干饼：\n「手还行。节前要是闲，再来。」"
		)
	_refresh_ui()


func _visit_shrine_pre() -> void:
	if not economy.spend_heavy():
		_set_dialogue("腿有点沉。改天再来吧。")
		_refresh_ui()
		return
	if not pre_events.has_seen("OBS_SHRINE_PAPER"):
		pre_events.mark("OBS_SHRINE_PAPER")
	_set_dialogue(
		pre_events.text_observe_shrine_paper()
		+ "\n\n我站了一会儿。翻纸的人没有抬头。"
	)
	_refresh_ui()

func _visit_clinic_pre() -> void:
	if not economy.spend_heavy():
		_set_dialogue("不太想再推门了。")
		_refresh_ui()
		return
	if not pre_events.has_seen("OBS_CLINIC"):
		pre_events.mark("OBS_CLINIC")
	_set_dialogue(pre_events.text_observe_clinic())
	_refresh_ui()

func _listen_drum_pre() -> void:
	if not pre_events.has_seen("PF20"):
		pre_events.mark("PF20")
		_set_dialogue(pre_events.text_pf20_drum())
	else:
		_set_dialogue("鼓声又试了一下。一下，又一下。像在数还有多久开节。")
	_refresh_ui()

'''
t = t[:idx] + replacement + t[end:]
path.write_text(t, encoding="utf-8")
print("applied", path, "lines", t.count("\n") + 1)
