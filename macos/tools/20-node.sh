#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
write_banner "Node.js (LTS)"
brew_install node "Node.js LTS"

if has_command npm; then
  write_step "Installing global npm packages (neovim provider, pnpm)…"
  for pkg in neovim pnpm; do
    npm install -g "$pkg" --silent 2>/dev/null && write_ok "npm -g $pkg" || write_warn "npm install -g $pkg failed"
  done
else
  write_warn "npm not on PATH yet; restart your shell and re-run this script."
fi
