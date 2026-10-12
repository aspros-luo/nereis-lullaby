# Village NPC Behavior Cards (Prototype)

> Status: first-pass behavior data for the system to read, not finalized canon. Cards constrain how characters react to what they know; they must not grant omniscient knowledge.

## Design rules

1. **Goals are not scripts.** Goals describe what a character tends to maintain, not a guaranteed action.
2. **Knowledge boundaries come first.** Characters act on personal experience, their own records, or explicitly received messages. Similar symptoms, anomalies, and rumors do not automatically become certain conclusions.
3. **Stress changes strategy, not knowledge.** Under pressure a character may avoid alarm, recheck records, preserve order, or offer care; stress cannot reveal hidden Church truths.
4. **Relationships are multidimensional.** Warmth, trust, willingness to cooperate, and perceived safety should not collapse into one affinity score.
5. **Memory records actual experiences.** Shared moments, promises, reports, and help may leave traces; events that never occurred must not be remembered.
6. **Cards are not canon.** These three cards summarize tendencies already implied by the prototype. New facts must be approved or explicitly labeled as proposals.

## Caregiver

- **Routine goals:** Care for Mite and preserve a stable, familiar household.
- **Motives:** Care, stability, familiarity.
- **Knowledge boundaries:** Knows household routines and Mite's childhood habits; cannot infer the cause of poor sleep from that symptom alone; the current prototype provides no evidence that she knows the Church's hidden research.
- **Memory dimensions:** Shared household moments, Mite's preferences, promises, and practical help.
- **Relationship dimensions:** Trust, warmth, perceived safety.
- **Stress response:** Avoid unnecessary alarm and offer practical care; do not force an explanation without evidence.
- **Fallback action:** Continue household care.

## Worship leader

- **Routine goals:** Keep public activities orderly and help villagers cooperate.
- **Motives:** Community cohesion, tradition, responsibility.
- **Knowledge boundaries:** Knows public customs and preparations personally coordinated; does not automatically know private medical records; a public explanation proves neither innocence nor deception.
- **Memory dimensions:** Shared preparations, public commitments, help received.
- **Relationship dimensions:** Trust, cooperation, respect for community roles.
- **Stress response:** Preserve routine and use a socially appropriate explanation without disclosing information not actually known.
- **Fallback action:** Continue public preparations.

## Doctor

- **Routine goals:** Care for patients and keep records usable and consistent.
- **Motives:** Duty of care, evidence, professional caution.
- **Knowledge boundaries:** Knows only patients and records personally encountered; date discrepancies do not establish a supernatural cause; similar symptoms alone do not prove a common cause.
- **Memory dimensions:** Patient reports, record discrepancies, care already provided.
- **Relationship dimensions:** Trust, reliability, willingness to share observations.
- **Stress response:** Recheck records, state uncertainty, and avoid premature diagnosis.
- **Fallback action:** Review patient notes.

## Code mapping and current scope

Cards live in `scripts/data/npc_behavior_profiles.gd`. The script exposes `get_profile(npc_id)` and required-field validation. Smoke-test code checks the three profiles, unknown-ID behavior, and defensive copying.

**Not yet complete:** The cards do not yet drive a full autonomous NPC decision loop; authored schedules and key dialogue remain controlled by the prototype script. Next, separate authored story beats from everyday choices driven by goals, knowledge, and pressure so autonomous behavior cannot overwrite critical scenes.
