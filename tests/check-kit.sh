#!/usr/bin/env bash
# Guard for the kit's invariants (see .vibes/INVARIANTS.md):
#   1. agent frontmatter is valid (name = file name, quoted description, tools, model, color)
#   2. every agent vibe.md may dispatch exists
#   3. every STACK key the agents cite exists in templates/vibes/STACK.md
#   4. shared vocabulary is identical across agents; retired rules stay retired
#   5. scripts contain no stray control / non-ASCII bytes (PowerShell 5.1 misreads them)
#   6. install contract: agents added then UPDATED, project files NEVER overwritten
#      (install.sh always; install.ps1 when PowerShell is available)
# Usage: bash tests/check-kit.sh    (exit 1 on any failure)
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENTS="$ROOT/.claude/agents"
STACK_TPL="$ROOT/templates/vibes/STACK.md"
PASS=0
FAIL=0
ok() { PASS=$((PASS + 1)); }
ko() { echo "FAIL: $*"; FAIL=$((FAIL + 1)); }
check() { if eval "$1"; then ok; else ko "$2"; fi; }

# 1. frontmatter
COLORS=" red blue green yellow purple orange pink cyan "
for f in "$AGENTS"/*.md; do
  name="$(basename "$f" .md)"
  if [[ "$(head -1 "$f")" != "---" ]]; then ko "$name: no frontmatter"; continue; fi
  fm="$(awk 'NR == 1 { next } /^---$/ { exit } { print }' "$f")"
  check 'grep -qx "name: $name" <<<"$fm"' "$name: 'name' does not match the file name"
  check 'grep -qE "^description: \".+\"$" <<<"$fm"' "$name: 'description' missing or not a quoted string"
  check 'grep -qE "^tools: .+" <<<"$fm"' "$name: 'tools' missing"
  check 'grep -qE "^model: .+" <<<"$fm"' "$name: 'model' missing"
  color="$(sed -n 's/^color: //p' <<<"$fm")"
  check '[[ -z "$color" || "$COLORS" == *" $color "* ]]' "$name: invalid color '$color'"
done

# 2. agents vibe.md may dispatch
for a in $(sed -n 's/^tools: .*Agent(\([^)]*\)).*/\1/p' "$AGENTS/vibe.md" | tr ',' ' '); do
  check '[[ "$a" == Explore || -f "$AGENTS/$a.md" ]]' "vibe.md may dispatch '$a', which does not exist"
done

# 3. STACK keys cited by the agents exist in the template (keys or section-title words)
STACK_WORDS="$(grep -oE '^[[:space:]]*[A-Z][A-Z0-9_]*[ :(]|^## [0-9]+\. .*' "$STACK_TPL" | grep -oE '[A-Z][A-Z0-9_]+' | sort -u)"
for tok in $(grep -ohE '`[A-Z][A-Z0-9_]*(\.[A-Z0-9_]+)?`' "$AGENTS"/*.md | tr -d '`' | sort -u); do
  [[ "$tok" =~ ^WP[0-9]+$ ]] && continue
  for part in ${tok//./ }; do
    check 'grep -qx "$part" <<<"$STACK_WORDS"' "agents cite STACK key '$tok' but '$part' is not in templates/vibes/STACK.md"
  done
done

# 4. shared vocabulary / retired rules
LEVELS='unit | build | e2e | live | render | checks'
for a in vibe vibe-plan-reviewer vibe-code-reviewer; do
  check 'grep -qF "$LEVELS" "$AGENTS/$a.md"' "$a.md does not carry the verification levels '$LEVELS'"
done
STATUSES='draft | plan-reviewed | in-progress | done | abandoned'
check 'grep -qF "$STATUSES" "$AGENTS/vibe.md"' "vibe.md lost the plan status vocabulary"
for s in backlog planned partial addressed obsolete wont-do; do
  check 'grep -qE "\*\*Status\*\*: $s" "$AGENTS/vibe.md"' "vibe.md note lifecycle lost state '$s'"
done
check '! grep -qi "plain ascii only" "$AGENTS"/*.md' "the retired 'Plain ASCII only' rule is back"
check '! grep -qE "git commit --amend" "$AGENTS"/*.md' "an agent instructs 'git commit --amend' (REVISE must be a new commit)"

# 5. stray bytes in scripts
for s in "$ROOT/install.ps1" "$ROOT/install.sh" "$ROOT/tests/check-kit.sh"; do
  check '! LC_ALL=C grep -qP "[^\x09\x0a\x0d\x20-\x7e]" "$s"' "$(basename "$s") contains control or non-ASCII bytes"
done

# 6. install contract
assert_install() { # $1 = label, $2 = target dir
  local label="$1" t="$2" a f d
  for a in "$AGENTS"/*.md; do
    check 'cmp -s "$a" "$t/.claude/agents/$(basename "$a")"' "$label: agent $(basename "$a") not installed"
  done
  for f in STACK INVARIANTS CONVENTIONS; do
    check 'cmp -s "$ROOT/templates/vibes/$f.md" "$t/.vibes/$f.md"' "$label: .vibes/$f.md not installed from templates/vibes"
  done
  for d in plans notes audits; do
    check '[[ -f "$t/.vibes/$d/.gitkeep" ]]' "$label: .vibes/$d/ not created"
  done
}
tamper() { # simulate a project edit and a stale agent
  echo "PROJECT EDIT" >>"$1/.vibes/STACK.md"
  echo "stale" >"$1/.claude/agents/vibe.md"
}
assert_rerun() { # $1 = label, $2 = target dir (copied to locals: check's eval has its own $1/$2)
  local label="$1" t="$2"
  check 'grep -q "PROJECT EDIT" "$t/.vibes/STACK.md"' "$label: re-run OVERWROTE a project file"
  check 'cmp -s "$AGENTS/vibe.md" "$t/.claude/agents/vibe.md"' "$label: re-run did not UPDATE a stale agent"
}

T="$(mktemp -d)"
git -C "$T" init -q
if bash "$ROOT/install.sh" "$T" >/dev/null; then ok; else ko "install.sh failed on a fresh repo"; fi
assert_install "install.sh" "$T"
tamper "$T"
if bash "$ROOT/install.sh" "$T" >/dev/null; then ok; else ko "install.sh failed on re-run"; fi
assert_rerun "install.sh" "$T"
rm -rf "$T"

PS="$(command -v pwsh || command -v powershell.exe || true)"
if [[ -n "$PS" ]]; then
  T="$(mktemp -d)"
  git -C "$T" init -q
  winpath() { if command -v cygpath >/dev/null; then cygpath -w "$1"; else echo "$1"; fi; }
  run_ps() { "$PS" -NoProfile -ExecutionPolicy Bypass -File "$(winpath "$ROOT/install.ps1")" -Target "$(winpath "$T")" >/dev/null; }
  if run_ps; then ok; else ko "install.ps1 failed on a fresh repo"; fi
  assert_install "install.ps1" "$T"
  tamper "$T"
  if run_ps; then ok; else ko "install.ps1 failed on re-run"; fi
  assert_rerun "install.ps1" "$T"
  rm -rf "$T"
else
  echo "note: PowerShell not found -- install.ps1 not exercised"
fi

echo "check-kit: $PASS passed, $FAIL failed"
[[ $FAIL -eq 0 ]]
