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
      })
    end,
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    opts = function(_, opts)
      local nls = require("null-ls")
      vim.list_extend(opts.sources, {
        nls.builtins.diagnostics.shellcheck,
        nls.builtins.code_actions.shellcheck,
        nls.builtins.formatting.rome,
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
    end,
  },
}
