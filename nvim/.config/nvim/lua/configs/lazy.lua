-- ~/.config/nvim/lua/configs/lazy.lua
-- Configuración global de lazy.nvim (el package manager).
-- Se pasa como segundo argumento a require("lazy").setup(...) en init.lua.
-- Documentación: https://github.com/folke/lazy.nvim

return {
  -- defaults.lazy = true: todos los plugins se cargan diferidos por defecto
  -- (al disparar un evento, un comando o un filetype). Reduce el tiempo
  -- de arranque drásticamente.
  defaults = { lazy = true },

  -- Colorscheme usado si NvChad no carga su tema a tiempo (fallback).
  install = { colorscheme = { "nvchad" } },

  -- ----- ICONOS DEL UI DE LAZY -----
  -- Iconos Nerd Font usados en el panel :Lazy (lista de plugins).
  ui = {
    icons = {
      ft = "",
      lazy = "󰂠 ",
      loaded = "",
      not_loaded = "",
    },
  },

  -- ----- PLUGINS BUILTIN DESACTIVADOS -----
  -- Plugins que vienen empaquetados con vim pero que no usamos. Apagarlos
  -- ahorra unos ms al startup. Notablemente netrw está aquí porque NvChad
  -- usa nvim-tree en su lugar.
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
