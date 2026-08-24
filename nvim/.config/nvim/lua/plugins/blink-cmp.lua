-- Note: This override the default setting in Lazyvim
-- Behaviour: When dropdown menu appears, the first item
-- will not be preselected, so you can use <CR> adding newline.
-- To select items, you can use <C-n> or <C-p> to navigate.
-- Then select with <CR> or <C-y> to accept.
-- <C-space> will trigger the completion menu, and <C-e> will close it.
-- Remember using Tab and Shift-Tab to navigate after selection for
-- navigating to rename the snippet placeholders.

local function in_css_context()
	local node = vim.treesitter.get_node()
	while node do
		local t = node:type()
		if t == "style_element" or t == "stylesheet" then
			return true
		end
		node = node:parent()
	end
	return false
end

local function in_css_or_class_attr()
	if in_css_context() then
		return true
	end
	local node = vim.treesitter.get_node()
	while node do
		if node:type() == "attribute" then
			local name_node = node:child(0)
			if name_node and vim.treesitter.get_node_text(name_node, 0) == "class" then
				return true
			end
		end
		node = node:parent()
	end
	return false
end

return {
	{
		"saghen/blink.cmp",
		opts = {
			sources = {
				default = { "css_vars", "css_classes" },
				providers = {
					css_vars = {
						name = "css-vars",
						module = "custom.css-vars-source",
						enabled = in_css_context,
						transform_items = function(_, items)
							for _, item in ipairs(items) do
								item.kind_icon = "󰆦"
							end
							return items
						end,
						opts = {
							search_extensions = { ".css", ".scss", ".less", ".svelte" },
						},
					},
					css_classes = {
						name = "css-classes",
						module = "custom.css-classes-source",
						enabled = in_css_or_class_attr,
						transform_items = function(_, items)
							for _, item in ipairs(items) do
								item.kind_icon = "󰌝"
							end
							return items
						end,
						opts = {
							search_extensions = { ".css", ".scss", ".less" },
						},
					},
				},
			},
			keymap = {
				preset = "default",
				["<CR>"] = { "accept", "fallback" },
			},
			completion = {
				list = {
					selection = { preselect = false, auto_insert = true },
				},
			},
			fuzzy = {
				sorts = {
					function(a, b)
						local k = vim.lsp.protocol.CompletionItemKind
						local source_priority = {
							["css-vars"] = 20,
							["css-classes"] = 20,
						}
						local kind_priority = {
							[k.Field] = 1,
							[k.Property] = 2,
							[k.EnumMember] = 3,
							[k.Method] = 10,
							[k.Function] = 11,
						}
						local pa = source_priority[a.source_name] or kind_priority[a.kind]
						local pb = source_priority[b.source_name] or kind_priority[b.kind]
						if pa ~= nil and pb ~= nil and pa ~= pb then
							return pa < pb
						end
					end,
					"score",
					"sort_text",
				},
			},
		},
	},
}
