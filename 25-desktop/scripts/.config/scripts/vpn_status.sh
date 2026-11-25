#!/bin/sh
# Shows the VPN's IPv4 in polybar's vpn_status module (bar/vpn_bar), or "Disconnected"; polybar runs
# it every second. Any tunnel counts: tun* (OpenVPN, the HTB and THM VPN) and wg* (WireGuard), the
# first one if there are several. It is the IP used as LHOST in the labs.
#
# One call to `ip`, the rest with sh builtins. No `set -e` on purpose: the bar must show a text even
# if something fails.

set -u

# nf-md-cube_outline (U+F01A7) as an escape: editing tools drop private use glyphs (PUA) written
# literally.
ICON=$(printf '\363\260\206\247')

# With `demo on` (ethernet_status.sh) the fake VPN is the second field.
DEMO_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/demo"
ip_address=""
[ -r "$DEMO_FILE" ] && read -r _ ip_address _ <"$DEMO_FILE"

if [ -z "$ip_address" ]; then
  # `ip -4 -br addr` prints "<interface> <state> <ip>/<prefix> ...".
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

# Connected: a green icon (success) and the IP highlighted. Disconnected: all grey, so it does not
# look like a good state.
if [ -n "$ip_address" ]; then
  echo "%{F${SUCCESS}}${ICON} %{F${STRONG}}${ip_address}%{F-}"
else
  echo "%{F${MUTED}}${ICON} Disconnected%{F-}"
fi
