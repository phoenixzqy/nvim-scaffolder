# Skill: Add a macOS/Linux Tool

Use this skill when adding a new tool to the macOS or Linux scaffolder.

## Steps

1. **Create the install script** under `macos/tools/` or `linux/tools/`.
   The script must source the shared lib and use its helpers:

   ```bash
   #!/usr/bin/env bash
   source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
   write_banner "<Tool Name>"

   # macOS: use brew helpers
   brew_install <formula> "<Display Name>"
   # OR for casks:
   brew_cask_install <cask> "<Display Name>"

   # Linux: use apt helper
   apt_install <package> "<Display Name>"
   # OR for tools not in apt:
   github_release_install "owner/repo" "version" "asset.tar.gz" "binary"

   # Deploy config if needed:
   deploy_config "$SCAFFOLDER_ROOT/configs/<tool>/config" "$HOME/.config/<tool>/config"
   ```

2. **Add config files** (if any) to `<platform>/configs/<tool>/`.
   Keep them as real, diffable files.

3. **Add a capture rule** in `capture.sh` to snapshot the config back.

4. **Verify**:
   - Script runs without errors on a fresh machine.
   - Re-run is safe (idempotent).
   - `bash -n <script>` passes syntax check.
   - No secrets or machine-specific absolute paths are committed.

## Conventions

- Use `#!/usr/bin/env bash` — common.sh handles `set -euo pipefail`.
- Source `lib/common.sh` and use its output helpers (`write_banner`, `write_step`, etc.).
- Use `brew_install`/`brew_cask_install` (macOS) or `apt_install`/`as_root` (Linux).
- For Linux tools not in apt, use `github_release_install` or `curl` installers.
- Back up existing configs via `deploy_config` (handles backup automatically).
- Keep scripts standalone — a user should be able to run a single script
  without the orchestrator.
