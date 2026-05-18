-- ~/.config/nvim/lua/configs/conform.lua
-- Configuración de conform.nvim (formateador de código).
-- Define qué formatter usar para cada filetype y, opcionalmente, formateo
-- automático al guardar.
-- Lo carga el plugin spec en lua/plugins/init.lua mediante `opts = require "configs.conform"`.

local options = {
  -- ----- FORMATEADORES POR FILETYPE -----
  -- Para añadir un lenguaje: instalar el formatter en el sistema y mapearlo aquí.
  -- conform.nvim lo invocará automáticamente al hacer :Format o, si se activa,
  -- al guardar el buffer.
  formatters_by_ft = {
    lua = { "stylua" },
    -- css = { "prettier" },
    -- html = { "prettier" },
  },

  -- ----- FORMATEO AL GUARDAR (DESACTIVADO) -----
  -- Descomentar para auto-formatear cada vez que se hace :w.
  -- format_on_save = {
  --   timeout_ms = 500,
  --   lsp_fallback = true,  -- si no hay conform formatter, usar el del LSP
  -- },
}

return options
