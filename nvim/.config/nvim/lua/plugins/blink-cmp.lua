-- Note: This override the default setting in Lazyvim
-- Behaviour: When dropdown menu appears, the first item
-- will not be preselected, so you can use <CR> adding newline.
-- To select items, you can use <C-n> or <C-p> to navigate.
-- Then select with <CR> or <C-y> to accept.
-- <C-space> will trigger the completion menu, and <C-e> will close it.
-- Remeber using Tab and Shift-Tab to navigate after selection to
-- navigate to rename the snippet placeholders.
return {
  "saghen/blink.cmp",
  opts = {
    keymap = {
      preset = "default",
      ["<CR>"] = { "accept", "fallback" },
    },
    completion = {
      list = {
        selection = { preselect = false, auto_insert = true },
      },
    },
  },
}
