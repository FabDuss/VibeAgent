# INVARIANTS -- established decisions (anti-drift anchor)

> The memory that survives across sessions, branches and people. It records decisions that are
> SETTLED so no future plan quietly reinvents or contradicts them. The `vibe` agent writes here
> (and only when the user established the decision, or a plan approved by the user did); the
> `vibe-plan-reviewer`, `vibe-code-reviewer` and `vibe-auditor` check work against it.
>
> Rules for this file:
> - **Cite by ID** (`INV-007`), everywhere: plans, reviews, audits, code comments. NEVER by line
>   number or "section NN" -- one inserted line silently re-points every such reference.
>   IDs are never reused, never renumbered.
> - **One entry = one rule of 3 lines or less**, plus the fields below. The story (why, live
>   counts, debates) lives in the plan that decided it, linked in `Source`.
> - **Amend IN PLACE**: rewrite the Rule, add one `Amended:` line. Never append paragraphs.
>   A superseded entry moves to `## Retired` with a pointer to its successor.
> - **No hypotheses**: an unvalidated idea is a `.vibes/notes/` item, not an invariant.
>   External-system facts carry `Verified: <date> <how>` and are re-probed before reuse.
> - **Guard**: a single-source-of-truth or cross-cutting rule names the automated check that
>   enforces it (test, lint rule, grep in CI), or `none` -- `none` is a debt the auditor reports.
> - **Budget ~12 KB.** Above that, split by category into `.vibes/invariants/<category>.md`
>   and keep only the Index here.
> - Start EMPTY on a new project. Do not invent invariants the project has not committed to.

## Index
| ID | Title | Category | Guard |
|----|-------|----------|-------|
<!-- | INV-001 | Front calls only the BFF | A | `api-boundary.spec.ts` |   <- example row, replace -->


## A. Architecture & boundaries
<!-- Entry shape (example -- write real entries OUTSIDE this comment):
### INV-001 -- Front calls only the BFF
Rule: the browser never calls an external system directly; every external call goes through the api.
Where: `client/src/app/core/api.service.ts`, `api/src/infrastructure/adapters/`
Guard: `api-boundary.spec.ts` (fails if the client references an external host)
Source: 2026-01-15, user (plan 001-bff-skeleton)
Amended: 2026-02-03, plan 014-sso -- the auth callback is the one exception
-->

## B. Single sources of truth (the ONE way we do X)
<!-- One entry per concept computed / stored / decided in exactly one place.
Say where it lives, who consumes it, and what a second implementation would look like
("no page recomputes X; they read the served DTO"). -->

## C. Product & domain rules
<!-- Business rules the user settled (scopes, thresholds, definitions).
Two meanings of one word? Put both in the Glossary and name them differently in code. -->

## D. External-system facts
<!-- Facts about an API / data source that code relies on. Each carries:
Verified: <YYYY-MM-DD> <probe: script / request / dictionary endpoint>
A fact never probed is not an invariant. Re-probe before a new decision relies on it. -->

## E. Do-not list (things we deliberately will NOT do)

## F. Do-not-fix (intentional oddities)
<!-- Things that LOOK wrong and must not be "corrected", each with the test that locks it.
Example: "Label X keeps its legacy wording -- it is the identity key of Y. Lock: `x.spec.ts`". -->

## Glossary
<!-- Overloaded or translated terms: one line each. Applies to new AND reused text.
Example: "bench (population)" = load < 20 % today ; "bench (row tag)" = row with no assignment. -->

## Retired
<!-- - INV-004 -- superseded by INV-019 (2026-03-02, plan 027-new-scope) -->
