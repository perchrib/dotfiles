-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Ensure the file ends with exactly one newline on save: extra blank lines at the end are
-- removed, and a missing final newline is added.
vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("single_newline_at_eof", { clear = true }),
	callback = function(args)
		local bo = vim.bo[args.buf]
		if bo.binary or not bo.modifiable or bo.buftype ~= "" then
			return
		end

		local view = vim.fn.winsaveview()
		vim.cmd([[silent! keeppatterns %s/\n\+\%$//e]])
		vim.fn.winrestview(view)

		bo.fixendofline = true
	end,
})
