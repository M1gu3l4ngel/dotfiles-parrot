#!/bin/bash
# ~/.config/scripts/firefox_personal_module.sh
# Polybar module — icono Firefox para lanzar profile "default-esr" (personal).
# El click-left del módulo está bindeado a `firefox -P default-esr --no-remote`
# en current.ini → módulo [module/firefox_personal].
#
# Icono  (firefox) en color rojo Firefox #FF7B72.
# Usamos escape \xef\x89\xa9 en bash (no el char literal) para evitar que
# Write/Edit lo reemplace por lookalikes CJK sin glifo.

ICON=$'\xef\x89\xa9'  #  firefox
echo "%{F#FF7B72}  $ICON  %{F-}"
