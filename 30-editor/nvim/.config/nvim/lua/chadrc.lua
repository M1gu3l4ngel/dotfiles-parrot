-- NvChad's UI settings (theme, statusline, dashboard, tabline). It follows the structure of
-- NvChad's nvconfig.lua, which documents every option:
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua

---@type ChadrcConfig
local M = {}

-- monekai is NvChad's take on the classic Monokai. <leader>th lists the themes inside nvim;
-- hl_override changes a highlight without forking the theme.
M.base46 = {
  theme = "monekai",
}

return M
