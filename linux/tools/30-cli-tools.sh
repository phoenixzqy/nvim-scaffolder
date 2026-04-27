#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
write_banner "CLI Tools (rg, fd, fzf, bat, zoxide, cmake)"

# Tools available directly via apt
apt_install ripgrep "ripgrep (rg)"
apt_install fd-find "fd-find"
apt_install fzf "fzf"
apt_install bat "bat"
apt_install cmake "cmake"

# Create compatibility symlinks for tools with different names on Ubuntu
# fd-find installs as 'fdfind', bat installs as 'batcat'
if has_command fdfind && ! has_command fd; then
  ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  write_ok "Symlinked fd → fdfind"
fi

if has_command batcat && ! has_command bat; then
  ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
  write_ok "Symlinked bat → batcat"
fi

# zoxide — install via official script (not always in apt)
if has_command zoxide; then
  write_skip "zoxide"
else
  write_step "Installing zoxide…"
  run_remote_script https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh
  write_ok "Installed zoxide"
fi
