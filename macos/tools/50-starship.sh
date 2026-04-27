#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
write_banner "Starship Prompt"
brew_install starship "Starship"

deploy_config "$SCAFFOLDER_ROOT/configs/starship/starship.toml" "$HOME/.config/starship.toml"

write_warn "Ensure your .zshrc contains: eval \"\$(starship init zsh)\""
write_warn "(The tools/90-zsh-profile.sh script handles this automatically.)"
