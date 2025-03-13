return {
  "folke/snacks.nvim",
  keys = {
    { "<leader>S", false },
  },
  opts = {
    picker = {
      sources = {
        grep = {
          hidden = true,
          exclude = { "node_modules", ".git", ".venv", "__pycache__", ".vscode", ".mypy_cache" },
        },

        files = {
          hidden = true,
          exclude = { "node_modules", ".git", ".venv", "__pycache__", ".vscode", ".mypy_cache" },
        },
        explorer = {
          hidden = true,
          auto_close = true,
          exclude = { "node_modules", ".git", ".venv", "__pycache__", ".vscode", ".mypy_cache" },
        },
      },
    },
  },
}
