# Outils de vibe quand il est l'agent par défaut

**Status**: obsolete -- plan 001-default-agent abandonné : vibe ne devient pas l'agent par défaut ; reprise éventuelle dans `vibe-default-agent.md` (2026-09-23)

## Problem
Quand `vibe` est l'agent principal par défaut d'un projet (plan 001), TOUTES les sessions du projet
(CLI, cloud, `claude -p`, VS Code si l'extension applique le réglage) tournent avec sa liste d'outils
fermée (`tools:` de `.claude/agents/vibe.md`) : ni serveurs MCP, ni WebSearch, ni skills. Une tâche hors
de son rôle oblige à sortir de vibe, ce qui est impossible dans une session cloud (seul le
`.claude/settings.json` commité y est lu).

## Direction
Mesurer d'abord le manque réel à l'usage. Si besoin : ajouter à `tools:` les outils sans risque pour la
séparation des pouvoirs (WebSearch en priorité), en gardant l'allowlist `Agent(...)`. Ne jamais retirer
`tools:` (vibe pourrait alors dispatcher n'importe quel agent).

## Trigger
La première fois que l'utilisateur doit sortir de vibe (ou ne peut pas, dans le cloud) pour un outil
absent de sa liste.

## Evidence
- `.claude/agents/vibe.md:4` (liste `tools:`)
- `.vibes/plans/001-default-agent.md` (R3, Q1)
