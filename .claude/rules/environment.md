# Entorno de ejecución

Parrot OS 7 (Debian 13 trixie) en VMware. Estos hechos no se deducen del
código y ya causaron problemas reales.

## Sesión gráfica

- bspwm solo funciona en X11. En el login hay que elegir la sesión `bspwm`,
  nunca una de Wayland.

## GPU en VMware y picom

- Requiere "Accelerate 3D graphics" activado en VM Settings -> Display.
- `glxinfo -B` y `picom --diagnostics` muestran `Accelerated: no` aunque la
  GPU funcione: es un falso positivo del driver vmwgfx. Lo que confirma la
  aceleración es el renderer `SVGA3D`; `llvmpipe` significaría renderizado por
  software.
- Por eso picom usa el backend `glx`. `xrender` compone en la CPU y hace que
  cambiar de workspace se sienta lento.

## polybar

- Nunca `interval = 0` en un `custom/script`: polybar lo relanza en bucle sin
  pausa (llegó al 30 % de CPU constante). Para iconos estáticos, `86400`.
- En `%{TN}`, el índice empieza en 1: `%{T1}` es `font-0`.

## Fuentes

- Solo tres, instaladas por `bootstrap.sh` en `~/.local/share/fonts/NerdFonts/`
  (Nerd Fonts v3.5.1, SHA-256 fijado): Iosevka (polybar), Hack Mono (logo de
  Parrot en polybar) y CaskaydiaCove (kitty, dunst, rofi).
- Para añadir una fuente: agregarla a `bootstrap.sh` con su hash, no al repo.

## Teclado

- El keymap se carga con `xkbcomp` desde `xkb/.config/xkb/keymap.xkb`, no con
  `setxkbmap`: setxkbmap no admite el símbolo propio `capsfix`, que hace que
  Caps Lock se apague al pulsar (en XKB estándar se apaga al soltar).

## Shell

- Los cambios en `.zshrc` solo se aplican en la terminal donde se ejecuta
  `exec zsh`; cada terminal abierta conserva las funciones que cargó al abrirse.
