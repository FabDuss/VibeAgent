<#
.SYNOPSIS
  Installs or updates the Vibe agents kit in a target repository, or globally.

.DESCRIPTION
  - Agents (.claude/agents/vibe*.md) are kit-owned: they are added or UPDATED (overwritten).
  - Project files (.vibes/STACK.md, INVARIANTS.md, CONVENTIONS.md, plans/, notes/, audits/)
    are project-owned: they are added only when missing, NEVER overwritten.
  - -WithDocs also adds VISION.md, ARCHITECTURE.md and CLAUDE.md templates at the repo root
    when missing.

.EXAMPLE
  .\install.ps1 -Target C:\code\my-project
  .\install.ps1 -Target C:\code\my-project -WithDocs
  .\install.ps1 -Global
#>
param(
  [string]$Target,
  [switch]$Global,
  [switch]$WithDocs
)

$ErrorActionPreference = 'Stop'
$kit = $PSScriptRoot
$agentsSrc = Join-Path $kit '.claude\agents'

if (-not $Target -and -not $Global) {
  Write-Host 'Usage: .\install.ps1 -Target <repo path> [-WithDocs]   or   .\install.ps1 -Global'
  exit 1
}

function Copy-Agents([string]$destDir) {
  New-Item -ItemType Directory -Force $destDir | Out-Null
  Get-ChildItem $agentsSrc -Filter 'vibe*.md' | ForEach-Object {
    $dest = Join-Path $destDir $_.Name
    if (Test-Path $dest) { $state = 'updated' } else { $state = 'added  ' }
    Copy-Item $_.FullName $dest -Force
    Write-Host "  agent $state : $dest"
  }
}

function Copy-IfMissing([string]$src, [string]$dest) {
  if (Test-Path $dest) {
    Write-Host "  kept          : $dest (exists, not overwritten)"
    return
  }
  New-Item -ItemType Directory -Force (Split-Path $dest) | Out-Null
  Copy-Item $src $dest
  Write-Host "  added         : $dest"
}

if ($Global) {
  $globalDir = Join-Path $HOME '.claude\agents'
  Write-Host "Installing the Vibe agents globally in $globalDir"
  Copy-Agents $globalDir
  Write-Host ''
  Write-Host 'Each project still needs its own .vibes/ (run with -Target on it).'
  Write-Host 'Cloud sessions only see agents versioned in the repo: prefer -Target for shared repos.'
}

if ($Target) {
  $Target = (Resolve-Path $Target).Path
  Write-Host "Installing the Vibe agents kit in $Target"
  Copy-Agents (Join-Path $Target '.claude\agents')

  foreach ($f in 'STACK.md', 'INVARIANTS.md', 'CONVENTIONS.md') {
    Copy-IfMissing (Join-Path $kit "templates\vibes\$f") (Join-Path $Target ".vibes\$f")
  }
  foreach ($d in 'plans', 'notes', 'audits') {
    $keep = Join-Path $Target ".vibes\$d\.gitkeep"
    if (-not (Test-Path (Join-Path $Target ".vibes\$d"))) {
      New-Item -ItemType Directory -Force (Join-Path $Target ".vibes\$d") | Out-Null
      New-Item -ItemType File $keep | Out-Null
      Write-Host "  added         : $keep"
    }
  }

  if ($WithDocs) {
    Copy-IfMissing (Join-Path $kit 'templates\VISION.md') (Join-Path $Target 'VISION.md')
    Copy-IfMissing (Join-Path $kit 'templates\ARCHITECTURE.md') (Join-Path $Target 'ARCHITECTURE.md')
    $claudeMd = Join-Path $Target 'CLAUDE.md'
    if (Test-Path $claudeMd) {
      Write-Host "  hint          : merge templates\CLAUDE.md (Vibe relay rules) into your existing CLAUDE.md"
    } else {
      Copy-IfMissing (Join-Path $kit 'templates\CLAUDE.md') $claudeMd
    }
  }

  Write-Host ''
  Write-Host 'Checks:'
  $isRepo = Test-Path (Join-Path $Target '.git')
  if ($isRepo) {
    $ErrorActionPreference = 'Continue'   # git writes to stderr on some setups; PS 5.1 would throw under 'Stop'
    foreach ($p in '.claude/agents/vibe.md', '.vibes/STACK.md') {
      git -C $Target check-ignore -q $p 2>$null
      if ($LASTEXITCODE -eq 0) {
        Write-Host "  WARNING       : $p is git-ignored. In .gitignore use '.claude/*' then '!.claude/agents/' (a bare '.claude/' cannot be re-included; cloud sessions need the agents versioned)."
      } else {
        Write-Host "  ok            : $p is not ignored"
      }
    }
    git -C $Target check-ignore -q .claude/worktrees/x 2>$null
    if ($LASTEXITCODE -ne 0) {
      Write-Host "  hint          : add '.claude/worktrees/' to .gitignore (vibe creates per-plan worktrees there)"
    }
    if (-not (Test-Path (Join-Path $Target '.gitattributes'))) {
      Write-Host "  hint          : no .gitattributes -- consider '* text=auto eol=lf' (see $kit\.gitattributes), in its own commit"
    }
  } else {
    Write-Host '  hint          : target is not a git repository (git init first to version .claude/agents and .vibes)'
  }

  Write-Host ''
  Write-Host 'Next steps:'
  Write-Host '  1. Fill .vibes/STACK.md from your CI workflows and rule files (AGENTS.md, CLAUDE.md).'
  Write-Host '  2. Measure the BASELINE (lint / typecheck / tests on the base branch) and write it in STACK.'
  Write-Host '  3. Set the project git identity: git config --local user.email <email>'
  Write-Host '  4. Fill Part B of .vibes/CONVENTIONS.md; keep or trim Part A.'
  Write-Host '  5. Commit .claude/agents and .vibes, then run: claude --agent vibe'
}

exit 0
