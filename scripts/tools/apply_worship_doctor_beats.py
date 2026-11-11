#!/usr/bin/env python3
"""Inject worship/doctor TALK_BEATS + shrine presence into npc_behavior_logic.gd."""
from pathlib import Path

path = Path("scripts/systems/daily/npc_behavior_logic.gd")
if not path.exists():
    path = Path(__file__).resolve().parents[2] / "scripts/systems/daily/npc_behavior_logic.gd"
t = path.read_text(encoding="utf-8")
if '"worship"' in t and "TALK_BEATS" in t and "礼拜主持把一束" in t:
    print("already applied")
    raise SystemExit(0)

old_p = (
    "\tif key == \"doctor\" and location == \"CLINIC\":\n"
    "\t\treturn \"诊疗处有人翻记录的声音\" if not festival_done else \"诊疗处异常安静\"\n"
    "\tif key == \"hero\" and location in [\"GROVE\", \"FOREST\"] and festival_done:\n"
)
new_p = (
    "\tif key == \"doctor\" and location == \"CLINIC\":\n"
    "\t\treturn \"诊疗处有人翻记录的声音\" if not festival_done else \"诊疗处异常安静\"\n"
    "\tif key == \"worship_leader\" and location == \"SHRINE\":\n"
    "\t\treturn \"礼拜场所里有人翻纸的声音\" if not festival_done else \"礼拜场所很静，整理过的痕迹比人声清楚\"\n"
    "\tif key == \"hero\" and location in [\"GROVE\", \"FOREST\"] and festival_done:\n"
)
if old_p not in t:
    raise SystemExit("presence anchor missing")
t = t.replace(old_p, new_p, 1)

marker = (
    "\t\"merchant\": {\n"
    "\t\t\"pre\": {\"default\": \"商人压低声音说林子边上有野葱，煮汤刚好。像顺口，又像在换一种招呼。\"},\n"
    "\t\t\"post\": {\"default\": \"商人：「节后的路好走些。你若还收草药，我下回还带。」担子已经绑紧了一半。\"},\n"
    "\t},\n"
    "}\n"
)
insert = (
    "\t\"merchant\": {\n"
    "\t\t\"pre\": {\"default\": \"商人压低声音说林子边上有野葱，煮汤刚好。像顺口，又像在换一种招呼。\"},\n"
    "\t\t\"post\": {\"default\": \"商人：「节后的路好走些。你若还收草药，我下回还带。」担子已经绑紧了一半。\"},\n"
    "\t},\n"
    "\t\"worship\": {\n"
    "\t\t\"pre\": {\"default\": \"礼拜主持把一束还没束紧的花放正：「节前要核对的东西多。你若只是站一站，也行。」名单在更里面的桌上，边角压得很平。\"},\n"
    "\t\t\"post\": {\n"
    "\t\t\t\"refused\": \"主持看了我一眼：「没来也没关系。有些位置，本来就不是人人都要站上去。」\",\n"
    "\t\t\t\"helped\": \"主持点了点头：「节上见过你帮忙。手稳的人，名单外也用得着。」他说完就把话收回去了。\",\n"
    "\t\t\t\"offered\": \"主持：「桌上有盘还热的。有人问是谁做的，没人答。吃过的人，记得自己坐过哪里就好。」\",\n"
    "\t\t\t\"default\": \"名单不在桌上。主持用布擦了一下木纹：「整理过了。你若来只是站一站，也可以。」\",\n"
    "\t\t},\n"
    "\t},\n"
    "\t\"worship_leader\": {\n"
    "\t\t\"pre\": {\"default\": \"礼拜主持把一束还没束紧的花放正：「节前要核对的东西多。你若只是站一站，也行。」名单在更里面的桌上，边角压得很平。\"},\n"
    "\t\t\"post\": {\n"
    "\t\t\t\"refused\": \"主持看了我一眼：「没来也没关系。有些位置，本来就不是人人都要站上去。」\",\n"
    "\t\t\t\"helped\": \"主持点了点头：「节上见过你帮忙。手稳的人，名单外也用得着。」他说完就把话收回去了。\",\n"
    "\t\t\t\"offered\": \"主持：「桌上有盘还热的。有人问是谁做的，没人答。吃过的人，记得自己坐过哪里就好。」\",\n"
    "\t\t\t\"default\": \"名单不在桌上。主持用布擦了一下木纹：「整理过了。你若来只是站一站，也可以。」\",\n"
    "\t\t},\n"
    "\t},\n"
    "\t\"doctor\": {\n"
    "\t\t\"pre\": {\"default\": \"诊疗处的人把药瓶归位：「外面若是割伤、烫着，先洗干净再来。」记录本合着，日期那一栏墨水比别处新一点。\"},\n"
    "\t\t\"post\": {\"default\": \"门半掩着。架子上多了未拆封的纱布。里间有人应了一声：「节后少出门。需要时再敲。」\"},\n"
    "\t},\n"
    "}\n"
)
if marker not in t:
    raise SystemExit("TALK_BEATS merchant marker missing")
t = t.replace(marker, insert, 1)
path.write_text(t, encoding="utf-8")
print("applied", path, "lines", t.count("\n") + 1)
