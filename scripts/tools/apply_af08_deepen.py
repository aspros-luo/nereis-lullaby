#!/usr/bin/env python3
"""Deepen AF08 shrine list-reread (two steps) + AF04 clinic second beat (idempotent)."""
from pathlib import Path

path = Path("scripts/systems/daily/aftermath_storylets.gd")
if not path.exists():
    path = Path(__file__).resolve().parents[2] / "scripts/systems/daily/aftermath_storylets.gd"
t = path.read_text(encoding="utf-8")
if "AF08b_list_gap" in t:
    print("already applied")
    raise SystemExit(0)

old_af08 = '''\tif loc == "SHRINE" and bool(flags.get("trace_shrine_flowers", false)) and not has_seen("AF08_shrine_reread"):
\t\tmark("AF08_shrine_reread")
\t\tvar shrine := "角落那束旧花还在。绳子勒出的印比昨天更深一点——或者只是我看久了。\\n\\n"
\t\tif bool(flags.get("festival_helped", false)) or bool(flags.get("festival_offered_food", false)):
\t\t\tshrine += "有人在门口对我点了点头。很轻。像确认我还在名单能看见的那一侧。"
\t\telif bool(flags.get("festival_refused", false)):
\t\t\tshrine += "门口经过的人目光从我身上滑开，速度太均匀，均匀得像练习过。"
\t\telse:
\t\t\tshrine += "名单仍不在桌上。翻纸的声音也没有回来。"
\t\treturn {"id": "AF08_shrine_reread", "text": shrine}
'''

new_af08 = '''\tif loc == "SHRINE" and bool(flags.get("trace_shrine_flowers", false)) and not has_seen("AF08_shrine_reread"):
\t\tmark("AF08_shrine_reread")
\t\tvar shrine := (
\t\t\t"角落那束旧花还在。绳子勒出的印比昨天更深一点——或者只是我看久了。\\n\\n"
\t\t\t+ "花瓣边缘干得发脆。桌面中央空着一块长方形的木色，\\n"
\t\t\t+ "比四周更浅：像长期被一张纸压着，纸却被收走了。\\n\\n"
\t\t)
\t\tif bool(flags.get("festival_helped", false)) or bool(flags.get("festival_offered_food", false)):
\t\t\tshrine += "有人在门口对我点了点头。很轻。像确认我还在「能被看见」的那一侧。"
\t\telif bool(flags.get("festival_refused", false)):
\t\t\tshrine += "门口经过的人目光从我身上滑开，速度太均匀，均匀得像练习过。"
\t\telse:
\t\t\tshrine += "翻纸的声音没有回来。只有绳子与木桌的细响。"
\t\treturn {
\t\t\t"id": "AF08_shrine_reread",
\t\t\t"text": shrine,
\t\t\t"learn": {"id": "shrine_flower_reread", "note": "礼拜场所旧花仍在；桌面有被名单压过的浅痕，名单本身却不在。"},
\t\t\t"set_flag": "trace_shrine_list_gap",
\t\t}
\tif loc == "SHRINE" and has_seen("AF08_shrine_reread") and not has_seen("AF08b_list_gap"):
\t\tmark("AF08b_list_gap")
\t\tvar gap := (
\t\t\t"我又在那块浅痕前停了一会儿。\\n\\n"
\t\t\t+ "木纹里嵌着极细的墨点，洗不掉，也读不成字。\\n"
\t\t\t+ "像有人用潮湿的布擦过名字，只留下不愿意被彻底忘记的一点黑。\\n\\n"
\t\t)
\t\tif bool(flags.get("hero_met", false)) or has_seen("AF09_hero_talk"):
\t\t\tgap += "忽然想起林缘那人说的「整理」。\\n桌子空着，整理却像还没结束。"
\t\telif bool(flags.get("festival_refused", false)):
\t\t\tgap += "空位比花香更清楚。我不确定自己是站在桌内，还是桌外。"
\t\telse:
\t\t\tgap += "若把掌心盖上去，温度会先凉一下，再慢慢跟上呼吸。"
\t\treturn {
\t\t\t"id": "AF08b_list_gap",
\t\t\t"text": gap,
\t\t\t"learn": {"id": "list_gap_ink", "note": "名单桌面有洗不掉的细墨点；名字被整理过，痕迹却还在。"},
\t\t\t"set_flag": "trace_list_ink",
\t\t}
'''

if old_af08 not in t:
    raise SystemExit("AF08 block not found")
t = t.replace(old_af08, new_af08, 1)

needle = '''\t\treturn {
\t\t\t"id": "AF04_clinic_quiet",
\t\t\t"text": clinic,
\t\t\t"learn": {"id": "clinic_quiet", "note": "诊疗处有未拆封的新纱布，人却不在。"},
\t\t}
'''
insert_after = needle + '''\tif loc == "CLINIC" and has_seen("AF04_clinic_quiet") and not has_seen("AF04b_record_margin"):
\t\tmark("AF04b_record_margin")
\t\tvar rec := (
\t\t\t"我又推开半掩的门。\\n\\n"
\t\t\t+ "记录本仍在原处，却被翻到空白页与字迹页之间。\\n"
\t\t\t+ "空白页的页脚有一行极淡的铅笔：日期未定。\\n\\n"
\t\t)
\t\tif bool(flags.get("trace_list_ink", false)) or bool(flags.get("trace_shrine_list_gap", false)):
\t\t\trec += "和礼拜场所那块洗不掉的墨点一样——有人在留空，而不是写满。"
\t\telif _t(flags) and not _p(flags):
\t\t\trec += "铅笔痕迹被擦过一次，又重新描上，比周围的字更犹豫。"
\t\telse:
\t\t\trec += "没有人解释「未定」是还没来，还是不打算写。"
\t\treturn {
\t\t\t"id": "AF04b_record_margin",
\t\t\t"text": rec,
\t\t\t"learn": {"id": "clinic_undated", "note": "诊疗处记录有「日期未定」的铅笔注记。"},
\t\t}
'''
if needle not in t:
    raise SystemExit("AF04 return not found")
t = t.replace(needle, insert_after, 1)

old_lab = '''\tif loc == "CLINIC" and not has_seen("AF04_clinic_quiet"):
\t\treturn "推开半掩的门看看"
\tif loc == "SHRINE" and bool(flags.get("trace_shrine_flowers", false)) and not has_seen("AF08_shrine_reread"):
\t\treturn "再看一次旧花束"
'''
new_lab = '''\tif loc == "CLINIC" and not has_seen("AF04_clinic_quiet"):
\t\treturn "推开半掩的门看看"
\tif loc == "CLINIC" and has_seen("AF04_clinic_quiet") and not has_seen("AF04b_record_margin"):
\t\treturn "再翻一次记录本"
\tif loc == "SHRINE" and bool(flags.get("trace_shrine_flowers", false)) and not has_seen("AF08_shrine_reread"):
\t\treturn "再看一次旧花束"
\tif loc == "SHRINE" and has_seen("AF08_shrine_reread") and not has_seen("AF08b_list_gap"):
\t\treturn "在名单空位前停一会儿"
'''
if old_lab not in t:
    raise SystemExit("labels block not found")
t = t.replace(old_lab, new_lab, 1)

path.write_text(t, encoding="utf-8")
print("applied", path, "lines", t.count("\n") + 1)
