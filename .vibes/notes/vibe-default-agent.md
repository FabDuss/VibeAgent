# vibe comme agent principal par défaut d'un projet

**Status**: backlog -- raised 2026-09-23 (plan 001-default-agent abandonné avant le GO)

## Problem
Sans réglage, `vibe` ne tourne en thread principal que via `claude --agent vibe` ; depuis une session
normale ou VS Code, il tourne en sous-agent, en mode relais (handbacks). Le plan 001 voulait le rendre
actif par défaut à l'installation ; l'utilisateur l'a jugé plus coûteux qu'utile (« crée plus de problème
qu'autre chose », conflit avec l'existant) : bascule de toutes les sessions de l'équipe, y compris à la
réinstallation ; aucune sortie de vibe dans le cloud ; outils de vibe seulement (ni MCP ni WebSearch) ;
`.claude/settings.json` déjà présents ou ignorés par git dans les projets.

## Direction
Ne rien imposer au niveau de l'équipe. Si le besoin revient, commencer par la voie sans conflit :
un opt-in PERSONNEL documenté (README), `.claude/settings.local.json` = `{ "agent": "vibe" }` dans un
projet (à garder ignoré par git), sans changer les scripts d'installation. Vérifier d'abord que la
conversation native VS Code applique ce réglage (H1 du plan 001, jamais vérifiée).

## Trigger
L'utilisateur redemande vibe par défaut, ou le mode relais cause une vraie erreur (GO paraphrasé,
handback perdu) sur un projet.

## Evidence
- `.vibes/plans/001-default-agent.md` : faits vérifiés F1-F9 (docs + sondes CLI 2.1.280 et PowerShell 5.1 du 2026-09-23), risques R1-R8, décision D10.
- `.vibes/notes/vibe-tools-as-default-agent.md` (obsolete, sous-idée de celle-ci).

## Findings
- 2026-09-23 -- sondes (Claude Code 2.1.280, `claude -p`) : `agent` dans `.claude/settings.json` -> session vibe (y compris headless) ; valeur vide via `.claude/settings.local.json` ou `--settings` -> Claude Code standard ; sous Windows PowerShell 5.1, `--settings '{"agent":""}'` est rejeté (« Invalid JSON »), il faut `'{\"agent\":\"\"}'`. Le cloud ne lit que le fichier commité (docs, non sondé).
