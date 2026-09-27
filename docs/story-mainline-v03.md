# Nereis Lullaby — v0.3 Mainline Skeleton

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

## Mainline stages

| Stage | Meaning | Player-facing behavior |
| --- | --- | --- |
| 1 | Village facade | Normal morning work and tavern routine |
| 2 | First abnormal clue | Hunter becomes willing to reveal a forest secret |
| 3 | Player commits to investigation | A later morning gains a temporary extra action |
| 4 | Investigation started | The world begins to diverge from the normal village routine |
| 5+ | Reserved for the real mainline | To be filled after the runtime skeleton is stable |

The stage is stored in `StoryState` as `mainline_stage` and is never displayed directly.

## Current flow

```text
Day 1
  normal village facade
        |
        v
Day 2-4
  hunter trust threshold
        |
        v
  hunter reveal
        |
        +-------------------+
        |                   |
     accept              avoid
        |                   |
        v                   v
  stage 2              hidden missed route
        |
        v
Day 3-6
  forest route available
        |
        v
  player chooses
        |
        v
  commit investigation
        |
        v
next morning
  "深入森林" becomes available
        |
        v
  player actively enters
        |
        v
  stage 4
```

## Important constraint

Do not turn the above into a quest log, objective tracker, countdown, trust meter, sanity meter, or visible branching diagram.

The runtime should create consequences first; UI should only expose the actions a player can naturally perceive in the current scene.
