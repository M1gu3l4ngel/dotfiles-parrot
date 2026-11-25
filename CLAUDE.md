# dotfiles-parrot

Dotfiles para Parrot OS con bspwm, sxhkd, polybar, picom, rofi, kitty, dunst,
zsh y Neovim (NvChad). Repo público.

Los componentes van en carpetas numeradas por capa, como en dotfiles-windows:
`10-shell`, `15-git`, `20-terminal`, `25-desktop`, `30-editor`, `40-format`,
`60-apps` (lista de apt que lee `bootstrap.sh`) y `70-system`. Dentro, cada componente sigue el patrón
`<capa>/<componente>/.config/<componente>/`, que `install.sh` enlaza en
`~/.config/` según `lib/links.sh`. `70-system/` se instala como copias con root.

## Idioma del código: inglés

En este repo los **comentarios de código, las salidas de los scripts, los nombres de los pasos
del CI y los nombres de los tests van en inglés**, con la forma de
`docs/contributing/comments.md`, como dice también la regla global de `~/.claude/CLAUDE.md`.
Siguen en español: los `.es.md`, este archivo, `.claude/rules/`, `docs/tasks.md`,
`docs/backlog.md` y los textos que ve el usuario en el escritorio (notificaciones, menús de
rofi). `./tools/check.sh` falla ante un comentario en español.

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
| Instalación completa | `./bootstrap.sh` |
| Solo symlinks (lista en `lib/links.sh`) | `./install.sh` |
| Quitar los symlinks y restaurar originales | `./uninstall.sh` (`--dry-run` para simular) |
| Hardening del sistema | `sudo ./70-system/setup.sh` |
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
