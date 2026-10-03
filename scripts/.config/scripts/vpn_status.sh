#!/bin/sh
# ~/.config/scripts/vpn_status.sh
# Muestra la IPv4 de la VPN en el módulo `vpn_status` de polybar
# (bar/vpn_bar), o "Disconnected" si no hay ninguna. polybar lo ejecuta cada
# segundo.
#
# Detecta cualquier túnel: tun* (OpenVPN, la VPN de HTB/THM) y wg* (WireGuard).
# Si hay varios, muestra el primero. Es la IP que se usa como LHOST en los labs.
#
# Una sola llamada a `ip`; el resto con builtins de sh. Sin `set -e` a
# propósito: la barra debe mostrar un texto aunque algo falle.

set -u

# Icono nf-md-cube_outline (U+F01A7) como escape: los glifos de uso privado
# (PUA) escritos literalmente los eliminan las herramientas de edición.
ICON=$(printf '\363\260\206\247')

# ----- MODO DEMO -----
# Con `demo on` (ver ethernet_status.sh), la VPN falsa es el segundo campo.
DEMO_FILE="$HOME/.config/bin/demo"
ip_address=""
[ -r "$DEMO_FILE" ] && read -r _ ip_address _ <"$DEMO_FILE"

if [ -z "$ip_address" ]; then
  # Formato de `ip -4 -br addr`: "<interfaz> <estado> <ip>/<prefijo> ...".
  while read -r iface _ addr _; do
    case "$iface" in
      tun* | wg*)
        ip_address=${addr%%/*}
        break
        ;;
      *) ;;
    esac
  done <<EOF
$(ip -4 -br addr show 2>/dev/null)
EOF
fi

# shellcheck source=palette.sh
. "${0%/*}/palette.sh"

# Conectada: icono verde (éxito) e IP destacada. Desconectada: todo en gris,
# para que no parezca un estado correcto.
if [ -n "$ip_address" ]; then
  echo "%{F${SUCCESS}}${ICON} %{F${STRONG}}${ip_address}%{F-}"
else
  echo "%{F${MUTED}}${ICON} Disconnected%{F-}"
fi
