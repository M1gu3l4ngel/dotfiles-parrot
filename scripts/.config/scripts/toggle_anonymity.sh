#!/bin/bash
# ~/.config/scripts/toggle_anonymity.sh
# Toggle de anonimato (Tor + anonsurf) on/off con feedback INSTANTÁNEO:
# el state file y la notificación se actualizan al instante; anonsurf
# corre en background así la UI no espera los 5-15s del bootstrap de Tor.
#
# Iconos (Nerd Font, codepoints UTF-8 directos):
#   - OFF (normal):   power-off (Font Awesome)      \xef\x80\x91
#   - ON  (anónimo):  fa-user-secret (Font Awesome) \xef\x88\x9b
#
# Uso:
#   - Atajo Super+A (configurado en sxhkdrc)
#   - Click izquierdo en el módulo "anon_status" de polybar
#   - Manual: ~/.config/scripts/toggle_anonymity.sh

STATE_FILE="$HOME/.config/bin/anon_state"
mkdir -p "$(dirname "$STATE_FILE")"

ICON_OFF=$'\xef\x80\x91'  #  power-off
ICON_ON=$'\xef\x88\x9b'   #  user-secret

# Estado actual
if [ -f "$STATE_FILE" ]; then
    current=$(cat "$STATE_FILE")
else
    current="off"
fi

if [ "$current" = "on" ]; then
    # ----- APAGAR (feedback inmediato + anonsurf en background) -----
    echo "off" > "$STATE_FILE"
    notify-send -u low -t 3000 \
        "$ICON_OFF  Anonimato OFF" \
        "Conexión directa restaurada · tráfico sin enmascarar"
    sudo -n anonsurf stop > /dev/null 2>&1 &
else
    # ----- ENCENDER (feedback inmediato + anonsurf en background) -----
    echo "on" > "$STATE_FILE"
    notify-send -u critical -t 4000 \
        "$ICON_ON  Anonimato ON" \
        "Todo el tráfico via Tor · verifica IP con curl ifconfig.me"
    sudo -n anonsurf start > /dev/null 2>&1 &
fi
