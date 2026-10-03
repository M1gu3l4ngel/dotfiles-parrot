#!/bin/bash
# ~/.config/scripts/victim_to_hack.sh
# Muestra la IP + nombre del target activo en el módulo `target_module` de
# polybar (bar/target_to_hack).
#
# El target se gestiona desde zsh con las funciones definidas en .zshrc:
#   settarget 10.10.11.42 nombre_maquina   -> escribe "IP nombre" en TARGET_FILE
#   cleartarget                             -> deja el archivo vacío (0 bytes)
#
# Polybar invoca este script cada segundo (ver current.ini →
# [module/target_module]), así que se evita lanzar procesos externos: la
# lectura se hace con el builtin `read` de bash, sin cat ni awk.

# Archivo que sirve de "estado compartido" entre el shell y la barra.
# Si cambias esta ruta, ajusta también settarget/cleartarget en .zshrc.
TARGET_FILE="$HOME/.config/bin/target"

# Icono nf-md-target (U+F04FE) como escape UTF-8: los glifos de uso privado
# (PUA) escritos literalmente los eliminan las herramientas de edición.
ICON=$'\xf3\xb0\x93\xbe'

# shellcheck source=palette.sh
. "${0%/*}/palette.sh"

# ----- LECTURA -----
# `read` falla si el archivo no existe, y deja las variables vacías si está
# vacío: ambos casos caen en "No target" más abajo.
# `2>/dev/null` va ANTES de `<`: las redirecciones se aplican en orden, y si
# fuera después, el error de "archivo no existe" ya se habría impreso.
ip_address="" machine_name=""
# Con `demo on` (ver ethernet_status.sh) se muestra el target falso del
# tercer y cuarto campo, sin tocar el target real.
DEMO_FILE="$HOME/.config/bin/demo"
if [ -r "$DEMO_FILE" ]; then
  read -r _ _ ip_address machine_name _ <"$DEMO_FILE"
else
  read -r ip_address machine_name _ 2>/dev/null <"$TARGET_FILE"
fi

# ----- SALIDA -----
# Con target: icono rojo (alerta: hay un objetivo activo), IP destacada y
# nombre en texto normal. Sin target: todo en gris, sin rojo que alarme.
if [ -n "$ip_address" ] && [ -n "$machine_name" ]; then
  echo "%{F${ERROR}}${ICON} %{F${STRONG}}${ip_address} %{F${TEXT}}- ${machine_name}%{F-}"
else
  echo "%{F${MUTED}}${ICON} No target%{F-}"
fi
