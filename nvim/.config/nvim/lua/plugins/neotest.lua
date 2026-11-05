return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"marilari88/neotest-vitest",
			"nsidorenco/neotest-vstest",
			"nvim-neotest/neotest-jest",
		},
		opts = {
			adapters = {
				["neotest-vitest"] = {},
				["neotest-vstest"] = {},
				["neotest-jest"] = {
					jestCommand = "npm test --",
				},
			},
			summary = {
				mappings = {
					-- Add "l" and "h" to the expand mapping.
					-- You can also keep "<CR>" so the Enter key still works.
					expand = { "l", "h", "<CR>", "<2-LeftMouse>" },
				},
			},
		},
	},
}
