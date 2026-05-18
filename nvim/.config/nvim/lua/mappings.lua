-- ~/.config/nvim/lua/mappings.lua
-- Atajos de teclado personalizados.
-- Los defaults de NvChad ya cubren la mayoría (telescope, file tree, etc.);
-- aquí solo se añaden los propios.

require "nvchad.mappings"

local map = vim.keymap.set

-- ----- ATAJOS DE PRODUCTIVIDAD -----
-- `;` entra al modo comando sin tener que pulsar Shift. Atajo clásico de
-- vimmers que escriben muchos `:w`, `:q`, etc.
map("n", ";", ":", { desc = "CMD enter command mode" })

-- `jk` en modo insert sale a normal. Mucho más rápido que estirar al ESC
-- y evita pulsar Ctrl+[.
map("i", "jk", "<ESC>")

-- Ejemplo de keybind multi-modo (Ctrl+S para guardar en normal/insert/visual):
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
