return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    opts.formatters_by_ft = opts.formatters_by_ft or {}
    opts.formatters_by_ft.xml = { "xmlformatter" }

    opts.formatters = opts.formatters or {}
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
  end,
}
