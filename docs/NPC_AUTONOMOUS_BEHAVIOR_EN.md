# Discrete NPC Autonomous Behavior (Prototype Implementation)

## Purpose

Villagers should continue observable daily routines when the player is not talking to them, without becoming omniscient plot devices. This is deterministic discrete choice, not an LLM or a complex planning AI.

## Behavior rules

- After each time-step advance, the system chooses one routine action for the caregiver, worship leader, and doctor.
- Choices use that character's behavior card, current time period, relationship value, and their own inbox size; they do not read global hidden truths.
- Identical inputs produce identical choices, making regression tests reproducible.
- A stronger Mite–caregiver relationship prioritizes checking on Mite; a doctor with incoming messages prioritizes reviewing records. These are prototype rules, not finalized character canon.
- Every autonomous action creates a unique worldline event containing actor, action, tick, and scheduled location.
- The latest action is stored in the existing game-state flags and is therefore included in the existing save format.
- Day changes and the anomaly transition are authored beats; autonomous behavior cannot overwrite them.
- Personal everyday scenes remain governed by their existing authored rules. Simulation does not rewrite dialogue, endings, or key facts.

## Code locations

- `scripts/data/npc_behavior_profiles.gd`: character goals, motives, knowledge boundaries, and stress responses.
- `scripts/managers/npc_behavior_simulator.gd`: deterministic action selection and result validation.
- `scripts/ui/main.gd`: advances time, records worldline events, and displays the villagers' current actions.
- `scripts/core/game_state.gd`: the existing world-state flags persist recent actions; no separate save format is needed.

## Limits and next steps

- The action sets are small and rule-based. There are no cross-region NPCs, NPC-to-NPC communications, resource costs, or long-term plans yet.
- Inbox size is currently only a simple behavior input; unread state, credibility, and whether a character believes a message are not yet factored separately.
- Autonomous behavior is wired into the main loop and smoke-test code but has not been executed in Godot.
- Next, strengthen regression coverage for observable feedback and causal events, then design limited-authority behavior blueprints for merchants, junior Church clerks, and Restoration Army quartermasters. Their loyalties and story roles will remain undecided until deliberately designed.
