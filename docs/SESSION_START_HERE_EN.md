# Required Context for New Conversations: Nereis Lullaby

Before any new conversation or development task, read this file and its Chinese counterpart, then read:
- `docs/PROJECT_BASELINE_CN.md` / `docs/PROJECT_BASELINE_EN.md`
- `docs/WORLDVIEW_CN.md` / `docs/WORLDVIEW_EN.md`
- `docs/DESIGN_CONTRACTS_CN.md` / `docs/DESIGN_CONTRACTS_EN.md`
- `docs/CORE_GAMEPLAY_CN.md` / `docs/CORE_GAMEPLAY_EN.md`
- `docs/ROADMAP_CN.md` / `docs/ROADMAP_EN.md`

## Cross-project narrative sync (required)
Before continuing work on plot, NPCs, clues, or world state, check the latest commit on Hero's `development` branch and follow the [Cross-Project Narrative Sync Ledger](CROSS_PROJECT_STORY_SYNC_CN_EN.md). The games have independent gameplay but compatible worldbuilding; newer explicit user decisions override older docs. Ending directions remain open, and Hero endings must not require physical union with Mite.

## Relationship and autonomous behavior baseline
- See `docs/NPC_RELATIONSHIP_AND_BEHAVIOR_MATRIX_CN.md` / `docs/NPC_RELATIONSHIP_AND_BEHAVIOR_MATRIX_EN.md` for the NPC relationship and behavior design.
- The matrix is **not complete**: only prototype contact types between Mite and the three key NPCs exist; many NPC-to-NPC ties remain open.
- Key NPCs use individual goals, memory, knowledge boundaries, relationship dimensions, and stress responses; ordinary NPCs use lightweight schedule/goal templates; background residents use group simulation.
- NPCs learn events only through plausible channels. Never sync the player's clue journal to all characters automatically. Keep relationship, investigation, and world state separate.

## Dual-perspective worldlines and causal events (required)
- Read `docs/DUAL_PERSPECTIVE_WORLDLINE_CONTRACT_CN.md` / `docs/DUAL_PERSPECTIVE_WORLDLINE_CONTRACT_EN.md`.
- Hero directly responds to opportunities; Lullaby indirectly changes information, motivation, contact, and opportunity through Mite's everyday life and relationships.
- Keep world facts, character knowledge/beliefs, intentions, opportunity states, and ending conditions separate. Never switch an ending directly from one hidden score.
- Restoration Army news, forest investigation, and the third umbilical cord are non-canon examples, not finalized plot conditions.
- Mite does not know her true identity; her care and innocence are genuine. Important choices need observable consequences in NPC behavior, dialogue, objects, or information access.

## Project boundary
This repository is only for Nereis Lullaby: daily-life simulation + free exploration + visual novel. Do not mix in Nereis-Hero's side-scrolling action-RPG code or systems.

## Confirmed project baseline
- Three action periods per day: morning, daytime, and evening.
- Region map plus location-based exploration.
- Key NPCs have states and schedules, driven by autonomous simulation and authored events together.
- Primarily Mite's viewpoint, with limited objective evidence creating narrative contrast.
- Relationships, clue/investigation progress, and world state are tracked separately and jointly influence endings.
- Prototype core systems before building a vertical slice.

## Most important narrative constraint
Mite is an innocent village girl who knows nothing of her role. Her feelings are sincere; she does not know her relationship to the Outer God or the ritual. **Do not design an insight meter or supernatural-awareness progression that Mite actively uses.** The clue journal supports player observation and deduction; it does not mean Mite understands the truth.

Always distinguish:
1. Mite's actual experience and understanding;
2. the player's deductions from evidence;
3. objective facts about the world.

These layers may differ, but causality must remain coherent. The Outer God's deception of the player should emerge from believable everyday life, information asymmetry, and retrospectively supported twists—not unsupported narrative lies.

## Canon-status discipline
Label design material as:
- **Confirmed**: a direction or fact explicitly approved by the user;
- **Proposed**: a candidate for discussion or prototype validation, not canon;
- **Open**: important plot, causality, ending, or timeline decisions that remain unresolved.

Do not finalize ritual mechanics, the cult base location, mass-villager events, Hero's fate, the Restoration Army's ending, or the exact conditions for the three endings without approval.

## Working rules
- Update Chinese and English design documents together.
- Continue work on the `development` branch.
- Do not intentionally trigger GitHub Actions.
- Validate the gameplay loop before expanding the full map and script.
- Weigh important decisions with pros and cons, then give a recommendation without exposing internal deliberation.
- Reports must distinguish work committed to the repository, work verified, and work not yet verified.


## Current playable prototype status (2026-10-11)

- `scripts/ui/main.gd` now contains seven destinations, a seven-day loop, one meaningful action per period, NPC conversations, everyday activities, relationship feedback, a clue journal, before/after anomaly changes, and an optional prologue ending.
- Day-opening story beats, contextual objectives, detailed location observations, a dark UI theme, and single-slot local save/load have been added.
- `scripts/core/game_state.gd` includes action limits, relationship bounds, clue IDs, and anomaly phases.
- `tests/prototype_smoke_test.gd` covers time progression, anomaly triggering, action limits, NPC schedules, seven-location content coverage, clue de-duplication, relationship bounds, and save restoration in ordinary/anomaly/completed phases.
- Bilingual playtest guides are in `docs/PLAYTEST_GUIDE_CN.md` and `docs/PLAYTEST_GUIDE_EN.md`.
- **Important: code is on GitHub, but the current execution environment has no usable Godot executable; the expanded prototype and smoke tests have not been run in-engine.** The user's confirmation that an earlier version launched does not verify this expanded version.
- The anomaly is vertical-slice prototype content and must not silently become finalized world canon.
