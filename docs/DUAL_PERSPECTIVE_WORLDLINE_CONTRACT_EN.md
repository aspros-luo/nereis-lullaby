# Dual-Perspective Worldlines and Causal Event Contract (Proposal)

> Status: architecture proposal, not finalized canon. This document constrains how *Nereis-Lullaby* expresses indirect influence on the shared world. Actual ending conditions must be implemented and verified independently in *Nereis-Hero*.

## 1. Core Design

*Nereis-Hero* and *Nereis-Lullaby* are two player perspectives on one causal history, not unrelated stories:

- **Hero — direct decision-maker.** Through exploration, investigation, combat, alliances, and explicit choices, the player decides how the knight responds to opportunities and dangers.
- **Lullaby — indirect shaper.** Through Mite's routines, relationships, actions, and approach to or avoidance of anomalies, the player changes when information appears, who can meet whom, what motivates an investigation, and which opportunities remain available.
- **The world does not wait for the player.** NPCs have their own goals, schedules, knowledge boundaries, and stress responses. They can be influenced, but should not become buttons waiting for player input.

This does not mean Mite consciously manipulates everyone. The player chooses actions, while Mite may understand them as ordinary life, care, or curiosity. Her own knowledge boundary must remain intact.

## 2. Causal Chains, Not Ending Switches

Represent progression as a traceable chain:

`Player action → local change → character observes/learns → character interprets → character acts → future opportunity changes → choices available to Hero`

Every transition needs a plausible cause. A hidden affinity score must not directly determine an ending, and an unrelated routine action must not magically change the world.

For example, picking flowers repeatedly in the forest should not directly set `eternal_paradise = true`. At most, it may change observable traces, villagers' ordinary judgments, whether Hero notices an anomaly, and whether a later investigation has a plausible motive. Whether Hero investigates deeply, finds evidence, and responds remains part of *Hero*'s own actions and decisions.

## 3. Cross-Game Event Contract

The games should share stable **world-fact/event semantics**, not depend on each other's scene nodes, script paths, or UI text.

Important events should define:

- `event_id`: stable identifier.
- `source_game`: perspective in which the event originated.
- `actor` / `target`: actor and affected subject.
- `preconditions`: requirements for the event.
- `world_facts_added`: what actually happened in the world.
- `knowledge_grants`: who learned what and through which channel.
- `opportunities_opened/closed`: which later opportunities became available or unavailable.
- `evidence`: observable scenes, objects, dialogue, or absence.
- `recovery_path`: whether alternate traces remain if the main scene is missed.
- `provenance`: confirmed fact, prototype content, or unresolved proposal.

Keep three layers separate:

1. **Facts:** what actually happened.
2. **Knowledge:** what each character knows, believes, misunderstands, or does not know.
3. **Opportunities:** what a character is currently able to do. An opportunity does not mean the character will take it.

*Lullaby* may emit stable worldline signals or event summaries. *Hero* can consume those signals, but must still use Hero's own action state to determine investigation, alliances, and endings. Runtime networking or shared saves between the games are not required at this stage.

## 4. Non-Canon Example: Rebel News and Forest Investigation

The following scenarios test the design, but are not finalized story or ending conditions.

### Path A: News reaches Hero

1. During a relationship scene with Hero, Mite encounters an outsider and hears news about the restoration army.
2. The player decides whether to tell Hero.
3. If Hero receives credible information, he may attempt to contact the restoration army. The message alone does not mean he joins, and does not determine an ending.
4. In *Hero*, the player must still complete the relevant contacts, tasks, and choices before the worldline moves toward a church-resistance/restoration-army route.

### Path B: Routine traces motivate a forest investigation

1. Mite visits the forest repeatedly, potentially leaving recurring picking traces or triggering unusual details.
2. Those traces affect another character only after that character observes, hears about, or reasonably infers them.
3. Hero may investigate the forest. In *Lullaby*, the player may avoid, discourage, or alter related interactions out of concern; this may weaken motivation, delay the investigation, or leave an evidence chain incomplete.
4. Whether Hero investigates deeply and obtains a particular key item must be determined by *Hero*'s exploration, conditions, and recoverable evidence paths.
5. “The third umbilical cord” is only a candidate key item from the user's example. Its role, acquisition requirements, and relationship to any ending remain undecided.

These paths illustrate the division: Lullaby affects **information, motivation, contact, and opportunity**; Hero decides **how to respond to opportunities and bear the consequences**.

## 5. State Categories Must Not Be Conflated

| Category | Example | Anti-pattern |
|---|---|---|
| World fact | An outsider arrives; a trace appears | Erasing a fact because the player did not see it |
| Character knowledge | Mite hears a rumor; Hero has not learned it | Syncing the journal to every NPC |
| Belief | Doctor suspects stress; villagers mistake a sound for an old bell | Treating suspicion as truth |
| Relationship | Mite worries about Hero; Hero trusts or distrusts her | Replacing all dimensions with one affinity score |
| Intention/action | Hero plans to investigate; doctor avoids a subject | Treating a plan as a completed action |
| Opportunity | Contact with the restoration army is possible; forest investigation remains open | Equating an open opportunity with an ending |
| Ending condition | A complete causal chain eventually satisfies requirements | Hardcoding Hero's ending in Lullaby |

## 6. Important Choices Need Observable Feedback

Players should perceive the consequences of choices, even when they do not immediately understand them. Feedback can include:

- NPC schedule changes, temporary absence, or an unexpected visit;
- changed dialogue, avoidance, or differing accounts of the same event;
- object placement, traces, records, or the presence/absence of information;
- whether Hero later mentions a message or gains a new investigation lead;
- secondary evidence or rumors after the primary scene is missed.

Avoid using “worldline +1” as the main feedback. Internal values may be useful, but players should perceive changes through people and the world.

## 7. Guardrails

- Do not promote examples to canon automatically, especially the relationship among the restoration army, forest investigation, third umbilical cord, and endings.
- Not every routine action must affect the main plot. Worldline changes need thresholds, transmission channels, and plausible accumulation.
- A key event may be missed, but important facts should generally leave a costlier, less informative, or riskier alternate path unless an irreversible tragedy is explicitly intended.
- Mite's kindness and innocence are genuine. Kindness may have complex consequences, but the system must not imply that she knowingly orchestrates everything.
- Hero does not know Mite's true identity unless a future, explicit, verifiable event changes that knowledge state.
- Cross-game synchronization uses stable event IDs and semantic contracts, not implementation details.
- Every ending decision must be traceable to player actions, character knowledge, world facts, and satisfied conditions.

## 8. Implementation Order

1. Establish character memory, knowledge-source, and event-causality data in Lullaby.
2. Make the three key NPCs' behavior visibly change schedules, dialogue, locations, or available information.
3. Give important actions stable event IDs and testable state changes.
4. Implement corresponding inputs/opportunities in Hero; test each game independently without runtime coupling.
5. Build a small number of end-to-end causal paths and test visibility, missability, and soft-lock risk.
6. Expand to ordinary NPCs and more worldline branches.

## 9. Current Status

This document defines a dual-perspective causal contract and non-canon examples. **The example plot, third umbilical cord, and ending bindings have not been added to gameplay code.** The NPC autonomous behavior simulator is not implemented, and Godot engine tests have not been run.