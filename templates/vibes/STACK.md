# STACK -- how this project is built, checked, run and shipped

```
STACK_STATUS: template        # set to "filled" once every value below is REAL for this project
```

> Every Vibe agent reads THIS file at the start of every session / dispatch. It is the ONLY
> place for commands, ports, environments and procedures: agents never guess a toolchain and
> never keep this kind of fact in personal memory (a cloud session or a teammate does not
> have your memory -- the repo is the only shared brain).
>
> **Every value below is an EXAMPLE** (a two-component web app) until you replace it. While
> `STACK_STATUS` is `template`, or a field still holds `<...>`, the `vibe` agent fills it with
> you before planning anything.
>
> Fill it FROM THE TRUTH: the CI workflow files and the repo rule files (AGENTS.md,
> CLAUDE.md, CONTRIBUTING). If this file disagrees with CI or with a rule file, CI and the
> rule file win -- fix this file. Write `none` when a field does not apply.

## 1. RULE FILES & PRECEDENCE
Repo files that carry rules agents must obey. Agents read them at session start.
```
RULE_FILES: AGENTS.md, CLAUDE.md
PRECEDENCE: RULE_FILES > .vibes/INVARIANTS.md > .vibes/STACK.md > .vibes/CONVENTIONS.md
```

## 2. LANGUAGES
```
CONVERSATION: fr          # how agents talk to the user
DOCS: fr                  # .vibes/ plans, notes, audits, INVARIANTS
CODE: en                  # identifiers and code comments
COMMITS: en               # every commit subject and body (the Codeur's and vibe's docs commits)
PR: en                    # pull request title and description
UI: fr                    # user-facing product strings (accents allowed; see CONVENTIONS Part B "Text & i18n")
CHARSET_SOURCE: utf-8     # "ascii" if the project forbids non-ASCII in source files
CHARSET_DOCS: utf-8       # "ascii" if .vibes/ docs must stay ASCII (the auditor then draws [###--] instead of stars)
```

## 3. COMPONENTS
One block per deployable / independently-built component. Single-component repo = one block
with `DIR: .`. Commands run from `DIR`. A field the component lacks = `none`.
`TYPECHECK` must cover test files too if CI does; if the typechecker cannot see some
sources (templates, generated code), say so -- then `BUILD` is the real gate for them.
```
COMPONENT: api
  DIR: api
  INSTALL: npm ci
  LINT: npm run lint
  FORMAT_CHECK: npx prettier --check <files>      # on touched files only
  TYPECHECK: npm run typecheck
  TEST: npm test
  TEST_SUBSET: npx jest <path-or-name-pattern>
  BUILD: npm run build
  E2E: none
  E2E_SUBSET: none
  MIGRATE: npm run db:migrate                     # none if no persistent store

COMPONENT: client
  DIR: client
  INSTALL: npm ci
  LINT: npm run lint
  FORMAT_CHECK: npx prettier --check <files>
  TYPECHECK: npm run typecheck        # does NOT see HTML templates -> BUILD is the gate for them
  TEST: npm test
  TEST_SUBSET: npx jest <pattern>
  BUILD: npm run build
  E2E: npx playwright test
  E2E_SUBSET: npx playwright test <spec> --workers=1
  MIGRATE: none
```
<!-- Other stacks, for inspiration:
  Python:  LINT: ruff check . | TYPECHECK: mypy . | TEST: pytest | TEST_SUBSET: pytest <file> -k "<name>"
  Go:      LINT: golangci-lint run | TYPECHECK: go vet ./... | TEST: go test ./... | BUILD: go build ./...
  Rust:    LINT: cargo clippy | TYPECHECK: cargo check | TEST: cargo test | BUILD: cargo build --release
-->

## 4. CI_PARITY
What CI actually runs (copied from the workflow files), and when it runs. A WP is not done
and nothing is pushed until the touched components pass this list locally.
```
CI_PARITY (per touched component, in order): LINT, TYPECHECK, TEST, BUILD  (+ E2E when a UI / user flow is touched)
CI_TRIGGERS: pull_request -> development ; workflow_dispatch        # e.g. "a direct push triggers NOTHING"
CI_PATH_FILTERS: ci-api runs on api/** only ; ci-client on client/**  # a docs-only PR gets NO check
CI_STATUS_CMD: gh pr checks <pr> ; gh run list --workflow <file> --limit 3
```

## 5. BASELINE
Known pre-existing failures / warnings / flaky tests, measured on the base branch, with the
date. Agents compare against it: the rule is "no NEW errors", and they never "fix" baseline
noise outside their WP scope. Re-measure when it changes; empty = everything is green.
```
BASELINE (measured <YYYY-MM-DD> on <base-branch>@<sha>):
  - client LINT: 0 errors, 4 prettier warnings in <files>
  - api TYPECHECK: clean
  - flaky: <suite/spec> -- times out under load, green alone (see FLAKE_PROTOCOL)
```

## 6. TEST_POLICY
```
RUN_SUITES: one component at a time, never two test runners in parallel (contention = false reds)
FLAKE_PROTOCOL: a suite that fails with 0 failed assertions, or times out -> re-run it ALONE
                (E2E_SUBSET, single worker) before calling it a regression; report "flaky under load" explicitly
OUTPUT: never pipe a test runner into tail/head (exit code and stack traces are lost);
        redirect to a file in the scratchpad and grep it
E2E_SERVER: always a server started from the CURRENT tree on TEST_PORTS (section 7);
            never reuse a long-running dev server (stale bundle) or another session's server
```

## 7. RUN, PORTS & LIVE CHECKS
How to run the app, which ports belong to whom, and how to verify against real / dev data.
```
DEV_SERVERS:                         # the commands (the user runs them on USER_PORTS)
  api:    npm run start:dev          # health: GET /health
  client: npm run start -- --port <port>
USER_PORTS: api 8000, client 4300, db 5434      # the user's own servers: agents NEVER stop, restart or reuse them
TEST_PORTS: api 8020, client 4399               # Codeur / reviewers: throwaway instances for E2E and checks
PREVIEW_PORTS: api 8030, client 4330            # vibe: the preview it shows the user
PORT_OFFSET_PER_WORKTREE: +100 per extra worktree (e.g. 8120 / 4499 / 8130 / 4430)
API_TARGET: how the client is pointed at a non-default api port, e.g. "API_URL=http://localhost:<port> npm run start"
PREREQS: docker compose up -d <db-service> ; <component> MIGRATE
LIVE_CHECK: <how to query real / dev data READ-ONLY: probe script, curl recipe, seed account>
            none -> every data-facing DoD says "NOT live-verified" + the degradation path
SCREENSHOT: <how to capture the rendered UI, e.g. a Playwright script on TEST_PORTS> | none
ENV_PITFALLS (verified quirks of this machine / environment):
  - e.g. "the api listens on :: -> use localhost, not 127.0.0.1"
  - e.g. "docker is not on PATH: prefix PATH with <dir>"
```

## 8. GIT
```
IDENTITY: <Name> <email>          # set with `git config --local` only, never --global
BASE_BRANCH: development          # the branch features start from and PRs target
BRANCH_NAMING: <type>/<NNN>-<slug>  # one branch per plan
DIRECT_PUSH_TO_BASE: no           # yes = work and push directly on BASE_BRANCH is allowed (see RELEASE for manual triggers)
WORKTREES_DIR: .claude/worktrees  # where vibe creates per-plan worktrees (must be git-ignored)
MERGED_BY: user                   # user | vibe -- vibe merges only if "vibe" AND the user asked for that merge
COMMIT_CONVENTION: Conventional Commits -- "<type>(<scope>): <short imperative>"
  type in: feat | fix | refactor | test | chore | docs | perf | ci | build
  scope: <component or area>
  subject <= 72 chars, lowercase start, no trailing period
COMMIT_HOOK: none                 # describe what a commit-msg hook enforces, if any
TRAILERS: none                    # e.g. "Co-Authored-By: ..." if the user wants one
PR_TITLE: same format as COMMIT_CONVENTION
PR_TEMPLATE: none                 # or path to the PR template
```

## 9. GUARDRAILS
```
PROTECTED_PATHS:                  # never modified without the user's approval recorded in the plan
  - .github/          (owner: <team / contact>)
  - <infra dir>/      (owner: <team / contact>)
DEPENDENCIES: ask first           # no new / upgraded dependency without the user's approval recorded in the plan
VERSION_PINNING: exact x.y.z      # how an approved dependency is pinned (never "latest")
PRODUCTION: human only            # agents never promote / deploy to production
```

## 10. RELEASE
How code reaches each environment, step by step, and how to confirm it got there.
`none` if the project is not deployed (library, local tool).
```
ENVIRONMENTS: staging (from development), production (from main, human only)
PATH_TO_STAGING: PR merged into development -> CI builds images -> GitOps bumps manifests -> ArgoCD syncs
MANUAL_TRIGGERS: after a direct push to development run `gh workflow run <release-api>` then `<release-client>`
ORDER: the component that PRODUCES a field ships before the one that READS it; never run two
       release jobs that commit to the same branch in parallel
VERIFY: CI_STATUS_CMD -> conclusion: success, THEN check the app itself
AFTER_BOT_COMMITS: `git pull --rebase origin <base>` before any new work
```

## 11. VIBES & REFERENCE DOCS
```
VIBES_TRACKED: yes                # yes = .vibes/ is committed by vibe in separate docs commits (recommended)
                                  # no  = .vibes/ stays local (single-person, single-machine only)
REFERENCE_DOCS:                   # docs that must stay true when a change makes them false
  - VISION.md          (why / what / for whom)
  - ARCHITECTURE.md    (shape + rationale; deployed config wins over it)
  - README.md          (run / build / deploy recipe)
  - docs/<external-api>.md  (verified facts about an external system)
```

## 12. REMOTE / CLOUD SESSIONS
What a cloud or remote session lacks here, so plans can say "not verified here" honestly.
```
REMOTE_LIMITS:
  - no secrets -> no live check against <external system>
  - local branches die with the container -> ask the user before pushing a backup branch you need later
  - preinstalled browser may not match the pinned E2E runner version -> <workaround>
```
