# Skill: Add a macOS/Linux Tool

Use this skill when adding a new tool to the macOS or Linux scaffolder.

## Steps

1. **Create or update the install script** under `macos/` (or `linux/` when
   that directory is added). The script must:

   ```bash
   #!/usr/bin/env bash
   set -euo pipefail

   echo "▸ Installing <tool>…"

   # macOS: use Homebrew
   brew install <formula>
   # OR for casks:
   brew install --cask <cask>

   # Deploy config if needed:
   CONFIG_DIR="$HOME/.config/<tool>"
   if [[ -d "$CONFIG_DIR" ]]; then
     BACKUP="$CONFIG_DIR.bak.$(date +%Y%m%d%H%M%S)"
     echo "  ⚠ Backing up $CONFIG_DIR → $BACKUP"
     mv "$CONFIG_DIR" "$BACKUP"
   fi
   mkdir -p "$CONFIG_DIR"
   cp -r configs/<tool>/* "$CONFIG_DIR/"
   echo "  ✓ Config deployed"
   ```

2. **Add config files** (if any) to `macos/configs/<tool>/` (or alongside the
   script). Keep them as real, diffable files.

3. **Verify**:
   - Script runs without errors on a fresh machine.
   - Re-run is safe (idempotent — `brew install` is already idempotent).
   - No secrets or machine-specific absolute paths are committed.

## Conventions

- Use `#!/usr/bin/env bash` and `set -euo pipefail`.
- Print status with `echo "▸ ..."` for actions, `echo "  ✓ ..."` for success.
- Back up existing configs before overwriting.
- Use Homebrew for macOS. For Linux, prefer the distro package manager or
  direct downloads.
- Keep scripts standalone — a user should be able to run a single script
  without the orchestrator.
