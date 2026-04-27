#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
write_banner "Neovim + plugins"
brew_install neovim "Neovim"

# Deploy config
src_dir="$SCAFFOLDER_ROOT/configs/nvim"
nvim_dir="$HOME/.config/nvim"

write_step "Deploying Neovim config to $nvim_dir …"
if [[ -d "$nvim_dir" ]]; then backup_path "$nvim_dir" || true; fi
cp -R "$src_dir" "$nvim_dir"
write_ok "Config deployed"

# Plugin bootstrap via lazy.nvim (headless)
if has_command nvim; then
  write_step "Syncing plugins (lazy.nvim headless)…"
  nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
  write_ok "Plugins synced"
else
  write_warn "nvim not on PATH yet; restart your shell and run ':Lazy sync' inside nvim."
fi
