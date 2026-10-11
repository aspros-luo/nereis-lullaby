# Required Context for New Conversations: Nereis Lullaby

Before any new conversation or development task, read this file and its Chinese counterpart, then read:
- `docs/PROJECT_BASELINE_CN.md` / `docs/PROJECT_BASELINE_EN.md`
- `docs/WORLDVIEW_CN.md` / `docs/WORLDVIEW_EN.md`
- `docs/DESIGN_CONTRACTS_CN.md` / `docs/DESIGN_CONTRACTS_EN.md`
- `docs/CORE_GAMEPLAY_CN.md` / `docs/CORE_GAMEPLAY_EN.md`
- `docs/ROADMAP_CN.md` / `docs/ROADMAP_EN.md`

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
