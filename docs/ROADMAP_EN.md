# Development Roadmap

## Phase 0: Clean design baseline
- [x] Define this repository as the Nereis Lullaby project for daily-life simulation, free exploration, and visual-novel storytelling.
- [x] Add bilingual worldview, design contracts, gameplay proposal, and session-start docs.
- [ ] Finish legacy-branch cleanup and establish the new branch strategy (depends on whether branch deletion is available through the connected GitHub integration).

## Phase 1: Core-loop prototype
- [x] Add the Godot 4.6 project shell, main scene, basic time state, three-NPC schedule manager, location switching, text UI, and clue notebook.
- [ ] Run in Godot 4.6.1 and fix engine errors (only repository and static-structure checks have been completed; runtime execution is not yet verified).
- [ ] Expand activity choices, relationship changes, event overrides, and event records; keep relationship, investigation, and world state independent.
- [ ] Implement traceable clue events and alternate routes for missed events.
- [ ] Implement forest exploration and one staged world-anomaly event; its mechanism must be designed and prototype-tested before becoming canon.

## Phase 2: Vertical slice
- [ ] Build roughly one in-game week of playable content.
- [ ] Reuse locations before and after transformation while changing text, character behavior, and environmental clues.
- [ ] Verify there are no hidden hard gates between relationships, investigation, and world stages.
- [ ] Run engine tests and human playtests, recording issues.

## Phase 3: Narrative design
- [ ] Decide the relationships among village, forest, church, and remnants of ancient divine power.
- [ ] Define knowledge boundaries, timeline, and causal chains for key characters.
- [ ] Design full routes and endings only after the systems can be tested.
- [ ] Keep all ending names and concepts labeled as proposals until approved.

## Phase 4: Content expansion
- [ ] Expand maps, villagers, personal stories, communal events, and transformation stages.
- [ ] Add music, art, presentation, and narrative content.
- [ ] Use regression tests to check event ordering, missed clues, and ending reachability.

## Engineering discipline
- Validate the core gameplay before scaling content.
- Do not treat the old implementation as a required foundation.
- Do not intentionally trigger GitHub Actions.
- Each progress report should state completed work, validation method, remaining tasks, and next steps.
