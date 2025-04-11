local wk = require("which-key")
wk.add({
  { "gs", group = "splitjoin", icon = "" },
  {
    "gsj",
    "<cmd>lua MiniSplitjoin.toggle()<CR>",
    desc = "Toggle Split/Join",
    icon = { icon = "", color = "orange" },
  },
  { "gss", "<cmd>lua MiniSplitjoin.split()<CR>", desc = "Split", icon = "󰉸" },
  { "gsJ", "<cmd>lua MiniSplitjoin.join()<CR>", desc = "Join", icon = "󰘦" },
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
