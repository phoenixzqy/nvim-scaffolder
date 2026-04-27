#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
write_banner "Node.js (nvm + LTS)"

# ── Install nvm via official installer ─────────────────────────────────────
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
  write_step "Installing nvm…"
  run_remote_script "https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh"
  write_ok "nvm installed"
else
  write_skip "nvm"
fi

# Load nvm into the current shell
load_nvm

# ── Install Node.js LTS via nvm ───────────────────────────────────────────
write_step "Installing Node.js LTS via nvm…"
nvm install --lts
nvm alias default lts/* 2>/dev/null
write_ok "Node.js LTS active (nvm)"

if has_command npm; then
  write_step "Installing global npm packages (neovim provider, pnpm)…"
  for pkg in neovim pnpm; do
    npm install -g "$pkg" --silent 2>/dev/null && write_ok "npm -g $pkg" || write_warn "npm install -g $pkg failed"
  done
else
  write_warn "npm not on PATH yet; restart your shell and re-run this script."
fi
