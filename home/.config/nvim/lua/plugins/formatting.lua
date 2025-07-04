return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    opts.formatters_by_ft = opts.formatters_by_ft or {}
    opts.formatters = opts.formatters or {}

    opts.formatters_by_ft.xml = { "xmlformatter" }
    opts.formatters.xmlformatter = {
      prepend_args = {
        "--indent",
        "4",
        "--indent-char",
        " ",
        "--selfclose",
        "--eof-newline",
        "--preserve-attributes",
        "--blanks",
      },
    }

    opts.formatters_by_ft.javascript = { "prettier" }
    opts.formatters.prettier = {
      prepend_args = {
        "--tab-width",
        "4",
        "--single-quote",
        "--jsx-single-quote",
        "--trailing-comma",
        "all",
        "--use-tabs",
        "false",
      },
    }

    opts.formatters_by_ft.go = { "gofumpt", "goimports_reviser", "golines" }
  end,
}
