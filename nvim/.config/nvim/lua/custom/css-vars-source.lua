local css_variables = nil

---@type blink.cmp.Source
local M = {}

function M.new(opts)
	local self = setmetatable({}, { __index = M })
	local config = vim.tbl_deep_extend("keep", opts or {}, {
		search_extensions = { ".css", ".scss", ".less" },
	})

	if css_variables then
		return self
	end

	local args = {
		"--no-ignore",
		"-oP",
		"--no-filename",
	}

	for _, extension in pairs(config.search_extensions) do
		table.insert(args, "-g")
		table.insert(args, "*" .. extension)
	end

	table.insert(args, "--")
	table.insert(args, "--[a-zA-Z][a-zA-Z0-9_-]*\\s*:\\s*[^;{}]+")
	table.insert(args, vim.uv.cwd())

	vim.system(
		vim.list_extend({ "rg" }, args),
		{ text = true },
		vim.schedule_wrap(function(result)
			if result.code ~= 0 then
				css_variables = {}
				return
			end

			local items = {}
			local processed = {}
			for line in result.stdout:gmatch("[^\r\n]+") do
				local name, value = line:match("^(--[%w_-]+)%s*:%s*(.+)$")
				if name and not processed[name] then
					processed[name] = true
					table.insert(items, {
						label = "var(" .. name .. ")",
						filterText = name,
						insertText = "var(" .. name .. ")",
						kind = require("blink.cmp.types").CompletionItemKind.Variable,
						documentation = value,
					})
				end
			end
			css_variables = items
		end)
	)

	return self
end

function M:get_completions(_, callback)
	callback({
		is_incomplete_forward = true,
		is_incomplete_backward = true,
		items = css_variables or {},
	})
end

function M:get_trigger_characters()
	return { "-" }
end

return M
