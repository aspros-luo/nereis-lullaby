#!/usr/bin/env python3
"""Post-festival rescue interlude AF13 (path) + rest echo + ending F (idempotent)."""
from pathlib import Path

path = Path("scripts/systems/daily/aftermath_storylets.gd")
if not path.exists():
    path = Path(__file__).resolve().parents[2] / "scripts/systems/daily/aftermath_storylets.gd"
t = path.read_text(encoding="utf-8")
if "AF13_rescue_cry" in t:
    print("aftermath already applied")
else:
    insert = '''\tif loc == "PATH" and has_seen("AF04_clinic_quiet") and not has_seen("AF13_rescue_cry"):
\t\tmark("AF13_rescue_cry")
\t\tvar cry := (
\t\t\t"通路拐角外传来一声压得很低的抽气。\\n"
\t\t\t+ "不是叫喊。像有人把痛咬在牙里，只漏出一点。\\n\\n"
\t\t)
\t\tif has_seen("AF06_hero_glimpse"):
\t\t\tcry += "声音不在脚印延伸的方向，而在路肩的草丛后。\\n像另一件事，挤在同一条路上。"
\t\telse:
\t\t\tcry += "草丛后有人蜷着。袖口深了一块颜色。"
\t\treturn {
\t\t\t"id": "AF13_rescue_cry",
\t\t\t"text": cry,
\t\t\t"learn": {"id": "path_someone_hurt", "note": "通路旁有人受伤，痛声压得很低。"},
\t\t}
\tif loc == "PATH" and has_seen("AF13_rescue_cry") and not has_seen("AF13_rescue_help"):
\t\tmark("AF13_rescue_help")
\t\tvar help := (
\t\t\t"我拨开草。对方抬眼看我，先是防备，随即卸了一点。\\n\\n"
\t\t\t+ "小臂有一道口子，不深，血已经半干。\\n"
\t\t)
\t\tif has_seen("AF04_clinic_quiet") or has_seen("AF04b_record_margin"):
\t\t\thelp += (
\t\t\t\t"我想起诊疗处那卷还没拆的纱布——这里没有。\\n"
\t\t\t\t+ "只能撕自己衣摆内侧的布，绕紧，再打结。\\n\\n"
\t\t\t)
\t\telse:
\t\t\thelp += "我撕下衣摆内侧一块布，绕紧，再打结。\\n\\n"
\t\tif bool(flags.get("festival_offered_food", false)) or bool(flags.get("gifted_popo", false)):
\t\t\thelp += "对方沙哑道谢，说家里还有热的，却推了推我：\\n「你留着。路还长。」\\n\\n"
\t\telse:
\t\t\thelp += "对方只说：「……谢了。」没有报名字。\\n\\n"
\t\thelper_end := (
\t\t\t"站起来时，他往林缘偏了一眼，又很快收回。\\n"
\t\t\t+ "「别跟着。有人看见，对你不好。」\\n\\n"
\t\t\t+ "脚步乱了一拍，仍是自己走了。"
\t\t)
\t\thelp += helper_end
\t\treturn {
\t\t\t"id": "AF13_rescue_help",
\t\t\t"text": help,
\t\t\t"learn": {"id": "path_rescue", "note": "在通路旁为受伤者包扎；对方不愿被跟随，目光曾偏向林缘。"},
\t\t\t"set_flag": "rescue_helped",
\t\t}
'''
    anchor = '\tif loc == "GROVE" and has_seen("AF06_hero_glimpse") and not has_seen("AF09_hero_meet"):\n'
    if anchor not in t:
        raise SystemExit("GROVE AF09 anchor missing")
    t = t.replace(anchor, insert + anchor, 1)

    rest_anchor = '\tif not has_seen("AF11_ending_soft") and (has_seen("AF07_threshold") or has_seen("AF10_hero_after") or _aftermath_depth() >= 6):\n'
    rest_echo = '''\tif has_seen("AF13_rescue_help") and not has_seen("AF13_rescue_echo"):
\t\tmark("AF13_rescue_echo")
\t\treturn {
\t\t\t"id": "AF13_rescue_echo",
\t\t\t"text": (
\t\t\t\t"夜里指缝里还留着一点干结的触感。\\n"
\t\t\t\t+ "那人没留下名字，也没说去哪里。\\n\\n"
\t\t\t\t+ "只记得他说：有人看见，对你不好。\\n"
\t\t\t\t+ "——像谢意，也像一条界。"
\t\t\t),
\t\t}
'''
    if "AF13_rescue_echo" not in t:
        if rest_anchor not in t:
            raise SystemExit("AF11 rest anchor missing")
        t = t.replace(rest_anchor, rest_echo + rest_anchor, 1)

    lab_old = '\tif loc == "PATH" and has_seen("AF02_visitor_rumor") and not has_seen("AF06_hero_glimpse"):\n\t\treturn "辨认路边的脚印"\n'
    lab_new = lab_old + (
        '\tif loc == "PATH" and has_seen("AF04_clinic_quiet") and not has_seen("AF13_rescue_cry"):\n'
        '\t\treturn "辨认路旁的动静"\n'
        '\tif loc == "PATH" and has_seen("AF13_rescue_cry") and not has_seen("AF13_rescue_help"):\n'
        '\t\treturn "循声过去帮忙"\n'
    )
    if "辨认路旁的动静" not in t:
        if lab_old not in t:
            raise SystemExit("PATH label anchor missing")
        t = t.replace(lab_old, lab_new, 1)

    path.write_text(t, encoding="utf-8")
    print("aftermath applied", path, "lines", t.count("\n") + 1)

ep = Path("scripts/systems/daily/ending_resolver.gd")
if not ep.exists():
    ep = Path(__file__).resolve().parents[2] / "scripts/systems/daily/ending_resolver.gd"
et = ep.read_text(encoding="utf-8")
if "rescue_helped" in et:
    print("ending already has rescue_helped")
else:
    old = '\tif bool(flags.get("hero_met", false)):\n\t\tF += 18.0\n\t\tE += 3.0\n'
    new = (
        '\tif bool(flags.get("rescue_helped", false)):\n'
        '\t\tF += 10.0\n'
        '\t\tE += 4.0\n'
        '\t\tA += 3.0\n'
        '\tif bool(flags.get("hero_met", false)):\n'
        '\t\tF += 18.0\n'
        '\t\tE += 3.0\n'
    )
    if old not in et:
        raise SystemExit("hero_met block missing in ending_resolver")
    et = et.replace(old, new, 1)
    ep.write_text(et, encoding="utf-8")
    print("ending applied", ep)

print("done")
