# ============================================================================
# Neovim One-Click Installer — Windows (PowerShell)
# Installs Neovim + all plugins, LSP servers, formatters, and config files.
# Usage:  irm <gist_raw_url> | iex
#    or:  Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
#         .\install-nvim-windows.ps1
# ============================================================================
#Requires -Version 5.1
$ErrorActionPreference = "Stop"

Write-Host @"
╔══════════════════════════════════════════════╗
║  Neovim Installer — Windows                  ║
╚══════════════════════════════════════════════╝
"@

# ── Helper: refresh PATH in current session ────────────────────────────────
function Refresh-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("Path", "User")
}

# ── Prerequisites: winget ──────────────────────────────────────────────────
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: winget not found. Please install App Installer from the Microsoft Store." -ForegroundColor Red
    exit 1
}

# ── Install Neovim & runtime dependencies ──────────────────────────────────
Write-Host "▸ Installing Neovim and dependencies via winget…"
$packages = @(
    "Neovim.Neovim",
    "BurntSushi.ripgrep.MSVC",
    "junegunn.fzf",
    "sharkdp.fd",
    "OpenJS.NodeJS.LTS",
    "Python.Python.3.12",
    "Git.Git",
    "Kitware.CMake"
)
foreach ($pkg in $packages) {
    Write-Host "  Installing $pkg …"
    winget install --id $pkg --accept-package-agreements --accept-source-agreements --silent 2>$null
}
Refresh-Path

# Ensure Python/Node providers
Write-Host "▸ Installing Python/Node providers…"
try { pip install pynvim 2>$null } catch {}
try { npm install -g neovim 2>$null } catch {}

# Formatters
try { pip install black 2>$null } catch {}

# ── Nerd Font ──────────────────────────────────────────────────────────────
Write-Host "▸ Installing JetBrainsMono Nerd Font…"
$fontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
$fontZip = "$env:TEMP\JetBrainsMono.zip"
$fontDir = "$env:TEMP\JetBrainsMono"
try {
    $userFontDir = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
    New-Item -ItemType Directory -Path $userFontDir -Force | Out-Null
    # Skip if already installed
    $already = Get-ChildItem $userFontDir -Filter "JetBrainsMono*NerdFont*.ttf" -EA SilentlyContinue
    if ($already) {
        Write-Host "  Font already installed — skipping."
    } else {
        Invoke-WebRequest -Uri $fontUrl -OutFile $fontZip -UseBasicParsing
        Expand-Archive -Path $fontZip -DestinationPath $fontDir -Force
        $regPath = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"
        if (-not (Test-Path $regPath)) { New-Item -Path $regPath -Force | Out-Null }
        Get-ChildItem "$fontDir\*.ttf" | ForEach-Object {
            $dest = Join-Path $userFontDir $_.Name
            Copy-Item $_.FullName $dest -Force
            # Register per-user without UAC
            try {
                $fontName = [System.IO.Path]::GetFileNameWithoutExtension($_.Name) + " (TrueType)"
                New-ItemProperty -Path $regPath -Name $fontName -Value $dest -PropertyType String -Force | Out-Null
            } catch {}
        }
        Remove-Item $fontZip, $fontDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "  Font installed (per-user). Set your terminal font to 'JetBrainsMono Nerd Font'."
    }
} catch {
    Write-Host "  ⚠ Could not auto-install font. Download from: https://www.nerdfonts.com/font-downloads" -ForegroundColor Yellow
}

# ── Write config files ─────────────────────────────────────────────────────
$nvimDir = "$env:LOCALAPPDATA\nvim"
Write-Host "▸ Writing Neovim config to $nvimDir …"

# Back up existing config
if (Test-Path $nvimDir) {
    $backup = "$nvimDir.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
    Write-Host "  ⚠ Existing config found — backing up to $backup"
    Move-Item $nvimDir $backup
}

New-Item -ItemType Directory -Path "$nvimDir\lua" -Force | Out-Null

# ── init.lua ───────────────────────────────────────────────────────────────
@'
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Leader key (set before lazy)
vim.g.mapleader = "\\"
vim.g.maplocalleader = "\\"

-- Load plugins
require("lazy").setup("plugins")

-- Load settings and keymaps
require("settings")
require("keymaps")
'@ | Set-Content -Path "$nvimDir\init.lua" -Encoding UTF8

# ── lua/settings.lua ──────────────────────────────────────────────────────
@'
-- Settings ported from .vimrc

local opt = vim.opt

-- fzf layout: full-screen split
vim.g.fzf_layout = { down = "100%" }

-- Rg: preview on top (80%), file list on bottom (20%)
vim.g.fzf_preview_window = { "up,80%", "ctrl-/" }

-- Use ripgrep for fzf :Files (respects .gitignore, includes hidden, excludes .git)
vim.env.FZF_DEFAULT_COMMAND = "rg --files --hidden --glob '!.git'"

-- Syntax and filetype (enabled by default in nvim, but explicit is fine)
vim.cmd("syntax on")
vim.cmd("filetype plugin indent on")

-- Indentation
opt.ignorecase = true
opt.smartcase = true
opt.tabstop = 2
opt.softtabstop = 0
opt.expandtab = true
opt.shiftwidth = 2

-- Line numbers
opt.number = true

-- Whitespace characters
opt.listchars = { tab = "|\\x20" }
opt.list = true
opt.fillchars:append({ vert = "|" })

-- Search
opt.hlsearch = true

-- Sign column (always show for LSP diagnostics & gitsigns)
opt.signcolumn = "yes"

-- Terminal true colors
opt.termguicolors = true

-- Mouse support (all modes)
opt.mouse = "a"
opt.mousemodel = "extend"

-- Swap files directory
local swapdir = vim.fn.expand("$HOME/.local/state/nvim/swap//")
vim.fn.mkdir(swapdir, "p")
opt.directory = swapdir

-- Auto-reload external changes
opt.autoread = true
opt.updatetime = 1000

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  callback = function()
    local mode = vim.fn.mode()
    if not mode:match("[crR!t]") and vim.fn.getcmdwintype() == "" then
      vim.cmd("checktime")
    end
  end,
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
  pattern = "*",
  callback = function()
    vim.api.nvim_echo({ { "File changed on disk. Buffer reloaded.", "WarningMsg" } }, true, {})
  end,
})

-- JavaScript JSDoc highlighting
vim.g.javascript_plugin_jsdoc = 1

-- Inline diagnostics (like VSCode)
vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
    spacing = 2,
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})
'@ | Set-Content -Path "$nvimDir\lua\settings.lua" -Encoding UTF8

# ── lua/keymaps.lua ───────────────────────────────────────────────────────
@'
-- Keymaps ported from .vimrc

local map = vim.keymap.set

-- Viewport navigation (Ctrl+Arrow)
map("n", "<C-Up>", "<C-W><C-K>", { desc = "Move to upper viewport" })
map("n", "<C-Down>", "<C-W><C-J>", { desc = "Move to lower viewport" })
map("n", "<C-Left>", "<C-W><C-H>", { desc = "Move to left viewport" })
map("n", "<C-Right>", "<C-W><C-L>", { desc = "Move to right viewport" })

-- Go to buffer 1-9 (F1-F9) via bufferline
for i = 1, 9 do
  map("n", "<F" .. i .. ">", "<cmd>BufferLineGoToBuffer " .. i .. "<CR>", { desc = "Go to buffer " .. i })
end

-- Buffer navigation (Shift+Arrow)
map("n", "<S-Right>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
map("n", "<S-Left>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })

-- Close current buffer without closing the window
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Close buffer" })

-- Ripgrep search (leader+f as project-wide find)
map("n", "<leader>f", "<cmd>Rg<CR>", { desc = "Rg search (project-wide find)" })

-- File finder: Ctrl+P uses fzf :Files for VS Code-like fuzzy search
map("n", "<C-p>", "<cmd>Files<CR>", { desc = "Fuzzy file finder (fzf)" })

-- Disable Ex mode and Ctrl+S
map("n", "Q", "<nop>")
map("n", "<C-s>", "<nop>")

-- Cmd+C to copy to system clipboard (visual mode)
map("v", "<D-c>", '"+y', { desc = "Copy to system clipboard" })
map("n", "<D-c>", '"+yy', { desc = "Copy line to system clipboard" })

-- Option+Left/Right to navigate by word (VS Code style)
map({'n', 'v'}, '<A-Left>', 'b', { desc = "Move word left" })
map({'n', 'v'}, '<A-Right>', 'w', { desc = "Move word right" })
map('i', '<A-Left>', '<C-o>b', { desc = "Move word left" })
map('i', '<A-Right>', '<C-o>w', { desc = "Move word right" })
map({'n', 'v'}, '<M-b>', 'b', { desc = "Move word left" })
map({'n', 'v'}, '<M-f>', 'w', { desc = "Move word right" })
map('i', '<M-b>', '<C-o>b', { desc = "Move word left" })
map('i', '<M-f>', '<C-o>w', { desc = "Move word right" })

-- Option/Ctrl+Backspace to delete word backward (VS Code style)
map('i', '<A-BS>', '<C-w>', { desc = "Delete word backward" })
map('i', '<C-BS>', '<C-w>', { desc = "Delete word backward" })
map('i', '<M-BS>', '<C-w>', { desc = "Delete word backward" })
-- Option/Ctrl+Delete to delete word forward (VS Code style)
map('i', '<A-Del>', '<C-o>dw', { desc = "Delete word forward" })
map('i', '<C-Del>', '<C-o>dw', { desc = "Delete word forward" })
map('i', '<M-d>', '<C-o>dw', { desc = "Delete word forward" })
'@ | Set-Content -Path "$nvimDir\lua\keymaps.lua" -Encoding UTF8

# ── lua/plugins.lua ───────────────────────────────────────────────────────
@'
return {
  -- ==========================================
  -- Theme
  -- ==========================================
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    config = function()
      require("kanagawa").setup({})
      vim.cmd("colorscheme kanagawa-wave")
    end,
  },

  -- ==========================================
  -- File explorer
  -- ==========================================
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = { { "<C-n>", "<cmd>NvimTreeToggle<CR>", desc = "Toggle file tree" } },
    cmd = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeFindFile" },
    config = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      require("nvim-tree").setup({
        view = { width = 30 },
        sync_root_with_cwd = true,
        respect_buf_cwd = true,
        update_focused_file = {
          enable = true,
          update_root = true,
        },
        git = { enable = true, ignore = false },
        renderer = {
          highlight_git = "name",
          icons = {
            glyphs = {
              folder = { arrow_closed = "+", arrow_open = "-" },
            },
          },
        },
        filters = { dotfiles = false, git_ignored = false },
      })
      vim.api.nvim_set_hl(0, "NvimTreeGitIgnoredHL", { fg = "#6a6a6a", italic = true })
    end,
  },

  -- ==========================================
  -- Fuzzy finders
  -- ==========================================
  { "junegunn/fzf", build = ":call fzf#install()" },
  { "junegunn/fzf.vim", dependencies = { "junegunn/fzf" } },

  -- Telescope (LSP-aware fuzzy finder)
  {
    "nvim-telescope/telescope.nvim",
    branch = "master",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-live-grep-args.nvim",
    },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
      { "<leader>fg", function() require("telescope").extensions.live_grep_args.live_grep_args() end, desc = "Live grep (with args)" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Help tags" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<CR>", desc = "Document symbols" },
      { "<leader>fw", "<cmd>Telescope lsp_workspace_symbols<CR>", desc = "Workspace symbols" },
    },
    config = function()
      local telescope = require("telescope")
      local lga_actions = require("telescope-live-grep-args.actions")
      telescope.setup({
        defaults = {
          layout_strategy = "vertical",
          layout_config = {
            vertical = {
              preview_cutoff = 0,
              preview_height = 0.7,
              mirror = true,
            },
            width = 0.95,
            height = 0.95,
          },
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
            "--no-ignore-vcs",
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            no_ignore = true,
          },
        },
        extensions = {
          live_grep_args = {
            auto_quoting = true,
            mappings = {
              i = {
                ["<C-k>"] = lga_actions.quote_prompt(),
                ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
              },
            },
            vimgrep_arguments = {
              "rg",
              "--color=never",
              "--no-heading",
              "--with-filename",
              "--line-number",
              "--column",
              "--smart-case",
              "--hidden",
              "--no-ignore-vcs",
            },
          },
        },
      })
      telescope.load_extension("fzf")
      telescope.load_extension("live_grep_args")
    end,
  },

  -- ==========================================
  -- LSP
  -- ==========================================
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    config = function()
      require("mason").setup()
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "ts_ls",
          "pyright",
          "lua_ls",
          "html",
          "cssls",
          "jsonls",
          "bashls",
        },
        automatic_installation = true,
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, opts)
          vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
          vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
          vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
        end,
      })

      local servers = {
        ts_ls = {},
        pyright = {},
        html = {},
        cssls = {},
        jsonls = {},
        bashls = {},
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
              workspace = { checkThirdParty = false },
            },
          },
        },
      }

      for server, opts in pairs(servers) do
        opts.capabilities = capabilities
        vim.lsp.config(server, opts)
      end
      vim.lsp.enable(vim.tbl_keys(servers))
    end,
  },

  -- ==========================================
  -- Autocompletion
  -- ==========================================
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
        }, {
          { name = "buffer" },
        }),
      })
    end,
  },

  -- ==========================================
  -- Treesitter (syntax highlighting & more)
  -- ==========================================
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = {
          "javascript", "typescript", "tsx", "python", "lua",
          "html", "css", "json", "yaml", "bash", "markdown",
          "c_sharp", "vim", "vimdoc", "regex",
        },
      })
    end,
  },

  -- ==========================================
  -- Statusline & Bufferline
  -- ==========================================
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    config = function()
      require("lualine").setup({
        options = {
          theme = "auto",
          section_separators = "",
          component_separators = "|",
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { "filename" },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },

  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    config = function()
      require("bufferline").setup({
        options = {
          diagnostics = "nvim_lsp",
          offsets = {
            { filetype = "NvimTree", text = "Explorer", text_align = "center" },
          },
          show_buffer_close_icons = false,
          show_close_icon = false,
        },
      })
    end,
  },

  -- ==========================================
  -- Git
  -- ==========================================
  { "tpope/vim-fugitive" },

  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "│" },
          change = { text = "│" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
        },
        current_line_blame = true,
      })
    end,
  },

  -- ==========================================
  -- Formatting (auto format-on-save)
  -- ==========================================
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          python = { "black" },
          lua = { "stylua" },
          sh = { "shfmt" },
        },
        format_on_save = {
          timeout_ms = 2000,
          lsp_format = "fallback",
        },
      })
    end,
  },

  -- ==========================================
  -- Linting (ESLint auto-fix on save)
  -- ==========================================
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        javascript = { "eslint" },
        javascriptreact = { "eslint" },
        typescript = { "eslint" },
        typescriptreact = { "eslint" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },

  -- ==========================================
  -- Spell checking
  -- ==========================================
  {
    "psliwka/vim-dirtytalk",
    build = ":DirtytalkUpdate",
    init = function()
      vim.opt.spelllang:append("programming")
    end,
  },

  {
    "kamykn/spelunker.vim",
    event = { "BufReadPost", "BufNewFile" },
    init = function()
      vim.g.spelunker_check_type = 2
      vim.g.spelunker_highlight_type = 2
      vim.opt.spell = false
    end,
    config = function()
      vim.cmd("highlight SpelunkerSpellBad cterm=undercurl gui=undercurl guisp=#7E9CD8")
      vim.cmd("highlight SpelunkerComplexOrCompoundWord cterm=undercurl gui=undercurl guisp=#957FB8")
    end,
  },

  -- ==========================================
  -- UI Enhancements
  -- ==========================================
  {
    "petertriho/nvim-scrollbar",
    event = "VeryLazy",
    config = function()
      require("scrollbar").setup({
        handle = { blend = 30 },
        marks = {
          Search = { color = "#ff9e64" },
          Error = { color = "#db4b4b" },
          Warn = { color = "#e0af68" },
          Info = { color = "#0db9d7" },
          Hint = { color = "#1abc9c" },
          Misc = { color = "#9d7cd8" },
          GitAdd = { color = "#449dab" },
          GitChange = { color = "#6183bb" },
          GitDelete = { color = "#914c54" },
        },
      })
      require("scrollbar.handlers.gitsigns").setup()
    end,
    dependencies = { "lewis6991/gitsigns.nvim" },
  },

  {
    "yamatsum/nvim-cursorline",
    event = "VeryLazy",
    config = function()
      require("nvim-cursorline").setup({
        cursorline = { enable = true, timeout = 500, number = false },
        cursorword = { enable = true, min_length = 3, hl = { underline = true } },
      })
    end,
  },

  {
    "nvim-zh/colorful-winsep.nvim",
    event = "WinNew",
    config = function()
      require("colorful-winsep").setup({})
    end,
  },

  {
    "Bekaboo/dropbar.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("dropbar").setup({})
    end,
  },

  -- ==========================================
  -- Markdown Preview
  -- ==========================================
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", desc = "Toggle Markdown Preview" },
    },
  },

  -- ==========================================
  -- Carried over from Vim
  -- ==========================================
  { "tpope/vim-surround" },
  {
    "luochen1990/rainbow",
    init = function()
      vim.g.rainbow_active = 1
    end,
  },

  -- ==========================================
  -- Copilot & CopilotChat
  -- ==========================================
  { "github/copilot.vim" },

  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "github/copilot.vim" },
      { "nvim-lua/plenary.nvim" },
    },
    build = "make tiktoken",
    opts = {
      show_help = true,
      window = {
        layout = "vertical",
        width = 0.4,
      },
    },
    keys = {
      { "<leader>cc", "<cmd>CopilotChatToggle<CR>", desc = "Toggle Copilot Chat" },
      { "<leader>ce", "<cmd>CopilotChatExplain<CR>", mode = "v", desc = "Explain selection" },
      { "<leader>cr", "<cmd>CopilotChatReview<CR>", mode = "v", desc = "Review selection" },
      { "<leader>cf", "<cmd>CopilotChatFix<CR>", mode = "v", desc = "Fix selection" },
      { "<leader>co", "<cmd>CopilotChatOptimize<CR>", mode = "v", desc = "Optimize selection" },
      { "<leader>ct", "<cmd>CopilotChatTests<CR>", mode = "v", desc = "Generate tests" },
    },
    cmd = {
      "CopilotChat",
      "CopilotChatToggle",
      "CopilotChatExplain",
      "CopilotChatReview",
      "CopilotChatFix",
      "CopilotChatOptimize",
      "CopilotChatTests",
    },
  },
}
'@ | Set-Content -Path "$nvimDir\lua\plugins.lua" -Encoding UTF8

# ── Bootstrap plugins ─────────────────────────────────────────────────────
Write-Host "▸ Bootstrapping plugins (lazy.nvim will clone everything)…"
Refresh-Path
try {
    & nvim --headless "+Lazy! sync" +qa 2>$null
} catch {
    Write-Host "  ⚠ Plugin sync may need a manual 'nvim' launch to complete." -ForegroundColor Yellow
}

Write-Host @"

╔══════════════════════════════════════════════╗
║  ✅ Done! Launch nvim to enjoy your setup.   ║
║  Tip: Set your terminal font to              ║
║       JetBrainsMono Nerd Font for icons.     ║
╚══════════════════════════════════════════════╝
"@
