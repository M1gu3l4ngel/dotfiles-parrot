#!/bin/sh
# ~/.config/scripts/ethernet_status.sh
# Muestra la IPv4 de la interfaz de red principal en el módulo `ethernet_status`
# de polybar (bar/ethernet_bar). polybar lo ejecuta cada segundo.
#
# Detecta la interfaz sola: la primera con IPv4 que no sea loopback ni un
# túnel/VPN (tun, wg) ni una red de contenedores (docker, br-, veth, virbr).
# Así funciona igual con ens33 (VMware), eth0 o enp0s3 sin tocar el script.
#
# Una sola llamada a `ip`; el resto con builtins de sh, para no lanzar
# procesos extra cada segundo. Sin `set -e` a propósito: si algo falla, la
# barra debe mostrar igualmente un texto, no quedarse en blanco.

set -u

# Icono nf-md-ethernet (U+F0200) como escape: los glifos de uso privado (PUA)
# escritos literalmente los eliminan las herramientas de edición.
ICON=$(printf '\363\260\210\200')

ip_address=""
# Formato de `ip -4 -br addr`: "<interfaz> <estado> <ip>/<prefijo> ...".
while read -r iface _ addr _; do
  case "$iface" in
    lo | tun* | wg* | docker* | br-* | veth* | virbr*) continue ;;
    *) ;;
  esac
  ip_address=${addr%%/*}
  break
done <<EOF
$(ip -4 -br addr show 2>/dev/null)
EOF

if [ -n "$ip_address" ]; then
  echo "%{F#2495e7}${ICON} %{F#ffffff}${ip_address}%{u-}"
else
  echo "%{F#2495e7}${ICON} %{u-}%{F#ffffff} Disconnected"
fi
