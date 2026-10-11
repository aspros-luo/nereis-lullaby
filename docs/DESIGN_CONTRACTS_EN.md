# Narrative and Design Contracts

## 1. Canon status
Every setting, plot, and ending proposal must have a status:
- **Confirmed**: explicitly approved by the user and binding for future work.
- **Proposal**: suggested by either party but not finalized.
- **Open**: unresolved or underspecified; do not infer a definitive answer.
Never silently promote a proposal into official story canon.

## 2. Boundaries between the games
- **Nereis Lullaby**: Mite's life, relationships, exploration, investigation, and experience of world changes.
- **Nereis-Hero**: a separate action-exploration RPG from Hero's perspective.
- Share confirmed world facts while allowing different perspectives, knowledge, and interpretations.
- Cross-game connections must preserve timeline, character knowledge, and causality; the games do not need one identical plotline.
- Do not unilaterally decide Hero's future, the restoration army's fate, or Mite's final fate.

## 3. Viewpoint and UI copy
- The game is primarily experienced in Mite's first person. For her own home, actions, observations, and feelings, prefer natural first-person wording such as “my home” or “I arrive here.”
- Do not refer to Mite as an external character in player-facing UI (for example, “Mite's home”), or describe her from an outside observer's perspective while the player is controlling her.
- Location names, NPC names, and factual records may remain neutral; do not mechanically prefix every label with “I/my.”
- The clue journal supports player deduction, but its wording must stay within Mite's current understanding and must not reveal truths she does not yet know.

## 4. Character knowledge
Always distinguish:
1. Information the player has;
2. What Mite genuinely believes at that point;
3. Objective facts in the world;
4. What each other character knows, misunderstands, or has forgotten.
Characters do not automatically learn what the player discovers. Memory anomalies need consistent rules and traceable evidence.

## 5. Independence of relationships and endings
- Relationship systems may affect personal scenes, companionship, dialogue, and character reactions.
- Investigation systems may affect clues, world understanding, and event access.
- Major endings must not be reduced to a simple affection threshold.
- Physical intimacy or a single intimate event must not be a hard gate for RPG major endings; this project should not assume such a gate either.
- Relationship and world-state systems may interact, but each causal chain must be explicit and testable.

## 6. Daily simulation and ritual
- Everyday actions must make sense as ordinary life; not every action should exist only to manipulate a hidden meter.
- Mite's kindness and emotions must be genuine.
- Villagers need individual schedules, relationships, memories, and stress responses; they should not be copies of one shared consciousness.
- A clear event should trigger major world changes. Hidden state may affect prerequisites, presentation, and clues, but one corruption meter should not automatically switch the world.
- When a major scene can be missed, provide traceable aftermath evidence where possible to avoid soft-locking understanding.

## 7. Player experience
- Free activities should yield meaningful feedback: relationships, clues, locations, resources, delayed consequences, or new interpretations of old events.
- Avoid turning each day into a mechanical checklist.
- Side content may be missable, but one missed routine action should not permanently lock the main narrative or a major ending without clear warning.
- Validate the core loop in a small vertical slice before scaling up.

## 8. Documentation and repository discipline
- Keep Chinese and English documents synchronized.
- New sessions must read the session-start, worldview, design-contracts, core-gameplay, and roadmap documents.
- Do not trigger GitHub Actions.
- Reports must distinguish static review, logic simulation, engine runtime tests, and human playtesting.
