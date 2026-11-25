-- lazy.nvim's own settings, the second argument of require("lazy").setup(...) in init.lua.
-- https://github.com/folke/lazy.nvim

return {
  -- Every plugin loads late by default (on an event, a command or a filetype): a much faster start.
  defaults = { lazy = true },

  -- The colorscheme used if NvChad's theme is not loaded in time.
  install = { colorscheme = { "nvchad" } },

  -- No plugin here needs rocks, and with luarocks on :checkhealth reports an error for missing
  -- luarocks and Lua 5.1, dependencies that would add nothing.
  rocks = { enabled = false },

  -- The :Lazy panel's icons.
  ui = {
    icons = {
      ft = "",
      lazy = "󰂠 ",
      loaded = "",
      not_loaded = "",
    },
  },

  -- Plugins bundled with vim that are not used; turning them off saves a few ms at start. netrw is
  -- here because NvChad uses nvim-tree instead.
  performance = {
    rtp = {
      disabled_plugins = {
        "2html_plugin",
        "tohtml",
        "getscript",
        "getscriptPlugin",
        "gzip",
        "logipat",
        "netrw",
        "netrwPlugin",
        "netrwSettings",
        "netrwFileHandlers",
        "matchit",
        "tar",
        "tarPlugin",
        "rrhelper",
        "spellfile_plugin",
        "vimball",
        "vimballPlugin",
        "zip",
        "zipPlugin",
        "tutor",
        "rplugin",
        "syntax",
        "synmenu",
        "optwin",
        "compiler",
        "bugreport",
        "ftplugin",
      },
    },
  },
}
