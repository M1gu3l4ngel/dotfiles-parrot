-- Neovim's entry point. It installs lazy.nvim on the first run, loads NvChad and the plugins in
-- lua/plugins/, loads the cached theme (base46) to avoid a flash on opening, and then the options,
-- autocmds and mappings, in that order.

-- Where NvChad caches the compiled themes (base46 is its highlight system).
vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
-- Space is the prefix of almost every custom shortcut (<leader>f finds files).
vim.g.mapleader = " "

-- lazy.nvim is cloned the first time nvim opens without it.
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- NvChad with lazy=false so its defaults are there at once; then the plugins in lua/plugins/.
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- The precompiled highlights avoid compiling them on every start; NvChad regenerates the cache
-- when chadrc.lua changes the theme.
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

-- Options and autocmds load synchronously, ready before the first buffer; mappings wait for
-- vim.schedule so they do not hold up the start.
require "options"
require "autocmds"

vim.schedule(function()
  require "mappings"
end)
