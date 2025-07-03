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
      COMPUTED_METHODS = { icon = "", color = "#C2EABD", alt = { "COMPUTED METHODS" } },
      API = { icon = "", color = "#00D9C0", alt = { "API RESPONE SCHEMAS" } },
      CONTROLLERS = { icon = "", color = "#B7AD99", alt = { "ENDPOINT ROUTERS" } },
      DEPENDENCY = { icon = "", color = "#744899", alt = { "DEPENDENCY DEFINITIONS" } },
      TEXTUAL = { icon = "", color = "#FAFF81", alt = { "TEXTUAL APPLICATION" } },
      ACTIONS = { icon = "", color = "#7EBCE6" },
      CRUD = { icon = "", color = "#FAFF81" },
      PROPS = { icon = "", color = "#FAFF81", alt = { "PROPS EXTENSION" } },
      INHERITED = { icon = "", color = "#F9B5AC", alt = { "INHERITED FUNCTIONS", "FUNCTION PATCHING" } },
      OVERRIDES = { icon = "", color = "#FFC53A" },
      CONSTRAINS = { icon = "", color = "#EE4B6A", alt = { "CONSTRAINS FUNCTIONS" } },
      DELETE = { icon = "", color = "#E01800", alt = { "REMOVE" } },
      DESC = { icon = "", color = "#C2EABD", alt = { "Desc" } },
    },
  },
}
