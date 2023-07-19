return {
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opt)
      local cmp = require("cmp")

      opt.mapping["<CR>"] = cmp.mapping({
        i = function(fallback)
          if cmp.visible() and cmp.get_active_entry() then
            cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
          else
            fallback()
          end
        end,
        s = cmp.mapping.confirm({ select = true }),
        c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
      })

      opt.mapping["<Tab>"] = cmp.mapping.confirm({ select = true })

      return opt
    end,
  },
  {
    "L3MON4D3/LuaSnip",
    config = function()
      print("a")
      local m = require("luasnip.loaders.from_vscode")
      -- load vscode global snippets
      m.lazy_load({
        paths = { "~/.local/share/chezmoi/private_Library/private_Application Support/private_Code/User/snippets" },
      })

      -- load project root snippets
      local vscode_dir = vim.fs.find(".vscode", {
        upward = true,
        type = "directory",
        path = vim.fn.getcwd(),
        stop = vim.env.HOME,
      })[1]

      if vscode_dir ~= nil then
        print(vscode_dir)
        local local_snippets = vim.fs.find(function(name)
          return name:match("%.code%-snippets$")
        end, {
          limit = 10,
          type = "file",
          path = vscode_dir,
        })
        for _, snippet in pairs(local_snippets) do
          m.load_standalone({ path = snippet })
        end
      end
    end,
  },
}
