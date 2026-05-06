return {
	"stevearc/conform.nvim",
	opts = {
		formatters_by_ft = {
			["yaml"] = { "yamlfmt" },
			["yml"] = { "yamlfmt" },
		},
		formatters = {
			yamlfmt = {
				prepend_args = { "-formatter", "retain_line_breaks=true" },
			},
		},
	},
}
