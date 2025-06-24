vim.cmd([[
  highlight ScopeIndentCustom guifg=#FFDD4A guibg=NONE gui=bold
  highlight IndentCustom1 guifg=#CD0015 guibg=NONE gui=bold
  highlight IndentCustom2 guifg=#FFDFBA guibg=NONE gui=bold
  highlight IndentCustom3 guifg=#FFFFBA guibg=NONE gui=bold
  highlight IndentCustom4 guifg=#BAFFC9 guibg=NONE gui=bold
  highlight IndentCustom5 guifg=#BAE1FF guibg=NONE gui=bold
  highlight IndentCustom6 guifg=#E2BAFF guibg=NONE gui=bold
  highlight IndentCustom7 guifg=#FFC3A0 guibg=NONE gui=bold
  highlight IndentCustom8 guifg=#FFCBCB guibg=NONE gui=bold
]])

return {
  "folke/snacks.nvim",
  keys = {
    { "<leader>S", false },
  },
  opts = {
    indent = {
      indent = {
        enabled = false,
        only_scope = false,
        only_current = false,
        char = "╎",
        hl = {
          "IndentCustom1",
          "IndentCustom2",
          "IndentCustom3",
          "IndentCustom4",
          "IndentCustom5",
          "IndentCustom6",
          "IndentCustom7",
          "IndentCustom8",
        },
      },
      scope = {
        char = "╎",
        underline = true,
        hl = "IndentCustom1",
      },
      chunk = {
        enabled = true,
        only_current = true,
        priority = 200,
        hl = "ScopeIndentCustom", ---@type string|string[]
        char = {
          corner_top = "┍",
          corner_bottom = "┕",
          horizontal = "╶",
          vertical = "╎",
          arrow = ">",
        },
      },
    },
    zen = {
      enabled = true,
      win = {
        backdrop = {
          transparent = false,
        },
      },
      toggles = {
        dim = true,
        git_signs = true,
        diagnostics = false,
        line_number = true,
        relative_number = true,
        signcolumn = "no",
        indent = true,
      },
    },
    picker = {
      sources = {
        grep = {
          hidden = true,
          ignored = true,
          exclude = { "node_modules", ".git", ".venv", "__pycache__", ".vscode", ".mypy_cache" },
        },

        files = {
          hidden = true,
          ignored = true,
          exclude = { "node_modules", ".git", ".venv", "__pycache__", ".vscode", ".mypy_cache" },
        },
        explorer = {
          hidden = true,
          ignored = true,
          auto_close = true,
          exclude = { "node_modules", ".git", ".venv", "__pycache__", ".vscode", ".mypy_cache" },
        },
      },
    },
  },
}
