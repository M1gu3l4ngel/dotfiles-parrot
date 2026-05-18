# Contribuir

¡Gracias por interesarte en contribuir! Este documento describe las
convenciones del repo: cómo hacer commits, cómo nombrar cosas, qué
archivos no tocar y cómo añadir features comunes (keybinds, módulos de
polybar, temas, etc.).

## Convenciones de commits

Formato:

```
type(scope): descripción en español
```

- **Type** (en inglés): `feat`, `fix`, `docs`, `style`, `refactor`, `chore`.
- **Scope** (opcional): componente afectado, p. ej. `bspwm`, `polybar`,
  `zsh`, `nvim`, `scripts`.
- **Descripción** en español, una sola línea, ≤ 72 caracteres.

Ejemplos:

```
docs(bspwm): mejorar comentarios del archivo bspwmrc
feat(polybar): añadir módulo de temperatura
fix(scripts): corregir interfaz hardcodeada en vpn_status.sh
chore: actualizar README con sección de troubleshooting
```

Si el cambio amerita más contexto, añade un cuerpo después de una línea
en blanco (formato GitHub estándar).

## Estilo de código

### Idioma de los comentarios

- **Español.** Coincide con el README y con el resto de los comentarios.

### Indentación (varía según el lenguaje)

| Tipo de archivo | Indentación |
|---|---|
| Markdown | 4 espacios |
| Shell (`.sh`, `bspwmrc`, `install.sh`, `launch.sh`, `polybar/scripts/*`) | 2 espacios |
| Lua (Neovim) | 2 espacios (lo fuerza `nvim/.config/nvim/.stylua.toml`) |
| sxhkd (`sxhkdrc`) | tabs (convención de sxhkd) |
| picom (`picom.conf`), rofi (`*.rasi`), polybar (`*.ini`) | 2 espacios |

El `.editorconfig` de la raíz aplica estas reglas automáticamente en
cualquier editor moderno (VS Code, Neovim, JetBrains, Sublime).

### Estructura de los archivos de config

- **Header explicativo** al inicio: qué hace el archivo, dónde lo carga
  el sistema, cómo recargarlo si aplica.
- **Secciones agrupadas** con comentarios de tipo:
    - `# ----- SECCIÓN -----` en shell.
    - `;; ----- SECCIÓN -----` en archivos `.ini`.
    - `-- ----- SECCIÓN -----` en Lua.
- Para bloques grandes, usar separadores `# ====...====` con título.
- **Comentarios pedagógicos:** explicar el **porqué**, no el **qué**.
    - Mal: `# Set border width`
    - Bien: `# Ancho del borde de ventana en píxeles. Mientras más alto,
      mayor el feedback visual al hacer focus`
- Máximo **1 línea en blanco** consecutiva.

## Archivos protegidos (no tocar en PRs)

- `LICENSE`
- `README.md` (solo PRs explícitamente de documentación)
- `assets/` (excepto añadir wallpapers nuevos)
- `zsh/.p10k.zsh` — auto-generado por Powerlevel10k.
- `nvim/.config/nvim/lazy-lock.json` — lock file de lazy.nvim.
- `nvim/.config/nvim/LICENSE` y `nvim/.config/nvim/README.md` — heredados
  del template de NvChad.
- Cualquier cosa dentro de `.git/`.

## Estructura del repo

Cada componente sigue el patrón `<componente>/.config/<componente>/<archivo>`
para que `install.sh` cree los symlinks directos a `~/.config/`.

```
bspwm/.config/bspwm/    bspwmrc + scripts/bspwm_resize
sxhkd/.config/sxhkd/    sxhkdrc
picom/.config/picom/    picom.conf
polybar/.config/polybar/  current.ini, workspace.ini, colors*.ini, launch.sh, scripts/
rofi/.config/rofi/      config.rasi + themes/
kitty/.config/kitty/    kitty.conf + color.ini
nvim/.config/nvim/      NvChad como base
scripts/.config/scripts/  ethernet_status, vpn_status, victim_to_hack
zsh/                    .zshrc + .p10k.zsh
```

## Reload de configs (sin reiniciar sesión)

| Componente | Cómo recargar |
|---|---|
| bspwm | `Super+Alt+R` (recarga bspwmrc en caliente) |
| sxhkd | `Super+Escape` |
| polybar | `~/.config/polybar/launch.sh` (mata y relanza); o `Super+Shift+R` si está bindeado |
| kitty | `Ctrl+Shift+F5` desde dentro de kitty |
| zsh | `exec zsh` |
| nvim | cerrar y reabrir, o `:source %` para el archivo abierto |

Evita `kill/killall/pkill` directos — usa los reload nativos.

## Validar antes de enviar un PR

| Archivo | Comando |
|---|---|
| Shell scripts | `bash -n <archivo>` o `sh -n <archivo>` |
| zsh | `zsh -n <archivo>` |
| picom | `picom --config <archivo> --diagnostics` |
| polybar | `polybar --config=<archivo> --dump=<key> <bar>` |
| rofi | `rofi -dump-config -config <archivo>` |
| kitty | `kitty +runpy 'import kitty.config; ...'` |
| Lua (nvim) | `nvim --headless -c "lua loadfile('<archivo>')" -c "qa!"` |

## Tareas comunes

### Añadir un keybind nuevo

Editar `sxhkd/.config/sxhkd/sxhkdrc` siguiendo el formato:

```
super + shift + n
	notify-send "hola"
```

Recargar con `Super+Escape`.

### Añadir un módulo a polybar

1. Definirlo en `current.ini` o `workspace.ini` con `[module/<nombre>]`.
2. Añadirlo a `modules-center` (o `modules-left`/`modules-right`) del bar
   que quieras.
3. Recargar con `~/.config/polybar/launch.sh`.

### Cambiar tema de rofi

Editar `rofi/.config/rofi/config.rasi`, comentar el `@theme` actual y
descomentar el nuevo. Los temas viven en `rofi/.config/rofi/themes/`.

### Cambiar tema de polybar (dark / light)

Copiar el contenido de `colors_dark.ini` o `colors_light.ini` sobre
`colors.ini` y recargar polybar.

### Cambiar tema de Neovim

Editar `nvim/.config/nvim/lua/chadrc.lua`, cambiar `M.base46.theme`.
Para listar temas disponibles desde nvim: `<leader>th`.

## Reportar bugs / sugerir features

- Abrir un issue en GitHub con un título corto y descriptivo.
- Incluir tu versión de Parrot/Debian/Ubuntu y de polybar/bspwm si aplica.
- Para bugs visuales: una captura de pantalla ayuda mucho.

¡Gracias!
