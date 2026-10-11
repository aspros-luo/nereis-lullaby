# Required Context for New Sessions

## Project boundary
- This repository is exclusively for **Nereis Lullaby / 蜜忒之歌**, a text-adventure / visual-novel game.
- **Nereis-Hero** is a separate action-exploration RPG with its own repository and development workflow. Do not implement RPG work here.
- The games share a world, but need not retell the same scenes. Their established facts, timeline, character knowledge, and event outcomes must not contradict each other.
- This repository is a clean design baseline. Previous code is not an architectural or gameplay constraint.

## Highest-priority creative rules
1. **A proposal is not canon.** Examples, candidate plots, and possible endings must remain proposals unless explicitly approved.
2. **Do not decide endings unilaterally.** This includes Hero's fate, whether the restoration army becomes corrupt, Mite's fate, and cross-game causal chains.
3. When the user gives an opinion, internally weigh opposing considerations and provide a clear recommendation. Do not expose internal debate.
4. Mark important undecided narrative decisions as “Proposal / Open”; only move them to “Confirmed” after explicit user approval.
5. Maintain Chinese and English documentation together. Do not trigger GitHub Actions.
6. Report repository changes, tests, and runtime validation accurately; never claim work that was not performed.

## Confirmed direction
- The game is primarily told from Mite's perspective. She is an agent of an outer god but does not know this. Her innocence and emotions are genuine, not simply a disguise or deliberate manipulation.
- The game needs richer play than a short, purely linear text visual novel. Exploration, daily activities, autonomous characters, and clue-based investigation are candidate core systems.
- Mite and villagers should actively live and act, not remain static NPCs waiting for the player.
- Mite's everyday actions, both before and after meeting Hero, may objectively participate in a ritual she does not understand. The exact ritual rules remain open.
- Village routines, relationships, and key events jointly drive the narrative.
- Character relationships and investigation / ending conditions are related but distinct. Physical intimacy or one romance event must not become a hard gate for a major ending.

## Not yet canon
- Whether the cult's ritual center is inside the village, in the nearby forest, or distributed across both.
- The ritual's true purpose, mechanics, timeline, and each character's knowledge.
- Specific post-arrival behavior for Hero and any cross-game plot.
- Final content and conditions for “A Grave for Mortals,” “Eternal Paradise,” and “Heaven's Retribution.”
- The idea that villagers may become one hundred cultists to protect Mite is a promising candidate, not a finalized event and not assigned to a particular ending.

## Development principle
Build and validate a small playable vertical slice of the core loop before expanding the full plot, cast, and map. New sessions should read this file and the four bilingual design documents.
