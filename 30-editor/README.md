**English** | [Español](README.es.md)

# 30-editor

The two code editors: Neovim with NvChad in the terminal, and VSCodium with the same style as VS
Code in [dotfiles-windows](https://github.com/M1gu3l4ngel/dotfiles-windows).

| Path | Linked to | What it is |
|---|---|---|
| `nvim/.config/nvim/` | `~/.config/nvim/` | Neovim with NvChad: `init.lua`, options, mappings, plugins and formatting (conform) |
| `vscodium/settings.json` | `~/.config/Visual Studio Code/User/settings.json` | Settings: Monokai for the code, the desktop palette for the interface, format on save |
| `vscodium/keybindings.json` | `~/.config/Visual Studio Code/User/keybindings.json` | Shortcuts, the same as VS Code on Windows |
| `vscodium/extensions.txt` | Not linked | Extensions from Open VSX that `bootstrap.sh` installs (only the missing ones) |

`install.sh` creates the links. Parrot's VSCodium reads its settings from `Visual Studio Code`,
not from `VSCodium`. The official Neovim, which NvChad needs, is installed by `bootstrap.sh` in
`/opt`; apt's is several versions behind.

## What not to touch

- `nvim/.config/nvim/lazy-lock.json`: the plugin lock file, updated with `:Lazy update`.
- `nvim/.config/nvim/LICENSE` and `nvim/.config/nvim/README.md`: inherited from the NvChad
  template.

## Reload

- Neovim: reopen it, or `:source %` on the edited file.
- VSCodium: settings and shortcuts apply on save.
