-- ~/.config/nvim/lua/plugins/init.lua
-- Especificación de los plugins propios (los que no vienen ya con NvChad).
-- lazy.nvim los descubre porque init.lua hace `{ import = "plugins" }`.
-- Cada entrada de la tabla es un spec con la URL del plugin y, opcionalmente,
-- una función `config` o `opts` para configurarlo.

return {
  -- ----- FORMATEADOR DE CÓDIGO -----
  -- conform.nvim: invoca formateadores externos (stylua, prettier, etc.).
  -- Su config vive en configs/conform.lua.
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre',  -- descomentar para formateo automático al guardar
    opts = require "configs.conform",
  },

  -- ----- LSP -----
  -- nvim-lspconfig: configuraciones base para los servidores LSP.
  -- El setup específico (qué servidores habilitar) está en configs/lspconfig.lua.
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- ----- PLUGINS ADICIONALES (DESACTIVADOS) -----
  -- Plantillas listas para activar si quieres más features:

  -- Autocompletado experimental (blink.cmp en lugar del default cmp):
  -- { import = "nvchad.blink.lazyspec" },

  -- Treesitter (parsers para mejor syntax highlighting y selección por nodos):
  -- {
  --   "nvim-treesitter/nvim-treesitter",
  --   opts = {
  --     ensure_installed = {
  --       "vim", "lua", "vimdoc",
  --       "html", "css",
  --     },
  --   },
  -- },
}
