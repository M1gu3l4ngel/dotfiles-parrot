#!/bin/sh
# ~/.config/scripts/vpn_status.sh
# Indica si hay una VPN activa (tun0) y, si la hay, muestra la IP asignada.
# Usado por el módulo `vpn_status` de polybar (bar/vpn_bar).
#
# Convención: las VPNs de OpenVPN (HTB, THM) crean siempre la interfaz tun0.
# Si usas WireGuard o varios túneles, ajusta el nombre.

# ----- DETECTAR INTERFAZ tun0 -----
# Buscamos "tun0" en la salida de ifconfig y nos quedamos solo con el nombre
# (sin los dos puntos finales que añade ifconfig).
IFACE=$(/usr/sbin/ifconfig | grep tun0 | awk '{print $1}' | tr -d ':')

# ----- OUTPUT FORMATEADO PARA POLYBAR -----
# Icono Nerd Font verde + IP en blanco si está conectada;
# icono verde + "Disconnected" si no hay tun0.
if [ "$IFACE" = "tun0" ]; then
  echo "%{F#1bbf3e}󰆧 %{F#ffffff}$(/usr/sbin/ifconfig tun0 | grep "inet " | awk '{print $2}')%{u-}"
else
  echo "%{F#1bbf3e}󰆧 %{u-} Disconnected"
fi
