#!/usr/bin/env python3
from __future__ import annotations

import json
import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
EVENT_DIR = ROOT / "data" / "game" / "events"
TIMELINE_DIR = ROOT / "data" / "dialogic" / "timelines"
CHAR_DIR = ROOT / "data" / "dialogic" / "character"


class CheckFailure(AssertionError):
    pass


def check(condition: bool, message: str) -> None:
    if not condition:
        raise CheckFailure(message)


def read_json(path: Path) -> dict[str, Any]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except Exception as exc:
        raise CheckFailure(f"Invalid JSON: {path}: {exc}") from exc
    check(isinstance(value, dict), f"Event must be an object: {path}")
    return value


def parse_dialogic_registrations(project_text: str, directory_name: str) -> dict[str, str]:
    match = re.search(
        rf"{re.escape(directory_name)}=\{{(.*?)\n\}}",
        project_text,
        flags=re.DOTALL,
    )
    check(match is not None, f"Missing Dialogic directory: {directory_name}")
    body = match.group(1)
    pairs = dict(
        re.findall(r'"([^"]+)":\s*"((?:res://)[^"]+)"', body)
    )
    check(pairs, f"No registrations found in {directory_name}")
    return pairs


def static_audit() -> tuple[dict[str, dict[str, Any]], dict[str, str], dict[str, str]]:
    project = (ROOT / "project.godot").read_text(encoding="utf-8")
    characters = parse_dialogic_registrations(project, "directories/dch_directory")
    timelines = parse_dialogic_registrations(project, "directories/dtl_directory")

    for key, resource in characters.items():
        path = ROOT / resource.removeprefix("res://")
        check(path.is_file(), f"Registered character missing: {key} -> {resource}")

    for key, resource in timelines.items():
        path = ROOT / resource.removeprefix("res://")
        check(path.is_file(), f"Registered timeline missing: {key} -> {resource}")

    required_characters = {"hunter", "mite", "hero", "merchant"}
    check(required_characters <= set(characters), "Not all active Dialogic characters are registered")

    events: dict[str, dict[str, Any]] = {}
    for path in sorted(EVENT_DIR.glob("*.json")):
        event = read_json(path)
        event_id = str(event.get("id", ""))
        check(event_id, f"Event id missing: {path}")
        check(event_id not in events, f"Duplicate event id: {event_id}")
        events[event_id] = event

        for action in list(event.get("actions", [])) + list(event.get("expire_actions", [])):
            if action.get("type") in {"queue_npc_dialogue", "queue_phase_dialogue"}:
                timeline = str(action.get("timeline", ""))
                check(timeline in timelines, f"Event {event_id} references unregistered timeline {timeline}")

        for choice in event.get("choices", []):
            for action in choice.get("actions", []):
                if action.get("type") == "request_ending":
                    ending_id = str(action.get("ending_id", ""))
                    check(
                        ending_id in {"outer_god", "church", "human"},
                        f"Unknown ending id in {event_id}: {ending_id}",
                    )

    obsolete = {
        "demo_bootstrap",
        "demo_church_shadow",
        "forest_investigation_delayed_start_event",
        "test_event",
    }
    check(not (obsolete & set(events)), f"Obsolete events still present: {sorted(obsolete & set(events))}")

    required_events = {
        "mainline_00_opening",
        "hunter_trust_event",
        "forest_route_commit",
        "forest_investigation_event",
        "forest_mark_consequence_touched",
        "forest_mark_consequence_untouched",
        "forest_mark_hero_anomaly",
        "forest_mark_hero_anomaly_untouched",
        "hero_anomaly_followup_touched",
        "hero_anomaly_followup_untouched",
        "hero_anomaly_question_touched",
        "hero_anomaly_question_untouched",
        "church_shadow_shared",
        "church_shadow_hidden",
        "church_encounter_choice",
        "demo_final_choice",
    }
    check(required_events <= set(events), "Active story event set is incomplete")

    timeline_speakers: dict[str, set[str]] = {}
    speaker_pattern = re.compile(r"^\s*([A-Za-z_][A-Za-z0-9_]*):")
    for timeline_id, resource in timelines.items():
        text = (ROOT / resource.removeprefix("res://")).read_text(encoding="utf-8")
        speakers = set()
        for line in text.splitlines():
            match = speaker_pattern.match(line)
            if match:
                speakers.add(match.group(1))
        timeline_speakers[timeline_id] = speakers
        missing = speakers - set(characters)
        check(not missing, f"Timeline {timeline_id} uses unregistered speakers: {sorted(missing)}")

    tavern_manager = (ROOT / "scripts/managers/TavernManager.gd").read_text(encoding="utf-8")
    check("func serve_normal()" in tavern_manager, "TavernManager.serve_normal() missing")
    check("func serve_special()" in tavern_manager, "TavernManager.serve_special() missing")

    story_manager = (ROOT / "scripts/managers/StoryManager.gd").read_text(encoding="utf-8")
    check("pending_phase_dialogues.get(phase, [])" in story_manager, "Phase dialogue queue was not converted to an array queue")
    check("func has_pending_phase_dialogue(phase:String)->bool:" in story_manager, "Morning phase dialogue guard missing")
    check("func reset_runtime_state():" in story_manager, "StoryManager runtime reset missing")

    morning = (ROOT / "scripts/systems/Morning.gd").read_text(encoding="utf-8")
    check('func _advance_pending_morning_story():' in morning, "Morning story queue driver missing")
    check("has_phase_dialogue:bool = StoryManager.has_pending_phase_dialogue" in morning, "Morning phase dialogue lock missing")

    npc_ui_scene = (ROOT / "scenes/NPCInteractionUI.tscn").read_text(encoding="utf-8")
    check("mouse_filter = 2" in npc_ui_scene, "NPC interaction overlay still blocks clicks to NPCs")

    npc_ui = (ROOT / "scripts/ui/NPCInteractionUI.gd").read_text(encoding="utf-8")
    check("talk_button.disabled = locked" in npc_ui, "Talk button is still disabled by pending choices")
    check("close_button.disabled = locked" in npc_ui, "NPC panel cannot be recovered from a pending choice")
    check("get_npc_choices(current_npc_id)" in npc_ui, "NPC choice state is not rendered")
    
    ending = (ROOT / "scripts/ui/Ending.gd").read_text(encoding="utf-8")
    check("StoryManager.reset_runtime_state()" in ending, "Ending restart does not clear StoryManager runtime state")
    check("NPCManager.reset_runtime_state()" in ending, "Ending restart does not reset NPC runtime state")
    check("GameManager.start_game()" in ending, "Ending restart does not restart the day flow through GameManager")

    resource_manager = (ROOT / "scripts/managers/ResourceManager.gd").read_text(encoding="utf-8")
    check("func reset():" in resource_manager, "ResourceManager reset missing")

    return events, characters, timelines


@dataclass
class SimState:
    day: int = 1
    flags: dict[str, Any] = field(default_factory=dict)
    world: dict[str, int] = field(
        default_factory=lambda: {
            "village_corruption": 0,
            "outer_god_progress": 0,
            "church_truth": 0,
            "hero_memory": 0,
            "hero_humanity": 100,
            "mite_humanity": 100,
        }
    )
    npc: dict[str, dict[str, Any]] = field(
        default_factory=lambda: {
            "hunter": {"trust": 20, "knows_forest_secret": False},
            "merchant": {"trust": 10},
            "hero": {"memory": 0, "humanity": 100, "trust": 0},
        }
    )
    statuses: dict[str, str] = field(default_factory=dict)
    pending_npc_dialogues: dict[str, str] = field(default_factory=dict)
    pending_phase_dialogues: dict[str, list[str]] = field(default_factory=dict)
    pending_npc_choices: dict[str, dict[str, Any]] = field(default_factory=dict)
    pending_phase_choices: dict[str, dict[str, Any]] = field(default_factory=dict)
    ending: str = ""

    def flag(self, key: str, default: Any = None) -> Any:
        return self.flags.get(key, default)


class Simulator:
    def __init__(self, events: dict[str, dict[str, Any]]) -> None:
        self.events = events
        self.s = SimState()

    def status(self, event_id: str) -> str:
        return self.s.statuses.get(event_id, "PENDING")

    def set_status(self, event_id: str, status: str) -> None:
        self.s.statuses[event_id] = status

    def complete(self, event: dict[str, Any]) -> None:
        self.set_status(event["id"], "COMPLETED")
        if bool(event.get("once", True)):
            self.s.flags[f"event:{event['id']}"] = True

    def compare(self, actual: Any, operator: str, expected: Any) -> bool:
        if actual is None:
            return expected is None if operator == "==" else expected is not None if operator == "!=" else False
        if operator == "==":
            return actual == expected
        if operator == "!=":
            return actual != expected
        if operator == ">":
            return actual > expected
        if operator == ">=":
            return actual >= expected
        if operator == "<":
            return actual < expected
        if operator == "<=":
            return actual <= expected
        return False

    def condition(self, condition: dict[str, Any]) -> bool:
        kind = condition.get("type", "")
        if kind == "day":
            actual = self.s.day
        elif kind == "story_flag":
            actual = self.s.flag(str(condition.get("key", "")), None)
        elif kind == "world_value":
            actual = self.s.world.get(str(condition.get("key", "")), 0)
        elif kind == "npc_permanent":
            npc = self.s.npc.get(str(condition.get("npc_id", "")), {})
            actual = npc.get(str(condition.get("key", "")), None)
        else:
            return False
        return self.compare(actual, str(condition.get("operator", "==")), condition.get("value"))

    def conditions(self, conditions: list[dict[str, Any]]) -> bool:
        return all(self.condition(c) for c in conditions)

    def can_trigger(self, event: dict[str, Any]) -> bool:
        event_id = event["id"]
        if bool(event.get("manual", False)):
            return False
        if self.status(event_id) in {"ACTIVE", "COMPLETED", "EXPIRED"}:
            return False
        if bool(event.get("once", True)) and self.s.flag(f"event:{event_id}", False):
            return False
        start_day = int(event.get("start_day", -1))
        end_day = int(event.get("end_day", -1))
        if start_day >= 0 and self.s.day < start_day:
            return False
        if end_day >= 0 and self.s.day > end_day:
            return False
        return self.conditions(event.get("conditions", []))

    def action(self, action: dict[str, Any]) -> None:
        kind = action.get("type", "")
        if kind == "set_story_flag":
            self.s.flags[str(action.get("key", ""))] = action.get("value")
        elif kind == "advance_mainline_stage":
            key = "mainline_stage"
            value = int(action.get("value", 0))
            self.s.flags[key] = max(int(self.s.flag(key, 0)), value)
        elif kind == "set_world_value":
            self.s.world[str(action.get("key", ""))] = int(action.get("value", 0))
        elif kind == "add_world_value":
            key = str(action.get("key", ""))
            self.s.world[key] = self.s.world.get(key, 0) + int(action.get("value", 0))
        elif kind == "add_npc_permanent":
            npc_id = str(action.get("npc_id", ""))
            key = str(action.get("key", ""))
            self.s.npc.setdefault(npc_id, {})
            self.s.npc[npc_id][key] = self.s.npc[npc_id].get(key, 0) + int(action.get("value", 0))
        elif kind == "set_npc_permanent":
            npc_id = str(action.get("npc_id", ""))
            key = str(action.get("key", ""))
            self.s.npc.setdefault(npc_id, {})
            self.s.npc[npc_id][key] = action.get("value")
        elif kind == "queue_npc_dialogue":
            self.s.pending_npc_dialogues[str(action.get("npc_id", ""))] = str(action.get("timeline", ""))
        elif kind == "queue_phase_dialogue":
            phase = str(action.get("phase", ""))
            timeline = str(action.get("timeline", ""))
            queue = self.s.pending_phase_dialogues.setdefault(phase, [])
            if timeline not in queue:
                queue.append(timeline)
        elif kind == "request_ending":
            self.s.ending = str(action.get("ending_id", ""))

    def execute(self, event: dict[str, Any]) -> None:
        event_id = event["id"]
        for action in event.get("actions", []):
            self.action(action)
        choices = event.get("choices", [])
        if choices:
            self.set_status(event_id, "ACTIVE")
            first = choices[0]
            if "npc_id" in first:
                self.s.pending_npc_choices[str(first["npc_id"])] = {
                    "event_id": event_id,
                    "choices": choices,
                }
            elif "phase" in first:
                self.s.pending_phase_choices[str(first["phase"])] = {
                    "event_id": event_id,
                    "choices": choices,
                }
        else:
            self.complete(event)

    def evaluate(self) -> None:
        for event in self.events.values():
            if self.status(event["id"]) in {"COMPLETED", "EXPIRED"}:
                continue
            end_day = int(event.get("end_day", -1))
            if end_day >= 0 and self.s.day > end_day:
                for action in event.get("expire_actions", []):
                    self.action(action)
                self.s.pending_npc_choices = {
                    k: v for k, v in self.s.pending_npc_choices.items()
                    if v.get("event_id") != event["id"]
                }
                self.s.pending_phase_choices = {
                    k: v for k, v in self.s.pending_phase_choices.items()
                    if v.get("event_id") != event["id"]
                }
                self.set_status(event["id"], "EXPIRED")

        candidates = [e for e in self.events.values() if self.can_trigger(e)]
        candidates.sort(key=lambda e: int(e.get("priority", 0)), reverse=True)
        for event in candidates:
            if self.can_trigger(event):
                self.execute(event)

    def manual(self, event_id: str) -> None:
        event = self.events[event_id]
        check(bool(event.get("manual", False)), f"{event_id} is not manual")
        check(self.status(event_id) not in {"COMPLETED", "EXPIRED"}, f"{event_id} unavailable")
        check(self.conditions(event.get("conditions", [])), f"{event_id} conditions false")
        self.execute(event)

    def consume_npc_dialogue(self, npc_id: str) -> str:
        return self.s.pending_npc_dialogues.pop(npc_id, "")

    def consume_phase_dialogues(self, phase: str) -> list[str]:
        queue = self.s.pending_phase_dialogues.pop(phase, [])
        return list(queue)

    def choose_npc(self, npc_id: str, choice_id: str) -> None:
        data = self.s.pending_npc_choices.get(npc_id)
        check(data is not None, f"No pending NPC choice for {npc_id}")
        event = self.events[data["event_id"]]
        selected = next(c for c in data["choices"] if c.get("id") == choice_id)
        for action in selected.get("actions", []):
            self.action(action)
        self.s.pending_npc_choices.pop(npc_id, None)
        self.complete(event)

    def choose_phase(self, phase: str, choice_id: str) -> None:
        data = self.s.pending_phase_choices.get(phase)
        check(data is not None, f"No pending phase choice for {phase}")
        event = self.events[data["event_id"]]
        selected = next(c for c in data["choices"] if c.get("id") == choice_id)
        for action in selected.get("actions", []):
            self.action(action)
        self.s.pending_phase_choices.pop(phase, None)
        self.complete(event)


def end_day(sim: Simulator) -> None:
    check(not sim.s.pending_npc_choices, f"Cannot end day with NPC choices pending: {sim.s.pending_npc_choices}")
    sim.s.day += 1
    sim.evaluate()


def run_path(events: dict[str, dict[str, Any]], touched: bool, shared: bool, follow: bool, ending: str) -> None:
    sim = Simulator(events)

    # Day 1: opening facade.
    sim.evaluate()
    check(sim.s.day == 1 and sim.s.flag("mainline_stage") == 1, "D1 mainline opening failed")
    end_day(sim)

    # Day 2: hunter reveal.
    check(sim.s.day == 2, "Did not enter D2")
    check(sim.s.flag("hunter_forest_route_unlocked") is True, "D2 hunter route did not unlock")
    check(sim.consume_npc_dialogue("hunter") == "hunter_trust_reveal", "Hunter reveal dialogue missing")
    end_day(sim)

    # Day 3: forest route and investigation choice.
    check(sim.s.day == 3, "Did not enter D3")
    check(sim.s.flag("forest_investigation_committed") is True, "Forest route did not commit")
    sim.manual("forest_investigation_event")
    check(sim.consume_phase_dialogues("MORNING") == ["forest_entry"], "Forest entry dialogue queue incorrect")
    mark_choice = "touch_strange_mark" if touched else "leave_mark_alone"
    sim.choose_phase("MORNING", mark_choice)
    check(sim.s.flag("mainline_stage") == 5, "D3 forest choice did not reach stage 5")
    if touched:
        check(sim.s.flag("forest_mark_touched") is True, "Touched branch flag missing")
    else:
        check(sim.s.flag("forest_mark_untouched") is True, "Untouched branch flag missing")
    end_day(sim)

    # D4: both consequence and anomaly dialogue must survive the same evaluation.
    check(sim.s.day == 4, "Did not enter D4")
    d4_dialogues = sim.consume_phase_dialogues("MORNING")
    expected_d4 = (
        ["forest_mark_touched_consequence", "hero_mark_anomaly"]
        if touched
        else ["forest_mark_untouched_consequence", "hero_mark_anomaly_untouched"]
    )
    check(d4_dialogues == expected_d4, f"D4 dialogue queue mismatch: {d4_dialogues}")
    check(sim.s.flag("mainline_stage") == 6, "D4 did not reach stage 6")
    end_day(sim)

    # D5: hero notices the mark.
    check(sim.s.day == 5, "Did not enter D5")
    notice = (
        "hero_notices_mark_touched" if touched else "hero_notices_mark_untouched"
    )
    check(sim.consume_npc_dialogue("hero") == notice, "Hero notice dialogue missing")
    end_day(sim)

    # D6: hero asks the decisive question and the player MUST choose.
    check(sim.s.day == 6, "Did not enter D6")
    question = (
        "hero_anomaly_question_touched" if touched else "hero_anomaly_question_untouched"
    )
    check(sim.consume_npc_dialogue("hero") == question, "Hero question dialogue missing")
    check(set(sim.s.pending_npc_choices) == {"hero"}, "D6 hero choice was not queued")
    question_choice = "tell_hero_about_mark" if shared else "deny_everything"
    sim.choose_npc("hero", question_choice)
    check(not sim.s.pending_npc_choices, "D6 NPC choice remained pending")
    check(sim.s.flag("mainline_stage") == 8, "D6 choice did not reach stage 8")
    if shared:
        check(sim.s.flag("hero_truth_shared") is True, "Truth-shared flag missing")
    else:
        check(sim.s.flag("hero_truth_hidden") is True, "Truth-hidden flag missing")
    end_day(sim)

    # D7: exactly one church shadow branch.
    check(sim.s.day == 7, "Did not enter D7")
    shadow = "church_shadow_shared" if shared else "church_shadow_hidden"
    check(sim.consume_phase_dialogues("MORNING") == [shadow], "Church shadow branch missing")
    check(sim.s.flag("mainline_stage") == 9, "D7 did not reach stage 9")
    end_day(sim)

    # D8 is a normal tavern day.
    check(sim.s.day == 8, "Did not enter D8")
    end_day(sim)

    # D9: patrol choice.
    check(sim.s.day == 9, "Did not enter D9")
    check(set(sim.s.pending_phase_choices) == {"MORNING"}, "D9 church choice missing")
    patrol_choice = "follow_church_patrol" if follow else "avoid_church_patrol"
    sim.choose_phase("MORNING", patrol_choice)
    patrol_dialogue = "church_patrol_follow" if follow else "church_patrol_avoid"
    check(sim.consume_phase_dialogues("MORNING") == [patrol_dialogue], "Patrol consequence dialogue missing")
    check(sim.s.flag("mainline_stage") == 10, "D9 did not reach stage 10")
    end_day(sim)

    # D10 is a normal tavern day.
    check(sim.s.day == 10, "Did not enter D10")
    end_day(sim)

    # D11: final choice reaches an actual ending.
    check(sim.s.day == 11, "Did not enter D11")
    check(sim.consume_phase_dialogues("MORNING") == ["demo_final_choice_intro"], "Final intro missing")
    check(set(sim.s.pending_phase_choices) == {"MORNING"}, "Final choice missing")
    sim.choose_phase("MORNING", {
        "outer_god": "answer_forest_voice",
        "church": "trust_church",
        "human": "stay_with_village",
    }[ending])
    check(sim.s.ending == ending, f"Ending request missing: expected {ending}, got {sim.s.ending}")
    check(sim.s.flag("mainline_stage") == 11, "Final choice did not reach stage 11")
    check(not sim.s.pending_phase_choices, "Final choice remained pending")


def test_missed_d6(events: dict[str, dict[str, Any]]) -> None:
    sim = Simulator(events)
    # Bring state to the D6 question without selecting.
    sim.evaluate()
    end_day(sim)
    sim.consume_npc_dialogue("hunter")
    end_day(sim)
    sim.manual("forest_investigation_event")
    sim.consume_phase_dialogues("MORNING")
    sim.choose_phase("MORNING", "leave_mark_alone")
    end_day(sim)
    sim.consume_phase_dialogues("MORNING")
    end_day(sim)
    sim.consume_npc_dialogue("hero")
    end_day(sim)
    check(sim.s.day == 6, "Missed-choice fixture did not reach D6")
    check(sim.s.pending_npc_choices.get("hero", {}).get("event_id") == "hero_anomaly_question_untouched", "D6 choice fixture failed")
    # The actual UI blocks end-day, so we model the expiration separately:
    sim.s.day = 7
    sim.evaluate()
    check(sim.s.flag("hero_anomaly_question_missed") is True, "Missed D6 question did not expire")
    check(sim.s.flag("church_shadow_started", False) is not True, "Missed D6 incorrectly bypassed into church shadow")


def main() -> int:
    events, _, _ = static_audit()
    for touched in (False, True):
        for shared in (False, True):
            for follow in (False, True):
                for ending in ("outer_god", "church", "human"):
                    run_path(events, touched, shared, follow, ending)
    test_missed_d6(events)

    print("PASS: static project audit")
    print("PASS: 24 full story branch simulations")
    print("PASS: missed D6 choice stays blocked and expires by design")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
