#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
write_banner "Ghostty (optional)"

# Ghostty on Linux is optional — skip gracefully if unavailable.
# As of 2025, Ghostty offers official .deb packages for Ubuntu/Debian.

if has_command ghostty; then
  # Try to update via apt if repo is available
  if [[ -f /etc/apt/sources.list.d/ghostty.list ]]; then
    apt_install ghostty "Ghostty"
  else
    write_ok "Ghostty is up to date (manual install)"
  fi
else
  if [[ "$DISTRO_ID" == "ubuntu" || "$DISTRO_ID" == "debian" ]]; then
    # Try the official Ghostty apt repo
    if [[ ! -f /etc/apt/sources.list.d/ghostty.list ]]; then
      write_step "Adding Ghostty apt repository…"
      local keyring_url="https://pkg.ghostty.org/ghostty-apt-keyring.gpg"
      local repo_line="deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/ghostty.gpg] https://pkg.ghostty.org/apt stable main"
      add_apt_repo "ghostty" "$keyring_url" "$repo_line" 2>/dev/null || {
        write_warn "Could not add Ghostty repo — skipping (install manually if desired)."
        deploy_config "$SCAFFOLDER_ROOT/configs/ghostty/config" "$HOME/.config/ghostty/config"
        exit 0
      }
    fi
    apt_install ghostty "Ghostty" 2>/dev/null || {
      write_warn "Ghostty not available via apt — skipping."
      deploy_config "$SCAFFOLDER_ROOT/configs/ghostty/config" "$HOME/.config/ghostty/config"
      exit 0
    }
  else
    write_warn "Ghostty auto-install not supported on $DISTRO_ID. Install manually: https://ghostty.org"
    deploy_config "$SCAFFOLDER_ROOT/configs/ghostty/config" "$HOME/.config/ghostty/config"
    exit 0
  fi
fi

deploy_config "$SCAFFOLDER_ROOT/configs/ghostty/config" "$HOME/.config/ghostty/config"
