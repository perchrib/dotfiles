return {
	"olimorris/codecompanion.nvim",
	version = "^19.0.0",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	opts = {
		opts = {
			log_level = "DEBUG",
		},
		interactions = {
			chat = {
				adapter = {
					name = "copilot",
					model = "claude-haiku-4.5",
				},
			},
			inline = {
				adapter = {
					name = "copilot",
					model = "claude-haiku-4.5",
				},
			},
			cmd = {
				adapter = {
					name = "copilot",
					model = "claude-haiku-4.5",
				},
			},
		},
	},
	config = function(_, opts)
		require("codecompanion").setup(opts)
		-- expand 'cc' into 'codecompanion' in the command line
		vim.cmd([[cab cc CodeCompanion]])
	end,
}
