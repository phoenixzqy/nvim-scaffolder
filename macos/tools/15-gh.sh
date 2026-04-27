#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
write_banner "GitHub CLI"
brew_install gh "GitHub CLI (gh)"

src="$SCAFFOLDER_ROOT/configs/gh/config.yml"
dst="$HOME/.config/gh/config.yml"
if [[ -f "$src" ]]; then deploy_config "$src" "$dst"; fi

write_warn "Run 'gh auth login' once to authenticate (oauth tokens are never committed to the repo)."
