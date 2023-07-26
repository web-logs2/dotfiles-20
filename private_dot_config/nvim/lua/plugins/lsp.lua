return {
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "rome",
        "prettierd",
        "gofumpt",
        "goimports-reviser",
        "shellcheck",
        "sql-formatter",
        "yamlfmt",
        "taplo",
      })
    end,
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    opts = function(_, opts)
      local nls = require("null-ls")

      local FORMATTING = nls.methods.FORMATTING

      vim.list_extend(opts.sources, {
        nls.builtins.diagnostics.shellcheck,
        nls.builtins.code_actions.shellcheck,
        nls.builtins.formatting.prettierd.with({
          disabled_filetypes = {
            "javascript",
            "typescript",
            "javascriptreact",
            "typescriptreact",
            "json",
          },
          env = {
            PRETTIERD_DEFAULT_CONFIG = vim.fn.expand("~/.config/nvim/utils/linter-config/.prettierrc.yaml"),
          },
        }),
      })

      nls.register({
        method = FORMATTING,
        filetypes = {
          "sql",
          "javascript",
          "typescript",
          "javascriptreact",
          "typescriptreact",
          "json",
          "yaml",
          "toml",
        },
        generator = nls.formatter({
          command = "fmt_file",
          args = { "-l", "$FILEEXT" },
          to_stdin = true,
        }),
      })
    end,
  },
}
