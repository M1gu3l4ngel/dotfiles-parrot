-- ~/.config/nvim/lua/chadrc.lua
-- Config de la UI de NvChad (tema, statusline, dashboard, tabline, etc.).
-- Debe tener la misma estructura que el nvconfig.lua de NvChad:
--   https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Esa referencia documenta TODAS las opciones disponibles.

---@type ChadrcConfig
local M = {}

-- ----- TEMA -----
-- monekai = variante del clásico Monokai adaptada por NvChad.
-- Para listar todos los temas disponibles: <leader>th dentro de nvim.
M.base46 = {
  theme = "monekai",

  -- Ejemplo de cómo customizar highlights del tema sin tener que forkearlo:
  -- hl_override = {
  --   Comment = { italic = true },
  --   ["@comment"] = { italic = true },
  -- },
}

-- ----- OTROS MÓDULOS DESACTIVADOS -----
-- M.nvdash = { load_on_startup = true }      -- dashboard al abrir nvim sin argumento
-- M.ui = {
--   tabufline = {
--     lazyload = false                       -- mostrar la tabline siempre, no diferida
--   }
-- }

return M
