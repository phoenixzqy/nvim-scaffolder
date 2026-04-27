#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
write_banner "CLI Tools (rg, fd, fzf, bat, zoxide, cmake)"

for pkg in ripgrep fd fzf bat zoxide cmake; do
  brew_install "$pkg"
done
