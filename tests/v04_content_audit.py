#!/usr/bin/env python3
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
EVENT_DIR = ROOT / "data" / "game" / "events"
TIMELINE_DIR = ROOT / "data" / "dialogic" / "timelines"

def fail(message: str) -> None:
    raise AssertionError(message)

def check(value: bool, message: str) -> None:
    if not value:
        fail(message)

campaign = json.loads((ROOT / "data" / "game" / "campaign.json").read_text(encoding="utf-8"))
check(campaign["target_hours"] == 40, "40-hour target changed")
check(campaign["target_days"] == 120, "120-day campaign target changed")
check(campaign["new_game_plus"]["reserved"] is True, "NG+ reservation missing")

project = (ROOT / "project.godot").read_text(encoding="utf-8")
registered = {
    key: resource
    for key, resource in re.findall(
        r'"([^"]+)":\s*"(res://data/dialogic/timelines/[^"]+\.dtl)"',
        project,
    )
}
check("demo_final_choice_intro" in registered, "Original final intro registration missing")
check("longform_d120_finale" in registered, "Finale timeline not registered")
check("ng_plus_d12_whisper" in registered, "NG+ timeline not registered")

for key, resource in registered.items():
    check((ROOT / resource.removeprefix("res://")).is_file(), f"Registered timeline missing: {key}")

events = {}
for path in sorted(EVENT_DIR.glob("*.json")):
    event = json.loads(path.read_text(encoding="utf-8"))
    event_id = str(event.get("id", ""))
    check(event_id and event_id not in events, f"Invalid/duplicate event: {path}")
    events[event_id] = event

longform_events = [e for e in events.values() if e["id"].startswith("longform_")]
check(len(longform_events) >= 40, f"Longform event coverage too small: {len(longform_events)}")

for event in longform_events:
    for action in list(event.get("actions", [])) + list(event.get("expire_actions", [])):
        if action.get("type") in {"queue_npc_dialogue", "queue_phase_dialogue"}:
            timeline = str(action.get("timeline", ""))
            check(timeline in registered, f"{event['id']} uses unregistered timeline {timeline}")

finale = events.get("longform_d120_finale")
check(finale is not None, "D120 finale event missing")
check(len(finale.get("choices", [])) == 3, "D120 must keep three endings")
valid_endings = {"outer_god", "church", "human"}
actual_endings = {
    str(action.get("ending_id", ""))
    for choice in finale["choices"]
    for action in choice.get("actions", [])
    if action.get("type") == "request_ending"
}
check(actual_endings == valid_endings, f"D120 endings mismatch: {actual_endings}")

speakers = set()
speaker_pattern = re.compile(r"^\s*([A-Za-z_][A-Za-z0-9_]*):")
for path in TIMELINE_DIR.glob("*.dtl"):
    for line in path.read_text(encoding="utf-8").splitlines():
        match = speaker_pattern.match(line)
        if match:
            speakers.add(match.group(1))
characters = set(re.findall(r'"([^"]+)":\s*"res://data/dialogic/character/[^"]+\.dch"', project))
check(speakers <= characters, f"Timeline speakers missing from Dialogic characters: {sorted(speakers - characters)}")

check((ROOT / "scenes/MainMenu.tscn").is_file(), "MainMenu scene missing")
check((ROOT / "scripts/managers/SaveManager.gd").is_file(), "SaveManager missing")
check((ROOT / "scripts/ui/GameMenu.gd").is_file(), "GameMenu missing")
check("mouse_filter = 2" in (ROOT / "scenes/NPCInteractionUI.tscn").read_text(encoding="utf-8"), "NPC overlay can block NPC clicks")

print("PASS: v0.4 content audit")
print(f"PASS: {len(longform_events)} longform events discovered")
print("PASS: 40-hour / 120-day campaign manifest")
print("PASS: NG+ reservation")
print("PASS: D120 has three actual ending requests")
