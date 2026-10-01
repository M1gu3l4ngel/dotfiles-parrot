#!/bin/bash
# ~/.config/scripts/power_module.sh
# Polybar module — botón de apagado. El click abre powermenu.sh (apagar,
# reiniciar, cerrar sesión), configurado en current.ini -> [module/power].
# Icono estático: polybar lo ejecuta una vez al día (interval = 86400).

# power-off (U+F011) como escape UTF-8: los glifos de uso privado (PUA)
# escritos literalmente los eliminan las herramientas de edición.
ICON=$'\xef\x80\x91'
# shellcheck source=palette.sh
. "${0%/*}/palette.sh"
# Color de texto, neutro: no es un estado (gris/verde) ni una alerta (rojo).
# %{O4} (4 px de desplazamiento) centra el icono en su card cuadrado: el glifo
# reserva el ancho de una letra (9,4 px a 12 pt) pero se dibuja con ~13,8 px.
# 9,4 + 4 ≈ 13,8: el bloque mide lo mismo que el dibujo.
echo "%{F${TEXT}}${ICON}%{O4}%{F-}"
