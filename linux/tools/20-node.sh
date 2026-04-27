#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
write_banner "Node.js (LTS)"

if has_command node; then
  write_skip "Node.js"
else
  # Install via NodeSource (LTS = 22.x as of 2025)
  if [[ ! -f /etc/apt/sources.list.d/nodesource.list ]]; then
    write_step "Adding NodeSource repository…"
    curl -fsSL https://deb.nodesource.com/setup_lts.x | as_root bash -
    write_ok "NodeSource repo added"
  fi
  apt_install nodejs "Node.js LTS"
fi

# npm global installs: use ~/.local prefix to avoid sudo
if has_command npm; then
  npm config set prefix "$HOME/.local" 2>/dev/null || true

  write_step "Installing global npm packages (neovim provider, pnpm)…"
  for pkg in neovim pnpm; do
    npm install -g "$pkg" --silent 2>/dev/null && write_ok "npm -g $pkg" || write_warn "npm install -g $pkg failed"
  done
else
  write_warn "npm not on PATH yet; restart your shell and re-run this script."
fi
