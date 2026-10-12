# Development Roadmap

## Phase 0: Clean design baseline
- [x] Define this repository as Nereis Lullaby: daily-life simulation, free exploration, and visual-novel storytelling.
- [x] Add bilingual worldview, design contracts, gameplay proposals, and session-start docs.
- [ ] Finish legacy-branch cleanup and establish the new branch strategy (depends on available branch-management permissions).

## Phase 1: Core-loop prototype
- [x] Add the Godot 4.6 project shell, core state, three-NPC schedules, location switching, text UI, and clue journal.
- [x] Add one meaningful action per period, relationship feedback, seven destinations, and forest exploration.
- [x] Add a prototype anomaly at the end of Day 7, changed location descriptions, and post-event clues.
- [x] Add wider discovery windows for several early clues and a core regression-test script.
- [ ] Run the project in Godot 4.6.1 and fix engine errors (code has been written and statically reviewed, but runtime execution is not yet verified).

## Phase 2: Vertical-slice delivery
- [x] Write the code for roughly one in-game week, including everyday activities, NPC conversations, relationships, the clue journal, and a staged anomaly.
- [x] Reuse locations before and after the anomaly while changing descriptions, NPC responses, and discoverable evidence.
- [x] Add post-anomaly revisits and an optional prologue ending.
- [x] Add day-specific opening story beats and contextual objective hints.
- [ ] Run the project in Godot and execute the regression tests; fix runtime errors.
- [ ] Validate the full save/exit/load flow in Godot, including malformed-save handling.
- [ ] Perform a human playtest for action feedback, clue reachability, pacing, and ending conditions.
- [x] Add single-slot local save/load for time, relationships, world phase, action history, and clue journal.
- [ ] Add production art, audio, and a fuller dialogue presentation.

## Phase 3: Narrative design
- [ ] Decide the relationships among the village, forest, Church, and remnants of ancient divine power.
- [ ] Define key characters' knowledge boundaries, timeline, and causal chains.
- [ ] Design full routes and endings after systems can be tested.
- [ ] Keep ending names and concepts labeled as proposals until approved.

## Phase 3.6: Dual-perspective worldlines and causal events
- [x] Define a bilingual causal contract separating world facts, character knowledge, intentions, opportunities, and ending conditions.
- [x] Add the first traceable event ledger: event-ID deduplication, world-fact provenance, explicit knowledge grants, opportunity state, and save serialization; routine actions and conversations now record events.
- [x] Add automated smoke-test code for the ledger (not yet executed by Godot).
- [ ] Give important actions stable event IDs, preconditions, information channels, observable feedback, and alternate evidence after a missed scene.
- [ ] Align cross-game event semantics with the Hero repository; keep both games independently runnable without runtime coupling.
- [ ] Keep example causal paths explicitly proposed; do not canonize the Restoration Army, forest investigation, third umbilical cord, or ending bindings prematurely.

## Phase 3.5: Relationships and autonomous behavior
- [x] Establish bilingual NPC relationship and behavior design baselines, separating known ties from open questions.
- [ ] Create data-driven behavior cards for the three key NPCs: goals, motives, knowledge boundaries, memory, relationship dimensions, and stress responses.
- [ ] Implement discrete NPC behavior simulation and authored-event schedule overrides.
- [ ] Add regression tests for information flow, relationship changes, action consequences, and save/load.

## Phase 4: Content expansion
- [x] Add one-time personal everyday moments for the three key villagers, with seen-state persisted in the save data (prototype content, not finalized canon).
- [ ] Expand maps, villagers, personal stories, communal events, and transformation stages.
- [ ] Add music, art, presentation, and narrative content.
- [ ] Use regression tests to check event order, missed clues, and ending reachability.

## Engineering discipline
- Validate gameplay before scaling content.
- Do not treat prototype story content as finalized canon.
- Do not intentionally trigger GitHub Actions.
- Report static review, automated tests, engine execution, and human playtesting separately.
