#!/bin/bash
# ~/.config/scripts/anon_module.sh
# Polybar module — muestra estado de anonimato como ÚNICO icono Nerd Font
# leyendo el state file que escribe toggle_anonymity.sh.
#
# Iconos (Nerd Font, codepoints UTF-8 directos):
#   - OFF (normal):   power-off (Font Awesome)      \xef\x80\x91
#   - ON  (anónimo):  fa-user-secret (Font Awesome) \xef\x88\x9b
#
# Invocado por el módulo [module/anon_status] en polybar/current.ini cada
# 2s. El click-left del módulo dispara toggle_anonymity.sh.

STATE_FILE="$HOME/.config/bin/anon_state"
state=$(cat "$STATE_FILE" 2>/dev/null || echo "off")

ICON_OFF=$'\xef\x80\x91'  #  power-off
ICON_ON=$'\xef\x88\x9b'   #  user-secret (anónimo)

if [ "$state" = "on" ]; then
    echo "%{F#193549}%{B#98E024}  $ICON_ON  %{B-}%{F-}"
else
    echo "%{F#888888}%{B#2a2a2a}  $ICON_OFF  %{B-}%{F-}"
fi
