#!/usr/bin/env python3
from pathlib import Path
path = Path("scripts/systems/daily/ending_resolver.gd")
if not path.exists():
    path = Path(__file__).resolve().parents[2] / "scripts/systems/daily/ending_resolver.gd"
t = path.read_text(encoding="utf-8")
if "trace_shrine_list_gap" in t:
    print("already applied")
    raise SystemExit(0)
old = 'for k in ["trace_home_bowl", "trace_commons_seat", "trace_shrine_flowers", "trace_path_scrap"]:'
new = 'for k in ["trace_home_bowl", "trace_commons_seat", "trace_shrine_flowers", "trace_path_scrap", "trace_shrine_list_gap", "trace_list_ink"]:'
if old not in t:
    raise SystemExit("trace loop missing")
t = t.replace(old, new, 1)
path.write_text(t, encoding="utf-8")
print("applied", path)
