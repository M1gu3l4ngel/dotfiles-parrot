-- ~/.config/nvim/lua/autocmds.lua
-- Auto-comandos: hooks que disparan acciones en eventos de nvim
-- (al abrir un buffer, al guardar, al cambiar de filetype, etc.).
-- Por ahora solo se cargan los defaults de NvChad. Si quieres añadir uno,
-- se hace así:
--   vim.api.nvim_create_autocmd("BufWritePre", { pattern = "*.lua", callback = ... })

require "nvchad.autocmds"
