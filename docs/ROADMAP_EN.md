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
- [ ] Run the project in Godot and execute the regression tests; fix runtime errors.
- [ ] Perform a human playtest for action feedback, clue reachability, pacing, and ending conditions.
- [x] Add single-slot local save/load for time, relationships, world phase, action history, and clue journal.
- [ ] Add production art, audio, and a fuller dialogue presentation.

## Phase 3: Narrative design
- [ ] Decide the relationships among the village, forest, Church, and remnants of ancient divine power.
- [ ] Define key characters' knowledge boundaries, timeline, and causal chains.
- [ ] Design full routes and endings after systems can be tested.
- [ ] Keep ending names and concepts labeled as proposals until approved.

## Phase 4: Content expansion
- [ ] Expand maps, villagers, personal stories, communal events, and transformation stages.
- [ ] Add music, art, presentation, and narrative content.
- [ ] Use regression tests to check event order, missed clues, and ending reachability.

## Engineering discipline
- Validate gameplay before scaling content.
- Do not treat prototype story content as finalized canon.
- Do not intentionally trigger GitHub Actions.
- Report static review, automated tests, engine execution, and human playtesting separately.
