-- Not sure this is necessary
return {
	"artemave/workspace-diagnostics.nvim",
	keys = {
		{
			"<leader>xW",
			function()
				local files = vim.fn.systemlist("git ls-files")
				if #files == 0 then
					vim.notify("No files found (not a git repo?)", vim.log.levels.WARN)
					return
				end
				for _, file in ipairs(files) do
					if file ~= "" then
						vim.fn.bufadd(file)
						vim.fn.bufload(file)
					end
				end
				vim.notify("Loaded " .. #files .. " project files", vim.log.levels.INFO)
			end,
			desc = "Load all project files (for LSP diagnostics)",
		},
		{
			"<leader>xw",
			function()
				local clients = vim.lsp.get_clients({ bufnr = 0 })
				if #clients == 0 then
					vim.notify("No LSP clients attached to buffer", vim.log.levels.WARN)
					return
				end
				for _, client in ipairs(clients) do
					if client.name ~= "copilot" then
						vim.notify("Skipping Copilot client for workspace diagnostics", vim.log.levels.INFO)
						require("workspace-diagnostics").populate_workspace_diagnostics(client, 0)
					end
				end
			end,
			desc = "Workspace diagnostics",
		},
	},
}
