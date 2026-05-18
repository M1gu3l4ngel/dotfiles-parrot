-- ~/.config/nvim/lua/configs/lspconfig.lua
-- Configuración de LSP (Language Server Protocol).
-- Carga primero los defaults de NvChad (que ya define on_attach y capabilities
-- razonables) y luego habilita los servidores que queremos usar.
--
-- Para añadir un lenguaje:
--   1. Instalar el servidor con `:MasonInstall <nombre>` o vía paquetes del sistema
--   2. Añadirlo a la tabla `servers` aquí abajo
--
-- Ver opciones por servidor en `:h vim.lsp.config`.

require("nvchad.configs.lspconfig").defaults()

-- ----- SERVIDORES HABILITADOS -----
-- html  = HTML (vscode-html-language-server)
-- cssls = CSS (vscode-css-language-server)
local servers = { "html", "cssls" }
vim.lsp.enable(servers)
