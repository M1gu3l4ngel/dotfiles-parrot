**English** | [Español](README.es.md)

# 20-terminal

kitty, the default terminal (`Super+Enter`).

| Path | Linked to | What it is |
|---|---|---|
| `kitty/.config/kitty/kitty.conf` | `~/.config/kitty/` (the folder) | Font (CaskaydiaCove Nerd Font 12), window and tab shortcuts, zsh as the shell |
| `kitty/.config/kitty/color.ini` | `~/.config/kitty/` (the folder) | The Monokai Soda palette, the same as Windows Terminal; `kitty.conf` includes it first, so a value set again there wins |

`install.sh` links the whole folder. The shortcuts are listed in the
[README](../README.md#shortcuts).

## Reload

Inside kitty: `Ctrl+Shift+F5`.
