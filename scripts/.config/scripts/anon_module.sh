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
# segundo. El click-left del módulo dispara toggle_anonymity.sh.

STATE_FILE="$HOME/.config/bin/anon_state"
# `read` (builtin) en vez de `cat`: polybar ejecuta esto cada segundo y así no
# se lanza ningún proceso. Si el archivo no existe, el estado queda en "off".
state="off"
read -r state 2>/dev/null <"$STATE_FILE"

# shellcheck source=palette.sh
. "${0%/*}/palette.sh"

ICON_OFF=$'\xef\x80\x91' #  power-off
ICON_ON=$'\xef\x88\x9b'  #  user-secret (anónimo)

# Encendido: icono verde (éxito). Apagado: gris, sin llamar la atención.
# %{O4} (4 px de desplazamiento) centra el icono en el card: el glifo reserva
# el ancho de una letra (9,4 px a 12 pt) pero se dibuja con ~13,8 px, así que
# sin compensar se desborda a la derecha. 9,4 + 4 ≈ 13,8: el bloque mide lo
# mismo que el dibujo. Un espacio entero (9,4 px) lo dejaba a la izquierda.
if [ "$state" = "on" ]; then
  echo "%{F${SUCCESS}}${ICON_ON}%{O4}%{F-}"
else
  echo "%{F${MUTED}}${ICON_OFF}%{O4}%{F-}"
fi
