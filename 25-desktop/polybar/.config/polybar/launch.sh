#!/usr/bin/env sh
# ~/.config/polybar/launch.sh
# Lanzador de polybar. Cierra las barras que haya por IPC y arranca todas las
# del setup (logo, ethernet, VPN, launchers, target, apagado y workspaces).
#
# Lo invoca bspwmrc al iniciar la sesión, pero también se puede ejecutar
# manualmente para recargar todas las barras:
#   ~/.config/polybar/launch.sh
# Atajo equivalente: Super+Alt+R (reinicia bspwm, y bspwmrc vuelve a lanzar
# este script).

# ----- CERRAR LAS BARRAS PREVIAS -----
# Por IPC (enable-ipc en cada barra): cada barra se cierra sola y limpia su
# socket, sin matar procesos. Sin barras corriendo, polybar-msg falla: se
# silencia porque no es un error.
polybar-msg cmd quit >/dev/null 2>&1

# Esperar a que terminen antes de relanzar; si no, conviven un instante barras
# viejas y nuevas (se ven duplicadas). Cada 0.2 s, hasta 5 s.
# `id -u` y no `$UID`: este script corre con sh (dash), donde UID no existe;
# con `$UID` vacío pgrep fallaba y el bucle nunca esperaba.
tries=0
while pgrep -u "$(id -u)" -x polybar >/dev/null; do
  # Una barra que sigue viva no tiene IPC (arrancó con una config anterior):
  # se para aquí para no duplicarla. Se cierra al salir de la sesión.
  if [ "$tries" -ge 25 ]; then
    echo "polybar: hay barras sin IPC que no se cerraron; cierra sesión y vuelve a entrar" >&2
    exit 1
  fi
  tries=$((tries + 1))
  sleep 0.2
done

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
