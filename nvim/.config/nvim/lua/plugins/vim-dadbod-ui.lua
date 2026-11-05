-- Installed with lazy extra, but override default keybinding here.
return {
	"kristijanhusak/vim-dadbod-ui",
	-- Use `config`, not `init`: lazy.nvim replaces `init`, which would drop the extra's settings.
	config = function()
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "dbui",
			callback = function(ev)
				-- Expand/collapse node with `l` or `h`
				vim.keymap.set("n", "l", "<Plug>(DBUI_SelectLine)", { buffer = ev.buf, remap = true })
				vim.keymap.set("n", "h", "<Plug>(DBUI_SelectLine)", { buffer = ev.buf, remap = true })
				-- Optional: remove a default you don't want
				-- pcall(vim.keymap.del, "n", "o", { buffer = ev.buf })
			end,
		})
	end,
}
