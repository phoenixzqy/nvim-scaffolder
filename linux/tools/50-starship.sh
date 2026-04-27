#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
write_banner "Starship Prompt"

if has_command starship; then
  write_skip "Starship"
else
  write_step "Installing Starship via official installer…"
  curl -sS https://starship.rs/install.sh | sh -s -- --yes --bin-dir "$HOME/.local/bin"
  write_ok "Starship installed"
fi

deploy_config "$SCAFFOLDER_ROOT/configs/starship/starship.toml" "$HOME/.config/starship.toml"

write_warn "Ensure your .zshrc contains: eval \"\$(starship init zsh)\""
write_warn "(The tools/90-zsh-profile.sh script handles this automatically.)"
