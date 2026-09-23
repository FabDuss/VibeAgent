# INVARIANTS -- established decisions (anti-drift anchor)

> This file is the memory that survives across Vibe sessions. It records decisions that
> are SETTLED, so no future plan quietly reinvents or contradicts them. The `vibe` agent
> writes here when the user establishes a durable decision; the `vibe-plan-reviewer` and
> `vibe-auditor` check every plan/audit against it.
>
> Keep entries SHORT and FACTUAL. One decision per bullet. Add the date it was set.
> Start empty on a new project and grow it as decisions are made -- do not invent
> invariants the project has not actually committed to.

## Established decisions
<!-- Example shape (delete these once you have real ones):
- (2026-01-15) The HTTP layer NEVER imports from the persistence layer directly; it goes through the service layer. Reason: keep transport swappable.
- (2026-01-20) `UserId` is a value object, not a raw string, everywhere past the request boundary.
- (2026-01-22) There is exactly ONE source of truth for pricing: `PricingService`. Do not add a second computation path.
-->

- (none yet)

## Do-not list (things we deliberately will NOT do)
<!-- Example:
- Do NOT add a second HTTP client library; use the one already wired.
- Do NOT catch-and-swallow errors at boundaries; surface them as typed failures.
-->

- (none yet)

## Canonical abstractions (the ONE way we do X)
<!-- Example:
- Repositories follow the repo + schema + mapper trio; do not hand-roll persistence in a service.
- All fallible operations return a Result type; no bare null to signal failure.
-->

- (none yet)
