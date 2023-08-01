-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.relativenumber = false

vim.b.autoformat = true

-- https://neovim.io/doc/user/lua.html#vim.filetype.add()
vim.filetype.add({
  extension = {
    d2 = "d2",
  },
  filename = {
    [".env"] = "dotenv",
  },
})
