-- ~/.config/nvim/init.lua
-- Entry point de Neovim. Se carga primero al arrancar nvim.
-- Su trabajo es:
--   1. Bootstrap del package manager (lazy.nvim) si no está clonado todavía
--   2. Cargar NvChad como base + los plugins propios definidos en lua/plugins/
--   3. Cargar el tema cacheado (base46) para evitar parpadeos al abrir
--   4. Cargar nuestras opciones, autocmds y mappings (en ese orden)
--
-- Para abrir nvim: `nvim` desde cualquier terminal.

-- Ruta donde NvChad cachea los temas compilados (base46 = sistema de highlights).
vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
-- Tecla líder = barra espaciadora. Se usa como prefijo en casi todos los
-- atajos custom (ej. <leader>f para buscar archivos).
vim.g.mapleader = " "

-- ----- BOOTSTRAP DE LAZY.NVIM -----
-- Si la primera vez que se abre nvim no existe lazy.nvim, se clona aquí.
-- Después de eso, vim.opt.rtp:prepend lo añade al runtimepath para poder usarlo.
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

-- Config del propio lazy.nvim (lazy-loading, performance, etc.).
local lazy_config = require "configs.lazy"

-- ----- CARGA DE PLUGINS -----
-- NvChad se importa con lazy=false para que sus defaults estén disponibles
-- de inmediato. Después se importan los plugins propios desde lua/plugins/.
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- ----- CARGA DEL TEMA (CACHE BASE46) -----
-- Cargar los archivos pre-compilados evita recompilar highlights en cada
-- arranque. Si se cambia el tema en chadrc.lua, NvChad regenera este cache.
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

-- ----- USER CONFIG -----
-- options y autocmds se cargan síncronamente para que estén listos antes de
-- abrir el buffer inicial. mappings se difiere con vim.schedule para evitar
-- bloquear el startup (los keymaps no son críticos en los primeros ms).
require "options"
require "autocmds"

vim.schedule(function()
  require "mappings"
end)
