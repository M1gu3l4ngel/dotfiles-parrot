---
# Rutas explícitas para lo que vive bajo `.config/`: los globs `**` no entran
# en directorios ocultos, así que `**/bspwmrc` no coincidiría con nada.
paths:
  - "**/*.sh"
  - "bspwm/.config/bspwm/bspwmrc"
  - "bspwm/.config/bspwm/scripts/*"
  - "polybar/.config/polybar/launch.sh"
  - "scripts/.config/scripts/*"
  - "system/sbin/*"
  - "tools/*"
  - "zsh/.zshrc"
---

# Scripts de shell

- Scripts nuevos en bash con `set -euo pipefail`; en `sh` (POSIX), `set -eu`.
- shellcheck sin avisos (`./tools/check.sh`). Formato con shfmt: `-i 2 -ci`.
- En `#!/bin/sh` nada de bashismos: `sh` es dash. Ejemplo real: `$UID` no
  existe en dash (usar `id -u`), y rompía la espera de `polybar/launch.sh`.
- Variables siempre entre comillas; `$(...)` en vez de backticks; arrays para
  comandos con argumentos (`cmd=(rofi -theme "$tema")`).
- Idempotencia: comprobar el estado antes de actuar, para que ejecutar dos
  veces no duplique nada (`install.sh`, `system/setup.sh` y `bootstrap.sh` lo
  cumplen).
- Scripts que polybar ejecuta cada segundo: sin procesos externos si se puede
  (`read` en vez de `cat`/`awk`). Cada fork por segundo suma CPU en todo el
  escritorio.
- Nunca `kill`, `killall` ni `pkill` para recargar: usar las recargas de
  `CLAUDE.md`. `bspwmrc` lanza los demonios con `run_once` para no duplicarlos
  en cada recarga.
- `sudo -n` en scripts no interactivos: falla en vez de colgarse pidiendo
  contraseña. Solo funciona con comandos autorizados en `system/sudoers.d/`.

## zsh (`.zshrc`)

- Validar con `zsh -n`; shellcheck no soporta zsh.
- `zsh-syntax-highlighting` se carga el último: envuelve los widgets que
  existen en ese momento.
- PATH con el array `path` y `typeset -U path`, nunca `export PATH=` con una
  lista fija.
