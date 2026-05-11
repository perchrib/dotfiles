-- Note: This override the default setting in Lazyvim
-- Behaviour: When dropdown menu appears, the first item
-- will not be preselected, so you can use <CR> adding newline.
-- To select items, you can use <C-n> or <C-p> to navigate.
-- Then select with <CR> or <C-y> to accept.
-- <C-space> will trigger the completion menu, and <C-e> will close it.
-- Remember using Tab and Shift-Tab to navigate after selection for
-- navigating to rename the snippet placeholders.

return {
	"saghen/blink.cmp",
	opts = {
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
					local priority = {
						[k.Field] = 1,
						[k.Property] = 1,
						[k.EnumMember] = 2,
						[k.Method] = 10,
						[k.Function] = 10,
					}
					local pa, pb = priority[a.kind], priority[b.kind]
					if pa ~= nil and pb ~= nil and pa ~= pb then
						return pa < pb
					end
				end,
				"score",
				"sort_text",
			},
		},
	},
}
