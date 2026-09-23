# CLAUDE.md -- VibeAgent kit

This repo IS the Vibe agents kit, and it is developed with its own agents.

## Two things that look alike -- never mix them (INV-002)
- `templates/` (incl. `templates/vibes/`): what `install.ps1` / `install.sh` copy INTO other
  projects. Placeholders stay placeholders; never fill them with this repo's values.
- `.vibes/`: this repo's own workspace (filled STACK, invariants, plans, notes, audits).
- `.claude/agents/`: the agents, both used here and distributed.

Before any work, read `.vibes/STACK.md`. The only gate is `bash tests/check-kit.sh`: run it
before every commit.

## Vibe agents
- Best: run the conductor as the main thread -- `claude --agent vibe`.
- When the conductor runs as a SUBAGENT (e.g. "vibe: ..." from a normal session, or in an IDE
  extension), it cannot talk to the user mid-run. It stops at every gate and returns a
  `HANDBACK (vibe)` block. The calling session MUST:
  0. start it with the user's message QUOTED VERBATIM (in quotation marks), then its own
     context after it, labelled as such -- a paraphrase is never treated as the user's request;
  1. show each handback's questions / GO request to the user as they are;
  2. never answer them on the user's behalf, never paraphrase a GO;
  3. send the user's reply back VERBATIM to the same agent with SendMessage (not a new Agent
     call), so the conductor keeps its context;
  4. if that agent cannot be resumed, start a new `vibe` with "resume plan <NNN>-<slug>" plus the
     user's verbatim reply.
- Never ask the `vibe` subagent to "do everything and deliver": the plan -> review -> GO gates
  are the point of the workflow.
