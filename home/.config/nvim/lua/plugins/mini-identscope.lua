return {
  "echasnovski/mini.indentscope",
  enable = false,
  opts = function(_, opts)
    opts.symbol = "╎"
    opts.options = opts.options or {}
    opts.options.try_as_border = true
  end,
}
