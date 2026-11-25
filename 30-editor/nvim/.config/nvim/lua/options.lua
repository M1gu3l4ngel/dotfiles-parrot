-- ~/.config/nvim/lua/options.lua
-- Opciones de editor (número de línea, indent, swap, etc.).
-- Carga primero los defaults de NvChad y luego se añaden overrides propios.
-- Para ver todas las opciones disponibles: :help option-list

require "nvchad.options"

-- Aquí van los overrides personalizados. Ejemplo de cómo hacerlo:
-- local o = vim.o
-- o.cursorlineopt = "both"  -- resaltar línea actual (no solo número)
