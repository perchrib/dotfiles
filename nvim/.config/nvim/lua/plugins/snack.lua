return {
  "folke/snacks.nvim",
  keys = {
    {
      "<leader>t",
      function()
        Snacks.scratch({ icon = " ", name = "Todo", ft = "markdown" })
      end,
      desc = "Todo List",
    },
    {
      "<leader>T",
      function()
        Snacks.scratch({ icon = " ", name = "Todo", ft = "markdown", file = "~/TODO.md" })
      end,
      desc = "Todo List",
    },
  },
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
  config = function(_, opts)
    require("snacks").setup(opts)

    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      once = true,
      callback = function()
        -- Set focus inside Snacks picker if it's open, otherwise default to normal window navigation
        -- We do not include the explorer picker since it has only one pane.
        local setFocusInsideSnacksPickerOrDefault = function(direction)
          local picker_list = Snacks.picker.get()
          local picker = picker_list and picker_list[#picker_list]

          if picker and picker.opts and picker.opts.source then
            if picker.opts.source == "explorer" then
              vim.cmd("wincmd " .. direction)
            elseif direction == "h" then
              Snacks.picker.actions.focus_list(picker)
            elseif direction == "l" then
              Snacks.picker.actions.focus_preview(picker)
            else
              vim.cmd("wincmd " .. direction)
            end
          else
            vim.cmd("wincmd " .. direction)
          end
        end

        vim.keymap.set({ "n", "i" }, "<C-l>", function()
          setFocusInsideSnacksPickerOrDefault("l")
        end)
        vim.keymap.set({ "n", "i" }, "<C-h>", function()
          setFocusInsideSnacksPickerOrDefault("h")
        end)
      end,
    })
  end,
}
