# CONVENTIONS -- how the kit is written

> The kit has no product code: Part A of the template (`templates/vibes/CONVENTIONS.md`) does
> not apply here, except A6 (tests that can fail) for `tests/` and A7 (docs tell the truth).

## Agent prompts (`.claude/agents/*.md`)
- English, imperative, second person ("You ..."). Frontmatter: `name` = file name, quoted
  `description` with its trigger words, explicit `tools`, `model`, `color`.
- Each agent is self-contained: it never needs to read another agent's file. Vocabulary shared
  between agents (plan statuses, note lifecycle, verification levels, STACK keys, ID formats) is
  written IDENTICALLY in each of them -- change it everywhere in the same commit.
- State a rule once per agent, where it acts; no restating the same rule in three sections.
- Every rule traces to a reason. When the reason is a field lesson, record it (INV-005).
- A rule that needs a project value cites a STACK key (INV-001, INV-004), never a literal.

## Templates (`templates/`)
- English, placeholders as `<...>`, examples clearly marked as examples. A template is what a
  project starts from: nothing in it may look like a real value the agents could execute
  (`STACK_STATUS: template` until filled).

## Scripts (`install.ps1`, `install.sh`, `tests/`)
- ASCII only (PowerShell 5.1 reads BOM-less files as ANSI). `install.ps1` runs on Windows
  PowerShell 5.1: no `&&`, no ternary, no `??`; native commands wrapped so stderr cannot throw.
- bash: `set -euo pipefail` (tests: `set -uo pipefail` and explicit counting).
- The two install scripts stay behaviourally identical (INV-003); change both in the same commit.
- Every script change is followed by `bash tests/check-kit.sh`.

## Docs (`README.md`, `CHANGELOG.md`, `docs/`)
- French. README describes the kit as it IS (tree, commands, flow); CHANGELOG gets an entry per
  change, with the version and date.
