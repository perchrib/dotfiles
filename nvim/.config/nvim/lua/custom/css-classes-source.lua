local css_classes = nil

---@type blink.cmp.Source
local M = {}

function M.new(opts)
	local self = setmetatable({}, { __index = M })
	local config = vim.tbl_deep_extend("keep", opts or {}, {
		search_extensions = { ".css", ".scss", ".less" },
	})

	if css_classes then
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
	table.insert(args, "\\.[a-zA-Z][a-zA-Z0-9_-]*(?=\\s*[{,:])")
	table.insert(args, vim.uv.cwd())

	vim.system(
		vim.list_extend({ "rg" }, args),
		{ text = true },
		vim.schedule_wrap(function(result)
			if result.code ~= 0 then
				css_classes = {}
				return
			end

			local items = {}
			local processed = {}
			for line in result.stdout:gmatch("[^\r\n]+") do
				local class_name = line:match("^%.(.+)$")
				if class_name and not processed[class_name] then
					processed[class_name] = true
					table.insert(items, {
						label = class_name,
						filterText = class_name,
						insertText = class_name,
						kind = require("blink.cmp.types").CompletionItemKind.Class,
					})
				end
			end
			css_classes = items
		end)
	)

	return self
end

local function in_class_attribute()
	local col = vim.api.nvim_win_get_cursor(0)[2]
	local line = vim.api.nvim_get_current_line()
	local before = line:sub(1, col)
	return before:match('class="[^"]*$') ~= nil or before:match("class='[^']*$") ~= nil
end

function M:enabled()
	return in_class_attribute()
end

function M:get_completions(_, callback)
	callback({
		is_incomplete_forward = true,
		is_incomplete_backward = true,
		items = css_classes or {},
	})
end

return M
