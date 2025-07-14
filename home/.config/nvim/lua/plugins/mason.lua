return {
  "mason-org/mason.nvim",
  opts = {
    ensure_installed = {
      "ruff",
      "pyright",
      "prettier",
      "docker-compose-language-service",
      "dockerfile-language-server",
      "stylua",
      "shellcheck",
    },
    -- registries = {
    -- "github:mason-org/mason-registry",
    -- "lua:tools.mason-registry",
    -- },
  },
}
