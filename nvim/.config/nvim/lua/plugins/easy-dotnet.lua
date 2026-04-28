return {
  {
    "GustavEikaas/easy-dotnet.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "folke/snacks.nvim" },
    config = function()
      require("easy-dotnet").setup()
    end,
  },
  {
    {
      "nvim-lualine/lualine.nvim",
      dependencies = {
        "GustavEikaas/easy-dotnet.nvim",
      },
      config = function()
        local job_indicator = {
          require("easy-dotnet.ui-modules.jobs").lualine,
        }

        require("lualine").setup({
          sections = {
            lualine_a = { "mode", job_indicator },
          },
        })
      end,
    },
  },
}
