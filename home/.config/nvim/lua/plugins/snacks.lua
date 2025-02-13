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
        },
        files = {
          hidden = true,
          ignored = { "node_modules", ".git", ".venv", "__pycache__" },
        },
        explorer = {
          hidden = true,
        },
      },
    },
  },
}
