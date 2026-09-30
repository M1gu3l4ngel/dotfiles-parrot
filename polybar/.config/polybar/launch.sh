#!/usr/bin/env sh
# ~/.config/polybar/launch.sh
# Lanzador de polybar. Mata cualquier instancia previa y arranca todas las
# barras del setup (logo, ethernet, VPN, launchers, target, anonimato y
# workspaces).
#
# Lo invoca bspwmrc al iniciar la sesión, pero también se puede ejecutar
# manualmente para recargar todas las barras:
#   ~/.config/polybar/launch.sh
# Atajo equivalente: Super+Alt+R (reinicia bspwm, y bspwmrc vuelve a lanzar
# este script).

# ----- LIMPIAR INSTANCIAS PREVIAS -----
# killall -q: silenciar el error si no había ninguna corriendo (idempotente).
killall -q polybar

# Esperar a que los procesos terminen del todo antes de relanzar; si no,
# conviven un instante barras viejas y nuevas (se ven duplicadas).
# `id -u` y no `$UID`: este script corre con sh (dash), donde UID no existe;
# con `$UID` vacío pgrep fallaba y el bucle nunca esperaba.
# Se comprueba cada 0.2 s para que la recarga sea casi instantánea.
while pgrep -u "$(id -u)" -x polybar >/dev/null; do sleep 0.2; done

# ----- BARRAS QUE USAN current.ini -----
# Cada `-c` apunta al archivo de config; el primer argumento es el nombre del
# bloque [bar/<nombre>] dentro de ese archivo.

# Logo de Parrot en la esquina izquierda.
polybar log -c ~/.config/polybar/current.ini &
# Estado de la interfaz Ethernet (IP local o "down").
polybar ethernet_bar -c ~/.config/polybar/current.ini &
# Estado de la VPN (HTB / THM / desconectada).
polybar vpn_bar -c ~/.config/polybar/current.ini &

# IP de la víctima cuando se exporta $RHOST con `settarget` en zsh.
polybar target_to_hack -c ~/.config/polybar/current.ini &
# Launchers de Firefox (personal + pentest), profile-aislados.
polybar launchers -c ~/.config/polybar/current.ini &
# Toggle de anonimato (Tor + anonsurf) en la esquina derecha.
polybar primary -c ~/.config/polybar/current.ini &

# ----- BARRA QUE USA workspace.ini -----
# Barra central con los workspaces de bspwm. Va en archivo separado porque
# usa otra fuente y no comparte módulos con las barras de estado.
polybar primary -c ~/.config/polybar/workspace.ini &
