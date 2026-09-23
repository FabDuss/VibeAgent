# INVARIANTS -- the VibeAgent kit

> Settled decisions for developing the kit itself. Same rules as the template
> (`templates/vibes/INVARIANTS.md`): cite by ID, one rule of 3 lines or less, amend in place,
> superseded entries to Retired, ~12 KB budget.

## Index
| ID | Title | Category | Guard |
|----|-------|----------|-------|
| INV-001 | Agent prompts are stack-agnostic | A | `tests/check-kit.sh` (STACK keys) |
| INV-002 | Distributed templates live in `templates/`; `.vibes/` is the kit's own workspace | A | `tests/check-kit.sh` (install contract) |
| INV-003 | Install: agents are kit-owned (updated), project files are never overwritten | A | `tests/check-kit.sh` (install contract) |
| INV-004 | Every STACK key an agent cites exists in the STACK template | B | `tests/check-kit.sh` (STACK keys) |
| INV-005 | Field lessons are traceable | B | none |
| INV-006 | Nothing durable in agent memory | C | none |

## A. Architecture & boundaries

### INV-001 -- Agent prompts are stack-agnostic
Rule: no toolchain, command, port, branch or project name is hard-coded in `.claude/agents/`; every project-specific value is read from the project's `.vibes/STACK.md` (or its rule files).
Where: `.claude/agents/*.md`, `templates/vibes/STACK.md`
Guard: `tests/check-kit.sh` section 3
Source: kit v1 principle (README v1), kept in v2 (2026-09-23)

### INV-002 -- Templates in `templates/`, `.vibes/` is the kit's own workspace
Rule: what `install.*` copies into projects lives in `templates/` (`templates/vibes/` for STACK / INVARIANTS / CONVENTIONS). The repo's `.vibes/` holds the kit's own filled STACK, invariants, plans and notes, and is never distributed.
Where: `templates/vibes/`, `.vibes/`, `install.ps1`, `install.sh`
Guard: `tests/check-kit.sh` section 6 (installed files must equal `templates/vibes/*`)
Source: 2026-09-23, user ("ok vas y" to the split proposal)

### INV-003 -- Install contract
Rule: `install.ps1` / `install.sh` add or overwrite `.claude/agents/vibe*.md`, and add project files (`.vibes/*`, VISION, ARCHITECTURE, CLAUDE.md) ONLY when missing -- never overwrite them. Both scripts behave the same.
Where: `install.ps1`, `install.sh`
Guard: `tests/check-kit.sh` section 6 (fresh install + re-run with a project edit and a stale agent)
Source: 2026-09-23, kit v2

## B. Single sources of truth

### INV-004 -- STACK keys
Rule: the STACK template is the single catalogue of project settings. An agent may cite a key only if it exists there; a new key is added to the template in the same change (and to this repo's `.vibes/STACK.md`).
Where: `templates/vibes/STACK.md`
Guard: `tests/check-kit.sh` section 3
Source: 2026-09-23, fresh review of kit v2 (keys cited but undefined)

### INV-005 -- Field lessons are traceable
Rule: a rule added because of a real-project lesson gets a row in `docs/LESSONS-TRANSFO.md` (or a sibling `docs/LESSONS-<project>.md`) saying where it is encoded; every change gets a CHANGELOG entry.
Where: `docs/`, `CHANGELOG.md`
Guard: none
Source: 2026-09-23, kit v2

## C. Product rules (how the agents must behave)

### INV-006 -- Nothing durable in agent memory
Rule: agents keep project state and knowledge in the repo (plans, notes, INVARIANTS, STACK), never in personal / agent memory -- cloud sessions and parallel sessions must resume from the repo alone.
Where: `.claude/agents/vibe.md` (Separation of Powers), `templates/vibes/STACK.md` header
Guard: none
Source: 2026-09-23, lesson from SuiviTransfo (docs/LESSONS-TRANSFO.md #41)

## D. External-system facts
- (none yet)

## E. Do-not list
- Do NOT add a runtime dependency to the kit (scripts stay plain bash / PowerShell 5.1).

## F. Do-not-fix
- (none yet)

## Glossary
- WP: work package, one Codeur dispatch. Plan: `.vibes/plans/<NNN>-<slug>.md`. Lane: standard / fast / live / plan-only.

## Retired
- (none yet)
