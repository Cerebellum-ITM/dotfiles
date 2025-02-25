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
vim.keymap.set({ "n", "v" }, "dd", '"_dd', opts)
-- Keep last yanked when pasting
vim.keymap.set("v", "p", '"_dP', opts)
vim.keymap.set({ "n", "v" }, "c", '"_c', opts)
-- enable and disable line wrap
vim.keymap.set("n", "<leader>ow", "<cmd>set wrap!<CR>", opts)
-- The original behavior of dd has been restored in other keybiding
vim.keymap.set("n", "<leader>od", "dd", opts)
vim.keymap.set("v", "<leader>od", "d", opts)
