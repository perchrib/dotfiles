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
					},
				},
			},
		},
	},
}
