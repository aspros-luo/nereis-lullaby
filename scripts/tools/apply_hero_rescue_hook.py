#!/usr/bin/env python3
"""Light-link rescue_helped into Hero AF09/AF10 dialogue (idempotent)."""
from pathlib import Path

path = Path("scripts/systems/daily/aftermath_storylets.gd")
if not path.exists():
    path = Path(__file__).resolve().parents[2] / "scripts/systems/daily/aftermath_storylets.gd"
t = path.read_text(encoding="utf-8")
if "rescue_sleeve_glance" in t or "袖口那道" in t or "你救的那人" in t:
    print("already applied")
    raise SystemExit(0)

old = '''\treturn {
\t\t"id": "AF09_hero_talk",
\t\t"portrait": "外来人",
\t\t"text": text,
\t\t"learn": {"id": "hero_spoken", "note": learn_note},
\t\t"set_flag": "hero_met",
\t}
'''
new = '''\tif bool(flags.get("rescue_helped", false)):
\t\ttext += (
\t\t\t"\\n\\n他的目光在我袖口停了一下——那里不久前撕过布。\\n\\n"
\t\t\t+ "外来人\\n"
\t\t\t+ "「路上的事，你做得干净。比很多人干净。」\\n\\n"
\t\t\t+ "没有表扬的笑。只是把一件事从「可能」划成「已知」。"
\t\t)
\t\tlearn_note = str(learn_note) + " 他似知通路上的包扎。"
\treturn {
\t\t"id": "AF09_hero_talk",
\t\t"portrait": "外来人",
\t\t"text": text,
\t\t"learn": {"id": "hero_spoken", "note": learn_note},
\t\t"set_flag": "hero_met",
\t}
'''
if old not in t:
    raise SystemExit("AF09 return anchor missing")
t = t.replace(old, new, 1)

old2 = '''\treturn {
\t\t"id": "AF10_hero_second",
\t\t"portrait": "外来人",
\t\t"text": open,
\t\t"learn": {"id": "hero_second", "note": "在林缘再次见到外来人，他谈到路与选择。"},
\t\t"set_flag": "hero_second_met",
\t}
'''
new2 = '''\tif bool(flags.get("rescue_helped", false)):
\t\topen += (
\t\t\t"\\n\\n外来人\\n"
\t\t\t+ "「你救的那人，没有留下名字。很好。」\\n\\n"
\t\t\t+ "外来人\\n"
\t\t\t+ "「有些债一记名字就会变重。你只伸了手，没有伸名册。」\\n\\n"
\t\t)
\tvar second_note := "在林缘再次见到外来人，他谈到路与选择。"
\tif bool(flags.get("rescue_helped", false)):
\t\tsecond_note += " 他提及通路救人且肯定未留下名字。"
\treturn {
\t\t"id": "AF10_hero_second",
\t\t"portrait": "外来人",
\t\t"text": open,
\t\t"learn": {"id": "hero_second", "note": second_note},
\t\t"set_flag": "hero_second_met",
\t}
'''
if old2 not in t:
    raise SystemExit("AF10 return anchor missing")
t = t.replace(old2, new2, 1)

path.write_text(t, encoding="utf-8")
print("applied", path, "lines", t.count("\n") + 1)
