# Nereis Lullaby — v0.3 Mainline Runtime

## Design rule

The player sees the passage of tavern days and changes in the world, but does not see the runtime values that drive the story.

Hidden runtime examples:

- NPC trust / fear / memory
- story flags
- sanity-like values
- event status
- event deadlines
- mainline stage
- branch locks

Visible information is limited to natural world information such as the current tavern day and available actions.

## Mainline flow

| Stage | Meaning | Player-facing behavior |
| --- | --- | --- |
| 1 | Village facade | Normal morning work and tavern routine |
| 2 | First abnormal clue | Hunter becomes willing to reveal a forest secret |
| 3 | Player commits to investigation | A later morning gains a temporary extra action |
| 4 | Investigation started | The world begins to diverge from the normal village routine |
| 5+ | Reserved for the real mainline | To be filled after the runtime skeleton is stable |

The stage is stored in `StoryState` as `mainline_stage` and is never displayed directly.

## Mainline flow

Day 1
  village facade

Day 2-4
  hunter trust threshold -> forest anomaly revealed

Day 3-6
  forest route window -> commit investigation or silently miss it

Next morning
  forest investigation -> touch or leave the strange mark

Day 5-6
  hero notices the anomaly -> player tells or hides the truth

Day 7-9
  church shadow appears

Day 9-10
  church patrol encounter -> follow or avoid

Day 11-12
  final three-way choice -> demo ending

## Runtime rules

- Story events are loaded automatically from data/game/events/*.json.
- Event windows use hidden day limits; missing a window can permanently expire that route.
- Story choices are exposed only when their current scene/phase makes them relevant.
- Phase dialogue queued by a choice is now played immediately after the choice.
- The final choice is introduced by a short morning dialogue before the options appear.
- EndingManager consumes the hidden demo_ending_request flag and opens the ending scene.

## Current implementation boundary

The v0.3 playable demo now has the full narrative skeleton from the hunter reveal through the three demo endings.

Next work:
- tavern interaction polish
- story-dialogue close/back UX
- stronger branch-specific consequences
- visual and audio feedback
- additional art assets
- expanding ending content

## Important constraint

Do not turn the above into a quest log, objective tracker, countdown, trust meter, sanity meter, or visible branching diagram.

The runtime should create consequences first; UI should only expose the actions a player can naturally perceive in the current scene.
