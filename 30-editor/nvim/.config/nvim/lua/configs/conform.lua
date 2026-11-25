-- conform.nvim's formatters per filetype, loaded by the spec in lua/plugins/init.lua
-- (`opts = require "configs.conform"`).

local options = {
  -- A new language goes here, then `:MasonInstallAll`: NvChad installs the formatters of this table
  -- through Mason. No format_on_save: formatting stays an explicit action.
  formatters_by_ft = {
    lua = { "stylua" },
    sh = { "shfmt" },
    bash = { "shfmt" },
  },

  -- shfmt with the repo's shell style: 2 spaces and indented `case`.
  formatters = {
    shfmt = { prepend_args = { "-i", "2", "-ci" } },
  },
}

return options
