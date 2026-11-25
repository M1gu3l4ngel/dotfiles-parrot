[English](README.md) | **Español**

# 10-shell

La shell y su prompt. zsh carga el mismo tema de oh-my-posh que PowerShell en
[dotfiles-windows](https://github.com/M1gu3l4ngel/dotfiles-windows), así que el prompt se ve igual
en las dos máquinas.

| Ruta | Se enlaza en | Qué es |
|---|---|---|
| `zsh/.zshrc` | `~/.zshrc` | zsh interactiva: historial, plugins de apt (autosugerencias y resaltado de sintaxis), alias de `bat` y `lsd`, `settarget` y `cleartarget` para el target de polybar, `demo` para capturas y nvm cargado al primer uso |
| `oh-my-posh/capr4n.omp.json` | Se lee en su sitio | Tema del prompt, compartido con dotfiles-windows |

`install.sh` crea el enlace. `.zshrc` encuentra el tema a través de su propio enlace, así que el
repo funciona clonado en cualquier carpeta.

## Recargar

En cada terminal abierta (cada una conserva lo que cargó al abrirse):

```bash
exec zsh
```
