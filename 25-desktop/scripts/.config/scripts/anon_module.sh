#!/bin/bash
# ~/.config/scripts/anon_module.sh
# Polybar module — muestra estado de anonimato con un fantasma, leyendo el
# state file que escribe toggle_anonymity.sh. El icono es el mismo en los dos
# estados: lo que cambia es el color (como en el resto de módulos).
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

# nf-md-ghost (U+F02A0) como escape UTF-8: los glifos de uso privado (PUA)
# escritos literalmente los eliminan las herramientas de edición.
ICON=$'\xf3\xb0\x8a\xa0'

# Activado: verde (éxito). Desactivado: gris, sin llamar la atención.
# El espacio tras el icono compensa su desborde a la derecha (el glifo se
# dibuja más ancho que el hueco que reserva); la separación con los iconos de
# Firefox la da module-margin en bar/launchers.
if [ "$state" = "on" ]; then
  echo "%{F${SUCCESS}}${ICON} %{F-}"
else
  echo "%{F${MUTED}}${ICON} %{F-}"
fi
