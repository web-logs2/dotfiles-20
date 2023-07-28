local util = require("util")

return {
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "rome",
        "prettierd",
        "gofumpt",
        "goimports-reviser",
        "goimports",
        "shellcheck",
        "sql-formatter",
        "yamlfmt",
        "taplo",
        "markdownlint",
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.format = {
        formatting_options = nil,
        timeout_ms = 5000,
      }
    end,
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    opts = function(_, opts)
      local nls = require("null-ls")

      vim.list_extend(opts.sources, {
        nls.builtins.diagnostics.shellcheck,
        nls.builtins.diagnostics.markdownlint,
        nls.builtins.code_actions.shellcheck,
        -- nls.builtins.formatting.prettierd.with({
        --   env = {
        --     PRETTIERD_DEFAULT_CONFIG = vim.fn.expand("~/.config/nvim/plugin_config/.prettierrc.yaml"),
        --   },
        -- }),
      })

      local FORMATTING = nls.methods.FORMATTING
      local function make_my_source(filetypes, lang)
        return {
          method = FORMATTING,
          filetypes = filetypes,
          generator = nls.formatter({
            command = "fmt_file",
            args = { "-l", lang, "-n", "$FILENAME" },
            to_stdin = true,
            -- ignore_stderr = false,
          }),
        }
      end
      local my_sources = {
        make_my_source({
          "sql",
          "javascript",
          "typescript",
          "javascriptreact",
          "typescriptreact",
          "yaml",
          "toml",
          "fish",
          "go",
          "vue",
          "css",
          "scss",
          "less",
          "html",
          "jsonc",
          "json",
          "markdown",
          "python",
          "d2",
        }, "$FILEEXT"),
        make_my_source({ "sh" }, "sh"),
        make_my_source({ "fish" }, "fish"),
      }

      local my_formatter_types = {}
      for _, src in pairs(my_sources) do
        for _, fileType in pairs(src.filetypes) do
          my_formatter_types[fileType] = true
        end
      end

      -- remove predefined formatter
      util.filter_inplace(opts.sources, function(src)
        local met = src.method
        if
          (type(met) == "string" and met == FORMATTING) or (type(met) == "table" and util.has_value(met, FORMATTING))
        then
          if #src.filetypes > 0 then
            util.filter_inplace(src.filetypes, function(ft)
              return not my_formatter_types[ft]
            end)
            -- print("a" .. table.concat(src.filetypes, ","))
            return #src.filetypes > 0
          end
        end
        return true
      end)

      nls.register(my_sources)
    end,
  },
}
