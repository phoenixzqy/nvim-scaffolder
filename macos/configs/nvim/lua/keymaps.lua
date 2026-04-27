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
