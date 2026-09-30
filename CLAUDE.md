# dotfiles-parrot

Dotfiles para Parrot OS con bspwm, sxhkd, polybar, picom, rofi, kitty, dunst,
zsh y Neovim (NvChad). Repo público.

Cada componente sigue el patrón `<componente>/.config/<componente>/`, que
`install.sh` enlaza en `~/.config/`. `system/` se instala como copias con root.

## Reglas

Las reglas detalladas están en `.claude/rules/` y se cargan solas:

- `security.md`: repo público, secretos, descargas verificadas, privilegios.
- `git.md`: formato de commits y qué no ejecutar.
- `file-edits.md`: cómo editar, glifos PUA y archivos protegidos.
- `style.md`: comentarios e indentación.
- `environment.md`: X11, GPU de VMware, polybar, fuentes, teclado.
- `shell.md`: scripts de shell y zsh (al tocar scripts).
- `documentation.md`: estilo de la documentación (al tocar `.md`).

## Comandos

| Tarea | Comando |
|---|---|
| Instalación completa | `./bootstrap.sh` (`--with-docker` opcional) |
| Solo symlinks | `./install.sh` |
| Hardening del sistema | `sudo ./system/setup.sh` |
| Comprobaciones (igual que el CI) | `./tools/check.sh` |

`./tools/check.sh` debe pasar antes de proponer un commit.

## Recargar configuraciones

Nunca con `kill`, `killall` ni `pkill`:

| Componente | Recarga |
|---|---|
| bspwm (y polybar) | `Super+Alt+R` |
| sxhkd | `Super+Escape` |
| polybar | `~/.config/polybar/launch.sh` |
| picom | Automática al guardar `picom.conf` |
| dunst | `dunstctl reload` |
| kitty | `Ctrl+Shift+F5` |
| zsh | `exec zsh` (en cada terminal abierta) |
| Neovim | Reabrir, o `:source %` |

## Validaciones que no cubre tools/check.sh

Requieren la sesión gráfica:

- picom: `picom --config <archivo> --diagnostics`
- polybar: `polybar --config=<archivo> --dump=<clave> <barra>`
- rofi: `rofi -dump-config -config <archivo>`
- dunst: `notify-send -u low|normal|critical "Título" "Texto"`
