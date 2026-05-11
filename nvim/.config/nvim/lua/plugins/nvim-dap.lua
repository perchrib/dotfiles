return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			-- virtual text for the debugger
			{
				"theHamsta/nvim-dap-virtual-text",
				opts = {},
			},
		},
  -- stylua: ignore
	keys = {
		{ "<F10>", function() require("dap").step_over() end, desc = "Step Over" },
		{ "<F11>", function() require("dap").step_into() end, desc = "Step Into" },
		{ "<leader>dT", function() require("dap").clear_breakpoints() require("dap").terminate() end, desc = "Terminate & Clear Breakpoints" },
	},
		-- config = function()
		--   local dap = require("dap")
		--
		--   -- Keymaps for controlling the debugger
		--   vim.keymap.set("n", "<leader>dq", function()
		--     dap.terminate()
		--     dap.clear_breakpoints()
		--   end, { desc = "Terminate and clear breakpoints" })
		--
		--   vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Start/continue debugging" })
		--   vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "Step over" })
		--   vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Step into" })
		--   vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "Step out" })
		--   vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
		--   -- vim.keymap.set("n", "<leader>dO", dap.step_over, { desc = "Step over (alt)" })
		--   vim.keymap.set("n", "<leader>dC", dap.run_to_cursor, { desc = "Run to cursor" })
		--   vim.keymap.set("n", "<leader>dr", dap.repl.toggle, { desc = "Toggle DAP REPL" })
		--   vim.keymap.set("n", "<leader>dj", dap.down, { desc = "Go down stack frame" })
		--   vim.keymap.set("n", "<leader>dk", dap.up, { desc = "Go up stack frame" })
		-- end,
	},
	{
		"Cliffback/netcoredbg-macOS-arm64.nvim",
		dependencies = { "mfussenegger/nvim-dap" },
		config = function()
			require("netcoredbg-macOS-arm64").setup(require("dap"))
		end,
	},
}
