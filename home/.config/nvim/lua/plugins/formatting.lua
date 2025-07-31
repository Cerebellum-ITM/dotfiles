return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    opts.formatters_by_ft = opts.formatters_by_ft or {}
    opts.formatters = opts.formatters or {}
    opts.formatters_by_ft.javascript = { "prettier" }
    opts.formatters_by_ft.typescript = { "prettier" }
    opts.formatters_by_ft.xml = { "prettier" }
    opts.formatters["prettier"] = {
      prepend_args = function(self, ctx)
        local args
        if ctx.filename:match("%.xml$") then
          args = {
            "--print-width",
            "180",
            "--bracket-same-line",
            "true",
            "--tab-width",
            "4",
            "--single-attribute-per-line",
            "false",
            "--xml-sort-attributes-by-key",
            "false",
            "--plugin=@prettier/plugin-xml",
          }
        else
          args = {
            "--tab-width",
            "4",
            "--single-quote",
            "--jsx-single-quote",
            "--trailing-comma",
            "all",
            "--use-tabs",
            "false",
          }
        end
        return args
      end,
    }

    opts.formatters_by_ft.go = { "gofumpt", "goimports_reviser", "golines" }
  end,
}
