#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
write_banner "GitHub CLI (gh)"

if has_command gh; then
  write_skip "GitHub CLI"
else
  add_apt_repo "github-cli" \
    "https://cli.github.com/packages/githubcli-archive-keyring.gpg" \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/github-cli.gpg] https://cli.github.com/packages stable main"

  apt_install gh "GitHub CLI"
fi

deploy_config "$SCAFFOLDER_ROOT/configs/gh/config.yml" "$HOME/.config/gh/config.yml"
