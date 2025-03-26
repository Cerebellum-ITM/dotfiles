return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    merge_keywords = true,
    highlight = {
      before = "fg",
      keyword = "fg",
      pattern = [[.*<(KEYWORDS)\s*]],
    },
    keywords = {
      HELPERS = { icon = "", color = "#5AA000", alt = { "COMPUTED METHODS", "ACTIONS" } },
      OVERRIDES = { icon = "", color = "#E01800" },
    },
  },
}
