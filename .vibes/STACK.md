# STACK -- the VibeAgent kit repository itself

```
STACK_STATUS: filled
```

> This is the kit's OWN workspace (developing the kit with the Vibe agents). The templates
> distributed to other projects live in `templates/vibes/` -- never treat them as this repo's
> config, and never fill them with this repo's values (INV-002).

## 1. RULE FILES & PRECEDENCE
```
RULE_FILES: CLAUDE.md
PRECEDENCE: RULE_FILES > .vibes/INVARIANTS.md > .vibes/STACK.md > .vibes/CONVENTIONS.md
```

## 2. LANGUAGES
```
CONVERSATION: fr
DOCS: fr                  # .vibes/, README.md, CHANGELOG.md, docs/
CODE: en                  # agent prompts (.claude/agents/), templates/, scripts, script output
COMMITS: en
PR: en
UI: none
CHARSET_SOURCE: ascii for install.ps1 / install.sh / tests/ (PowerShell 5.1 misreads non-ASCII); utf-8 elsewhere
CHARSET_DOCS: utf-8
```

## 3. COMPONENTS
One component: the kit (agent prompts, templates, install scripts). No build, no typechecker.
```
COMPONENT: kit
  DIR: .
  INSTALL: none
  LINT: none                 # the consistency lint is part of TEST
  FORMAT_CHECK: none
  TYPECHECK: none
  TEST: bash tests/check-kit.sh
  TEST_SUBSET: none
  BUILD: none
  E2E: none
  E2E_SUBSET: none
  MIGRATE: none
```

## 4. CI_PARITY
```
CI_PARITY: TEST                      # there is no CI: the local TEST is the only gate, run it before every commit
CI_TRIGGERS: none
CI_PATH_FILTERS: none
CI_STATUS_CMD: none
```

## 5. BASELINE
```
BASELINE (measured 2026-09-23 on main): TEST green (134 checks, install.ps1 exercised)
```

## 6. TEST_POLICY
```
RUN_SUITES: one run at a time (the TEST installs into throwaway repos under the temp dir)
FLAKE_PROTOCOL: none known
OUTPUT: never pipe the TEST into tail/head; redirect to a scratch file and grep it
E2E_SERVER: none
```

## 7. RUN, PORTS & LIVE CHECKS
```
DEV_SERVERS: none
USER_PORTS: none
TEST_PORTS: none
PREVIEW_PORTS: none
PORT_OFFSET_PER_WORKTREE: none
API_TARGET: none
PREREQS: bash (Git Bash on Windows), git; PowerShell for the install.ps1 part of TEST
LIVE_CHECK: install the kit into a throwaway git repo and read the result:
            ./install.sh <scratch-repo> --with-docs   (or .\install.ps1 -Target <scratch-repo> -WithDocs)
            The real proof of an agent-prompt change is its first use on a project: say so in the plan.
SCREENSHOT: none
ENV_PITFALLS:
  - Python string literals: a backslash before v, t, n... becomes a control byte ("templates\vibes" once became
    "templates<VT>ibes" in install.ps1). Use raw strings or the Edit tool for paths with backslashes.
  - Git Bash maps /tmp to the Windows temp dir; pass Windows paths (cygpath -w) to PowerShell.
```

## 8. GIT
```
IDENTITY: Fabien Dussaucy <fabien.dussaucy@gmail.com>   # the global identity (GitHub account FabDuss)
BASE_BRANCH: main
BRANCH_NAMING: <type>/<NNN>-<slug>   # optional: single maintainer, see DIRECT_PUSH_TO_BASE
DIRECT_PUSH_TO_BASE: yes             # personal repo, single maintainer; pushing still needs the user's request
WORKTREES_DIR: .claude/worktrees
MERGED_BY: user
COMMIT_CONVENTION: Conventional Commits -- "<type>(<scope>): <short imperative>"
  type in: feat | fix | refactor | test | chore | docs
  scope: agents | templates | install | tests | docs  (optional)
  subject <= 72 chars, lowercase start, no trailing period
COMMIT_HOOK: none
TRAILERS: none
PR_TITLE: same format as COMMIT_CONVENTION
PR_TEMPLATE: none
```

## 9. GUARDRAILS
```
PROTECTED_PATHS: none
DEPENDENCIES: none allowed without the user's approval (the kit has zero dependencies: keep it that way)
VERSION_PINNING: n/a
PRODUCTION: n/a
```

## 10. RELEASE
```
ENVIRONMENTS: GitHub FabDuss/VibeAgent, branch main
PATH_TO_STAGING: none
MANUAL_TRIGGERS: none
ORDER: n/a
VERIFY: git ls-remote origin refs/heads/main == local HEAD
RELEASE_NOTES: every user-visible change gets a CHANGELOG.md entry (version + date) in the same change
DISTRIBUTION: projects get a new version by re-running install.ps1 / install.sh on themselves
AFTER_BOT_COMMITS: none
```

## 11. VIBES & REFERENCE DOCS
```
VIBES_TRACKED: yes
REFERENCE_DOCS:
  - README.md              (what the kit is, install, flow, who owns which file)
  - CHANGELOG.md           (every change)
  - docs/LESSONS-TRANSFO.md (field lessons -> where each one is encoded)
  - templates/             (what gets installed in projects)
```

## 12. REMOTE / CLOUD SESSIONS
```
REMOTE_LIMITS:
  - no PowerShell on Linux cloud sessions -> the install.ps1 part of TEST is skipped (the TEST says so)
```
