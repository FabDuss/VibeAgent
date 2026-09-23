# 001 -- vibe, agent par défaut des projets équipés

**Status**: abandoned
**Delivery**: branch `main` ; commits none (abandonné avant tout dispatch : aucun code) ; pushed: no ; PR: none ; deployed: no ; verified: no
**Lane**: standard
**Origin**: user request 2026-09-23 (session VS Code, vibe relayé en sous-agent)
**Scope**: faire de `vibe` l'agent principal par défaut de tout projet où le kit est installé, via un `.claude/settings.json` versionné (`"agent": "vibe"`) que `install.sh` / `install.ps1` créent s'il manque (jamais modifié s'il existe, opt-out par option), avec garde de test, contrôle `.gitignore`, doc, et application au dépôt du kit lui-même.
**Date**: 2026-09-23

## Request (verbatim)
> je vais que l'agent devienne par défaut dans les projets ou il est installé

## Context
Les agents gardent leurs noms une fois installés (`vibe`, `vibe-codeur`, ...). Aujourd'hui l'installation
se contente d'afficher « run: claude --agent vibe » (`install.sh:115`, `install.ps1:119`) : rien ne rend
`vibe` actif par défaut. Dans VS Code, surface principale de l'utilisateur, `vibe` tourne donc en
sous-agent, en mode relais (c'est le cas de cette session même).

## Analysis
### Verified facts
- F1 -- La clé de réglage `agent` « Start every session as a named subagent with its prompt, tools, and model », portée « Any file » ; « To make it the default for every session in a project, set `agent` in `.claude/settings.json` [...] The CLI flag overrides the setting if both are present. » -- source : code.claude.com/docs/en/settings-reference et /sub-agents, lus le 2026-09-23.
- F2 -- Sonde 2026-09-23, Claude Code 2.1.280 (binaire natif de l'extension VS Code, `claude -p --max-turns 1`, Git Bash), dépôt jetable avec le kit installé, question « ton prompt système contient-il "Vibe Coder" ? » :
  `.claude/settings.json` = `{"agent": "vibe"}` -> **YES** (« You are the Vibe Coder -- ... ») ;
  même dépôt + `--settings '{"agent":""}'` -> NO ; même dépôt + `.claude/settings.local.json` = `{ "agent": "" }` -> NO ;
  sans `settings.json` -> NO. Donc : le réglage projet marche en CLI, **y compris en headless `claude -p`**, et une valeur vide rend le Claude Code standard, pour une session ou pour une personne dans un projet.
- F3 -- Précédence : managed > `--settings` > `.claude/settings.local.json` > `.claude/settings.json` > `~/.claude/settings.json`. Une session cloud (un seul dépôt) lit le `.claude/settings.json` **commité**, jamais les réglages utilisateur ni `settings.local.json`. -- source : code.claude.com/docs/en/settings (« Settings in cloud sessions »), 2026-09-23. Non sondé en cloud.
- F4 -- `.claude/settings.local.json` n'est exclu de git automatiquement que si Claude Code le crée lui-même ; créé à la main, il faut l'ignorer soi-même. -- même source.
- F5 -- Projets réels sur ce poste (2026-09-23) : `SuiviTransfo/.gitignore` = `.claude/*` + `!.claude/agents/` -> un `.claude/settings.json` y serait **ignoré** (ni commité ni vu du cloud) ; `SitePerso/.claude/settings.json` existe déjà (hooks, sans `agent`) ; `EvaluationAlenia` et `Feedback` ignorent `.claude/` en entier ; `.gitignore` du kit = `.claude/*` + `!.claude/agents/`. Le motif que le kit recommande lui-même (`install.sh:94`, README étape 4) ignorerait donc le nouveau fichier.
- F6 -- L'extension VS Code 2.1.280 lance le CLI via l'Agent SDK avec `settingSources: ["user","project","local"]`, un prompt système `preset: "claude_code"` + `append`, et ne passe `--agent` que si sa propre option est posée (`extension.js`). Ses réglages VS Code (`package.json`) n'ont aucune option d'agent ; il existe `claudeCode.useTerminal` (Claude dans le terminal, donc le CLI de F2 -- effet non sondé). Que la conversation native applique la clé `agent` n'est PAS établi -> H1.
- F7 -- Résolution des agents par `name` : `.claude/agents/` du projet l'emporte sur `~/.claude/agents/` (docs /sub-agents) ; l'utilisateur n'a pas de `~/.claude/agents/` (vérifié le 2026-09-23).
- F8 -- Sonde 2026-09-23 sous Windows PowerShell 5.1.26100 : `claude --settings '{"agent":""}'` -> « Error: Invalid JSON provided to --settings » (PS 5.1 retire les guillemets internes) ; `claude --settings '{\"agent\":\"\"}'` -> NO (Claude Code standard) ; témoin sans `--settings` -> YES. La commande de sortie dépend donc du shell.
- F9 -- La liste `tools:` de vibe est fermée (`.claude/agents/vibe.md:4` : Read, Write, Edit, Grep, Glob, Bash, WebFetch, TodoWrite, AskUserQuestion, `Agent(...)`) et `model: opus` : une session par défaut n'a ni MCP, ni WebSearch, ni skills.

### Existing code
- `install.sh` : `copy_if_missing` (L44-53), boucle de contrôle `.gitignore` (L92-98), aide `sed -n '2,10p'` (L22), étapes suivantes (L110-115).
- `install.ps1` : `Copy-IfMissing` (L42-50), boucle de contrôle (L94-101), étapes suivantes (L114-119).
- `tests/check-kit.sh` section 6 (L68-114) : `assert_install`, `tamper`, `assert_rerun`, pour chaque script ; la sortie des scripts part aujourd'hui dans `>/dev/null` (L93, L105).
- Réutilise `copy_if_missing` / `Copy-IfMissing` pour copier un modèle `templates/claude/settings.json` : aucun JSON écrit par les scripts, octets identiques entre les deux scripts par construction (pas de piège BOM / CRLF de PowerShell 5.1), même mécanisme que `templates/vibes/` (INV-002).
- Aucun mécanisme existant ne modifie un fichier projet (lecture des deux scripts) : le kit n'a pas d'outil JSON (zéro dépendance, pas de `jq`).
- Mentions de `claude --agent vibe` : `README.md:46,92,153`, `CLAUDE.md:15`, `templates/CLAUDE.md:10`, `install.sh:115`, `install.ps1:119`, `.claude/agents/vibe.md:3,18` (liste confirmée par la revue).

### Hypotheses
- H1 -- La conversation native de l'extension VS Code applique la clé `agent` du projet. -- vérifié par : l'utilisateur, AVANT le GO si possible (dossier sonde, voir handback), sinon à la Preview sur le dépôt du kit après WP02. -- si faux : dans VS Code, vibe reste un sous-agent en mode relais (bloc CLAUDE.md) ; repli possible `claudeCode.useTerminal` (F6, à sonder) ; CLI et cloud gardent le défaut ; la doc (WP03) ne cite que les surfaces vérifiées.

## Scope
IN : modèle `templates/claude/settings.json` ; les deux scripts (création si absent, état affiché, option d'opt-out, contrôle `.gitignore`) ; garde `check-kit` ; application au dépôt du kit ; README, CLAUDE.md (kit + modèle), prompt de `vibe`, CHANGELOG 2.2.0 ; INVARIANTS.
OUT :
- Installation globale qui poserait `agent` dans `~/.claude/settings.json` -> not tracked : rendrait vibe par défaut dans TOUS les dépôts du poste, y compris sans `.vibes/` (refus de conception, D5).
- Modification automatique d'un `.claude/settings.json` existant -> not tracked : INV-003 (sauf si Q2 en décide autrement).
- Élargir les outils de vibe (MCP, WebSearch) quand il est l'agent par défaut -> `.vibes/notes/vibe-tools-as-default-agent.md`.
- Mise à jour des projets déjà équipés (SuiviTransfo, ...) -> ops, pas un WP du kit : relancer l'installation sur chacun ; l'avertissement `.gitignore` dira quoi corriger (SuiviTransfo, F5).
- Vérification JetBrains / desktop -> not tracked : surfaces non utilisées.

## Decisions
- D1 Mécanisme : clé `agent` dans le `.claude/settings.json` du projet (F1, F2). Rejeté : alias / script d'enveloppe `claude --agent vibe` (par poste, sans effet dans l'IDE ni le cloud) ; `~/.claude/settings.json` (tous les dépôts) ; `.claude/settings.local.json` (personnel, jamais dans le cloud : voir Q1). [technique, sous réserve de Q1]
- D2 Le contenu vit dans `templates/claude/settings.json` = exactement `{` / `  "agent": "vibe"` / `}` (LF, sans BOM), copié par `copy_if_missing` / `Copy-IfMissing`. Rejeté : JSON écrit par `echo` / `Set-Content` (deux sources, piège BOM en PS 5.1). [technique]
- D3 Un `.claude/settings.json` existant n'est jamais modifié. L'installation affiche l'état du fichier dès qu'il existe (y compris sous opt-out) : `vibe` / autre valeur (dont `""`) / pas de clé `agent` + la ligne exacte à ajouter. L'étape suivante 5 découle de cet état. [technique, sous réserve de Q2]
- D4 Opt-out à l'installation : `--no-default-agent` / `-NoDefaultAgent` = ne pas créer le fichier ; s'il n'existe pas, afficher `skipped`. Pourquoi : le réglage change les sessions de toute l'équipe ; un fichier conservé n'est jamais recréé, mais la première installation doit pouvoir s'en passer proprement. [technique]
- D5 L'installation globale ne pose jamais `agent`. [technique]
- D6 Contrôle `.gitignore` de `.claude/settings.json` seulement quand il porte `"agent": "vibe"`, avec un avertissement dédié : dés-ignorer le fichier, une fois vérifié qu'il ne contient ni secret ni réglage personnel (ceux-là vont dans `settings.local.json`). Le conseil existant pour les agents ne change pas. [technique, suite revue]
- D7 Prompt de `vibe` : agent par défaut, il reçoit toutes les sessions (questions d'un coéquipier, `claude -p`) -> une question simple (rien à changer) reçoit une réponse directe, en lisant seulement ce qu'il lui faut : ni récapitulatif de Phase 0 (fetch, plans ouverts), ni plan, ni porte « remplir STACK d'abord » ; la Phase 0 complète tourne dès que la demande implique du travail (changement, plan, reprise). Ce qui change le dépôt passe par une voie. Quand l'utilisateur a besoin d'une session standard, il donne la sortie propre à la surface (F2, F8) : pour soi dans ce projet `.claude/settings.local.json` = `{ "agent": "" }`, en vérifiant qu'il est ignoré par git (`git check-ignore .claude/settings.local.json`, F4) ; pour une session CLI `claude --settings '{"agent":""}'` (bash / zsh) ou `'{\"agent\":\"\"}'` (Windows PowerShell 5.1 ; pwsh 7 non sondé) ; dans le cloud, aucune sortie hors modification du fichier commité. [change le comportement visible de vibe : soumis à l'utilisateur, Q4]
- D8 Version 2.2.0 (comportement visible de l'installation). WP01 à WP03 partent ensemble : aucun push entre eux (le push n'a lieu que sur demande), le CHANGELOG et le README arrivent donc avec le changement. [technique, suite revue]
- D9 Après l'APPROVE de WP01, vibe met à jour le BASELINE de `.vibes/STACK.md` (nouveau nombre de checks). [technique, suite revue]
- D10 Plan abandonné avant le GO : le coût (sessions de toute l'équipe basculées, y compris à la réinstallation ; pas de sortie dans le cloud ; outils de vibe seulement ; fichiers projet existants) l'emporte sur le gain. Idée parquée dans `.vibes/notes/vibe-default-agent.md` avec les faits vérifiés. [user 2026-09-23: "ok j'ai l'impression que mettre l'agent par défaut crée plus de problème qu'autre chose, et que ca risque de rentrer en conflit avec ce qui est déjà en place"]
- INVARIANT à écrire quand WP01 est APPROVE :
  - INV-003 amendé : « ajoutent les fichiers projet (`.vibes/*`, `.claude/settings.json`, VISION, ARCHITECTURE, CLAUDE.md) SEULEMENT s'ils manquent -- jamais écrasés ni modifiés ». Guard : `tests/check-kit.sh` section 6.
  - INV-007 (A) « Agent par défaut » : l'installation projet fait de `vibe` l'agent principal par défaut via un `.claude/settings.json` versionné (`"agent": "vibe"`), créé seulement s'il manque, sauf `--no-default-agent` / `-NoDefaultAgent` ; l'installation globale ne le pose jamais. Guard : `tests/check-kit.sh` section 6.
  - INV-008 (D) fait externe : `agent` dans `.claude/settings.json` démarre chaque session CLI (y compris `-p`) sur cet agent ; une valeur vide (`--settings`, `settings.local.json`) rend le Claude Code standard. Verified: 2026-09-23 (F2, F8). Le cloud (ne lit que le fichier commité, F3) reste hors de l'entrée tant qu'une session cloud ne l'a pas confirmé ; il sera ajouté par amendement avec sa date.

### To ratify (STOP before dispatch)
- Q1 Où poser le défaut ? **recommandé : `.claude/settings.json` commité.** Effet : toutes les sessions du projet démarrent sur vibe, pour toute l'équipe : CLI, `claude -p` et automatisations (F2), cloud (F3), VS Code si H1. Coût (F9, F3) : ces sessions n'ont ni MCP, ni WebSearch, ni skills, et tournent sur opus ; sortie possible en local (`settings.local.json`, `--settings`), **aucune dans le cloud** sauf modifier le fichier commité. Pourquoi quand même : c'est ce que dit la demande (« par défaut dans les projets »), et les agents sont déjà versionnés pour que le cloud ait vibe (leçon 44). Alternative : `.claude/settings.local.json` (toi seul, ce poste seul, jamais dans le cloud ; l'installation devrait vérifier qu'il est ignoré). -- bloque WP01, WP02.
- Q2 Projet qui a déjà un `.claude/settings.json` (ex. SitePerso) : **recommandé : ne pas le toucher**, afficher la ligne exacte à ajouter (INV-003 : jamais modifier un fichier projet). Alternative : insérer automatiquement `"agent": "vibe",` après la première `{` (cas `{}` à part), ce qui amende INV-003. -- bloque WP01.
- Q3 Appliquer aussi au dépôt du kit (vibe par défaut ici, `.gitignore` corrigé) ? **recommandé : oui** (le kit se développe avec ses agents, et c'est le test le plus simple de H1 dans VS Code). -- bloque WP02.
- Q4 D7 (vibe répond directement aux questions simples, sans plan ni Phase 0 ni remplissage préalable de STACK, et indique comment sortir de vibe) : **recommandé : oui.** -- bloque WP03.

## Risks
- R1 Un coéquipier ne veut pas de vibe à chaque session -> sortie personnelle vérifiée en local (F2, F8), documentée (WP03) ; option d'installation (D4) ; **pas de sortie dans le cloud** (F3), dit dans Q1 et la doc.
- R2 Un `.gitignore` à la SuiviTransfo garde le fichier hors de git : pas de défaut dans le cloud ni chez les autres -> avertissement dédié de l'installation (D6), testé (WP01 (c)).
- R3 Outils restreints de vibe (F9) : devenu défaut, il gêne les tâches hors de son rôle -> D7 (il dit comment sortir) + doc ; suite éventuelle : `.vibes/notes/vibe-tools-as-default-agent.md`.
- R4 H1 faux -> VS Code inchangé ; doc honnête (WP03), mode relais intact, repli `claudeCode.useTerminal` à sonder.
- R5 Détection textuelle de `"agent"` (pas de parseur JSON) : une clé `agent` imbriquée serait lue comme « autre valeur » -> message neutre, sans effet sur le fichier ; accepté.
- R6 Un fichier supprimé exprès est recréé à la réinstallation -> option D4 ; documenté (WP03).
- R7 Les automatisations (`claude -p` dans un script, CI, GitHub Action Claude) d'un projet équipé tournent aussi sous vibe (F2 pour `-p` ; CI non sondée) -> ligne README (WP03) : y passer `--agent <autre>` ou `--settings`.
- R8 Écrire `.claude/settings.json` depuis un sous-agent (Codeur, WP02) peut déclencher une demande de permission -> si refusée : blocage remonté, jamais un skip.

## Addresses Notes
None (`.vibes/notes/` ne contenait aucune note ; `vibe-tools-as-default-agent` naît de ce plan, en backlog).

## Work Packages

### WP01: installation -- vibe par défaut via `.claude/settings.json`, avec garde
**Tasks**:
1. Create `templates/claude/settings.json` containing exactly three lines `{`, `  "agent": "vibe"`, `}` (LF, final newline, no BOM).
2. In `install.sh`: add `--no-default-agent`. In the target part: unless it is set, `copy_if_missing "$KIT/templates/claude/settings.json" "$TARGET/.claude/settings.json"`. Then, if `.claude/settings.json` exists, print ONE state line: `  default agent : vibe (.claude/settings.json)` when it matches `"agent"[[:space:]]*:[[:space:]]*"vibe"` ; else `  default agent : not vibe -- .claude/settings.json sets "agent" to another value (left as is)` when it matches `"agent"[[:space:]]*:` ; else `  hint          : add "agent": "vibe" to .claude/settings.json to make vibe the default agent`. If it does not exist (opt-out): `  skipped       : .claude/settings.json (--no-default-agent)`. In the checks, ONLY when the state is `vibe` and the target is a git repo: if `git check-ignore -q .claude/settings.json`, print `  WARNING       : .claude/settings.json is git-ignored: teammates and cloud sessions will not start as vibe. Add '!.claude/settings.json' after '.claude/*' in .gitignore, once the file holds no secret or personal setting (those go to .claude/settings.local.json).` ; else `  ok            : .claude/settings.json is not ignored`. The existing agents / STACK check and its advice stay unchanged. Next step 5 follows the state: `vibe` -> `  5. Commit .claude/agents, .claude/settings.json and .vibes; 'claude' then starts as vibe (project default).` ; otherwise the current line. Update the header comment, the usage line and the `-h` line range.
3. In `install.ps1`: the same with `[switch]$NoDefaultAgent`, the SAME output strings (only the flag spelling in the `skipped` line differs: `(-NoDefaultAgent)`), matching with `Select-String -CaseSensitive -Quiet` and the patterns `'"agent"\s*:\s*"vibe"'` then `'"agent"\s*:'`. Update `.SYNOPSIS` / `.DESCRIPTION` / `.EXAMPLE` and the usage line.
4. In `tests/check-kit.sh` section 6, capture each install's output, and for BOTH scripts assert: (a) fresh repo -> `.claude/settings.json` is byte-identical to `templates/claude/settings.json`, output has `default agent : vibe (.claude/settings.json)`, `ok            : .claude/settings.json is not ignored`, the step 5 line with `'claude' then starts as vibe`, and NO `WARNING` naming `.claude/settings.json` ; (b) the re-run after `tamper` (which now also appends `PROJECT EDIT` to `.claude/settings.json`) keeps it ; then, chained IN ONE repo whose `.gitignore` is `.claude/*` + `!.claude/agents/` (so that the negative assertion of (d) can fail): (c) no settings file -> file created, output has a `WARNING` naming `.claude/settings.json` and no `WARNING` naming `.claude/agents/vibe.md` ; (d) file replaced by `{ "hooks": {} }` -> byte-identical after install, output has the `hint` line, the step 5 line with `claude --agent vibe`, and no line with `.claude/settings.json is git-ignored` ; (e) file replaced by `{"agent": "other"}`, install with the opt-out flag -> byte-identical, output has the `not vibe` line and no `skipped` line ; (f) file deleted, install with the opt-out flag -> no `.claude/settings.json`, output has the `skipped` line. PowerShell's captured output ends lines with CRLF: match substrings (no `grep -x`, no `$` anchor), or negative assertions pass vacuously.
5. Update the header comment of `tests/check-kit.sh` (item 6) to cover the settings file, its states and the opt-out, and add `templates/claude/settings.json` to the section 5 byte scan (locks "no BOM" of D2).
**Wiring**: scripts copy from `$KIT/templates/claude/` ; `.gitattributes` (`* text=auto eol=lf`) keeps the template LF ; `templates/claude/` is not matched by the kit's root-anchored `.claude/*` ignore rule.
**Tests & blast radius**:
- New: (a)-(f) above, x2 scripts (PowerShell is present on this machine).
- Breaks (a) typecheck: n/a (no typechecker).
- Breaks (b) runtime: none expected -- no existing assertion reads `.claude/settings.json` or the output; the check count grows from 134 (BASELINE).
- Callers (c): `install.sh -h` prints the header through `sed -n '2,10p'` -> range follows the new header.
**Docs made false**: `install.sh:2-10`, `install.ps1:1-16`, `tests/check-kit.sh:6-9` (this WP) ; README / CLAUDE.md / templates/CLAUDE.md / vibe.md -> WP03 (same delivery, D8).
**DoD**:
- [unit] `bash tests/check-kit.sh` green with (a)-(f) for install.sh AND install.ps1, count > 134.
- [unit] mutation check reported by the Codeur (then reverted): removing the settings copy from one script fails (a) ; forcing an overwrite fails (b)/(d) ; warning whatever `git check-ignore` says fails (a) ; changing one state string in ONE script fails (a), (d), (e) or (f) for that script.
- [live] LIVE_CHECK: install into two throwaway repos, one per script -> `.claude/settings.json` byte-identical to the template in both ; a throwaway repo with SuiviTransfo's `.gitignore` pattern -> the settings WARNING.
- [checks] scripts ASCII (check-kit section 5) ; PowerShell 5.1 rules of CONVENTIONS (no `&&`, no ternary, no `??`).
**Files**: `templates/claude/settings.json` (CREATE), `install.sh` (MODIFY), `install.ps1` (MODIFY), `tests/check-kit.sh` (MODIFY).

### WP02: le dépôt du kit démarre lui aussi sur vibe
**Tasks**:
1. In `.gitignore`, add `!.claude/settings.json` right after `!.claude/agents/`, and reword the comment above to say the agents and the shared settings are versioned.
2. Create `.claude/settings.json` byte-identical to `templates/claude/settings.json`.
**Wiring**: None.
**Tests & blast radius**:
- New: none (config).
- Breaks: none -- check-kit section 1 only globs `.claude/agents/*.md`.
**Docs made false**: `CLAUDE.md:15` -> WP03.
**DoD**:
- [unit] `git check-ignore -q .claude/settings.json` exits 1 ; `git check-ignore -q .claude/settings.local.json` exits 0 ; `cmp templates/claude/settings.json .claude/settings.json` exits 0.
- [live] headless probe run by vibe at review in the kit repo (as F2) -> YES ; VS Code (H1) -> checked by the user (before the GO or at Preview).
- [checks] `bash tests/check-kit.sh` green.
**Files**: `.gitignore` (MODIFY), `.claude/settings.json` (CREATE).

### WP03: doc, prompt de vibe, CHANGELOG 2.2.0
**Tasks**:
1. `README.md` (French): « Démarrer » -- when `.claude/settings.json` sets `"agent": "vibe"` (the install does it unless opted out or the file already existed), `claude` (incl. `claude -p`) starts as `vibe` (verified) and cloud sessions too (per the docs, not probed) ; VS Code as per H1's status at dispatch time (verified -> say so ; else « même réglage, effet non vérifié ; sinon le mode relais s'applique ») ; `claude --agent vibe` still works ; cost: such sessions have vibe's tools only (no MCP, no WebSearch) ; leaving vibe per surface (D7, both shell forms, with the `git check-ignore .claude/settings.local.json` check) ; automation (`claude -p`, CI): pass `--agent <other>` or `--settings` (R7) ; the relay paragraph now says it applies when vibe is not the main thread. « Installation » -- bullet for `.claude/settings.json` (created if missing, never modified, state printed, `-NoDefaultAgent` / `--no-default-agent`, the settings WARNING) ; rewrite L72 (« relance simplement le script : seuls les agents sont remplacés ») -- a re-run also creates `.claude/settings.json` when missing, which switches the whole team's default, unless the opt-out flag is passed. « Faire évoluer le kit » L161 -- check-kit also checks the settings file and the install output states. Checklist step 4 (add `!.claude/settings.json`, only for a file with no secret / personal setting) and step 8 (commit `.claude/settings.json`, then `claude`). « Qui porte quoi » -- row `.claude/settings.json`. « Portée » -- the global install never sets the default agent, and why. « Contenu du dépôt » -- `templates/claude/settings.json` and the kit's own `.claude/settings.json`. « Faire évoluer le kit » -- `claude` is enough here.
2. `templates/CLAUDE.md` and `CLAUDE.md` (English): replace the « Best: run the conductor as the main thread -- `claude --agent vibe`. » line with a CONDITIONAL sentence: when `.claude/settings.json` sets `"agent": "vibe"` (the kit's install does it unless opted out), `claude` [and VS Code per H1] and cloud sessions start as vibe ; otherwise run `claude --agent vibe` ; opt out for yourself with `.claude/settings.local.json` = `{ "agent": "" }` (check it is git-ignored: `git check-ignore .claude/settings.local.json`), for one session with `claude --settings '{"agent":""}'` (Windows PowerShell 5.1: `'{\"agent\":\"\"}'`). Keep the relay rules, introduced as applying whenever vibe is NOT the main thread.
3. `.claude/agents/vibe.md`: in `<execution_context>`, replace « (recommended: `claude --agent vibe`) » by « (the project default when `.claude/settings.json` sets `"agent": "vibe"`, as the kit's install does; otherwise `claude --agent vibe`) » and add, in the MAIN THREAD paragraph, the D7 rule in two sentences at most. In the frontmatter `description`, replace « (`claude --agent vibe`) » by « (the project's default agent, or `claude --agent vibe`) » -- description stays one quoted line.
4. `CHANGELOG.md`: entry `## 2.2.0 -- 2026-09-23` -- Nouveau (vibe agent par défaut via `.claude/settings.json`, option d'opt-out, état affiché, avertissement `.gitignore` dédié), Changé (prompt de vibe D7), « Projets déjà équipés » (relancer l'installation ; corriger le `.gitignore` si averti ; `settings.json` existant : ajouter la ligne indiquée), « À savoir » (outils de vibe seulement ; pas de sortie dans le cloud).
**Wiring**: None.
**Tests & blast radius**:
- Breaks: check-kit section 1 (vibe `description` must stay a one-line quoted string) and section 3 (no new uppercase backtick token in agents).
**Docs made false**: covered by the tasks (all mentions listed under Existing code).
**DoD**:
- [checks] `bash tests/check-kit.sh` green.
- [checks] `grep -rn "claude --agent vibe" README.md CLAUDE.md templates/CLAUDE.md .claude/agents install.sh install.ps1` -> every hit presents it as the explicit alternative or the not-default path ; none says it is the only way (reviewed by vibe).
- [checks] each surface named in the docs is tagged with its truth: CLI verified, cloud per docs, VS Code per H1 ; every `settings.local.json` opt-out comes with the git-ignore check (reviewed by vibe).
- [live] NOT live-verified: the real proof of the prompt change is the first session where vibe is the default (STACK LIVE_CHECK) -- degradation: vibe opens a plan, runs Phase 0 or demands a filled STACK before answering a plain question ; cloud: first cloud session after the push.
- [render] NOT render-verified (no SCREENSHOT tool) -- the user reads the README at Preview.
**Files**: `README.md`, `CHANGELOG.md`, `CLAUDE.md`, `templates/CLAUDE.md`, `.claude/agents/vibe.md` (all MODIFY).

## Deferred
- Mise à jour des projets équipés (SuiviTransfo, ...) -> not tracked : ops par projet, déclenchées par l'avertissement de l'installation.
- Outils de vibe comme agent par défaut -> `.vibes/notes/vibe-tools-as-default-agent.md`.

## Review Log
| # | Date | Phase | Actor | Verdict | Evidence / key findings |
|---|------|-------|-------|---------|-------------------------|
| 1 | 2026-09-23 | Plan | vibe | written | faits F1-F7 (docs + sonde CLI 2.1.280), H1 ouverte ; Q1-Q3 à ratifier |
| 2 | 2026-09-23 | Plan | vibe-plan-reviewer | REVISE (MEDIUM) | 1 BLOCKER : pas de sortie de vibe dans le cloud, outils perdus, non dits dans Q1/R1/D7. 8 WARN : H1 à vérifier avant le GO ; 3 états de sortie faux (étape 5, opt-out + fichier existant, `"agent": ""`) ; 2 lignes d'état non testées ; conseil `.gitignore` vs secrets ; headless / CI ; échappatoire dépendante du shell ; templates/CLAUDE.md inconditionnel ; CHANGELOG un WP en retard. INFO : cloud non sondé, BASELINE, INV-007 en A, permission d'écriture de settings.json |
| 3 | 2026-09-23 | Plan fixes | vibe | applied | sonde PS 5.1 (F8 : forme `'{"agent":""}'` invalide, forme échappée OK) ; F9 (outils) ; Q1 réécrite avec son coût ; Q4 (D7) soumise ; H1 à vérifier avant le GO ; D3/D4/D6 revus (état affiché même sous opt-out, `""` = « autre valeur », étape 5 selon l'état, avertissement dédié limité au fichier qui porte vibe, mention secrets) ; tests (a)-(f) couvrent les 4 lignes d'état ; templates/CLAUDE.md conditionnel ; D8 livraison groupée ; D9 BASELINE ; INV-007 en A ; R7 automatisation ; R8 permission ; note `vibe-tools-as-default-agent` |
| 4 | 2026-09-23 | Plan (round 2) | vibe-plan-reviewer | APPROVE (MEDIUM) | les 9 points du round 1 résolus ; 6 WARN : W1 (a) sans contrôle négatif du WARNING, W2 (d) creux hors dépôt ignoré, W3 INV-008 déclarait le cloud vérifié, W4 opt-out `settings.local.json` sans contrôle d'ignore, W5 Phase 0 non traitée par D7, W6 README L72 / L161 ; INFO : mutation (f), CRLF de la sortie PS, D2 sans garde, pwsh 7, niveaux DoD WP03 |
| 5 | 2026-09-23 | Plan fixes | vibe | applied | W1 (a) exige la ligne `ok` et aucun WARNING ; W2 (c)-(f) enchaînés dans le dépôt ignoré ; W3 INV-008 limité au CLI vérifié ; W4 contrôle `git check-ignore` partout où l'opt-out local est cité ; W5 D7/Q4 : question simple sans Phase 0 ni porte STACK ; W6 README L72 et L161 dans WP03 ; INFO : mutation « warn always » et (f), piège CRLF, template dans le scan d'octets, pwsh 7 non sondé, DoD WP03 en `[checks]`. Statut plan-reviewed |
| 6 | 2026-09-23 | Abandon | user | "ok j'ai l'impression que mettre l'agent par défaut crée plus de problème qu'autre chose, et que ca risque de rentrer en conflit avec ce qui est déjà en place" | aucune réponse à Q1-Q4, aucun GO ; vibe d'accord (D10) ; statut abandoned ; idée -> note `vibe-default-agent` (backlog) ; note `vibe-tools-as-default-agent` -> obsolete ; aucun INVARIANT n'avait été écrit (brouillons seulement) |

## Delivered (DoD observed)
Rien : plan abandonné avant le GO (D10). Seuls restent les faits vérifiés F1-F9, repris par `.vibes/notes/vibe-default-agent.md`.
