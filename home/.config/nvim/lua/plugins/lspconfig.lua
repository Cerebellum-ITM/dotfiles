return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.bashls = opts.servers.bashls or {}
      opts.servers.bashls.filetypes = { "sh", "zsh", "bash" }
      opts.servers.bashls.settings = {
        bash = {
          filetypes = { "sh", "zsh", "bash" },
        },
      }
    end,
  },
}
