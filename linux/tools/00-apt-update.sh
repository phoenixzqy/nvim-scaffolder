#!/usr/bin/env bash
# Update apt cache and install essential build tools.
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
write_banner "APT Update + Build Essentials"

ensure_sudo

write_step "Updating apt package cache…"
as_root apt-get update -qq
write_ok "Package cache updated"

# Essential tools needed by later scripts
for pkg in curl wget git unzip build-essential make gcc g++ pkg-config software-properties-common; do
  apt_install "$pkg"
done

write_ok "Base prerequisites ready"
