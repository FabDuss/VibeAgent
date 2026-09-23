# CLAUDE.md -- session rules for this repo

> Keep this file short: procedures and commands live in `.vibes/STACK.md`, settled decisions in
> `.vibes/INVARIANTS.md`, code rules in `.vibes/CONVENTIONS.md`. Merge this block into an
> existing CLAUDE.md rather than replacing it.

## Vibe agents
This repo uses the Vibe agents (`.claude/agents/vibe*.md`) and their workspace `.vibes/`.

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
- Before any work, read `.vibes/STACK.md` (commands, ports, git and release procedure).
