-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<Tab>", ">>", { desc = "Indent line" })
vim.keymap.set("n", "<S-Tab>", "<<", { desc = "Unindent line" })
vim.keymap.set("n", "<C-c>", "<Plug>(comment_toggle_linewise_current)", { desc = "Comment current line" })
vim.keymap.set("n", "<S-Up>", ":m .-1<CR>==", { desc = "Move line up" })
vim.keymap.set("n", "<S-Down>", ":m .+1<CR>==", { desc = "Move line down" })
