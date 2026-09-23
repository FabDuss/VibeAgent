# Changelog

## 2.0.0 -- 2026-09-23

Refonte à partir des leçons de SuiviTransfo (voir [docs/LESSONS-TRANSFO.md](docs/LESSONS-TRANSFO.md)).

### Nouveau
- **`vibe-code-reviewer`** : agent de revue fraîche en lecture seule, avec un Bash qui ne modifie rien. La v1 prescrivait une
  « revue par sous-agent frais » que `vibe` ne pouvait pas lancer (sa liste `Agent(...)` l'interdisait).
- **Mode relais** de `vibe` quand il tourne en sous-agent : il s'arrête à chaque porte avec un `HANDBACK`, et seul un
  GO cité mot pour mot compte. Un bloc `CLAUDE.md` indique à la session principale comment relayer.
- **Voies** fast / live / plan only, à côté de la voie standard. Elles collent à la façon réelle de travailler
  (demandes directes, itération en direct sur l'appli).
- **Phases Preview, Ship et Close** : aperçu local avant toute PR ; push, PR, vérification de la CI, release dans
  l'ordre et jamais la prod, uniquement sur demande ; clôture de session (branches, serveurs, worktrees).
- **Mode CHANGE de l'auditeur** (audit avant merge d'une branche) : axe A0 « conformité au plan et intégrité de
  la livraison », balayage de tout le repo, provenance des checks, verdicts MERGE-READY / AFTER-FIXES / DO-NOT-MERGE,
  section **Fix Handoff**.
- **Scripts `install.ps1` / `install.sh`** : installation et mise à jour sans jamais écraser les fichiers projet.
- **Templates optionnels** VISION, ARCHITECTURE, CLAUDE.md.
- **Worktrees par plan** sous `.claude/worktrees/`, avec décalage des ports, quand plusieurs sessions partagent un clone ;
  chaque dispatch porte la racine absolue du repo.
- **Ports séparés** : ceux de l'utilisateur (jamais touchés), des tests et de l'aperçu. `STACK_STATUS: template`
  empêche d'exécuter des valeurs d'exemple.

### Changé
- **STACK** : fichiers de règles et leur précédence, langues, commandes **par composant** (lint, format, typecheck,
  test, build, E2E, migrate), parité CI, baseline, politique de tests, serveurs, ports et vérification live,
  identité git, branches, conventions, garde-fous (chemins protégés, dépendances), release, sessions cloud.
- **INVARIANTS** : identifiants stables `INV-NNN` (plus jamais de renvoi par numéro de ligne), entrées de 3 lignes,
  champs Where / Guard / Source / Amended, sections faits externes (avec `Verified:`), do-not-fix, glossaire,
  retired, budget ~12 Ko.
- **CONVENTIONS** : partie A = doctrine d'ingénierie du kit (source de vérité unique par extraction, absence
  modélisée, affichage distinct des données, contrats, temps déterministe, tests qui peuvent échouer, docs
  vraies, plancher UI/a11y, opérations) ; partie B = règles du projet.
- **Plan** : demande mot pour mot, faits vérifiés et hypothèses, portée IN/OUT, décisions D# et questions à
  ratifier, risques, blast radius des tests en 3 catégories, docs rendues fausses, DoD étiquetée par niveau de
  vérification (unit / build / e2e / live / render), dispositions d'audit, journal de revue avec preuves,
  section « Livré ». Ligne `Delivery` (branche, commits, push, PR, déploiement).
- **Porte de dispatch** : un GO au niveau du plan couvre les WPs nommés, exécutés en séquence avec revue ; il
  s'arrête sur blocker, déviation, WP ajouté. Chaque GO est consigné mot pour mot.
- **Codeur** : parité CI par composant comparée à la baseline, hygiène des tests (pas de pipe vers `tail`,
  suites séquentielles, protocole flaky), E2E sur un serveur frais et des ports isolés, environnement de
  l'utilisateur jamais touché, vérification d'identité git, résumé enrichi (niveau de vérification atteint,
  mutation check, déviations, environnement), vérification de la branche et du HEAD attendu. REVISE : toujours
  un nouveau commit, jamais d'amend (HEAD peut être un commit docs de `vibe`).
- **Plan reviewer** : 8 contrôles (DRIFT, LOGIC, DATA, IMPACT, BOUNDARIES, TESTABILITY, OPERATIONS, PROCESS),
  questions produit séparées des constats techniques.
- `.vibes/` est versionné et commité par `vibe` dans des commits docs séparés ; un numéro de plan est réservé
  en commitant le squelette.
- La règle « Plain ASCII only » est supprimée. Les langues sont un réglage du projet, et les textes UI gardent leurs accents.

## 1.0.0

Version d'origine, utilisée sur SuiviTransfo : `vibe`, `vibe-codeur`, `vibe-plan-reviewer`, `vibe-auditor`,
templates STACK / INVARIANTS / CONVENTIONS.
