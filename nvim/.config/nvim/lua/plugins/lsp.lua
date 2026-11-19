return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			-- The '*' key applies this keymap globally to all LSP servers
			servers = {
				["*"] = {
					keys = {
						{
							"<leader>ca",
							function()
								vim.lsp.buf.code_action({
									context = {
										only = {
											"source",
											"refactor",
											"quickfix",
										},
									},
								})
							end,
							desc = "Code Action (Combined)",
							mode = { "n", "v" },
							has = "codeAction",
						},
						-- Hover + SVG icon preview + Roslyn escape fix, see lua/custom/hover.lua
						{
							"K",
							function()
								require("custom.hover").hover()
							end,
							desc = "Hover",
							has = "hover",
						},
					},
				},
			},
		},
	},
}
