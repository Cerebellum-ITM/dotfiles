return {
  {
    "whenrow/odoo-ls.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
      local odools = require("odools")
      local h = os.getenv("HOME")
      odools.setup({
        -- mandatory
        odoo_path = h .. "/odoo_base_code/odoo_ce_17",
        python_path = "/usr/bin/python3",

        -- optional
        server_path = h .. "/.local/share/nvim/odoo/odoo_ls_server",
        addons = {
          h .. "/odoo_base_code/odoo_ce_17/addons",
          h .. "/diverza/odoo_develop_pascual/enterprise",
          h .. "/diverza/odoo_develop_pascual/addons",
        },
        additional_stubs = { h .. "/odoo_develop_data/odoo-stubs", h .. "/odoo_develop_data/custom_studs" },
        root_dir = h .. "/diverza/odoo_develop_pascual/addons",
        settings = {
          autoRefresh = true,
          autoRefreshDelay = nil,
          diagMissingImportLevel = "none",
        },
      })
    end,
  },
}
