# Skill: Bash Conventions

Use this skill when writing or reviewing Bash scripts in this project.

## Required Structure

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "╔══════════════════════════════════════════════╗"
echo "║  <Script Title>                               ║"
echo "╚══════════════════════════════════════════════╝"

# ... installation and config logic ...
```

## Conventions

### Error Handling
- Always use `set -euo pipefail` — fail fast on errors.
- Use `|| true` only for commands where failure is expected and acceptable
  (e.g., `brew install <pkg> || true` when it may already be installed).

### Output
- `echo "▸ <action>…"` — action being performed.
- `echo "  ✓ <result>"` — success.
- `echo "  ⚠ <warning>"` — warning (non-fatal).

### Package Management
- **macOS**: Use Homebrew (`brew install`, `brew install --cask`).
- **Linux**: Use the distro package manager (`apt`, `dnf`, `pacman`) or
  direct downloads when no package exists.
- Check prerequisites with `command -v <tool> &>/dev/null`.

### Config Deployment
- Back up existing configs before overwriting:
  ```bash
  if [[ -d "$TARGET" ]]; then
    mv "$TARGET" "$TARGET.bak.$(date +%Y%m%d%H%M%S)"
  fi
  ```
- Use `mkdir -p` to create target directories.
- Use `cp -r` for directory copies.

### Paths
- Use `$HOME` instead of `~` in scripts (tilde doesn't expand in all contexts).
- Use `"$SCRIPT_DIR"` pattern for relative paths:
  ```bash
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  ```

### Security
- Never commit secrets, tokens, or credentials.
- Never hardcode machine-specific paths.
- Use `curl -fsSL` for downloads (fail silently on HTTP errors, follow redirects).
