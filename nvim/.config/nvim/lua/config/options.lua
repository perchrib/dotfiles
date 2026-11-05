-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- vim.opt.completeopt = { "menu", "menuone", "noselect", "popup" }
-- https://github.com/LazyVim/LazyVim/discussions/4830
vim.g.ai_cmp = false

-- Set new line at end of file
vim.opt.fixeol = true

-- Spell checking: US English and Norwegian
vim.opt.spelllang = { "en_us", "nb" }

-- stylua: ignore start
vim.g.dbs = {
	{ name = "LOCAL_HurtigtastenDB", url = "sqlserver://sa:Secret1234@localhost/HurtigtastenDb" },
	{ name = "LOCAL_TeksternDB", url = "sqlserver://sa:Secret1234@localhost/TeksternDb" },
}
-- stylua: ignore end

-- Append connections from env vars DBS_<order>_<Name>=<url> (from LastPass), sorted by <order>.
-- Not DB_UI_*: dadbod-ui lowercases those names and lists them in random order.
-- Remember to <az login> in terminal before starting nvim if you want to use Azure SQL connections.
-- Login as tmp user
local env_dbs = {}
for key, url in pairs(vim.fn.environ()) do
	local order, name = key:match("^DBS_(%d+)_(.+)$")
	if order then
		table.insert(env_dbs, { order = tonumber(order), name = name, url = url })
	end
end
table.sort(env_dbs, function(a, b)
	return a.order < b.order
end)
local dbs = vim.g.dbs
for _, db in ipairs(env_dbs) do
	table.insert(dbs, { name = db.name, url = db.url })
end
vim.g.dbs = dbs
