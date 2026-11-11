#!/usr/bin/env python3
"""Add shrine worship / clinic doctor talk actions (idempotent)."""
from pathlib import Path

path = Path("scripts/ui/main_shell.gd")
if not path.exists():
    path = Path(__file__).resolve().parents[2] / "scripts/ui/main_shell.gd"
t = path.read_text(encoding="utf-8")
if "func _talk_worship" in t and "func _talk_doctor" in t:
    print("already applied")
    raise SystemExit(0)

old = (
    "\tif not world_flags.has_flag(\"festival_done\"):\n"
    "\t\tif loc == \"SHRINE\":\n"
    "\t\t\t_add_action(\"在礼拜场所站一会儿\", _visit_shrine_pre, can_heavy)\n"
    "\t\tif loc == \"CLINIC\":\n"
    "\t\t\t_add_action(\"推开诊疗处的门看看\", _visit_clinic_pre, can_heavy)\n"
    "\t\tif loc == \"COMMONS\" and int(economy.segment_index) >= 3:\n"
    "\t\t\t_add_action(\"听听远处的鼓声\", _listen_drum_pre, true)\n"
)
new = (
    "\tif loc == \"SHRINE\":\n"
    "\t\tif not world_flags.has_flag(\"festival_done\"):\n"
    "\t\t\t_add_action(\"在礼拜场所站一会儿\", _visit_shrine_pre, can_heavy)\n"
    "\t\t_add_action(\"和礼拜主持说几句\", _talk_worship, can_heavy)\n"
    "\tif loc == \"CLINIC\":\n"
    "\t\tif not world_flags.has_flag(\"festival_done\"):\n"
    "\t\t\t_add_action(\"推开诊疗处的门看看\", _visit_clinic_pre, can_heavy)\n"
    "\t\t_add_action(\"向诊疗处的人打听\", _talk_doctor, can_heavy)\n"
    "\tif not world_flags.has_flag(\"festival_done\"):\n"
    "\t\tif loc == \"COMMONS\" and int(economy.segment_index) >= 3:\n"
    "\t\t\t_add_action(\"听听远处的鼓声\", _listen_drum_pre, true)\n"
)
if old not in t:
    raise SystemExit("location actions block missing")
t = t.replace(old, new, 1)

handlers = (
    "\nfunc _talk_worship() -> void:\n"
    "\tif not economy.spend_heavy():\n"
    "\t\t_set_dialogue(\"不太想再开口了。\")\n"
    "\t\t_refresh_ui()\n"
    "\t\treturn\n"
    "\t_apply_portrait_key(\"worship\")\n"
    "\tvar line: String = npc_bridge.talk_line(\"worship\", _npc_ctx())\n"
    "\tif line == \"\":\n"
    "\t\tline = npc_bridge.talk_line(\"worship_leader\", _npc_ctx())\n"
    "\tif line == \"\":\n"
    "\t\tline = \"礼拜主持点了点头，没有多说。花束的影子在木桌上轻轻晃。\"\n"
    "\tvar note: String = npc_bridge.presence_note(\"worship\", \"SHRINE\", world_flags.has_flag(\"festival_done\"), false)\n"
    "\tif note != \"\":\n"
    "\t\tline = note + \"\\n\\n\" + line\n"
    "\t_set_dialogue(line)\n"
    "\t_refresh_ui()\n"
    "\n"
    "func _talk_doctor() -> void:\n"
    "\tif not economy.spend_heavy():\n"
    "\t\t_set_dialogue(\"不太想再问了。\")\n"
    "\t\t_refresh_ui()\n"
    "\t\treturn\n"
    "\t_apply_portrait_key(\"doctor\")\n"
    "\tvar line: String = npc_bridge.talk_line(\"doctor\", _npc_ctx())\n"
    "\tif line == \"\":\n"
    "\t\tline = \"诊疗处很安静。药瓶反射着一点冷光。\"\n"
    "\tvar note: String = npc_bridge.presence_note(\"doctor\", \"CLINIC\", world_flags.has_flag(\"festival_done\"), false)\n"
    "\tif note != \"\":\n"
    "\t\tline = note + \"\\n\\n\" + line\n"
    "\t_set_dialogue(line)\n"
    "\t_refresh_ui()\n"
    "\n"
)

old_v = (
    "func _visit_shrine_pre() -> void:\n"
    "\tif not economy.spend_heavy():\n"
    "\t\t_set_dialogue(\"腿有点沉。改天再来吧。\")\n"
    "\t\t_refresh_ui()\n"
    "\t\treturn\n"
    "\tif not pre_events.has_seen(\"OBS_SHRINE_PAPER\"):\n"
    "\t\tpre_events.mark(\"OBS_SHRINE_PAPER\")\n"
    "\t_set_dialogue(\n"
    "\t\tpre_events.text_observe_shrine_paper()\n"
    "\t\t+ \"\\n\\n我站了一会儿。翻纸的人没有抬头。\"\n"
    "\t)\n"
    "\t_refresh_ui()\n"
    "\n"
    "func _visit_clinic_pre() -> void:\n"
    "\tif not economy.spend_heavy():\n"
    "\t\t_set_dialogue(\"不太想再推门了。\")\n"
    "\t\t_refresh_ui()\n"
    "\t\treturn\n"
    "\tif not pre_events.has_seen(\"OBS_CLINIC\"):\n"
    "\t\tpre_events.mark(\"OBS_CLINIC\")\n"
    "\t_set_dialogue(pre_events.text_observe_clinic())\n"
    "\t_refresh_ui()\n"
)
new_v = (
    "func _visit_shrine_pre() -> void:\n"
    "\tif not economy.spend_heavy():\n"
    "\t\t_set_dialogue(\"腿有点沉。改天再来吧。\")\n"
    "\t\t_refresh_ui()\n"
    "\t\treturn\n"
    "\t_apply_portrait_key(\"worship\")\n"
    "\tif not pre_events.has_seen(\"OBS_SHRINE_PAPER\"):\n"
    "\t\tpre_events.mark(\"OBS_SHRINE_PAPER\")\n"
    "\tvar extra: String = npc_bridge.routine_line(\"worship\", _npc_ctx())\n"
    "\tvar body: String = pre_events.text_observe_shrine_paper() + \"\\n\\n我站了一会儿。翻纸的人没有抬头。\"\n"
    "\tif extra != \"\":\n"
    "\t\tbody += \"\\n\\n\" + extra\n"
    "\t_set_dialogue(body)\n"
    "\t_refresh_ui()\n"
    "\n"
    "func _visit_clinic_pre() -> void:\n"
    "\tif not economy.spend_heavy():\n"
    "\t\t_set_dialogue(\"不太想再推门了。\")\n"
    "\t\t_refresh_ui()\n"
    "\t\treturn\n"
    "\t_apply_portrait_key(\"doctor\")\n"
    "\tif not pre_events.has_seen(\"OBS_CLINIC\"):\n"
    "\t\tpre_events.mark(\"OBS_CLINIC\")\n"
    "\tvar extra2: String = npc_bridge.routine_line(\"doctor\", _npc_ctx())\n"
    "\tvar body2: String = pre_events.text_observe_clinic()\n"
    "\tif extra2 != \"\":\n"
    "\t\tbody2 += \"\\n\\n\" + extra2\n"
    "\t_set_dialogue(body2)\n"
    "\t_refresh_ui()\n"
)
if old_v not in t:
    raise SystemExit("visit handlers missing")
t = t.replace(old_v, new_v, 1)
t = t.replace("func _visit_shrine_pre", handlers + "func _visit_shrine_pre", 1)

path.write_text(t, encoding="utf-8")
print("applied", path, "lines", t.count("\n") + 1)
