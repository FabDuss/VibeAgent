# ARCHITECTURE -- <product name>

> The SHAPE of the system and the RATIONALE behind it. Settled rules are enforced from
> `.vibes/INVARIANTS.md` (cite them by `INV-` id here); how to build / run / ship is in
> `.vibes/STACK.md`; how code is written is in `.vibes/CONVENTIONS.md`.
>
> **Last verified: <YYYY-MM-DD>.** If this file disagrees with the deployed configuration
> (manifests, compose files, CI), the deployed configuration wins -- fix this file.

## Constraints
- <organisational / technical constraints: mandated stack, hosting, security, data residency>

## Stack
| Layer | Choice | Version | Why |
|-------|--------|---------|-----|
| Front | | | |
| Back | | | |
| Data | | | |
| Infra / CI | | | |

## Components
<Component map: what each deployable does, what it talks to. A small diagram helps.>

## Data model
<Main entities, which system is the source of truth for each, how our own data references external data.>

## Integrations
<External systems, direction (read / write), auth mechanism, where the verified facts about them live.>

## Deployment
<Environments, how code reaches each one, what is automated and what is human-only.>

## Key decisions
- <decision> -- see INV-<NNN> / plan <NNN>-<slug>
