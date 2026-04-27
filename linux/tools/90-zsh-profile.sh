#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
write_banner "Zsh + Oh My Zsh"

# Install zsh if not present
if has_command zsh; then
  write_skip "zsh"
else
  apt_install zsh "Zsh"
fi

# Install Oh My Zsh (idempotent — skips if already installed)
if [[ -d "$HOME/.oh-my-zsh" ]]; then
  write_skip "Oh My Zsh"
else
  write_step "Installing Oh My Zsh…"
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  write_ok "Oh My Zsh installed"
fi

# Install popular plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
  write_step "Installing zsh-autosuggestions…"
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  write_ok "zsh-autosuggestions installed"
else
  write_skip "zsh-autosuggestions"
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
  write_step "Installing zsh-syntax-highlighting…"
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
  write_ok "zsh-syntax-highlighting installed"
else
  write_skip "zsh-syntax-highlighting"
fi

# Deploy .zshrc
deploy_config "$SCAFFOLDER_ROOT/configs/zsh/.zshrc" "$HOME/.zshrc"

# Offer to change default shell to zsh
current_shell="$(basename "$SHELL")"
if [[ "$current_shell" != "zsh" ]]; then
  write_step "Changing default shell to zsh…"
  chsh -s "$(command -v zsh)" 2>/dev/null || {
    write_warn "Could not change shell automatically. Run: chsh -s \$(which zsh)"
  }
fi

write_warn "Restart your shell (or run 'source ~/.zshrc') to activate."
