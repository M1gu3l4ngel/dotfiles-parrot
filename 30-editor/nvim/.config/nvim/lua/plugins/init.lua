-- The plugins NvChad does not bring, found by lazy.nvim through `{ import = "plugins" }` in init.lua.

return {
  -- Runs external formatters; its settings are in configs/conform.lua.
  {
    "stevearc/conform.nvim",
    opts = require "configs.conform",
  },

  -- Base configs for the LSP servers; which ones are enabled is in configs/lspconfig.lua.
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
}
