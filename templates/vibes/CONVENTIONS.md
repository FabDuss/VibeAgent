# CONVENTIONS -- how we build here

> The `vibe-codeur` applies these rules, the `vibe-plan-reviewer` and `vibe-code-reviewer`
> check against them, the `vibe-auditor` audits deviations from them. INVARIANTS.md records
> the project's settled decisions; this file records how code is written.
>
> **Part A** is the kit's default engineering doctrine, distilled from real projects. Its core
> (one source of truth, explicit failure, display is not data, tests that can fail, secrets and
> migrations) is also enforced by the agents themselves; the rest (contracts, time, UI floor,
> toggles...) applies only while it is written here. Adapt a rule by EDITING it here (say what
> the project does instead); deleting a core rule does not switch the agents' core checks off.
> **Part B** is for this project's own rules: fill it, keep it short enough that an agent
> actually reads it.

---

## Part A -- Kit defaults (keep, edit or delete per rule)

### A1. One source of truth, reuse by extraction
- A concept (a rule, a predicate, a computation, a constant that defines something) lives in
  ONE place. "Reuse X" when X lives inside another component means: move X to a shared module,
  repoint the original caller (behavior unchanged, its tests still green), THEN use it -- in
  the same WP. Copying X is a second source of truth, even if the copy is identical today.
- Fix a rule at its source, never with a second filter downstream.
- Deliberately keeping a duplication (rule of three) is allowed only with a note carrying an
  explicit extraction trigger ("a 4th consumer, or the first behavior change").
- Two close concepts get two distinct names, and the difference is written where they are
  defined (and in the INVARIANTS Glossary).

### A2. Fail explicitly, model absence
- A fallible operation fails explicitly (Result type, typed error, explicit branch) -- never a
  silent null / empty / NaN / default.
- Absence is a first-class state: `unknown` / `not-evaluated` / an empty-but-valid record, never
  a 404 for "nothing yet", never a default that looks good (no false-green), never a delta
  computed from an absence.
- A missing setting never enables a costly or risky path (safe default = off).
- Tolerating an error is allowed only on discovery / secondary paths where a failure can only
  under-report, never invent data. Each tolerance names the error classes it tolerates, stays in
  the adapter, and is locked by tests (tolerated vs propagated).
- Malformed input at a boundary returns a client error (4xx or equivalent), never a crash / 5xx.
- Error messages never contain a secret, a token or personal data.

### A3. Display is not data
- Display filters and defaults (hide, collapse, limit to a period) live in the view layer's
  derived view, never in the shared data that metrics and aggregates read. A WP that touches
  both adds a test proving metrics are identical with the filter on and off.
- Never hide data silently: a default that hides something shows an explicit indicator.
  A metric's label / tooltip states its definition and scope.
- Sorting is display-only: it never filters or recomputes.

### A4. Contracts between components
- Cross-component features: the PROVIDER side ships first with an explicit contract (additive
  changes only), the CONSUMER mirrors it exactly -- no invented field, no "reuse a DTO with
  empty fields" (prefer a minimal new one).
- A constant needed on both sides has one owner and a documented mirror (with a test that
  fails if they diverge, when feasible).

### A5. Time and determinism
- "Now" is injected; tests pin the clock. Date-only values use timezone-free arithmetic.
- Day-level and month-level helpers stay separate; boundaries (year end, open intervals, a
  window that does not contain M+N) are tested explicitly.

### A6. Tests that can fail
- Unit tests always; E2E whenever a UI or user flow is touched; backend-only work gets unit +
  integration tests. External systems are mocked in tests: no real network call, no secret.
- Every test / guard must be able to fail: fixtures produce non-trivial values (not 0, not
  empty, not "absent because nothing matched"); a "nothing left" guard asserts its corpus is
  non-empty and has a positive control; "unchanged" assertions start from a non-zero baseline;
  assert exact outputs rather than "does not contain"; assert real geometry / real container,
  not just "is visible". Never a lone "is defined".
- For risky logic, do a mutation check: remove the guard / condition, watch the tests fail.
- A test whose premise changed is ADAPTED, never deleted. Global / module state touched by a
  test (language, storage, clock, singletons) is restored in teardown. Parametrize fixture
  factories instead of adding rows to a shared default setup other tests assert on exactly.
- Build fixtures from captured REAL payloads when an external system is involved.

### A7. Docs and comments tell the truth
- A change that makes a doc, docstring or code comment false rewrites it in the same WP
  (grep affirmative claims: "one-to-one", "always", "single", "by construction", "every").
- Code comments never cite a plan number or an INVARIANTS line; cite an `INV-` id if needed,
  or explain the why in plain words.

### A8. UI quality floor (delete if no UI)
- Text contrast meets WCAG AA (4.5:1 body text, 3:1 large text / UI parts), computed from the
  real tokens. No interactive element nested in another (no link inside a button). No
  `aria-hidden` on a focusable element. Correct roles for exclusive choices (radiogroup).
  Keyboard reachable; Escape restores focus.
- Every user-visible string goes through the project's text mechanism (i18n dictionary if any);
  translate at render time, never at initialization.
- A UI change is verified on the real rendered page (screenshot at the target viewport), not
  only by DOM tests.

### A9. Operations
- Secrets / config: never hard-coded, logged, committed or baked into a build artifact; read at
  runtime through the project's config mechanism (one loader / schema).
- Persistent schema changes ship as generated, ordered, forward-only migrations through ONE
  apply path; never rewrite a shipped migration.
- An artifact that ships (container, prod build, CI step, deploy manifest) is exercised the way
  it ships at least once in the WP that changes it (or the plan says when it first will be).
- A new component comes with its deploy / infra wiring in the same change, or the wiring is the
  very next plan (and a note says so). Build a walking skeleton before stacking features.
- Feature whose value depends on uncertain data: ship a thin slice behind a runtime toggle
  (default off), validate it on real data with the user, then build on it.

---

## Part B -- Project rules (fill in)

### Layering & dependency direction
<!-- e.g. api -> core -> infrastructure, dependencies point inward only; core depends on ports, never on adapters. -->
- (describe your layers and which direction dependencies may point)

### Error taxonomy
<!-- e.g. domain errors in core/errors, infra errors mapped at the adapter, HTTP mapping in one filter. -->
- (how failures are represented and surfaced per layer)

### Reads vs writes
<!-- e.g. read-only on the external system of record; writes only to our own annotation tables, keyed by external id. -->
- (state your command/query stance, or "no formal separation")

### Wiring / dependency injection
<!-- e.g. a new port = token + adapter + provider + module registration, same change; a new deployable = its infra manifests, same change. -->
- (how a new component gets registered / injected / exported / deployed)

### Testing specifics
<!-- where tests live, naming, harness, how E2E stubs the backend, what "integration" means here. -->
- (project-specific test rules on top of A6)

### Naming & style
<!-- e.g. files kebab-case; classes PascalCase; no default exports; formatter = prettier. -->
- (conventions a reviewer should enforce)

### Text & i18n
<!-- e.g. UI in French with accents; all UI strings in dict/*.ts; EN glossary in INVARIANTS. Delete if N/A. -->
- (how user-facing text is written and translated)
