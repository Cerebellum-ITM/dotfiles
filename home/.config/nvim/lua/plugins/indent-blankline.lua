return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  ---@module "ibl"
  ---@type ibl.config
  opts = function(_, opts)
    opts.indent = opts.indent or {}
    opts.indent.char = "╎"
    local highlight = {
      "RainbowIvory",
      "RainbowGreen",
      "RainbowRed",
      "RainbowViolet",
      "RainbowAmethys",
      "RainbowBlue",
      "RainbowTurquoise",
    }
    local hooks = require("ibl.hooks")
    hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
      vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#FF7477" })
      vim.api.nvim_set_hl(0, "RainbowIvory", { fg = "#FFFFF3" })
      vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#5BC0EB" })
      vim.api.nvim_set_hl(0, "RainbowTurquoise", { fg = "#00D9C0" })
      vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#CEF7A0" })
      vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#6A0136" })
      vim.api.nvim_set_hl(0, "RainbowAmethys", { fg = "#9B5DE5" })
    end)
    opts.indent.highlight = highlight
  end,
}
