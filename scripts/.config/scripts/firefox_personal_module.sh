#!/bin/bash
# ~/.config/scripts/firefox_personal_module.sh
# Polybar module — icono Firefox para lanzar profile "default-esr" (personal).
# El click-left del módulo está bindeado a `firefox -P default-esr --no-remote`
# en current.ini → módulo [module/firefox_personal].
#
# Icono  (firefox) en naranja (ACCENT de palette.sh).
# Usamos escape \xef\x89\xa9 en bash (no el char literal) para evitar que
# Write/Edit lo reemplace por lookalikes CJK sin glifo.

ICON=$'\xef\x89\xa9' #  firefox
# shellcheck source=palette.sh
. "${0%/*}/palette.sh"
# Naranja: el color de marca de Firefox, dentro de la paleta Monokai Soda.
# El espacio tras el icono compensa su desborde a la derecha (el glifo se
# dibuja más ancho que el hueco que reserva). La separación entre iconos la da
# module-margin en bar/launchers.
echo "%{F${ACCENT}}${ICON} %{F-}"
