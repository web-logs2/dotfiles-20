local ls = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load({
  paths = { "~/.local/share/chezmoi/private_Library/private_Application Support/private_Code/User/snippets" },
})

local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets("yaml", {
  s("ternary", {
    i(1, "cond"),
    t(" ? "),
    i(2, "then"),
    t(" : "),
    i(3, "else"),
  }),
})
