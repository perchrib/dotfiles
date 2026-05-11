return {
	"sindrets/diffview.nvim",
	cmd = {
		"DiffviewOpen",
		"DiffviewClose",
		"DiffviewToggleFiles",
		"DiffviewFocusFiles",
	},
	-- Optional: Configure keybindings, e.g., to toggle diffview
	keys = {
		{ "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview Open" },
		{ "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Diffview Close" },
	},
	opts = {}, -- Runs setup() automatically
}
