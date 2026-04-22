# 🖥️ Windows Dev-Machine Scaffolder

One-click reproducible setup for a fresh Windows PC. Installs and configures my
whole terminal stack — Neovim, Copilot CLI, Node, Python, Lazygit, Starship,
Windows Terminal, Git, GitHub CLI, PowerShell profile, and more — exactly the
way I like it.

## Quick start (new machine)

```powershell
git clone https://github.com/phoenixzqy/nvim-scaffolder $env:USERPROFILE\workspace\nvim-scaffolder
cd $env:USERPROFILE\workspace\nvim-scaffolder
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
.\install-all.ps1
```

Or run a subset:

```powershell
.\install-all.ps1 -Only nvim,starship,pwsh-profile
.\install-all.ps1 -Skip windows-terminal
.\install-all.ps1 -DryRun
```

## Layout

```
install-all.ps1          # orchestrator — runs tools/*.ps1 in numeric order
capture.ps1              # snapshot live configs from this machine into configs/
lib/common.ps1           # shared helpers (winget, scoop, deploy, backup)
tools/
  00-package-managers.ps1
  10-git.ps1   15-gh.ps1   20-node.ps1   25-python.ps1
  30-cli-tools.ps1   40-fonts.ps1   50-starship.ps1   55-lazygit.ps1
  60-copilot-cli.ps1   70-nvim.ps1   80-windows-terminal.ps1   90-pwsh-profile.ps1
configs/
  nvim/   starship/   windows-terminal/   lazygit/   gh/   pwsh/
```

Each `tools/*.ps1` is **standalone** — run it on its own to (re)install just
that tool. The orchestrator simply runs them in order. Config files live in
`configs/` as real files you can diff, edit, and review in PRs.

## Updating settings

Edit the real config wherever the app lives (e.g. `~/.config/starship.toml`),
then snapshot the change back into this repo and commit:

```powershell
.\capture.ps1
git add configs && git commit -m "tweak: starship palette"
```

## Tools covered

| # | Tool | Winget / source | Config deployed |
|---|------|-----------------|-----------------|
| 00 | winget, scoop (+extras bucket) | built-in / https://get.scoop.sh | — |
| 10 | Git | `Git.Git` | — |
| 15 | GitHub CLI (gh) | `GitHub.cli` | `config.yml` (no tokens) |
| 20 | Node.js LTS + `neovim`, `pnpm` npm globals | `OpenJS.NodeJS.LTS` | — |
| 25 | Python 3.12 + `pynvim`, `black`, `pytest` | `Python.Python.3.12` | — |
| 30 | ripgrep, fd, fzf, bat, zoxide, CMake | winget | — |
| 40 | JetBrainsMono Nerd Font | nerd-fonts release zip (per-user, no admin) | — |
| 50 | Starship prompt | `Starship.Starship` | `~/.config/starship.toml` |
| 55 | Lazygit | scoop `extras/lazygit` | `%APPDATA%\lazygit\config.yml` |
| 60 | GitHub Copilot CLI | `npm i -g @github/copilot` | — |
| 70 | Neovim + plugins | `Neovim.Neovim` + lazy.nvim headless sync | `%LOCALAPPDATA%\nvim\` |
| 80 | Windows Terminal | `Microsoft.WindowsTerminal` | `settings.json` (BlulocoDark + JetBrainsMono NF) |
| 90 | PowerShell profile | — | `$PROFILE` (aliases, starship init, helpers) |

## Notes

- **Idempotent.** Re-running is safe; installers skip packages that are already present.
- **No admin required.** Fonts register per-user; packages install at user scope.
- **Secrets are never committed.** `gh auth` tokens (`hosts.yml`) are deliberately excluded — run `gh auth login` once after install.
- **Backups.** Any existing target config is renamed to `<name>.bak.<timestamp>` before a deploy.

## Neovim details

## What's Included

| Category | Plugins |
|----------|---------|
| **Theme** | kanagawa.nvim (wave) |
| **File Explorer** | nvim-tree.lua + devicons |
| **Fuzzy Finders** | fzf.vim + Telescope (with live-grep-args, fzf-native) |
| **LSP** | mason.nvim + mason-lspconfig + nvim-lspconfig (ts_ls, pyright, lua_ls, html, cssls, jsonls, bashls) |
| **Autocompletion** | nvim-cmp + LuaSnip + friendly-snippets |
| **Syntax** | nvim-treesitter (JS/TS/Python/Lua/HTML/CSS/JSON/YAML/Bash/Markdown/C#) |
| **Statusline** | lualine.nvim + bufferline.nvim |
| **Git** | vim-fugitive + gitsigns.nvim |
| **Formatting** | conform.nvim (black, stylua, shfmt) |
| **Linting** | nvim-lint (ESLint) |
| **Spell Check** | vim-dirtytalk + spelunker.vim |
| **UI** | nvim-scrollbar, nvim-cursorline, colorful-winsep, dropbar.nvim |
| **Markdown** | markdown-preview.nvim |
| **AI** | copilot.vim + CopilotChat.nvim |
| **Classic Vim** | vim-surround, rainbow |

## Testing

The repo ships with two layers of tests.

### 1. Pester unit tests — fast, safe, runs anywhere

```powershell
.\tests\Invoke-Tests.ps1          # pretty output
.\tests\Invoke-Tests.ps1 -CI      # returns non-zero on failure
```

Covers ~60 assertions: every `.ps1` parses, every `tools/*.ps1` dot-sources the shared lib, `Deploy-Config` backs up existing targets, `-Only/-Skip/-DryRun` filters work, captured configs exist, and `gh/config.yml` has no OAuth tokens.

### 2. Windows Sandbox — fresh Windows VM, real install

The only way to truly verify a from-scratch install works is to run it on a fresh Windows box. `tests\sandbox.wsb` spins up an ephemeral, disposable Windows VM that mounts this repo read-only and auto-runs `install-all.ps1` on logon.

One-time setup (elevated PowerShell, then reboot):

```powershell
Enable-WindowsOptionalFeature -Online -FeatureName Containers-DisposableClientVM -All
```

Then just double-click `tests\sandbox.wsb`. The sandbox is destroyed when you close the window, so you can re-run as often as you like with zero state bleed.

### 3. Live idempotency check (on your current machine)

Re-running any `tools/*.ps1` on a machine that already has the tool installed should be a no-op. This is tested explicitly and you can sanity-check on demand:

```powershell
.\tools\10-git.ps1       # prints "Git (already present)"
.\tools\40-fonts.ps1     # prints "JetBrainsMono Nerd Font (already present)"
```

## macOS (nvim only — legacy)

```bash
./install-nvim-macos.sh
```

The older `install-nvim-windows.ps1` at the repo root is kept for compatibility; prefer `install-all.ps1` or `tools/70-nvim.ps1`.

## Neovim key bindings

| Key | Action |
|-----|--------|
| `Ctrl+N` | Toggle file tree |
| `Ctrl+P` | Fuzzy file finder (fzf) |
| `\f` | Ripgrep project-wide search |
| `\ff` | Telescope find files |
| `\fg` | Telescope live grep |
| `\fb` | Telescope buffers |
| `F1-F9` | Go to buffer 1-9 |
| `Shift+←/→` | Cycle buffers |
| `Ctrl+↑/↓/←/→` | Navigate viewports |
| `gd / gr / K` | LSP: definition / references / hover |
| `\rn / \ca` | LSP: rename / code action |
| `\cc` | Toggle Copilot Chat |
| `\mp` | Toggle Markdown preview |

## Notes

- Backs up existing `~/.config/nvim` (macOS) or `%LOCALAPPDATA%\nvim` (Windows) before overwriting
- Installs JetBrainsMono Nerd Font for proper icon rendering
- Leader key is `\` (backslash)
- Requires Neovim 0.11+ for `vim.lsp.config` API
