-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
require("config.snippets")

vim.opt.relativenumber = false

vim.b.autoformat = true

-- vim.api_nvim_set_keymap("c", "w!!", "<esc>:lua require'utils'.sudo_write()<CR>", { silent = true })
