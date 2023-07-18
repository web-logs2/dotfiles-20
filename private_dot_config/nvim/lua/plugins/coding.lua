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
}
