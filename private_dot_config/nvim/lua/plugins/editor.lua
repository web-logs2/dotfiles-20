return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = function(_, opt)
      opt.filesystem.filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_gitignored = true,
      }
      return opt
    end,
  },
  {
    "folke/todo-comments.nvim",
    enabled = false,
  },
}
