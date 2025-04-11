local wk = require("which-key")
wk.add({
  { "gs", group = "splitjoin", icon = "" },
  { "gsj", "<cmd>MiniSplitjoinToggle<CR>", desc = "Toggle Split/Join", icon = { icon = "", color = "orange" } },
  { "gss", "<cmd>MiniSplitjoinSplit<CR>", desc = "Split", icon = "󰉸" },
  { "gsJ", "<cmd>MiniSplitjoinJoin<CR>", desc = "Join", icon = "󰘦" },
})

return {
  "echasnovski/mini.splitjoin",
  opts = {
    mappings = {
      toggle = "gsj",
      split = "gss",
      join = "gsJ",
    },
  },
}
