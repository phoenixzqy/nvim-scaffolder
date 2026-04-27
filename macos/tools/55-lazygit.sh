#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
write_banner "Lazygit"
brew_install lazygit "Lazygit"

deploy_config "$SCAFFOLDER_ROOT/configs/lazygit/config.yml" "$HOME/Library/Application Support/lazygit/config.yml"
