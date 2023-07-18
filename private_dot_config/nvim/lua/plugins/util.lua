return {
  {
    "theniceboy/joshuto.nvim",
    keys = {
      {
        "<leader>r",
        "<cmd>Joshuto<cr>",
        mode = "n",
        desc = "Joshuto",
      },
    },
  },
  {
    "ojroques/nvim-osc52",
    config = function()
      require("osc52").setup({
        max_length = 5000, -- Maximum length of selection (0 for no limit)
        silent = true, -- Disable message on successful copy
        trim = true, -- Trim surrounding whitespaces before copy
      })
    end,
    keys = {
      {
        "<leader>cc",
        function()
          return require("osc52").copy_operator()
        end,
        mode = "n",
        desc = "Copy using OSC52",
        expr = true,
      },
      {
        "<leader>cc",
        function()
          return require("osc52").copy_visual()
        end,
        mode = "v",
        desc = "Copy using OSC52",
      },
      {
        "<leader>ccc",
        "<leader>cc_",
        mode = "n",
        remap = true,
        desc = "Copy using OSC52",
      },
    },
  },
}
