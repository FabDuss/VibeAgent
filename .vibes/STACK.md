# STACK -- project toolchain config for the Vibe agents

> The Vibe agents read THIS file to stay stack-agnostic. Fill in the 4 blocks below
> for your project, then delete the examples you do not use. This is the ONLY file
> you must edit to make the agents "just work" in a new repo.

## PROJECT_DIR
Where the code lives, relative to the repo root. All git/build/test commands run from here.
Use `.` if the code is at the repo root.

```
PROJECT_DIR: .
```

## TYPECHECK
The command that statically checks the code without running it. Set to `none` for a
dynamic language with no separate typecheck step (the Codeur will rely on tests instead).

```
TYPECHECK: npx tsc --noEmit
```

<!-- Examples for other stacks (delete once you picked yours):
TYPECHECK: mypy .                 # Python (typed)
TYPECHECK: none                   # Python/JS with no separate typecheck
TYPECHECK: go build ./...         # Go
TYPECHECK: cargo check            # Rust
TYPECHECK: ./gradlew compileJava  # Java/Gradle
-->

## TEST
The command that runs the test suite. If the runner can scope to a subset (a path,
a name pattern), note how -- the Codeur will run just the relevant subset per WP,
then you can trust a final full run.

```
TEST: npm test
TEST_SUBSET_HINT: npx jest --testPathPattern="<pattern>" --no-coverage
```

<!-- Examples (delete once you picked yours):
TEST: pytest
TEST_SUBSET_HINT: pytest path/to/test_file.py -k "<name>"

TEST: go test ./...
TEST_SUBSET_HINT: go test ./path/to/pkg -run "<TestName>"

TEST: cargo test
TEST_SUBSET_HINT: cargo test <name>
-->

## COMMIT_CONVENTION
The exact commit-message format the Codeur must satisfy. If the repo has a commit-msg
hook (husky, pre-commit, a custom git hook), describe the rule it enforces so the Codeur
writes a message that passes on the first try.

```
COMMIT_CONVENTION: Conventional Commits -- "<type>(<scope>): <short imperative>"
  type in: feat | fix | refactor | test | chore | docs | perf | ci | build
  subject <= 72 chars, lowercase start, no trailing period
HOOK: none
```

<!-- Example of a custom hook constraint (delete if not applicable):
COMMIT_CONVENTION: "<imperative> <description> (WP<NN> T<NN>-XX)"
HOOK: a commit-msg hook rejects messages that do not match the regex above.
-->

## Notes for the agents (optional)
Anything else the agents should know to operate here: monorepo layout, how to run a
single test, a lint command to also pass, env setup needed before tests, etc.

```
LINT: (optional) e.g. npm run lint
NOTES: -
```
