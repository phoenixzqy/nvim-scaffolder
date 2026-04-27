#!/usr/bin/env bash
# Ensure Homebrew is installed.
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
write_banner "Homebrew"
ensure_brew
write_ok "Homebrew ready"
