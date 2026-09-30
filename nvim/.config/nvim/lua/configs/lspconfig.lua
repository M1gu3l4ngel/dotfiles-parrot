-- ~/.config/nvim/lua/configs/lspconfig.lua
-- Configuración de LSP (Language Server Protocol).
-- Carga primero los defaults de NvChad (que ya define on_attach y capabilities
-- razonables) y luego habilita los servidores que queremos usar.
--
-- Para añadir un lenguaje: añadirlo a la tabla `servers` y ejecutar
-- `:MasonInstallAll` dentro de nvim. NvChad deduce qué paquetes de Mason
-- instalar a partir de esta tabla, así que no hay que instalarlos a mano.
--
-- Ver opciones por servidor en `:h vim.lsp.config`.

require("nvchad.configs.lspconfig").defaults()

-- ----- SERVIDORES HABILITADOS -----
-- Elegidos según lo que se edita en este repo:
-- lua_ls = Lua (la propia config de nvim); NvChad ya le pasa el runtime de
--          nvim para que reconozca la API `vim.*` sin falsos errores.
-- bashls = shell scripts (install.sh, bspwmrc, scripts de polybar). Si
--          shellcheck está instalado, lo usa para marcar bugs comunes de bash.
local servers = { "lua_ls", "bashls" }
vim.lsp.enable(servers)
