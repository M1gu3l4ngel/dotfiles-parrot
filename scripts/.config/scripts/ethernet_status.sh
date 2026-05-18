#!/bin/sh
# ~/.config/scripts/ethernet_status.sh
# Muestra la IP local de la interfaz Ethernet (ens33) en formato listo
# para que lo consuma el módulo `ethernet_status` de polybar (bar/ethernet_bar).
#
# Los `%{F#...}` y `%{u-}` son tags de formato de polybar:
#   %{F#hex} cambia el color del foreground a ese hex
#   %{u-}    quita el subrayado
#
# Para cambiar de interfaz: reemplazar `ens33` por el nombre real (`ip link` para verlo).

# Icono Nerd Font azul + IP en blanco. Si ens33 no tiene IP o no existe,
# awk imprime cadena vacía (no se rompe la barra, solo queda el icono).
echo "%{F#2495e7}󰈀 %{F#ffffff}$(/usr/sbin/ifconfig ens33 | grep "inet " | awk '{print $2}')%{u-}"
