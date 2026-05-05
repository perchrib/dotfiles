return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "marilari88/neotest-vitest",
      "nsidorenco/neotest-vstest",
    },
    opts = {
      adapters = {
        ["neotest-vitest"] = {},
        ["neotest-vstest"] = {},
      },
    },
  },
}
