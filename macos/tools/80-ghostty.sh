#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
write_banner "Ghostty"
brew_cask_install ghostty "Ghostty"

deploy_config "$SCAFFOLDER_ROOT/configs/ghostty/config" "$HOME/.config/ghostty/config"
