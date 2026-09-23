# CONVENTIONS -- architecture & style rules for this project (OPTIONAL)

> This file is OPTIONAL. It holds the deeper "how we build here" rules that the
> `vibe-codeur` obeys, the `vibe-plan-reviewer` checks plans against, and the
> `vibe-auditor` audits deviations from. If you delete it, the agents fall back to
> the language-agnostic non-negotiables baked into their prompts plus INVARIANTS.md.
>
> Fill it with YOUR project's real rules. The examples below are illustrative defaults
> for a layered/hexagonal TypeScript backend -- replace them with what your repo does,
> or trim to the essentials. Keep it short enough that an agent actually reads it.

## Layering & dependency direction
<!-- Example:
- Layers: domain -> application -> infrastructure -> api. Dependencies point inward only.
- domain has NO framework imports. api never imports an infrastructure implementation directly.
- Cross-module imports use path aliases (@domain/, @application/, ...), never deep relative paths.
-->
- (describe your layers and which direction dependencies may point)

## Error handling
<!-- Example:
- Fallible operations return Result<T, E>; no bare null/undefined to signal failure.
- Error taxonomy is layer-correct: domain errors, application errors, infra errors do not leak across boundaries unmapped.
-->
- (how failures are represented and surfaced)

## Reads vs writes (if you separate them)
<!-- Example: CQRS -- queries are side-effect free and return data; commands return void or Result and never leak read models. -->
- (state your command/query stance, or "no formal separation")

## Wiring / dependency injection
<!-- Example: every new port lists token + adapter + provider + barrel re-export, all in the same change. No orphan token. -->
- (how a new component gets registered / injected / exported)

## Testing
<!-- Example: tests assert real behaviour (no lone toBeDefined); unit tests colocate as *.spec.ts; integration tests under tests/. -->
- (what a good test looks like here, where tests live)

## Naming & style
<!-- Example: files kebab-case; classes PascalCase; no default exports; ASCII only in source. -->
- (the conventions a reviewer should enforce)

## Config & secrets (delete if the project has none)
<!-- Example:
- Config is read through ONE loader/schema (env.schema.ts); no ad-hoc process.env / os.getenv scattered in code.
- Secrets are NEVER committed or baked into a build artifact; they are injected at runtime from <env file / Vault / cloud secret manager>.
-->
- (how config and secrets are sourced, or "N/A")

## Data migrations (delete if the project has no persistent store)
<!-- Example:
- Schema changes ship as generated migrations under <dir>, named with a sortable prefix so history stays chronological; the generated SQL is reviewed before commit (the tool diffs the schema, it does not hand-write the migration).
- Migrations are forward-only; never rewrite one that has already shipped. Apply path: <boot flag like DB_MIGRATE=true / an explicit CLI command> -- exactly one.
-->
- (how schema evolves and how migrations are applied, or "N/A")

## Docs that must track the code (delete if none)
<!-- Example:
- A change to the build/run/deploy/migration workflow updates <README section> in the SAME change.
- The dev-vs-prod run recipe in the README is load-bearing; keep it in sync with docker-compose / CI.
-->
- (which docs are load-bearing and must not drift, or "N/A")
