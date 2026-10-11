# Week One NPC Schedules and Event Chain (Prototype Proposal)

> Status: This is a content draft for the core-system prototype, not finalized canon. The three NPCs use slots A Caregiver, B Worship Leader, and C Doctor / Herbalist from the character matrix. Names, exact identities, and ritual mechanics remain open. Schedules, clues, and the Day 7 anomaly are proposals.

## 1. Prototype goals

- Each day has morning, daytime, and evening. Players choose locations or activities; they need not complete every event.
- NPCs continue their lives when the player does not visit: they work, meet others, handle tasks, and leave consequences.
- Everyday actions must work as real life before gaining a second meaning through later evidence.
- The notebook records only observations, statements, and contradictions the player actually encountered. It does not automatically label them “cult,” “Outer God agent,” or another unproven conclusion.
- Missed key conversations or observations need a reasonable alternate route.
- The Day 7 anomaly is a proposal only. This document does not define the Outer God's arrival mechanism, ritual location, or full story trigger conditions.

## 2. Draft schedules for three NPCs

Location codes are prototype placeholders: HOME = near Mite's home; COMMONS = village public space; SHRINE = public worship space; CLINIC = treatment room; PATH = village paths. Exact map placement comes later.

| Day | Slot | A Caregiver | B Worship Leader | C Doctor / Herbalist |
|---|---|---|---|---|
| 1 | Morning | HOME: prepare breakfast and do chores | SHRINE: tidy the space and check flowers | CLINIC: sort herbs and patient notes |
| 1 | Daytime | COMMONS: shop for household goods | COMMONS: respond to residents' requests | CLINIC: see a resident with poor sleep |
| 1 | Evening | HOME: tidy up and wait for Mite | SHRINE: prepare a public prayer | CLINIC: finish case notes and close |
| 2 | Morning | HOME: mend clothing | SHRINE: replace wilted flowers | CLINIC: check common remedies |
| 2 | Daytime | COMMONS: help a neighbor carry food | COMMONS: help a displaced person with an errand | PATH: gather common herbs |
| 2 | Evening | HOME: remind Mite not to skip dinner | SHRINE: discuss an upcoming community activity | CLINIC: organize the previous day's notes |
| 3 | Morning | HOME: prepare a simple meal | SHRINE: check doors and the table as usual | CLINIC: notice two records mentioning similar dreams |
| 3 | Daytime | COMMONS: return a borrowed tool | COMMONS: coordinate communal work | CLINIC: ask patients about recent sleep routines |
| 3 | Evening | HOME: talk with Mite about ordinary chores | SHRINE: privately confirm an activity's time | CLINIC: group similar symptoms without a supernatural conclusion |
| 4 | Morning | HOME: prepare food and notice a household item out of place | SHRINE: tidy an ordinary object used repeatedly | CLINIC: update a patient's sleep notes |
| 4 | Daytime | PATH: deliver something to a neighbor | COMMONS: help a newcomer understand local arrangements | CLINIC: see a resident reporting fatigue |
| 4 | Evening | HOME: explain a custom as “how the village has always done it” | SHRINE: explain an activity's public meaning | CLINIC: notice residents recall different symptom-onset dates |
| 5 | Morning | HOME: prepare breakfast as usual | SHRINE: prepare a public activity without explaining hidden meaning | CLINIC: review the week's cases without inferring causation |
| 5 | Daytime | COMMONS: help distribute food or supplies | COMMONS: lead an ordinary community activity | CLINIC: briefly leave to gather materials |
| 5 | Evening | HOME: worry if Mite returns late | SHRINE: tidy the space alone after the activity | CLINIC: write a question beside a case note |
| 6 | Morning | HOME: ordinary chores; available for questions about earlier days | SHRINE: prepare worship and give their own explanation of dates if asked | CLINIC: verify timestamps without treating correlation as cause |
| 6 | Daytime | COMMONS: handle a small neighborhood task | COMMONS: mediate a minor disagreement | CLINIC: check whether a patient's symptoms returned |
| 6 | Evening | HOME: ask Mite to return early for an ordinary-sounding reason | SHRINE: appear uneasy when a routine is interrupted, without explaining why | CLINIC: notice similar symptoms do not always affect the same person |
| 7 | Morning | HOME: ordinary life; no foreknowledge of an anomaly | SHRINE: prepare the public activity as usual | CLINIC: organize case notes as usual |
| 7 | Daytime | COMMONS: handle daily tasks; react from current location if an event occurs | SHRINE / COMMONS: follow public plans; react from current location | CLINIC: see a patient or sort notes; react from current location |
| 7 | Evening | HOME or a reachable location: notice a subtle environmental or behavioral change | SHRINE: try to maintain familiar order and perhaps avoid explaining the change | CLINIC: revisit old notes and decide some details merit checking |

Scheduling rules:
- This is a logical draft; the player will not necessarily see every NPC in every slot.
- NPC locations come from game state. Any story override must record its reason, start condition, and recovery condition.
- Design the Day 7 anomaly's visuals, audio, text, and trigger separately after the core prototype passes. No character is assumed to know the truth.

## 3. Seven-day pacing

### Day 1: establish believable ordinary life
The player freely explores near home, the commons, worship space, and clinic. They see everyday care, public service, and routine medical work. The notebook records public roles, daily observations, and words heard directly. Do not make everyone suspicious on day one.

### Day 2: establish community support
The player may carry goods, accompany a displaced person, gather common herbs, or decline. Displaced people have their own goals rather than existing as investigation tools. If the player skips an activity, next-day conversation or leftover objects can establish that it happened.

### Day 3: the first subtle repetition
At the clinic, two people may describe similar sleep trouble. If missed, a later case summary or casual remark preserves the clue. Record similarity without inferring a shared cause. Ordinary explanations include war stress, season, diet, or common illness.

### Day 4: one custom, different explanations
The caregiver explains an arrangement as everyday habit; the worship leader describes a similar arrangement as public tradition. Neither needs to be lying. Record both statements and contexts, not a verdict. A later public notice or location detail can provide the missed perspective.

### Day 5: an ordinary object repeats across settings
Similar objects or preparations appear in two everyday scenes. Record appearance, place, time, and what was actually observed; do not label it ritual equipment. Ordinary explanations include shared tools, communal purchases, customary supplies, or work requirements. Mite does not guess the hidden purpose.

### Day 6: a checkable discrepancy appears in records
The doctor notices patients recall different dates for symptom onset; the worship leader is unusually careful about an arrangement; the caregiver wants Mite home at the customary time. Record date discrepancies and behavior separately. Ordinary explanations include stress-related memory errors, habits, or responsibility.

### Day 7: subtle world anomaly (proposal)
Proposed direction: after a clear event condition is met, an environmental sound, familiar public routine, or NPC response to a familiar detail changes briefly and observably. Do not explain the cause immediately.

Candidate reactions: the caregiver first checks Mite's safety; the worship leader tries to preserve public order; the doctor records observations and seeks ordinary explanations.

Candidate observable changes:
1. An environmental detail in a familiar location changes.
2. An NPC's usual schedule or wording changes.
3. An old record, repeated object, or earlier statement gains a new contradiction.

These are prototype proposals only. They do not define the Outer God's arrival, ritual mechanics, or final plot. Whether the anomaly occurs in week one must be playtested. Afterwards, players should be able to revisit places, reread notes, and compare earlier statements.

## 4. Suggested event and state model

A first version can use explicit conditions and records rather than a complex dynamic narrative engine:

- day_index: current in-game day.
- time_slot: morning, daytime, or evening.
- npc_schedule: planned location and activity for the current slot.
- schedule_override: whether a story event overrides the schedule, plus reason and recovery condition.
- event_id: stable event identifier.
- event_conditions: required day, location, observed facts, or world phase.
- event_outcomes: explicit effects on NPC state, world state, visible text, and location presentation.
- observed_facts: facts actually observed by the player.
- clue_links: candidate relationships between evidence, not equivalent to truth.
- alternate_clue_routes: alternate acquisition paths when an original event is missed.

Keep relationship, investigation/clues, and world state separate. Affection must not become a proxy for truth or a replacement for ending conditions.

## 5. Alternate clue routes for missed events

| Original event | Proposed alternate route | Must not reveal directly |
|---|---|---|
| Similar symptoms on Day 3 | Later anonymized case summary or a patient's casual remark | Supernatural cause |
| Two explanations of a custom on Day 4 | Attend a later public activity, inspect the layout, and speak to the other person | Who is lying or the ritual's truth |
| Repeated object on Day 5 | See a similar object or preparation in another ordinary location | Hidden ritual purpose |
| Different remembered dates on Day 6 | Revisit records or ask a relevant character again | Whether one force caused the discrepancy |
| Environmental anomaly on Day 7 | Revisit the location for a lingering change or hear separate accounts | Full explanation of the Outer God, Mite's role, or arrival mechanism |

An alternate clue need not reproduce the original scene's drama, but must preserve the minimum evidence needed to understand the contradiction.

## 6. Prototype checklist

- [ ] The day advances through three slots without requiring every activity.
- [ ] All three NPCs continue their schedules without player intervention.
- [ ] No NPC appears in multiple places in the same slot.
- [ ] Schedule overrides have explicit causes and recover correctly.
- [ ] The notebook records only encountered information and does not conclude for the player.
- [ ] Each anomaly has at least one credible ordinary explanation.
- [ ] Missing one key activity does not permanently remove the core contradiction.
- [ ] If tested, at least three Day 7 changes trace back to earlier details.
- [ ] Mite gains no active second-sight or supernatural-knowledge progression system.
- [ ] Proposals are not promoted to canon without approval.

## 7. Next steps

1. Use this schedule as sample content data to validate time progression and NPC scheduling.
2. Design minimal event-log and clue-notebook data structures.
3. Implement testable prototypes for NPC schedules, event overrides, and clue records.
4. Once stable, decide whether week one uses the Day 7 anomaly and define its presentation and trigger.
