return {
	"folke/snacks.nvim",
	keys = {
		-- Disable default keymaps, we will set our own to enable DiffView
		{ "<Leader>gd", false },
		-- Map <C-7> to toggle terminal, works in tmux not in kitty.
		{
			"<C-7>",
			function()
				Snacks.terminal()
			end,
			mode = { "n", "t" },
			desc = "Terminal (Toggle)",
		},
		{
			"<leader>fl",
			function()
				Snacks.scratch({ icon = " ", name = "Todo", ft = "markdown" })
			end,
			desc = "Todo List",
		},
		-- {
		-- 	"<leader>fL",
		-- 	function()
		-- 		Snacks.scratch({ icon = " ", name = "Todo", ft = "markdown", file = "~/TODO.md" })
		-- 	end,
		-- 	desc = "Todo List",
		-- },
	},
	opts = {
		zen = {
			toggles = {
				dim = false,
			},
		},
		image = {
			enabled = true,
			doc = {
				inline = false,
			},
		},
		picker = {
			-- ui_select set to used by copilotChat.nvim package.
			-- ui_select = true,
			layouts = {
				-- Wider preview layout, toggle with <C-p> inside any picker
				wide_preview = {
					layout = {
						box = "horizontal",
						width = 0,
						height = 0,
						{
							box = "vertical",
							border = "rounded",
							title = "{source} {live}",
							{ win = "input", height = 1, border = "bottom" },
							{ win = "list", border = "none" },
						},
						{ win = "preview", border = "rounded", width = 0.7 },
					},
				},
			},
			actions = {
				toggle_wide_preview = function(picker)
					local current = picker.layout and picker.layout.preset or "default"
					picker:set_layout(current == "wide_preview" and "default" or "wide_preview")
				end,
			},
			win = {
				input = {
					keys = {
						["I"] = { "toggle_ignored" },
						["H"] = { "toggle_hidden" },
						["<c-w><c-w>"] = { "cycle_win", mode = { "n", "i" } },
						-- ["<c-w><c-p>"] = { "toggle_preview", mode = { "n", "i" } },
						["<c-w><c-m>"] = { "toggle_maximize", mode = { "n", "i" } },
						["<c-w>f"] = { "toggle_wide_preview", mode = { "i", "n" } },
						-- Not work, overriden by other key, focus window
						-- ["<c-h>"] = { "focus_list", mode = { "i", "n" } },
					},
				},
			},
			-- focus = "preview",
			sources = {
				explorer = {
					win = {
						list = {
							keys = {
								["A"] = "explorer_add_dotnet",
							},
						},
					},
					actions = {
						explorer_add_dotnet = function(picker)
							local dir = picker:dir()
							local easydotnet = require("easy-dotnet")

							easydotnet.create_new_item(dir, function(item_path)
								local tree = require("snacks.explorer.tree")
								local actions = require("snacks.explorer.actions")
								tree:open(dir)
								tree:refresh(dir)
								actions.update(picker, { target = item_path })
								picker:focus()
							end)
						end,
					},
					-- follow_file = false,
					-- tree = false,
					-- auto_close = true,
				},
			},
		},
	},
	-- config = function(_, opts)
	-- 	require("snacks").setup(opts)
	--
	-- 	vim.api.nvim_create_autocmd("User", {
	-- 		pattern = "VeryLazy",
	-- 		once = true,
	-- 		callback = function()
	-- 			-- Set focus inside Snacks picker if it's open, otherwise default to normal window navigation
	-- 			-- We do not include the explorer picker since it has only one pane.
	-- 			local setFocusInsideSnacksPickerOrDefault = function(direction)
	-- 				local picker_list = Snacks.picker.get()
	-- 				local picker = picker_list and picker_list[#picker_list]
	--
	-- 				if picker and picker.opts and picker.opts.source then
	-- 					if picker.opts.source == "explorer" then
	-- 						vim.cmd("wincmd " .. direction)
	-- 					elseif direction == "h" then
	-- 						Snacks.picker.actions.focus_list(picker)
	-- 					elseif direction == "l" then
	-- 						Snacks.picker.actions.focus_preview(picker)
	-- 					else
	-- 						vim.cmd("wincmd " .. direction)
	-- 					end
	-- 				else
	-- 					vim.cmd("wincmd " .. direction)
	-- 				end
	-- 			end
	--
	-- 			vim.keymap.set({ "n", "i" }, "<C-l>", function()
	-- 				setFocusInsideSnacksPickerOrDefault("l")
	-- 			end)
	-- 			vim.keymap.set({ "n", "i" }, "<C-h>", function()
	-- 				setFocusInsideSnacksPickerOrDefault("h")
	-- 			end)
	-- 		end,
	-- 	})
	-- end,
}
