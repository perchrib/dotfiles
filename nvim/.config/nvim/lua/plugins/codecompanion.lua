return {
  "olimorris/codecompanion.nvim",
  version = "^19.0.0",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    opts = {
      log_level = "DEBUG",
    },
    interactions = {
      chat = {
        adapter = {
          name = "copilot",
          model = "claude-sonnet-4",
        },
      },
      inline = {
        adapter = {
          name = "copilot",
          model = "claude-sonnet-4",
        },
      },
      cmd = {
        adapter = {
          name = "copilot",
          model = "claude-sonnet-4",
        },
      },
    },
  },
  config = function(_, opts)
    require("codecompanion").setup(opts)
    -- expand 'cc' into 'codecompanion' in the command line
    vim.cmd([[cab cc CodeCompanion]])
  end,
}
