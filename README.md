# Vibe Agents Kit

Un kit **stack-agnostique** de 4 agents Claude Code pour du développement itératif rigoureux :
idée/bug → plan → revue de plan → code → revue de code, avec un garde anti-dérive à chaque étape.

Ces agents étaient à l'origine couplés à un projet précis (TypeScript / DDD / graph LangGraph).
Cette version est **découplée** : toute la config spécifique au projet vit dans un seul fichier
(`.vibes/STACK.md`), et les règles d'archi optionnelles dans `.vibes/CONVENTIONS.md`.

## Les 4 agents

| Agent | Rôle | Écrit du code ? |
|-------|------|-----------------|
| **vibe** | Chef d'orchestre : discovery → plan → orchestration → revue. Le seul avec qui tu discutes. | Non (uniquement `.vibes/`) |
| **vibe-codeur** | Implémente exactement 1 work package, self-check (typecheck + tests), commit. | Oui (le seul) |
| **vibe-plan-reviewer** | Relit le PLAN avant tout code, contre les invariants. Garde anti-dérive. | Non |
| **vibe-auditor** | Audit technique read-only du système, rapport structuré dans `.vibes/audits/`. | Non |

`vibe-codeur` et `vibe-plan-reviewer` sont dispatchés automatiquement par `vibe` — tu ne les
appelles pas directement. `vibe-auditor` s'invoque à la demande ("audit technique", "état des lieux").

## Contenu du kit

```
vibe-agents-kit/
├── README.md                       <- ce fichier (ne pas copier dans le projet cible)
├── .claude/
│   └── agents/
│       ├── vibe.md
│       ├── vibe-codeur.md
│       ├── vibe-plan-reviewer.md
│       └── vibe-auditor.md
└── .vibes/
    ├── STACK.md                    <- **LE fichier à remplir** (toolchain + commit convention)
    ├── INVARIANTS.md               <- décisions établies (démarre vide, grandit au fil du projet)
    ├── CONVENTIONS.md              <- règles d'archi optionnelles (supprimable)
    ├── plans/    (.gitkeep)
    ├── notes/    (.gitkeep)
    └── audits/   (.gitkeep)
```

## Installation dans un autre projet (2 minutes)

### 1. Copier les 2 dossiers à la racine du repo cible
Copie **le contenu** du kit (`.claude/` et `.vibes/`) à la racine de ton projet — **pas** le
dossier `vibe-agents-kit/` lui-même, et **pas** ce `README.md`.

- Si `.claude/agents/` existe déjà dans le projet cible : ajoute juste les 4 fichiers `vibe*.md`
  dedans (fusion, n'écrase rien d'autre).
- Si `.vibes/` existe déjà : garde tes fichiers, ajoute seulement ceux qui manquent.

Exemple (Bash, depuis la racine du kit) :
```bash
cp -r .claude .vibes /chemin/vers/projet-cible/
```
Exemple (PowerShell) :
```powershell
Copy-Item -Recurse .\.claude, .\.vibes -Destination C:\chemin\vers\projet-cible\
```

### 2. Remplir `.vibes/STACK.md` (obligatoire)
C'est le seul fichier requis pour que tout fonctionne. Renseigne 4 blocs :
- **PROJECT_DIR** — où est le code (`.` si racine, sinon `packages/app`, etc.).
- **TYPECHECK** — la commande de vérification statique (ex. `npx tsc --noEmit`, `mypy .`, `go build ./...`, ou `none`).
- **TEST** — la commande de tests (ex. `npm test`, `pytest`, `go test ./...`).
- **COMMIT_CONVENTION** — le format de commit à respecter (+ contrainte d'un éventuel hook `commit-msg`).

Des exemples multi-stacks sont déjà dans le fichier ; supprime ceux que tu n'utilises pas.

### 3. (Optionnel) Renseigner `.vibes/CONVENTIONS.md`
Les vraies règles d'archi/style de ton projet (couches, gestion d'erreurs, wiring, tests…).
Si tu le supprimes, les agents retombent sur des non-négociables génériques + `INVARIANTS.md`.

### 4. `INVARIANTS.md` démarre vide
Ne l'invente pas : le `vibe` agent le remplit quand tu établis une décision durable.

### 5. Vérifier que Claude Code voit les agents
Dans le projet cible, lance Claude Code et tape `/agents` : les 4 `vibe*` doivent apparaître
(source « project »). Puis lance-toi avec, par exemple : « vibe: j'ai une idée … ».

## Portée : project vs global
- **Project** (recommandé) : `.claude/agents/` dans le repo → versionné, partagé avec l'équipe.
- **Global** (tous tes repos) : copie les 4 `vibe*.md` dans `~/.claude/agents/`. Dans ce cas,
  chaque projet doit quand même avoir son `.vibes/STACK.md`. Si un même nom d'agent existe au
  niveau projet ET global, la version **projet** l'emporte.

## Personnalisation rapide
- **Changer de stack** → édite `.vibes/STACK.md` uniquement. Les prompts n'ont pas de toolchain en dur.
- **Format de commit d'équipe** → `COMMIT_CONVENTION` dans `STACK.md`.
- **Règles d'archi** → `.vibes/CONVENTIONS.md`.
- **Modèle** → chaque agent a `model: opus` dans son frontmatter ; change-le si besoin.

## Rappel
Ce dossier `vibe-agents-kit/` n'est qu'un **conteneur de distribution**. Une fois le contenu
copié dans le projet cible, tu peux le supprimer ici — il n'est pas destiné à être commité
dans ce repo-ci.
