#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
write_banner "Starship Prompt"

if has_command starship; then
  write_skip "Starship"
else
  write_step "Installing Starship via official installer…"
  local tmp
  tmp="$(mktemp)"
  if ! curl -sS -o "$tmp" https://starship.rs/install.sh; then
    rm -f "$tmp"
    write_warn "Failed to download Starship installer"
    exit 1
  fi
  sh "$tmp" --yes --bin-dir "$HOME/.local/bin"
  rm -f "$tmp"
  write_ok "Starship installed"
fi

deploy_config "$SCAFFOLDER_ROOT/configs/starship/starship.toml" "$HOME/.config/starship.toml"

write_warn "Ensure your .zshrc contains: eval \"\$(starship init zsh)\""
write_warn "(The tools/90-zsh-profile.sh script handles this automatically.)"
