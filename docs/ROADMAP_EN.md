# Development Roadmap

## Stage 0: Clean design baseline
- [x] Define this repository as the home of Nereis Lullaby's schedule simulation, free exploration, and visual-novel gameplay.
- [x] Add bilingual worldbuilding, design constraints, proposals, and a continuation entry point.
- [ ] Finish old-branch cleanup and branch strategy after confirming branch deletion support.

## Stage 1: Core loop prototype
- [x] Add the Godot 4.6 project skeleton, main scene, time state, three NPC schedules, location selection, text UI, and clue journal.
- [x] Add one primary action per time slot, scalar relationship changes, seven locations, and forest exploration.
- [x] Add the Day 7 evening anomaly, changed location descriptions, and clues.
- [x] Add early clues that can be discovered later and a core regression test script.
- [ ] Run and fix the project in Godot 4.6.1 (not yet engine-verified).

## Stage 2: Vertical slice
- [x] Implement roughly one in-game week with daily activities, NPC conversations, relationships, clue journal, and phase anomaly.
- [x] Reuse locations before and after the anomaly, with altered descriptions, NPC responses, and discoverable evidence.
- [x] Add post-anomaly visits and an explicit prologue completion flow.
- [x] Add day-specific opening text and contextual objectives.
- [x] Add a single-slot local save for time, relationships, phase, action history, and clues.
- [ ] Run Godot and regression tests; fix actual runtime errors.
- [ ] Verify save, quit, restart, and load in Godot.
- [ ] Complete human playtesting for action feedback, clue accessibility, pacing, and completion conditions.
- [ ] Add final art, audio, and richer dialogue presentation.

## Stage 3: Dual-perspective worldline and causal events
- [x] Document the dual-perspective contract: world facts, character knowledge, intent, opportunities, and ending conditions are distinct.
- [x] Add a traceable event ledger, explicit knowledge grants, opportunity states, and save serialization.
- [x] Add smoke-test code for the ledger, information network, and NPC behavior (not yet executed by Godot).
- [x] Add message delay, inboxes, credibility, and belief confidence as separate concepts.
- [x] Connect an initial deterministic NPC routine selector, with authored story beats taking priority.
- [x] Harden ledger save loading: required event fields, fact/first-event consistency, and existence of every event-referenced fact.
- [x] Validate clue-journal saves atomically; reject malformed or duplicate entries before replacing runtime state.
- [x] Validate information-network saves: inbox entries must match delivered messages, beliefs require delivered-message evidence, and non-finite credibility is rejected.
- [x] Validate cross-system references between restored messages and ledger facts/source/delivery events.
- [x] Validate save consistency: discovered-fact IDs in the clue journal must exactly match investigation state, and each journal fact must have a worldline-ledger source.
- [x] Validate personal-moment, post-anomaly conversation, and last-NPC-action flags; reject completed-prologue saves without three distinct post-anomaly visits.
- [x] Record provenance events for observations and the Day 7 anomaly; defer dialogue-derived clues and relationship side effects until the primary action is accepted.
- [ ] Complete stable event IDs, trigger conditions, observable feedback, and alternate evidence for missable events.
- [ ] Align event semantics with Nereis Hero; the two games remain independently runnable without runtime coupling.

## Stage 4: Character matrix and autonomous behavior
- [x] Create behavior cards for the three key NPCs: goals, motives, knowledge boundaries, memory, relationship dimensions, and stress response.
- [x] Document cross-region influence matrices and candidate causal networks (design proposals only, not implemented gameplay).
- [ ] **Entry gate: pass Godot engine tests, save/load regression, and human playtesting for core gameplay.**
- [ ] Connect multidimensional relationships, memory, knowledge boundaries, message triggers, and behavioral consequences to runtime.
- [ ] Make NPC actions produce traceable state changes, not just text output.
- [ ] Verify several chains of condition → decision → action → result → information transfer or missed opportunity.

## Stage 5: Story and presentation
- [ ] Finalize story, side quests, endings, and character arcs only after the core loop and character matrix are validated.
- [ ] Expand the map, village population, personal scenes, group events, and anomaly stages.
- [ ] Add final art, audio, staging, and richer text presentation.
- [ ] Regression-test event order, missable clues, and ending reachability.
- [ ] Keep unconfirmed ending names and causal ideas marked as proposals.

## Engineering discipline
- Validate core gameplay before expanding the character matrix, then complete the story.
- Acceptance checklist: `docs/CORE_PLAYABILITY_ACCEPTANCE_CN.md` and `docs/CORE_PLAYABILITY_ACCEPTANCE_EN.md`.
- Do not treat prototype narrative as finalized canon.
- Do not trigger GitHub Actions proactively.
- Reports must distinguish static review, automated tests, engine execution, and human playtesting.
