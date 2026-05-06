return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "marilari88/neotest-vitest",
      "nsidorenco/neotest-vstest",
      "nvim-neotest/neotest-jest",
    },
    opts = {
      adapters = {
        ["neotest-vitest"] = {},
        ["neotest-vstest"] = {},
        ["neotest-jest"] = {
          jestCommand = "npm test --",
        },
      },
    },
  },
}
