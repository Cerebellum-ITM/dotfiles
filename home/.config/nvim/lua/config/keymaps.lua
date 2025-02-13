-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<Tab>", ">>", { desc = "Indent line" })
vim.keymap.set("n", "<S-Tab>", "<<", { desc = "Unindent line" })
vim.keymap.set("n", "<C-c>", "<Plug>(comment_toggle_linewise_current)", { desc = "Comment current line" })
vim.keymap.set("n", "<S-Up>", "<cmd>m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("n", "<S-Down>", "<cmd>m .+1<CR>==", { desc = "Move line down" })

-- For conciseness
local opts = { noremap = true, silent = true }

-- delete single character without copying into register
vim.keymap.set({ "n", "v" }, "x", '"_x', opts)
-- Keep last yanked when pasting
vim.keymap.set("v", "p", '"_dP', opts)
