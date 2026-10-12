# Core Playability Acceptance Checklist (Development)

> Status: the code prototype contains the main loop, but Godot engine execution and human playtesting are not complete. This is an acceptance gate, not a claim that the gate has passed.

## Development order
1. Validate the core gameplay loop and save/load regression.
2. Connect the character matrix to actual decisions and observable consequences.
3. Expand story, side quests, endings, and presentation.

## Stage 1: Required loop checks
- [ ] Advance from Day 1 through the evening of Day 7; the phase transition occurs only once.
- [ ] An ordinary time slot permits one primary action; travel and observation do not consume it.
- [ ] NPCs appear at scheduled locations, and conversation is unavailable when they are elsewhere.
- [ ] Activities, conversations, and personal moments consume actions and produce expected relationship/clue changes.
- [ ] Repeated observations do not create duplicate journal entries.
- [ ] After the Day 7 anomaly, time remains stopped; exploration, visits, conversations, and completion conditions work. Completion requires at least three distinct valid locations; revisits do not count, and absent or unknown NPCs cannot be addressed.
- [ ] After saving, quitting, restarting, and loading, time, location, relationships, phase, action history, personal-moment flags, journal, ledger, and information network remain consistent; verify the version 1 save migration.
- [ ] Invalid save data does not partially overwrite the current runtime state; game day/slot, clue dates, network clock, and message ticks must be integers without relying on implicit coercion; message credibility and belief confidence must be finite numbers, and inbox receipt ticks must be integers; relationship values must be bounded integers with the complete expected character keys; clue-journal IDs match investigation state, every journal fact has ledger provenance, malformed NPC flags, NPC autonomous actions with mismatched or future in-game tick/day/slot values, inconsistent action history, an information-network clock later than game time, messages sent after the network's own saved clock or pending messages already due at that clock are rejected, and completed saves require three distinct visits.
- [ ] Event IDs are deduplicated; facts have supporting events; character knowledge has an explicit source; receiving a message does not automatically become objective knowledge.
- [ ] Clues from ordinary observations and the Day 7 anomaly have provenance events; failed conversations do not mutate clues or relationships.
- [ ] Complete one end-to-end playthrough and record blockers, softlocks, misleading feedback, and missable content.

## Current code baseline
- Implemented: 7 locations, 7 days × 3 slots, 3 key NPCs, action economy, schedules, scalar relationships, clue journal, phase anomaly, post-anomaly investigation, and a single-slot save.
- Implemented: event ledger, explicit knowledge grants, delayed information transfer, and an initial deterministic NPC routine selector.
- New protection: ledger loading validates required event fields, fact/first-event consistency, and all event-referenced facts; clue-journal loading now validates entries atomically and rejects duplicate IDs or missing fields.
- Core-state loading also rejects invalid locations, duplicate/unknown anomaly visits, missing anomaly flags, duplicate clue IDs, and malformed action history; completion requires visits to three distinct locations.
- Information-network loading checks inbox/delivered-message consistency, evidence for beliefs, and credibility bounds; the main flow also validates message provenance against the restored ledger and rejects a network clock later than game time.
- Not yet accepted: actual execution in Godot 4.6.1, full UI playtesting, and real save-file recovery after process restart.
- Tool limitation: static review cannot replace engine tests if a Godot executable is unavailable. Never report an unexecuted test script as passed.

## Gate for Stage 2
Do not expand the runtime character matrix until engine checks, save/load regression, and human playtesting for Stage 1 have been addressed. The matrix may continue as design documentation, but candidate characters, relationships, and causal links must not be treated as finalized story canon prematurely.
