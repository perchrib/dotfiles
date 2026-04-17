return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      -- ui_select set to used by copilotChat.nvim package.
      -- ui_select = true,
      win = {
        input = {
          keys = {
            ["I"] = { "toggle_ignored" },
            ["H"] = { "toggle_hidden" },
            -- ["<c-l>"] = { "focus_preview", mode = { "i", "n" } },
            -- Not work, overriden by other key, focus window
            -- ["<c-h>"] = { "focus_list", mode = { "i", "n" } },
          },
        },
      },
      -- focus = "preview",
      sources = {
        explorer = {
          -- follow_file = false,
          -- tree = false,
          -- auto_close = true,
        },
      },
    },
  },
}
