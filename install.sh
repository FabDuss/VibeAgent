#!/usr/bin/env bash
# Installs or updates the Vibe agents kit in a target repository, or globally.
#   - Agents (.claude/agents/vibe*.md) are kit-owned: added or UPDATED (overwritten).
#   - Project files (.vibes/STACK.md, INVARIANTS.md, CONVENTIONS.md, plans/, notes/, audits/)
#     are project-owned: added only when missing, NEVER overwritten.
#   - --with-docs also adds VISION.md, ARCHITECTURE.md and CLAUDE.md templates when missing.
#
# Usage:
#   ./install.sh <repo path> [--with-docs]
#   ./install.sh --global
set -euo pipefail

KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET=""
GLOBAL=0
WITH_DOCS=0

for arg in "$@"; do
  case "$arg" in
    --global) GLOBAL=1 ;;
    --with-docs) WITH_DOCS=1 ;;
    -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
    *) TARGET="$arg" ;;
  esac
done

if [[ -z "$TARGET" && $GLOBAL -eq 0 ]]; then
  echo "Usage: ./install.sh <repo path> [--with-docs]   or   ./install.sh --global"
  exit 1
fi

copy_agents() {
  local dest_dir="$1"
  mkdir -p "$dest_dir"
  for f in "$KIT"/.claude/agents/vibe*.md; do
    local dest="$dest_dir/$(basename "$f")"
    local state="added  "
    [[ -e "$dest" ]] && state="updated"
    cp "$f" "$dest"
    echo "  agent $state : $dest"
  done
}

copy_if_missing() {
  local src="$1" dest="$2"
  if [[ -e "$dest" ]]; then
    echo "  kept          : $dest (exists, not overwritten)"
    return
  fi
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  echo "  added         : $dest"
}

if [[ $GLOBAL -eq 1 ]]; then
  echo "Installing the Vibe agents globally in $HOME/.claude/agents"
  copy_agents "$HOME/.claude/agents"
  echo
  echo "Each project still needs its own .vibes/ (run with a repo path)."
  echo "Cloud sessions only see agents versioned in the repo: prefer a per-repo install for shared repos."
fi

if [[ -n "$TARGET" ]]; then
  TARGET="$(cd "$TARGET" && pwd)"
  echo "Installing the Vibe agents kit in $TARGET"
  copy_agents "$TARGET/.claude/agents"

  for f in STACK.md INVARIANTS.md CONVENTIONS.md; do
    copy_if_missing "$KIT/.vibes/$f" "$TARGET/.vibes/$f"
  done
  for d in plans notes audits; do
    if [[ ! -d "$TARGET/.vibes/$d" ]]; then
      mkdir -p "$TARGET/.vibes/$d"
      touch "$TARGET/.vibes/$d/.gitkeep"
      echo "  added         : $TARGET/.vibes/$d/.gitkeep"
    fi
  done

  if [[ $WITH_DOCS -eq 1 ]]; then
    copy_if_missing "$KIT/templates/VISION.md" "$TARGET/VISION.md"
    copy_if_missing "$KIT/templates/ARCHITECTURE.md" "$TARGET/ARCHITECTURE.md"
    if [[ -e "$TARGET/CLAUDE.md" ]]; then
      echo "  hint          : merge templates/CLAUDE.md (Vibe relay rules) into your existing CLAUDE.md"
    else
      copy_if_missing "$KIT/templates/CLAUDE.md" "$TARGET/CLAUDE.md"
    fi
  fi

  echo
  echo "Checks:"
  if [[ -e "$TARGET/.git" ]]; then
    for p in .claude/agents/vibe.md .vibes/STACK.md; do
      if git -C "$TARGET" check-ignore -q "$p"; then
        echo "  WARNING       : $p is git-ignored. In .gitignore use '.claude/*' then '!.claude/agents/' (a bare '.claude/' cannot be re-included; cloud sessions need the agents versioned)."
      else
        echo "  ok            : $p is not ignored"
      fi
    done
    if ! git -C "$TARGET" check-ignore -q .claude/worktrees/x; then
      echo "  hint          : add '.claude/worktrees/' to .gitignore (vibe creates per-plan worktrees there)"
    fi
    if [[ ! -e "$TARGET/.gitattributes" ]]; then
      echo "  hint          : no .gitattributes -- consider '* text=auto eol=lf' (see $KIT/.gitattributes), in its own commit"
    fi
  else
    echo "  hint          : target is not a git repository (git init first to version .claude/agents and .vibes)"
  fi

  echo
  echo "Next steps:"
  echo "  1. Fill .vibes/STACK.md from your CI workflows and rule files (AGENTS.md, CLAUDE.md)."
  echo "  2. Measure the BASELINE (lint / typecheck / tests on the base branch) and write it in STACK."
  echo "  3. Set the project git identity: git config --local user.email <email>"
  echo "  4. Fill Part B of .vibes/CONVENTIONS.md; keep or trim Part A."
  echo "  5. Commit .claude/agents and .vibes, then run: claude --agent vibe"
fi
