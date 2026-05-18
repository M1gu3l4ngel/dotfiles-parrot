#!/bin/bash
# ~/.config/scripts/victim_to_hack.sh
# Muestra la IP + nombre del target activo en el módulo `target_module` de
# polybar (bar/target_to_hack).
#
# El target se gestiona desde zsh con las funciones definidas en .zshrc:
#   settarget 10.10.11.42 nombre_maquina   -> escribe en TARGET_FILE
#   cleartarget                             -> vacía el archivo
#
# Polybar invoca este script cada `interval` segundos (ver current.ini →
# [module/target_module]).

# Archivo que sirve de "estado compartido" entre el shell y la barra.
# Si cambias esta ruta, ajusta también settarget/cleartarget en .zshrc.
TARGET_FILE="$HOME/.config/bin/target"

# ----- TARGET NO DEFINIDO -----
# Si el archivo no existe o está vacío, mostrar icono rojo + "No target".
# El test `-s` cubre ambos casos (no existe o tiene 0 bytes).
if [ ! -s "$TARGET_FILE" ]; then
  echo "%{F#e51d0b}󰓾 %{u-}%{F#ffffff} No target"
  exit 0
fi

# ----- LECTURA DEL ARCHIVO -----
# Ruta absoluta a /bin/cat por seguridad (evita aliases o cosas raras del PATH).
content=$(/bin/cat "$TARGET_FILE")

# Si el contenido es literalmente "No target", tratarlo igual que vacío.
# Permite escribir "No target" en el archivo a mano sin romper el formato.
if [ "$content" = "No target" ]; then
  echo "%{F#e51d0b}󰓾 %{u-}%{F#ffffff} No target"
  exit 0
fi

# ----- PARSEAR Y MOSTRAR -----
# Esperamos "IP nombre" separados por espacio (formato que escribe settarget).
ip_address=$(echo "$content" | awk '{print $1}')
machine_name=$(echo "$content" | awk '{print $2}')

if [ -n "$ip_address" ] && [ -n "$machine_name" ]; then
  echo "%{F#e51d0b}󰓾 %{F#ffffff}$ip_address%{u-} - $machine_name"
else
  # Salvavidas: archivo con un solo campo o formato raro.
  echo "%{F#e51d0b}󰓾 %{u-}%{F#ffffff} No target"
fi
