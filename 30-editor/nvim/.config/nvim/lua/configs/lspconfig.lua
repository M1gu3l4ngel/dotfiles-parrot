-- LSP: NvChad's defaults first (on_attach and capabilities), then the servers this repo needs. A
-- new language goes in `servers`, then `:MasonInstallAll` inside nvim: NvChad works out the Mason
-- packages from this table. Per-server options: `:h vim.lsp.config`.

require("nvchad.configs.lspconfig").defaults()

-- lua_ls for nvim's own config (NvChad gives it nvim's runtime, so the `vim.*` API raises no false
-- errors); bashls for the shell scripts, which uses shellcheck when it is installed.
local servers = { "lua_ls", "bashls" }
vim.lsp.enable(servers)
