# Convenciones del proyecto

Este repo es mi setup personal de dotfiles para Parrot Security
(bspwm + polybar + kitty + zsh + nvim), basado en el curso de S4vitar.

## Git

- NO ejecutar comandos git (commit, add, push, pull) sin permiso explícito del
  usuario; solo sugerir commit names.
- Formato: `type(scope): descripción en español` — una sola línea, type en
  inglés (feat, fix, docs, style, refactor, chore), descripción en ESPAÑOL.
  Ejemplo: `docs(bspwm): mejorar comentarios del archivo bspwmrc`.
- Proponer UN solo commit por bloque de trabajo, aunque se hayan tocado varios
  archivos o hecho varias cosas: un único `git add` con los archivos
  implicados y un único mensaje de una línea que resuma el conjunto.

## Estilo

- Comentarios en **español**.
- Indentación según convención del lenguaje:
    - **Markdown:** 4 espacios.
    - **Shell scripts (.sh, bspwmrc, install.sh, launch.sh, scripts/\*):** 2 espacios.
    - **Lua (nvim):** 2 espacios (forzado por `nvim/.config/nvim/.stylua.toml`).
    - **sxhkdrc:** tabs (convención de sxhkd).
    - **picom.conf / rofi.rasi / polybar .ini:** 2 espacios donde aplique.
- Máximo 1 línea en blanco consecutiva.
- Header explicativo al inicio de cada archivo de config: qué hace, dónde lo
  carga el sistema, cómo recargarlo.
- Secciones agrupadas con comentarios de tipo `# ----- SECCIÓN -----` (o
  `;; ----- SECCIÓN -----` en archivos .ini, `-- ----- SECCIÓN -----` en Lua).
- Para bloques grandes usar también separadores `# ====...====` con título.
- Comentarios pedagógicos: explicar el **porqué**, no el **qué**.
    - Mal: `# Set border width`
    - Bien: `# Ancho del borde de ventana en píxeles. Mientras más alto, mayor
      el feedback visual al hacer focus`.
- **No mencionar a S4vitar, ni al curso, ni al autor original** en los
  comentarios. La justificación técnica de cada decisión debe sostenerse por
  sí sola.

## Archivos protegidos (NO MODIFICAR)

- `LICENSE`
- `README.md`
- `assets/`
- `zsh/.p10k.zsh` — auto-generado por Powerlevel10k.
- `nvim/.config/nvim/lazy-lock.json` — lock file de lazy.nvim.
- `nvim/.config/nvim/LICENSE` y `nvim/.config/nvim/README.md` — heredados
  del template de NvChad.
- Cualquier cosa dentro de `.git/`.

## Estructura del repo

Cada componente sigue el patrón `<componente>/.config/<componente>/<archivo>`
para que `install.sh` pueda crear los symlinks directamente a `~/.config/`.

- `bspwm/.config/bspwm/bspwmrc` — config del window manager.
- `sxhkd/.config/sxhkd/sxhkdrc` — atajos de teclado.
- `picom/.config/picom/picom.conf` — compositor (sombras, blur, fades).
- `polybar/.config/polybar/` — barras (`current.ini` + `workspace.ini`),
  paleta (`colors.ini`) y lanzador (`launch.sh`). Los módulos son scripts de
  `scripts/.config/scripts/`.
- Glifos de iconos (Nerd Font: rango PUA) NUNCA literales en ningún archivo:
  las herramientas de edición los borran. Van en scripts como escapes `$'\x..'`
  (ver `scripts/.config/scripts/*_module.sh`).
- `rofi/.config/rofi/` — menú de aplicaciones (config + temas).
- `kitty/.config/kitty/` — terminal (`kitty.conf` + `color.ini`).
- `dunst/.config/dunst/` — notificaciones de escritorio (`dunstrc`).
- `xkb/.config/xkb/` — keymap de la sesión (`keymap.xkb`) y símbolos propios
  (`symbols/capsfix`: Caps Lock que se apaga al pulsar). Lo carga bspwmrc
  con xkbcomp; validar con `xkbcomp -w 0 -I<dir> keymap.xkb <salida.xkm>`.
- `zsh/.zshrc` — shell interactiva.
- `scripts/.config/scripts/` — scripts custom invocados por polybar
  (estado VPN, Ethernet, target de pentest).
- `nvim/.config/nvim/` — Neovim con NvChad como base.

## Reload de configs

Usar los atajos ya configurados; no hacer kill/killall/pkill:

- **bspwm:** `Super+Alt+R` (recarga bspwmrc en caliente).
- **sxhkd:** `Super+Escape` (relee sxhkdrc).
- **polybar:** ejecutar `~/.config/polybar/launch.sh` (mata las instancias
  y las relanza), o `Super+Alt+R` (reinicia bspwm, que relanza polybar).
- **picom:** se recarga solo al guardar `picom.conf` (vigila el archivo).
- **dunst:** `dunstctl reload`. Probar el aspecto con
  `notify-send -u low|normal|critical "Título" "Texto"`.
- **kitty:** `Ctrl+Shift+F5` desde dentro de kitty.
- **zsh:** `exec zsh` (reemplaza el proceso con uno nuevo).
- **nvim:** cerrar y reabrir, o `:source %` para recargar el archivo abierto.

## Validación

Antes de marcar un archivo como completado, validar sintaxis:

- Shell scripts: `bash -n <archivo>` o `sh -n <archivo>`.
- zsh: `zsh -n <archivo>`.
- picom: `picom --config <archivo> --diagnostics`.
- polybar: `polybar --config=<archivo> --dump=<key> <bar>` para resolver valores.
- rofi: `rofi -dump-config -config <archivo>`.
- kitty: `kitty +runpy 'import kitty.config; ...'` para inspeccionar valores.
- Lua (nvim): `nvim --headless -c "lua loadfile('<archivo>')" -c "qa!"`.

Si la herramienta no está instalada, decirlo y seguir.

## Tareas comunes

- **Añadir un keybind nuevo:** editar `sxhkd/.config/sxhkd/sxhkdrc`, recargar
  con `Super+Escape`.
- **Añadir un módulo a polybar:** definirlo en `current.ini` o `workspace.ini`
  (sección `[module/...]`) y referenciarlo en `modules-center` del bar deseado;
  recargar con `~/.config/polybar/launch.sh`.
- **Cambiar tema de rofi:** editar `rofi/.config/rofi/config.rasi`, comentar
  la línea `@theme` actual y descomentar la nueva.
- **Cambiar tema de polybar:** copiar el contenido de `colors_dark.ini` o
  `colors_light.ini` sobre `colors.ini` y recargar polybar.
- **Cambiar tema de nvim:** editar `nvim/.config/nvim/lua/chadrc.lua`,
  cambiar `M.base46.theme`. Para listar temas: `<leader>th` dentro de nvim.
