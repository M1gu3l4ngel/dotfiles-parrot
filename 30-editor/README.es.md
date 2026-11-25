[English](README.md) | **Español**

# 30-editor

Los dos editores de código: Neovim con NvChad en la terminal, y VSCodium con el mismo estilo que VS
Code en [dotfiles-windows](https://github.com/M1gu3l4ngel/dotfiles-windows).

| Ruta | Se enlaza en | Qué es |
|---|---|---|
| `nvim/.config/nvim/` | `~/.config/nvim/` | Neovim con NvChad: `init.lua`, opciones, atajos, plugins y formato (conform) |
| `vscodium/settings.json` | `~/.config/Visual Studio Code/User/settings.json` | Ajustes: Monokai para el código, la paleta del escritorio para la interfaz, formato al guardar |
| `vscodium/keybindings.json` | `~/.config/Visual Studio Code/User/keybindings.json` | Atajos, los mismos que VS Code en Windows |
| `vscodium/extensions.txt` | No se enlaza | Extensiones de Open VSX que instala `bootstrap.sh` (solo las que faltan) |

`install.sh` crea los enlaces. El VSCodium de Parrot lee sus ajustes de `Visual Studio Code`, no de
`VSCodium`. El Neovim oficial, que necesita NvChad, lo instala `bootstrap.sh` en `/opt`; el de apt
va varias versiones por detrás.

## Qué no tocar

- `nvim/.config/nvim/lazy-lock.json`: el lock de los plugins, que se actualiza con `:Lazy update`.
- `nvim/.config/nvim/LICENSE` y `nvim/.config/nvim/README.md`: heredados de la plantilla de
  NvChad.

## Recargar

- Neovim: reabrirlo, o `:source %` en el archivo editado.
- VSCodium: los ajustes y los atajos se aplican al guardar.
