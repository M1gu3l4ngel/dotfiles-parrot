#!/bin/bash

  TARGET_FILE="/home/bytebit/.config/bin/target"

  # Si el archivo no existe o está vacío
  if [ ! -s "$TARGET_FILE" ]; then
      echo "%{F#e51d0b}󰓾 %{u-}%{F#ffffff} No target"
      exit 0
  fi

  # Leer contenido
  content=$(/bin/cat "$TARGET_FILE")

  # Si dice "No target" explícitamente
  if [ "$content" = "No target" ]; then
      echo "%{F#e51d0b}󰓾 %{u-}%{F#ffffff} No target"
      exit 0
  fi

  # Parsear IP y nombre
  ip_address=$(echo "$content" | awk '{print $1}')
  machine_name=$(echo "$content" | awk '{print $2}')

  if [ -n "$ip_address" ] && [ -n "$machine_name" ]; then
      echo "%{F#e51d0b}󰓾 %{F#ffffff}$ip_address%{u-} - $machine_name"
  else
      echo "%{F#e51d0b}󰓾 %{u-}%{F#ffffff} No target"
  fi
