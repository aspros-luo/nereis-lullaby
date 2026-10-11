# Playable Prototype Guide

> Scope: the seven-day text vertical slice on the current development branch. The Day 7 anomaly is prototype story content, not finalized world canon.

## Launch

1. Open `project.godot` in Godot 4.6.x.
2. Run the main scene.
3. The game starts on Day 1 morning. Save/load is not implemented yet, so restarting begins a new run.

## Core rules

- Each day has morning, daytime, and evening.
- During ordinary days, take one meaningful action per period: talk to a present villager or perform an everyday activity at the current location.
- Travel and observation do not consume the main action.
- Relationship values exist to test state feedback; they are not a finalized affection or ending formula.
- The clue journal records encountered evidence. It does not reveal the correct answer or imply that Mite understands the hidden truth.
- Advancing time from the evening of Day 7 triggers the prototype anomaly. Time then stays at evening while the player can freely travel, talk, and explore.

## Suggested first run

1. Talk to the caregiver or perform an everyday activity near home.
2. Visit the commons, shrine, and clinic. Different people may be present at different times.
3. From Day 3 onward, talk to the doctor at the clinic to hear about several villagers' sleep troubles.
4. From Day 4 onward, talk to the relevant characters near home and at the shrine, then compare their ordinary explanations of a village custom.
5. From Day 5 onward, inspect the commons or shrine; you can also gather flowers or inspect the forest.
6. Continue to the evening of Day 7 and pay attention to familiar locations before and after the anomaly.
7. After the anomaly, revisit at least three locations. Exploration can continue; once three locations have been revisited, the “End This Chapter of Daily Life” button appears.

## Known limitations

- This is a text UI prototype, without final map art, character portraits, animation, music, or sound effects.
- Save/load is not implemented; closing the game loses the current run.
- Characters and plot text are prototype content. Specific ritual mechanics and hidden identities are not finalized canon.
- The automated smoke-test script is in the repository but has not yet been run by Godot in the current tool environment.
- If Godot reports an error, save the full error text and the steps that triggered it.

## Questions to evaluate

- Does one meaningful action per period feel too restrictive or too loose?
- Are travel and observation easy to understand?
- Do NPCs feel as if they follow their own routines?
- Do clues invite questions instead of explaining everything?
- Do revisited locations feel noticeably different after the anomaly?
