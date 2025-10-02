vim.lsp.config["odoo_ls"] = {
  cmd = {
    vim.fn.expand("$HOME/.local/share/nvim/odoo/odoo_ls_server"),
    "--stdlib",
    vim.fn.expand("$HOME/.local/share/nvim/odoo/typeshed/stdlib/"),
  },
  filetypes = { "python", "xml" },
  root_markers = { "odools.toml", ".commitcraft.toml" },
  settings = {
    Odoo = {
      selectedProfile = "main",
    },
  },
}

vim.lsp.enable({ "odoo_ls" })
