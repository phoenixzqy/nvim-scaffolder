#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
write_banner "Python 3"

apt_install python3 "Python 3"
apt_install python3-pip "pip"
apt_install python3-venv "venv"

if has_command python3; then
  write_step "Installing user-level Python packages (pynvim, black, pytest)…"
  for pkg in pynvim black pytest; do
    python3 -m pip install --user --upgrade "$pkg" --quiet --break-system-packages 2>/dev/null \
      || python3 -m pip install --user --upgrade "$pkg" --quiet 2>/dev/null \
      && write_ok "pip --user $pkg" \
      || write_warn "pip install $pkg failed"
  done
else
  write_warn "python3 not on PATH yet; restart your shell and re-run this script."
fi
