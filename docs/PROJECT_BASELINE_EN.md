# Nereis Lullaby — Formal Project Baseline

> Status: the project direction is approved. This document records approved decisions; it does not finalize every worldbuilding or plot detail.
> Change rule: update the Chinese and English versions together and label material as Confirmed, Proposed, or Open.

## 1. Confirmed project direction

- **Format**: daily-life simulation + free exploration + visual novel.
- **Time structure**: three action periods per day—morning, daytime, and evening.
- **Spatial structure**: region map plus location-based exploration, not continuous side-scrolling action scenes.
- **Character simulation**: key NPCs have states and schedules; authored events and autonomous simulation work together.
- **Narrative viewpoint**: primarily Mite's perspective, with limited objective evidence creating contrast.
- **Ending variables**: relationship state, clue/investigation progress, and world state are tracked separately and jointly influence endings.
- **Development order**: validate core-system prototypes before building a vertical slice.

## 2. Mite/player information gap: core narrative contract

Mite is a young woman living in the village. She knows nothing about the Outer God, the ritual, or her true role. Her innocence, kindness, attachment, and feelings are sincere—not a performance designed to deceive the player.

**There is no player-facing “insight level” that Mite actively uses, nor a protagonist progression system in which she deliberately upgrades her supernatural awareness.** The player is not controlling an investigator who knows they are seeking the truth about an Outer God.

The narrative must distinguish three layers:

1. **Mite's experience and understanding**: what she sees, hears, remembers, and believes.
2. **The player's deductions**: conclusions drawn from environments, objects, dialogue, villagers' actions, and contradictions.
3. **The world's actual events**: what objectively happens, including facts that may temporarily remain hidden from Mite and the player.

These layers may differ, but the causal rules must remain consistent. Do not manufacture twists through unsupported narration, arbitrary retroactive changes to established facts, or convenient character amnesia.

## 3. How the player investigates without turning Mite into an investigator

Investigation is a player-level activity; Mite does not need to recognize it as a mission.

- The player can inspect places, objects, and everyday activities while reading Mite's natural interpretation of them.
- A clue journal records events, statements, objects, and contradictions the player has encountered. It organizes player information; it does not mean Mite automatically understands the hidden truth.
- Narrative wording, environmental details, event order, character behavior, and recurring objects can create objective contrast.
- Mite's inner monologue must fit her knowledge, personality, and emotions. She must not suddenly explain the Outer God from an omniscient perspective.
- The player may form hypotheses, but unverified hypotheses must not automatically become objective facts.

## 4. Daily loop

Each day has three action periods:

- **Morning**: begin the day, notice recent village developments, and choose an activity or destination.
- **Daytime**: visit people, help, gather, explore, join activities, or handle personal matters.
- **Evening**: continue activities, revisit characters, trigger eligible events, and resolve daily state changes.

This is a time framework, not a final activity list. Action costs, whether a period can be skipped, and whether night events need a separate phase remain subject to prototype validation. Avoid turning the game into a mandatory daily checklist.

Key NPCs have their own schedules, relationships, and states. Authored events and autonomous behavior jointly move the village forward. Events may happen while the player is elsewhere, but important information should have reasonable alternative discovery paths so one missed action does not permanently soft-lock the main story.

## 5. Space, clues, and world changes

- Use a region map to enter specific locations. Locations may change according to time period, event phase, and character state.
- The first prototype includes a central village area and one forest area. This is a validation scope, not the final world map.
- The clue journal records evidence encountered by the player. There is no “insight meter,” and insight is not a universal key for unlocking hidden content.
- World transformations are governed by narrative events, conditions, and world state. After a transformation, existing locations, dialogue, character behavior, or item meanings should change.
- Players should revisit familiar locations and reinterpret earlier details in a new context.

## 6. Endings and state model

Keep these dimensions logically separate:

- **Relationship state**: trust, closeness, conflict, or commitments between Mite and other characters.
- **Clue/investigation state**: evidence the player has encountered, recorded, or connected.
- **World state**: events that have occurred, village changes, faction actions, and transformation phases.

Endings may combine these dimensions, but a single affection score must not control the entire story. Physical intimacy is not assumed to be a hard prerequisite for a major ending. The content and conditions of each ending remain open.

## 7. First prototype and vertical slice

Development order:

1. Build the smallest runnable project and state model.
2. Validate the morning/daytime/evening action loop.
3. Validate region-map navigation, location visits, and time-based changes.
4. Validate key NPC schedules combined with authored events.
5. Validate how the clue journal records player evidence without violating Mite's knowledge boundary.
6. Then build a vertical slice: a small village, three key villagers with distinct behavior, one forest area, a clue journal, and one major world transformation with clear before-and-after differences.

This scope is a development proposal, not a cap on the final game. Validate the loop before expanding the map and script.

## 8. Status labels and decisions that must remain open

### Confirmed
The project direction and design constraints in sections 1, 2, 4, and 6.

### Proposed
Three key villagers; a small village plus forest; one major transformation in the vertical slice; specific activities and technical implementation.

### Open
- The ritual's true purpose, mechanics, and how much each participant knows.
- Whether the ritual structure is in the village, the forest, or distributed across multiple locations.
- Why and under what conditions villagers protect Mite.
- The final causal model and timeline for the Church, ancient gods, the Outer God, and kingdom history.
- Hero's fate, the Restoration Army's role, and cross-game chronology.
- The formal conditions and content of “A Grave for Mortals,” “Eternal Paradise,” and “Blazing Divine Retribution.”
- Whether to use specific plot beats such as villagers becoming cultists or a crowd of one hundred.

A proposal does not become canon merely because it appears in a design document.

## 9. Project boundaries and working rules

- This repository develops the daily-life simulation, location exploration, and visual-novel systems for Nereis Lullaby only. Do not mix in Nereis-Hero action-RPG implementation.
- Maintain important design documents in both Chinese and English.
- Develop on the `development` branch and commit milestones after staged checks.
- Do not intentionally trigger GitHub Actions.
- Every new conversation must begin by reading `docs/SESSION_START_HERE_CN.md` and its English counterpart.
