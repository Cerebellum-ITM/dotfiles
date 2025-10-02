return {
  "saghen/blink.cmp",
  opts = {
    completion = {
      menu = {
        draw = {
          treesitter = {
            { "lsp" },
          },
          columns = {
            { "kind_icon", "kind", gap = 1 },
            { "label", "label_description", gap = 1 },
            { "source_name", gap = 1 },
          },
        },
      },
    },
  },
}
