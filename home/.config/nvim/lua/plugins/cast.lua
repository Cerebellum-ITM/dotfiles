return {
  {
    "Cerebellum-ITM/cast_vim_addon",
    cmd = { "CastToggle", "CastShow", "CastHide", "CastKill" },
    event = { "VeryLazy" },
    keys = {
      { "<leader>ct", "<cmd>CastToggle<cr>", desc = "Cast: toggle" },
    },
    opts = {},
  },
}
