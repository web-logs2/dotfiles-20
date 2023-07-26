local function filter_inplace(arr, func)
  local new_index = 1
  local size_orig = #arr
  for old_index, v in ipairs(arr) do
    if func(v, old_index) then
      arr[new_index] = v
      new_index = new_index + 1
    end
  end
  for i = new_index, size_orig do
    arr[i] = nil
  end
end

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

      vim.list_extend(opts.sources, {
        nls.builtins.diagnostics.shellcheck,
        nls.builtins.code_actions.shellcheck,
        nls.builtins.formatting.prettierd.with({
          env = {
            PRETTIERD_DEFAULT_CONFIG = vim.fn.expand("~/.config/nvim/plugin_config/.prettierrc.yaml"),
          },
        }),
      })

      local FORMATTING = nls.methods.FORMATTING
      local my_sources = {
        {
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
            "fish",
            "go",
          },
          generator = nls.formatter({
            command = "fmt_file",
            args = { "-l", "$FILEEXT" },
            to_stdin = true,
          }),
        },
        {
          method = FORMATTING,
          filetypes = { "sh" },
          generator = nls.formatter({
            command = "fmt_file",
            args = { "-l", "sh" },
            to_stdin = true,
          }),
        },
      }

      local my_formatter_types = {}
      for _, src in pairs(my_sources) do
        for _, fileType in pairs(src.filetypes) do
          my_formatter_types[fileType] = true
        end
      end

      -- remove predefined formatter
      for _, src in pairs(opts.sources) do
        if src.method == FORMATTING then
          filter_inplace(src.filetypes, function(ft)
            return not my_formatter_types[ft]
          end)
          print("a" .. table.concat(src.filetypes, ","))
        end
      end
      filter_inplace(opts.sources, function(src)
        return src.method ~= FORMATTING or #src.filetypes > 0
      end)

      nls.register(my_sources)
    end,
  },
}
