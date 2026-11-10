#!/usr/bin/env python3
from pathlib import Path
path = Path("scripts/systems/daily/aftermath_storylets.gd")
if not path.exists():
    path = Path(__file__).resolve().parents[2] / "scripts/systems/daily/aftermath_storylets.gd"
t = path.read_text(encoding="utf-8")
if '"preview": preview' in t or '"preview": preview2' in t:
    print("already applied")
    raise SystemExit(0)
a = '''\t\t\t"ending": str(result.get("id", "")),
\t\t\t"ending_label": str(result.get("label", "")),
\t\t\t"set_flag": "ending_soft_seen",
'''
b = '''\t\t\t"ending": str(result.get("id", "")),
\t\t\t"ending_label": str(result.get("label", "")),
\t\t\t"preview": preview,
\t\t\t"set_flag": "ending_soft_seen",
'''
if a not in t:
    raise SystemExit("AF11 on_rest anchor missing")
t = t.replace(a, b, 1)
a2 = '''\t\t\t"ending": str(result2.get("id", "")),
\t\t\t"ending_label": str(result2.get("label", "")),
\t\t\t"set_flag": "ending_soft_seen",
'''
b2 = '''\t\t\t"ending": str(result2.get("id", "")),
\t\t\t"ending_label": str(result2.get("label", "")),
\t\t\t"preview": preview2,
\t\t\t"set_flag": "ending_soft_seen",
'''
if a2 in t:
    t = t.replace(a2, b2, 1)
path.write_text(t, encoding="utf-8")
print("applied", path)
