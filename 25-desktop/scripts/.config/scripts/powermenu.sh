#!/bin/bash
# ~/.config/scripts/powermenu.sh
# Menú de sesión con rofi: apagar, reiniciar o cerrar sesión. Lo abre el botón
# de apagado de polybar ([module/power] en current.ini).
#
# Pide elegir la acción en vez de apagar con un solo click: el botón está
# junto al de anonimato y un click equivocado cerraría todo lo abierto. Esc o
# "Cancelar" cierran el menú sin hacer nada.
#
# Apaga y reinicia con systemctl, que cierra los programas y escribe en disco
# todo lo pendiente antes de apagar: un corte brusco de la VM puede dejar
# archivos vacíos (ya ocurrió con objetos de git). No pide contraseña: polkit
# lo permite a la sesión local activa.

set -euo pipefail

# Iconos como escapes UTF-8 (los glifos PUA literales se pierden al editar).
ICON_POWEROFF=$'\xef\x80\x91'   # power-off (U+F011)
ICON_REBOOT=$'\xf3\xb0\x9c\x89' # nf-md-restart (U+F0709)
ICON_LOGOUT=$'\xf3\xb0\x8d\x83' # nf-md-logout (U+F0343)
ICON_CANCEL=$'\xf3\xb0\x85\x96' # nf-md-close (U+F0156)

POWEROFF="$ICON_POWEROFF  Apagar"
REBOOT="$ICON_REBOOT  Reiniciar"
LOGOUT="$ICON_LOGOUT  Cerrar sesión"
CANCEL="$ICON_CANCEL  Cancelar"

# Mismo tema que Super+D (config.rasi), más estrecho y sin buscador: solo se
# elige con flechas/Enter o con el ratón. -no-custom impide ejecutar texto
# escrito a mano. `|| true`: Esc hace que rofi salga con error, y eso no es
# un fallo sino "cancelar".
choice=$(printf '%s\n' "$POWEROFF" "$REBOOT" "$LOGOUT" "$CANCEL" |
  rofi -dmenu -i -no-custom -p "Sesión" \
    -theme-str 'window { width: 300px; } listview { lines: 4; } inputbar { enabled: false; }' ||
  true)

case "$choice" in
  "$POWEROFF") systemctl poweroff ;;
  "$REBOOT") systemctl reboot ;;
  # bspc quit cierra bspwm y vuelve a la pantalla de login.
  "$LOGOUT") bspc quit ;;
  *) ;; # Cancelar o Esc: no hacer nada.
esac
