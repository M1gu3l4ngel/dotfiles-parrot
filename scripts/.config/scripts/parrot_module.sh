#!/bin/bash
# ~/.config/scripts/parrot_module.sh
# Polybar module — logo de Parrot OS en la barra `log` (esquina izquierda).
# Lo ejecuta [module/parrot] de current.ini una vez al día (el logo es estático).
#
# %{T2} selecciona font-1 de current.ini (Hack Nerd Font Mono): el glifo
# nf-linux-parrot (U+F329) solo existe en Nerd Fonts v3+, y Hack es la fuente
# instalada que lo trae. Si falta Hack, el logo no se ve.
# Se escribe como escape UTF-8 `$'\x..'` y no como carácter literal: los
# glifos de uso privado (PUA) los eliminan las herramientas de edición.

ICON=$'\xef\x8c\xa9' # U+F329 nf-linux-parrot
echo "%{T2}${ICON}%{T-}"
