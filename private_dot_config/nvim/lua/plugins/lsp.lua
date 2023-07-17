return {
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      local pkg = opts.ensure_installed
      table.insert(pkg, "rome")
      table.insert(pkg, "prettierd")
      table.insert(pkg, "goimports-reviser")
      table.insert(pkg, "gofumpt")
      table.insert(pkg, "shellcheck")
    end,
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    opts = function(_, opts)
      local nls = require("null-ls")
      -- table.insert(opts.sources, nls.builtins.code_actions.gitrebase)
      table.insert(opts.sources, nls.builtins.diagnostics.shellcheck)
      table.insert(opts.sources, nls.builtins.code_actions.shellcheck)
      table.insert(opts.sources, nls.builtins.formatting.rome)
      table.insert(
        opts.sources,
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
        })
      )
    end,
  },
}
