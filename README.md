# 🖥️ Neovim One-Click Setup

My personal Neovim configuration — installs Neovim, all plugins, LSP servers, formatters, and config files with a single command.

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

## Quick Install

### macOS

```bash
curl -fsSL <RAW_URL_OF_install-nvim-macos.sh> | bash
```

Or download and run:

```bash
chmod +x install-nvim-macos.sh
./install-nvim-macos.sh
```

### Windows (PowerShell as Admin)

```powershell
irm <RAW_URL_OF_install-nvim-windows.ps1> | iex
```

Or download and run:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
.\install-nvim-windows.ps1
```

## Key Bindings

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
