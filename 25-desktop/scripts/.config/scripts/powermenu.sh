#!/bin/bash
# The session menu in rofi (power off, reboot, log out), opened by polybar's power button
# ([module/power] in current.ini). It asks for the action instead of powering off on one click, so a
# wrong click does not close everything that is open; Esc or "Cancelar" close it doing nothing.
#
# systemctl powers off and reboots after closing the programs and writing everything pending to
# disk: a hard VM cut can leave empty files (it happened to git objects). No password: polkit
# allows it to the active local session.

set -euo pipefail

# Icons as UTF-8 escapes (literal PUA glyphs are lost on editing).
ICON_POWEROFF=$'\xef\x80\x91'   # power-off (U+F011)
ICON_REBOOT=$'\xf3\xb0\x9c\x89' # nf-md-restart (U+F0709)
ICON_LOGOUT=$'\xf3\xb0\x8d\x83' # nf-md-logout (U+F0343)
ICON_CANCEL=$'\xf3\xb0\x85\x96' # nf-md-close (U+F0156)

POWEROFF="$ICON_POWEROFF  Apagar"
REBOOT="$ICON_REBOOT  Reiniciar"
LOGOUT="$ICON_LOGOUT  Cerrar sesión"
CANCEL="$ICON_CANCEL  Cancelar"

# The same theme as Super+D (config.rasi), narrower and with no search box: arrows and Enter or the
# mouse only. -no-custom keeps typed text from running. Esc makes rofi exit with an error, which
# here means cancel, not a failure.
choice=$(printf '%s\n' "$POWEROFF" "$REBOOT" "$LOGOUT" "$CANCEL" |
  rofi -dmenu -i -no-custom -p "Sesión" \
    -theme-str 'window { width: 300px; } listview { lines: 4; } inputbar { enabled: false; }' ||
  true)

case "$choice" in
  "$POWEROFF") systemctl poweroff ;;
  "$REBOOT") systemctl reboot ;;
  # Quitting bspwm goes back to the login screen.
  "$LOGOUT") bspc quit ;;
  *) ;; # Cancel or Esc: nothing to do.
esac
