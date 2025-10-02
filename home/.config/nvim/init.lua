-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
vim.cmd([[
  highlight MiniIndentscopeSymbol guifg=#FE9000 guibg=NONE gui=bold
]])

require("config.odoo_ls")
