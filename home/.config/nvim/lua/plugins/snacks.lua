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
        },
        explorer = {
          hidden = true,
        },
      },
    },
  },
}
