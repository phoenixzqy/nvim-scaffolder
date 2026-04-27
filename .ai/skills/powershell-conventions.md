# Skill: PowerShell Conventions

Use this skill when writing or reviewing PowerShell scripts in this project.

## Required Structure

Every `windows/tools/*.ps1` must follow this structure:

```powershell
#Requires -Version 5.1
. "$PSScriptRoot\..\lib\common.ps1"
Write-Banner "<Section Name>"

# ... tool install and config deployment logic ...
```

## Helper Functions (from `lib/common.ps1`)

| Function | Purpose |
|----------|---------|
| `Write-Banner "Title"` | Section header with box drawing |
| `Write-Step "msg"` | Action being performed (cyan ▸) |
| `Write-Ok "msg"` | Success (green ✓) |
| `Write-Skip "msg"` | Already present (gray •) |
| `Write-Warn2 "msg"` | Warning (yellow ⚠) |
| `Install-WingetPackage -Id "X" -DisplayName "Y"` | Idempotent winget install |
| `Install-ScoopPackage -Name "X" -Bucket "Y"` | Idempotent scoop install |
| `Deploy-Config -Source $src -Target $dst` | Copy config with auto-backup |
| `Backup-Path $path` | Rename existing file to `.bak.<timestamp>` |
| `Ensure-Dir $path` | Create directory if missing |
| `Test-Command "name"` | Check if a command exists on PATH |
| `Refresh-Path` | Reload PATH from registry (picks up new installs) |
| `Get-ScaffolderRoot` | Returns the scaffolder root directory |
| `Ensure-Scoop` | Bootstrap scoop if not installed |
| `Ensure-ScoopBucket -Name "X"` | Add a scoop bucket if missing |

## Style Rules

- Use `$ErrorActionPreference = "Stop"` (set in common.ps1, inherited).
- Prefer `Join-Path` over string concatenation for paths.
- Use `Refresh-Path` after any install that adds to PATH.
- Use `-ErrorAction SilentlyContinue` when checking for optional things.
- Wrap risky operations in `try/catch` and use `Write-Warn2` for failures.
- Never use `Write-Host` directly — use the Write-* helpers for consistency.
- No admin/elevation required — all installs must be per-user.
