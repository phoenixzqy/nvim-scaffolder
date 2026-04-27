#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
write_banner "GitHub Copilot CLI"

if ! has_command npm; then
  write_warn "npm not found — run tools/20-node.sh first."
  exit 1
fi

if npm ls -g --depth=0 2>/dev/null | grep -q "@github/copilot@"; then
  write_skip "@github/copilot"
else
  write_step "Installing @github/copilot via npm…"
  npm install -g "@github/copilot" --silent
  write_ok "Copilot CLI installed (command: copilot)"
fi

write_warn "Run 'copilot' and follow the auth prompt on first launch."
