# Prologue Vertical Slice Implementation Plan (Direction B · Balanced)

> Status: approved execution plan. Individual dialogue and anomaly details remain prototype content and do not automatically become canon.
> Baseline: `development` branch. The project maintainer performs local Godot and human-play validation; a code commit does not imply tests passed.

## Delivery goal

Deliver a Galgame-style prologue that can be started from the beginning, saved and resumed, and completed normally. The core experience should form a complete loop:

**Establish daily life → build relationships → notice contradictions → Day 7 anomaly → revisit familiar places → restrained prologue closure.**

Keep the current seven destinations, seven days with three periods each, three key NPCs, clue journal, event ledger, information network, and single-slot save. Evolve existing code instead of abstracting for its own sake or prematurely expanding into a full village simulation.

## Work packages and estimates

| ID | Work package | Scope | Acceptance criteria | Estimated effort |
|---|---|---|---|---|
| P0 | Core regression and boundary fixes | Review time progression, action economy, NPC presence, anomaly trigger, completion rules, and cross-system save consistency; fix issues provable by static review | Smoke and schedule-boundary tests cover key edges; failed actions never publish partial state; unexecuted tests are never reported as passing | 1–3 days |
| P1 | Seven-day narrative continuity | Define each day's emotional/information role; reduce repetitive dialogue; connect personal moments, discovered clues, and anomaly callbacks; keep hidden explanations non-canonical | First-time players understand the current daily goal; key evidence has an alternate discovery path; dialogue distinguishes evidence from inference; Mite remains unaware of her hidden identity | 3–6 days |
| P2 | NPC actions and observable consequences | Connect deterministic autonomous actions, character memory, relationship feedback, and observations made while present; only transmit information through plausible channels | No NPC appears in multiple locations in one period; off-screen actions are not directly narrated as witnessed; important state changes have event provenance; save/load preserves results | 2–5 days |
| P3 | Prologue closure and usability | Improve post-anomaly location feedback, ending text, restart, objective hints, journal readability, and save/load feedback | Players can finish and see a clear closure; completion can be saved and restored; restart resets every runtime subsystem; invalid operations provide clear feedback | 2–4 days |
| P4 | Documentation and delivery | Keep the CN/EN roadmap, acceptance checklist, playtest guide, and change log aligned | CN/EN docs agree; implementation, static review, automated execution, engine validation, and human acceptance are reported separately | In parallel, about 1 day |

These are rough development days, not calendar promises; work packages overlap. Initial total is approximately **7–14 development days**, subject to findings during review. Local Godot validation is scheduled by the maintainer and is not counted as assistant coding effort.

## Current iteration: low-risk P1 entry point

- [x] Add restrained callbacks to post-anomaly exploration based on evidence the player personally recorded earlier.
- [x] Add core smoke-test assertions for these callbacks.
- [x] Add alternate observation routes for missed conversations: clinic records recover sleep-trouble and date-discrepancy evidence, the home area recovers the everyday-custom explanation, and the shrine recovers the public-custom explanation; pure-logic tests cover the reusable route selector.
- [ ] Audit dialogue and clue conditions for repetition, conflicts, and clues with no alternate discovery route.
- [ ] Review each day across three layers: what the player sees, what Mite understands, and what objectively happens in the world.
- [ ] Document stable event IDs, conditions, outcomes, and alternate evidence for key actions.

## Acceptance gates

### A. Core systems
- [ ] Progress from Day 1 to Day 7 evening normally; the anomaly triggers only once.
- [ ] At most one primary action is consumed per ordinary period; movement and observation are free.
- [ ] NPCs outside the current location cannot be spoken to; invalid schedules and time coordinates fail safely.
- [ ] Events, clues, relationships, action history, and information transfer remain consistent; failed actions publish no staged state.
- [ ] Corrupt or cross-system-inconsistent saves are rejected without partially replacing current runtime state.
- [ ] After save → quit → restart → load, time, location, relationships, clues, world phase, event ledger, and information network agree.

### B. Galgame prologue experience
- [ ] First-time players can understand basic controls, the current period, and optional objectives.
- [ ] The three key NPCs have distinct dialogue and routines; personal moments trigger correctly and do not repeatedly grant rewards.
- [ ] Early details gain new context later without automatically revealing hidden truth.
- [ ] Missing one important conversation does not block the minimum evidence needed to understand the core contradiction.
- [ ] The Day 7 anomaly changes observable content in at least three existing locations.
- [ ] Visiting three distinct locations after the anomaly allows the player to finish; revisiting the same location does not count twice.
- [ ] Closure reflects what the player actually experienced, does not use relationship values as direct ending switches, and does not canonize prototype plot.

### C. Transparent delivery
- [ ] Each iteration reports changed files, commit links, static-review scope, unexecuted tests, and remaining work.
- [ ] The maintainer runs Godot tests locally; writing a test is not described as passing it.
- [ ] Do not proactively trigger GitHub Actions.
- [ ] Maintain Chinese and English documentation together.

## Deferred work

- Production character portraits, backgrounds, animation, voice acting, music, and sound effects.
- A large population of generic villagers or high-complexity village-wide simulation.
- Finalizing endings, ritual mechanics, hidden-identity reveals, and cross-game story conditions.
- Large frameworks or external dependencies for gameplay that has not yet been validated.

## Iteration report format

1. Committed changes and commit links.
2. Problems solved and observable player-experience changes.
3. Verification level: static review / test code added / automated tests executed / Godot engine validation / human playtest.
4. Remaining effort and next tasks.
