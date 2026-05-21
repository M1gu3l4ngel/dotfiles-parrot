#!/usr/bin/env sh
# ~/.config/polybar/launch.sh
# Lanzador de polybar. Mata cualquier instancia previa y arranca todas las
# barras del setup (workspaces, VPN, ethernet, target, power-menu, log).
#
# Lo invoca bspwmrc al iniciar la sesión, pero también se puede ejecutar
# manualmente para recargar todas las barras:
#   ~/.config/polybar/launch.sh
# Atajo equivalente: Super+Shift+R (si está bindeado en sxhkdrc).

# ----- LIMPIAR INSTANCIAS PREVIAS -----
# killall -q: silenciar el error si no había ninguna corriendo (idempotente).
killall -q polybar

# Esperar a que los procesos terminen del todo antes de relanzar; si no, las
# nuevas instancias pueden chocar con las viejas en el socket de IPC.
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# ----- BARRAS QUE USAN current.ini -----
# Cada `-c` apunta al archivo de config; el primer argumento es el nombre del
# bloque [bar/<nombre>] dentro de ese archivo.

# Barra estrecha izquierda con etiqueta/icono.
polybar log -c ~/.config/polybar/current.ini &
# Estado de la interfaz Ethernet (IP local o "down").
polybar ethernet_bar -c ~/.config/polybar/current.ini &
# Estado de la VPN (HTB / THM / desconectada).
polybar vpn_bar -c ~/.config/polybar/current.ini &

# IP de la víctima cuando se exporta $RHOST con `settarget` en zsh.
polybar target_to_hack -c ~/.config/polybar/current.ini &
# Launchers de Firefox (personal + pentest), profile-aislados.
polybar launchers -c ~/.config/polybar/current.ini &
# Botón circular en la esquina derecha que abre el power-menu.
polybar primary -c ~/.config/polybar/current.ini &

# ----- BARRA QUE USA workspace.ini -----
# Barra central con los workspaces de bspwm. Va en archivo separado para que
# sus fuentes y módulo de workspaces no choquen con los otros bars.
polybar primary -c ~/.config/polybar/workspace.ini &

# Nota: el bar "top" de current.ini está reservado para alsa/battery/network
# pero no se lanza aquí (queda comentado abajo por si se quiere reactivar).
# polybar top -c ~/.config/polybar/current.ini &
