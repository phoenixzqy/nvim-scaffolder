#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
write_banner "Lazygit"

LAZYGIT_VERSION="0.44.1"

if has_command lazygit; then
  write_skip "Lazygit"
else
  local_arch="$ARCH_ALT"  # x86_64 or aarch64
  asset="lazygit_${LAZYGIT_VERSION}_Linux_${local_arch}.tar.gz"
  github_release_install "jesseduffield/lazygit" "$LAZYGIT_VERSION" "$asset" "lazygit"
fi

deploy_config "$SCAFFOLDER_ROOT/configs/lazygit/config.yml" "$HOME/.config/lazygit/config.yml"
