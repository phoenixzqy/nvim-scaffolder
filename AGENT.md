# AGENT.md — Project Instructions for AI Agents

> Automatically loaded by GitHub Copilot coding agent and Copilot CLI.
> Also referenced from `.github/copilot-instructions.md` (VS Code Copilot)
> and `CLAUDE.md` (Claude Code).

## Project Overview

**dev-scaffolder** is a one-click, idempotent dev-machine setup tool. It installs
CLI tools, deploys config files, and configures the terminal environment from
scratch. Platform-specific code lives in `windows/` and `macos/`.

## Repository Layout

```
windows/                    # Windows scaffolder (PowerShell)
  install-all.ps1           #   orchestrator — runs tools/*.ps1 in numeric order
  capture.ps1               #   snapshot live configs back into configs/
  lib/common.ps1            #   shared helpers (winget, scoop, deploy, backup)
  tools/NN-<name>.ps1       #   one script per tool, standalone & idempotent
  configs/<tool>/           #   config files deployed to their target locations
  tests/                    #   Pester 5 tests + Windows Sandbox .wsb

macos/                      # macOS scaffolder (Bash)
  install-nvim.sh           #   standalone Neovim installer

.ai/skills/                 # Reusable LLM skill prompts (see below)
```

## Conventions

### PowerShell (Windows)

- Every `tools/*.ps1` script **must** dot-source `"$PSScriptRoot\..\lib\common.ps1"` on line 2.
- Scripts are named `NN-<tool>.ps1` where NN is a two-digit sort order.
- Use `Install-WingetPackage` or `Install-ScoopPackage` from `lib/common.ps1`
  for idempotent installs — never raw `winget install` / `scoop install`.
- Use `Deploy-Config -Source ... -Target ...` to place config files (handles
  backup of existing targets automatically).
- Use `Write-Banner`, `Write-Step`, `Write-Ok`, `Write-Skip`, `Write-Warn2`
  for consistent output.
- All scripts must be `#Requires -Version 5.1`.
- Scripts must be idempotent — re-running on a machine that already has the
  tool installed should be a no-op (print "already present" and return).

### Bash (macOS / Linux)

- Scripts must start with `#!/usr/bin/env bash` and `set -euo pipefail`.
- Use Homebrew (`brew install`) for macOS package management.
- Back up existing configs before overwriting.
- Print status messages with `echo "▸ ..."` for actions.

### Config Files

- Config files live in `<platform>/configs/<tool>/` as real, diffable files.
- Never commit secrets, tokens, or machine-specific paths (like absolute home dirs).
- Use `capture.ps1` (Windows) to snapshot live configs back into the repo.

### Testing

- Windows Pester tests live in `windows/tests/` and require Pester 5+.
- Every `.ps1` file must parse without syntax errors.
- Every `tools/*.ps1` must dot-source `lib/common.ps1`.
- Run tests: `windows/tests/Invoke-Tests.ps1`

## Skills

Reusable skill prompts are stored in `.ai/skills/`. Reference them when
performing common tasks:

| Skill | File | Use When |
|-------|------|----------|
| Add Windows Tool | `.ai/skills/add-windows-tool.md` | Adding a new tool to the Windows scaffolder |
| Add macOS/Linux Tool | `.ai/skills/add-unix-tool.md` | Adding a new tool to the macOS or Linux scaffolder |
| PowerShell Conventions | `.ai/skills/powershell-conventions.md` | Writing or reviewing PowerShell scripts |
| Bash Conventions | `.ai/skills/bash-conventions.md` | Writing or reviewing Bash scripts |
| Manage Configs | `.ai/skills/manage-configs.md` | Adding, updating, or deploying config files |

## Do's and Don'ts

- **Do** keep scripts idempotent and standalone.
- **Do** use the helper functions in `lib/common.ps1` instead of raw commands.
- **Do** back up existing configs before overwriting.
- **Do** run `windows/tests/Invoke-Tests.ps1` after changes.
- **Don't** commit secrets, OAuth tokens, or API keys.
- **Don't** require admin/elevated permissions — use per-user installs.
- **Don't** add tools that can't be installed silently/unattended.
