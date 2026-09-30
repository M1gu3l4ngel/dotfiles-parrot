-- ~/.config/nvim/lua/configs/conform.lua
-- Configuración de conform.nvim (formateador de código).
-- Define qué formatter usar para cada filetype y, opcionalmente, formateo
-- automático al guardar.
-- Lo carga el plugin spec en lua/plugins/init.lua mediante `opts = require "configs.conform"`.

local options = {
  -- ----- FORMATEADORES POR FILETYPE -----
  -- Para añadir un lenguaje: mapearlo aquí y ejecutar `:MasonInstallAll`
  -- (NvChad instala vía Mason los formatters listados en esta tabla).
  formatters_by_ft = {
    lua = { "stylua" },
    sh = { "shfmt" },
    bash = { "shfmt" },
  },

  -- ----- OPCIONES POR FORMATTER -----
  -- shfmt: 2 espacios (convención del repo para shell) y `case` indentado.
  formatters = {
    shfmt = { prepend_args = { "-i", "2", "-ci" } },
  },

  -- ----- FORMATEO AL GUARDAR (DESACTIVADO) -----
  -- Descomentar para auto-formatear cada vez que se hace :w.
  -- format_on_save = {
  --   timeout_ms = 500,
  --   lsp_fallback = true,  -- si no hay conform formatter, usar el del LSP
  -- },
}

return options
