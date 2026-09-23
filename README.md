# VibeAgent -- kit d'agents Claude Code pour du développement itératif rigoureux

Cinq agents Claude Code, indépendants de la stack, pour aller vite **sans dériver** :
idée / bug / retour → faits vérifiés → plan → revue de plan impartiale → **GO utilisateur** →
code WP par WP avec revue → aperçu local → livraison sur demande.

La v2 intègre les leçons de ~2,5 mois d'usage réel sur **SuiviTransfo** : 42 plans, 1 audit,
des dizaines de revues et de sessions en parallèle. Le détail, avec ses preuves, est dans
[docs/LESSONS-TRANSFO.md](docs/LESSONS-TRANSFO.md) et les changements dans [CHANGELOG.md](CHANGELOG.md).

## Les 5 agents

| Agent | Rôle | Écrit du code ? |
|-------|------|-----------------|
| **vibe** | Chef d'orchestre : vérifie les faits, planifie, fait relire, demande le GO, dispatche, revoit, montre, livre sur demande. Ton interlocuteur au quotidien. | Non (uniquement `.vibes/`, qu'il commite lui-même) |
| **vibe-codeur** | Implémente exactement 1 WP, le prouve (parité CI : lint, typecheck, tests, build, E2E / live / rendu si la DoD le demande), commite. | Oui (le seul) |
| **vibe-plan-reviewer** | Relit le PLAN avant tout code : dérive vs invariants, logique et cas limites, données non vérifiées, blast radius des tests, testabilité de la DoD, opérations. | Non |
| **vibe-code-reviewer** *(nouveau)* | Revue fraîche et impartiale d'un WP risqué : relance les checks, vérifie chaque point de DoD avec preuve, traque les tests creux. | Non |
| **vibe-auditor** | Audit read-only : mode SYSTEM (état des lieux) ou CHANGE (avant merge d'une branche), rapport structuré + « Fix Handoff ». | Non |

`vibe-codeur`, `vibe-plan-reviewer` et `vibe-code-reviewer` sont dispatchés par `vibe`. `vibe-auditor`
s'invoque à la demande (« audit technique », « audite la branche avant merge ») ou sur proposition de `vibe`.

## Le flux

```
 Resume ─► Understand ─► Plan ─► Plan review ─► GO ─► ┌ WP: Codeur ─► Review ┐ ─► Preview ─► Wrap up ─► Ship* ─► Close
 (git,     (faits        (numéro   (impartiale,   (toi)  └──────── × N ────────┘   (local,    (notes,      (*sur ta
  plans     vérifiés,     réservé,  8 contrôles)                                    frais)     invariants)  demande)
  ouverts)  écrans frères) commité)
```

Quatre **voies** selon la demande :
- **standard** : feature, contrat, schéma, infra, questions produit → le flux complet ;
- **fast** : petite demande directe et bornée (1 WP, ~5 fichiers, 1 composant, rien de structurant) → micro-plan, ta demande vaut GO pour ce WP ;
- **live** : tu regardes l'appli qui tourne et tu enchaînes les retours → chaque retour devient un WP ajouté au plan en cours ;
- **plan only** : « ne code pas encore », lot de retours à trier → on s'arrête au plan relu.

Push, PR, merge et déploiement ne font partie d'**aucune** voie : ils demandent toujours ton instruction explicite.
La production n'est jamais promue par un agent.

## Démarrer

**Recommandé : `vibe` en thread principal**, pour qu'il puisse te poser ses questions et attendre ton GO :
```bash
claude --agent vibe
```

**Depuis une session normale ou l'extension VS Code** (« vibe: j'ai une idée… ») : `vibe` tourne alors comme
sous-agent et ne peut pas te parler en cours de route. Il passe en **mode relais** : il s'arrête à chaque porte et
renvoie un bloc `HANDBACK (vibe)` (questions numérotées, demande de GO). La session appelante te le montre, puis
lui renvoie ta réponse **mot pour mot**, via SendMessage pour qu'il garde son contexte. Un GO paraphrasé ne compte
pas. Le bloc à ajouter au `CLAUDE.md` du projet est dans [templates/CLAUDE.md](templates/CLAUDE.md).

## Installation dans un projet

```powershell
# Windows
.\install.ps1 -Target C:\chemin\vers\projet -WithDocs
```
```bash
# macOS / Linux / Git Bash
./install.sh /chemin/vers/projet --with-docs
```

Le script :
- ajoute ou **met à jour** les 5 agents dans `.claude/agents/` (ils appartiennent au kit) ;
- ajoute `.vibes/STACK.md`, `INVARIANTS.md`, `CONVENTIONS.md`, `plans/`, `notes/`, `audits/` **seulement s'ils manquent**. Il n'écrase jamais les fichiers du projet ;
- avec `-WithDocs` / `--with-docs`, ajoute `VISION.md`, `ARCHITECTURE.md` et `CLAUDE.md` s'ils manquent ;
- vérifie que `.claude/agents/` n'est pas ignoré par git (les sessions cloud en ont besoin) et suggère un `.gitattributes`.

Pour **mettre à jour** un projet déjà équipé, relance simplement le script : seuls les agents sont remplacés.

### Checklist de démarrage (15 minutes qui en économisent des heures)
1. **Remplir `.vibes/STACK.md` à partir de la vérité** (toutes ses valeurs sont des exemples tant que
   `STACK_STATUS: template` ; `vibe` le remplit avec toi avant tout plan si tu ne l'as pas fait) : les workflows CI et les fichiers de règles du repo
   (AGENTS.md, CLAUDE.md, CONTRIBUTING). Tu y déclares :
   - les commandes par composant (lint, typecheck, tests, build, E2E) ;
   - la parité CI et ses déclencheurs ;
   - les ports : les tiens, que les agents ne touchent jamais ; ceux des tests ; ceux de l'aperçu ; plus la recette de vérification live ;
   - git : identité, branche de base, qui merge ;
   - les chemins protégés, la politique de dépendances, la procédure de release ;
   - les langues (conversation, docs, commits, PR, UI).
2. **Mesurer la BASELINE** sur la branche de base (erreurs de lint / typecheck préexistantes, tests flaky) et
   l'écrire dans STACK. La règle devient alors « aucune NOUVELLE erreur ».
3. **Identité git du projet** : `git config --local user.email <email>`.
4. **`.gitignore`** : si `.claude/` est ignoré, remplacer par `.claude/*` puis `!.claude/agents/` ; ignorer
   `.claude/worktrees/` (c'est là que `vibe` crée un worktree par plan quand plusieurs sessions tournent).
5. **`.gitattributes`** (`* text=auto eol=lf`) dès le premier jour, dans son propre commit.
6. **CONVENTIONS** : garder ou élaguer la partie A (doctrine du kit), remplir la partie B (règles du projet).
7. **INVARIANTS démarre vide** : `vibe` le remplit quand une décision est actée.
8. Commiter `.claude/agents/` et `.vibes/`, puis `claude --agent vibe`.

## Qui porte quoi

| Fichier | Contenu | Écrit par |
|---------|---------|-----------|
| `VISION.md` | Pourquoi / quoi / pour qui (1 page) | toi, et `vibe` via le codeur quand un plan change la promesse |
| `ARCHITECTURE.md` | Forme du système et justification (la config déployée fait foi) | idem |
| `.vibes/STACK.md` | Comment on construit, vérifie, lance et livre | `vibe` (avec toi) |
| `.vibes/CONVENTIONS.md` | Comment on écrit le code (A : doctrine kit, B : projet) | `vibe` (avec toi) |
| `.vibes/INVARIANTS.md` | Décisions actées, **identifiants stables `INV-NNN`**, garde automatique, budget ~12 Ko | `vibe` |
| `.vibes/plans/NNN-slug.md` | Un plan par itération : demande mot pour mot, faits vérifiés, décisions, WPs, journal de revue, livré | `vibe` |
| `.vibes/notes/slug.md` | Backlog, une idée par fichier, cycle de vie `backlog → planned → partial/addressed` | `vibe`, `vibe-auditor` |
| `.vibes/audits/NNN-slug-date.md` | Rapports d'audit | `vibe-auditor` |

Rien de durable ne vit dans la mémoire d'un agent : une session cloud, un collègue ou une session parallèle
doivent pouvoir reprendre à partir du repo seul.

## Portée : projet ou global
- **Projet** (recommandé) : `.claude/agents/` versionné dans le repo. C'est indispensable pour les sessions cloud
  (claude.ai/code), qui ne voient que les agents du repo.
- **Global** : `.\install.ps1 -Global` copie les agents dans `~/.claude/agents/`, ce qui est pratique en local. Chaque projet
  garde son `.vibes/`. Si un même agent existe au niveau projet et global, la version **projet** l'emporte.

## Migrer un projet équipé en v1 (ex. SuiviTransfo)
1. Relancer le script sur le projet : les agents passent en v2, et les fichiers `.vibes/` existants sont conservés.
2. Demander à `vibe` un plan « migration .vibes v2 » (voie standard) couvrant :
   - réécrire STACK au format v2 (composants, parité CI, baseline, ports, git, release, langues), en partant du template du kit ;
   - fusionner la partie A du `CONVENTIONS.md` du kit dans le fichier existant (les revues y renvoient, par exemple le plancher UI A8) ;
   - convertir INVARIANTS en entrées `INV-NNN` courtes avec champ Guard, archiver l'historique dans `## Retired` ou dans les plans, et remplacer les renvois `§NN` dans le code ;
   - normaliser les statuts des plans et des notes ;
   - commiter les plans non suivis.

## Contenu du dépôt

```
.
├── README.md                  <- ce fichier
├── CHANGELOG.md
├── .gitattributes             <- fins de ligne LF (modèle à reprendre dans tes projets)
├── docs/LESSONS-TRANSFO.md    <- les leçons SuiviTransfo et où chacune est encodée
├── install.ps1 / install.sh   <- installation / mise à jour dans un projet
├── .claude/agents/            <- les 5 agents (copiés dans le projet)
│   ├── vibe.md
│   ├── vibe-codeur.md
│   ├── vibe-plan-reviewer.md
│   ├── vibe-code-reviewer.md
│   └── vibe-auditor.md
├── .vibes/                    <- templates copiés s'ils manquent
│   ├── STACK.md
│   ├── INVARIANTS.md
│   ├── CONVENTIONS.md
│   └── plans/ notes/ audits/
└── templates/                 <- optionnels (-WithDocs)
    ├── VISION.md
    ├── ARCHITECTURE.md
    └── CLAUDE.md              <- règles du mode relais pour la session principale
```

## Personnalisation
- **Changer de stack** : `.vibes/STACK.md` uniquement. Aucun prompt n'a de toolchain en dur.
- **Règles d'archi / de code** : `.vibes/CONVENTIONS.md`. On adapte une règle de la partie A en la **réécrivant** ;
  son noyau (source de vérité unique, échec explicite, affichage distinct des données, tests qui peuvent échouer,
  secrets, migrations) reste de toute façon vérifié par les agents.
- **Modèle** : `model: opus` dans le frontmatter de chaque agent.
