return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    merge_keywords = true,
    highlight = {
      before = "",
      keyword = "fg",
      pattern = [[.*<(KEYWORDS)\s*]],
      multiline_pattern = "^[^-].*",
    },
    keywords = {
      HELPERS = { icon = "", color = "#f1009a" },
      COMPUTED_METHODS = { icon = "", color = "#5AA000", alt = { "COMPUTED METHODS" } },
      ACTIONS = { icon = "", color = "#7EBCE6" },
      CRUD = { icon = "", color = "#FAFF81" },
      INHERITED = { icon = "", color = "#F9B5AC", alt = { "INHERITED FUNCTIONS" } },
      OVERRIDES = { icon = "", color = "#FFC53A" },
      DELETE = { icon = "", color = "#E01800", alt = { "REMOVE" } },
    },
  },
}
