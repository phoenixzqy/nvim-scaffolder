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
