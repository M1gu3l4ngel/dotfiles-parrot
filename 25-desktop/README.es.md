[English](README.md) | **Español**

# 25-desktop

La sesión gráfica: gestor de ventanas, atajos, barras, compositor, lanzador, notificaciones,
teclado y los scripts que hay detrás de los módulos de polybar. Todo usa la paleta Monokai Soda,
con los mismos valores en cada archivo.

| Ruta | Se enlaza en | Qué es | Recarga |
|---|---|---|---|
| `bspwm/.config/bspwm/bspwmrc` | `~/.config/bspwm/bspwmrc` | Gestor de ventanas: márgenes, bordes, reglas y el arranque de la sesión (keymap, picom, dunst, polybar, sxhkd) | `Super+Alt+R` |
| `bspwm/.config/bspwm/scripts/` | `~/.config/bspwm/scripts/` | `bspwm_resize`, al que llaman `Super+Alt+Flechas` | `Super+Alt+R` |
| `sxhkd/.config/sxhkd/sxhkdrc` | `~/.config/sxhkd/sxhkdrc` | Todos los atajos de teclado ([README](../README.es.md#atajos)) | `Super+Escape` |
| `polybar/.config/polybar/` | `~/.config/polybar/` | `current.ini` (barras de estado), `workspace.ini` (escritorios), `colors.ini` (paleta activa, con `colors_dark.ini` y `colors_light.ini` como variantes) y `launch.sh` | `Super+Alt+R`, o `~/.config/polybar/launch.sh` |
| `picom/.config/picom/picom.conf` | `~/.config/picom/` (la carpeta) | Compositor: sombras, transparencia, desenfoque y esquinas redondeadas, con el backend `glx` | Al guardar |
| `rofi/.config/rofi/` | `~/.config/rofi/` | Lanzador (`Super+D`) y menú de apagado; el tema activo es `themes/monokai-soda.rasi` | La próxima vez que se abre |
| `dunst/.config/dunst/dunstrc` | `~/.config/dunst/` (la carpeta) | Notificaciones, abajo a la derecha | `dunstctl reload` |
| `gtk/.config/gtk-4.0/` | `gtk.css` y `settings.ini` en `~/.config/gtk-4.0/` | Colores y ajustes de las apps GTK4 (Nautilus) | Cerrar y volver a abrir la app |
| `xkb/.config/xkb/` | `~/.config/xkb/` | Keymap: distribuciones us y latam (`Alt+Shift`) y el arreglo de Bloq Mayús (`symbols/capsfix`) | `Super+Alt+R` |
| `scripts/.config/scripts/` | `~/.config/scripts/` | Módulos de polybar (red, VPN, target, anonimato, Firefox, apagado), `palette.sh`, `powermenu.sh` y `toggle_anonymity.sh` | Con polybar |

`install.sh` crea los enlaces. En `gtk-4.0` solo se enlazan los dos archivos: otras apps guardan su
estado en esa carpeta.

## Qué no tocar

- `interval = 0` en un módulo `custom/script` de polybar: polybar lo relanza sin pausa y ocupa un
  núcleo de CPU.
- Iconos de Nerd Font como caracteres literales: las herramientas de edición los pierden. Viven en
  los scripts como escapes UTF-8 (`$'\xef\x8c\xa9'`), y por eso los iconos de polybar están en
  `scripts/` y no en los `.ini`.
- El keymap se carga con `xkbcomp`, no con `setxkbmap`: `setxkbmap` no puede cargar el símbolo
  propio `capsfix`.
- Nunca recargar con `kill`, `killall` ni `pkill`: usar las recargas de la tabla.

Colores, fuentes y fondo de pantalla: [docs/customization.es.md](../docs/customization.es.md).
