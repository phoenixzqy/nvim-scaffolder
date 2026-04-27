#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
write_banner "Git"
apt_install git "Git"

# ── Git aliases ──────────────────────────────────────────────────────────
write_step "Configuring Git aliases…"

git config --global alias.l 'log --pretty=format:"%C(yellow)%h\ %ad%Cred%d\ %Creset%s%Cblue\ [%cn]" --decorate --date=short'
git config --global alias.a 'add'
git config --global alias.ap 'add -p'
git config --global alias.c 'commit --verbose'
git config --global alias.ca 'commit -a --verbose'
git config --global alias.cm 'commit -m'
git config --global alias.cam 'commit -a -m'
git config --global alias.m 'commit --amend --verbose'
git config --global alias.discard 'checkout -- .'
git config --global alias.d 'diff'
git config --global alias.ds 'diff --stat'
git config --global alias.dc 'diff --cached'
git config --global alias.s 'status'
git config --global alias.co 'checkout'
git config --global alias.cob 'checkout -b'
git config --global alias.pon 'push -u origin'
git config --global alias.rbs '!echo "[fetching...]"; git fetch; echo "[pull and rebasing...]"; git pull origin master --rebase'
git config --global alias.gbr '!git checkout master && git branch -D $(git branch | grep -v "master")'
git config --global alias.bclear '!git branch | grep -v "master" | xargs git branch -D'
git config --global alias.graph 'log --graph --date-order -C -M --pretty=format:"<%h> %ad [%an] %Cgreen%d%Creset %s" --all --date=short'
git config --global alias.b "!git for-each-ref --sort='-authordate' --format='%(authordate)%09%(objectname:short)%09%(refname)' refs/heads | sed -e 's-refs/heads/--'"
git config --global alias.upsub '!f() { cd $1 && git checkout master && git pull && git submodule update --init --recursive; }; f'
git config --global alias.subup "!git submodule foreach 'git fetch origin --tags; git checkout master; git pull --rebase' && git pull && git submodule update --init --recursive"
git config --global alias.la '!git config -l | grep alias | cut -c 7-'

write_ok "Git aliases configured"
