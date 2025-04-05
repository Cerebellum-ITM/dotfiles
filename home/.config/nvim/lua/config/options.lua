-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.o.tabstop = 4 -- A Tab character will be 4 spaces wide.
vim.o.shiftwidth = 4 -- Indentation levels will be 4 spaces.
vim.o.softtabstop = 4 -- Tab key inserts 4 spaces.
vim.o.expandtab = true -- Convert tabs to spaces.
vim.o.clipboard = "unnamedplus" -- Sync clipboard between OS and Neovim. (default: '')
vim.opt.spelllang = "en_us,es_mx"
vim.opt.guicursor = {
  "i:ver25",
  "a:blinkon100",
}
