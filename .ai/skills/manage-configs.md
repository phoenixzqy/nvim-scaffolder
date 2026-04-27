# Skill: Manage Config Files

Use this skill when adding, updating, or deploying configuration files.

## Where Configs Live

```
windows/configs/<tool>/     # Windows config files
macos/configs/<tool>/       # macOS config files (when added)
```

Config files are **real, committed files** — not templates. They are deployed
verbatim to the target machine.

## Adding a New Config

1. **Place the file** in `<platform>/configs/<tool>/<filename>`.

2. **Deploy it** from the tool's install script:
   ```powershell
   # PowerShell (Windows)
   $src = Join-Path (Get-ScaffolderRoot) "configs\<tool>\<file>"
   $dst = "<target path on the user's machine>"
   Deploy-Config -Source $src -Target $dst
   ```
   ```bash
   # Bash (macOS/Linux)
   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   cp "$SCRIPT_DIR/configs/<tool>/<file>" "$HOME/.config/<tool>/<file>"
   ```

3. **Add capture logic** (Windows only) in `windows/capture.ps1`:
   ```powershell
   Snap "<live config path>" "$root\configs\<tool>\<filename>"
   ```

4. **Add to tests** — update `orchestrator.Tests.ps1` "Captured configs exist"
   section to verify the new file is present.

## Rules

- **No secrets.** Never commit OAuth tokens, API keys, or `hosts.yml` files.
  If a config file normally contains secrets, strip them before committing
  and add a note in the tool script to configure manually.
- **No machine-specific paths.** Use environment variables (`$env:APPDATA`,
  `$HOME`, `$env:LOCALAPPDATA`) instead of hardcoded paths.
- **Diffable formats.** Prefer TOML, YAML, JSON, or plain text. Avoid binary
  config files.
- **Backup before deploy.** Always use `Deploy-Config` (PowerShell) or manual
  backup (Bash) to preserve the user's existing config.

## Updating an Existing Config

### Option A: Edit directly in the repo
Edit the file in `<platform>/configs/<tool>/`, commit, and re-run the tool
script to deploy.

### Option B: Capture from live system (Windows)
1. Make changes in the live app (e.g., Windows Terminal settings).
2. Run `windows/capture.ps1` to snapshot back into the repo.
3. Review `git diff` and commit.

## Current Config Locations (Windows)

| Tool | Repo Path | Deploy Target |
|------|-----------|---------------|
| Starship | `configs/starship/starship.toml` | `~/.config/starship.toml` |
| Windows Terminal | `configs/windows-terminal/settings.json` | `%LOCALAPPDATA%/Packages/Microsoft.WindowsTerminal_.../settings.json` |
| Lazygit | `configs/lazygit/config.yml` | `%APPDATA%/lazygit/config.yml` |
| GitHub CLI | `configs/gh/config.yml` | `%APPDATA%/GitHub CLI/config.yml` |
| PowerShell | `configs/pwsh/Microsoft.PowerShell_profile.ps1` | `$PROFILE` |
| Neovim | `configs/nvim/` | `%LOCALAPPDATA%/nvim/` |
