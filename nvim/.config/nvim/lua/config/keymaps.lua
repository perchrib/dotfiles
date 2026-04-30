-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("i", "jk", "<ESC>")

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Yank full file path to clipboard

vim.keymap.set("n", "yp", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  vim.notify("Yanked full path: " .. path)
end, { desc = "Yank full file path to clipboard" })

-- Yank relative file path to clipboard
vim.keymap.set("n", "yP", function()
  local path = vim.fn.expand("%")
  vim.fn.setreg("+", path)
  vim.notify("Yanked relative path: " .. path)
end, { desc = "Yank relative file path to clipboard" })
