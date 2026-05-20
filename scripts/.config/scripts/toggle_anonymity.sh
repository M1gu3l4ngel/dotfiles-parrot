#!/bin/bash
# ~/.config/scripts/toggle_anonymity.sh
# Toggle de anonimato endurecido. Pasos al activar:
#   1. anonsurf start  → redirige TCP+DNS a Tor vía iptables
#   2. ip6tables OUTPUT DROP → mata IPv6 (anonsurf solo cubre IPv4; sin esto,
#      si la red soporta v6, todo el tráfico v6 sale FUERA de Tor)
#   3. iptables ICMP OUTPUT DROP → evita ping/traceroute → IP real
#   4. curl check.torproject.org/api/ip → confirma que REALMENTE salimos por
#      Tor (no solo que el proceso `tor` esté vivo). Si falla, revierte todo.
# Al desactivar, se restauran las policies a ACCEPT y se quita la regla ICMP.
#
# Iconos (Nerd Font, UTF-8 directos):
#   - OFF (normal):   power-off (Font Awesome)      \xef\x80\x91
#   - ON  (anónimo):  fa-user-secret (Font Awesome) \xef\x88\x9b
#
# Uso:
#   - Atajo Super+A (configurado en sxhkdrc)
#   - Click izquierdo en el módulo "anon_status" de polybar
#   - Manual: ~/.config/scripts/toggle_anonymity.sh
#
# Requisitos sudoers: el archivo dotfiles/system/setup.sh instala
# /etc/sudoers.d/anon_toggle con la regla NOPASSWD necesaria (anonsurf +
# ip6tables + iptables). Idempotente, correr una vez tras el install.sh.

STATE_FILE="$HOME/.config/bin/anon_state"
mkdir -p "$(dirname "$STATE_FILE")"

ICON_OFF=$'\xef\x80\x91'  #  power-off
ICON_ON=$'\xef\x88\x9b'   #  user-secret

# ----- HARDENING: IPv6 + ICMP -----
# Bloquea/desbloquea capas que anonsurf no cubre.
harden_up() {
  # IPv6 OUTPUT DROP: anonsurf opera solo en iptables (v4). Cualquier tráfico
  # v6 saldría por la ruta directa. Política DROP en OUTPUT lo elimina.
  sudo -n ip6tables -P OUTPUT DROP 2>/dev/null
  sudo -n ip6tables -P INPUT   DROP 2>/dev/null
  sudo -n ip6tables -P FORWARD DROP 2>/dev/null
  # ICMP OUTPUT DROP: evita que un `ping 8.8.8.8` revele la IP real (ICMP no
  # va por Tor; Tor solo transporta TCP). Marcamos la regla con un comment
  # para poder quitarla limpio en harden_down sin afectar a otras reglas.
  sudo -n iptables -A OUTPUT -p icmp -m comment --comment "anon_toggle_icmp" -j DROP 2>/dev/null
}

harden_down() {
  sudo -n ip6tables -P OUTPUT ACCEPT 2>/dev/null
  sudo -n ip6tables -P INPUT   ACCEPT 2>/dev/null
  sudo -n ip6tables -P FORWARD ACCEPT 2>/dev/null
  # Quita TODAS las reglas que marcamos con el comment (idempotente)
  while sudo -n iptables -C OUTPUT -p icmp -m comment --comment "anon_toggle_icmp" -j DROP 2>/dev/null; do
    sudo -n iptables -D OUTPUT -p icmp -m comment --comment "anon_toggle_icmp" -j DROP 2>/dev/null
  done
}

# ----- VALIDACIÓN: ¿salimos REALMENTE por Tor? -----
# check.torproject.org/api/ip devuelve JSON: {"IsTor":true,"IP":"x.x.x.x"}.
# Falla si: (a) tor no está bootstrapped, (b) DNS no se está routeando por
# Tor, (c) hay un leak. Más fiable que `pgrep tor`.
verify_tor() {
  local resp
  resp=$(curl --max-time 15 -s https://check.torproject.org/api/ip 2>/dev/null)
  [ -z "$resp" ] && return 1
  echo "$resp" | grep -q '"IsTor":true'
}

# Estado actual: ¿el proceso tor está corriendo?
if pgrep -x tor > /dev/null; then
  current="on"
else
  current="off"
fi

if [ "$current" = "on" ]; then
  # ----- DESACTIVAR -----
  notify-send -u low -t 3000 \
    "$ICON_OFF  Desactivando anonimato..." \
    "Cerrando Tor y restaurando conexión directa"
  harden_down
  # `yes y |` auto-confirma el prompt "kill dangerous apps? [Y/n]"
  yes y | sudo -n anonsurf stop > /dev/null 2>&1
  sleep 2

  if pgrep -x tor > /dev/null; then
    notify-send -u critical -t 5000 \
      "$ICON_ON  Error al desactivar" \
      "Tor sigue corriendo. Intenta manualmente: sudo anonsurf stop"
  else
    echo "off" > "$STATE_FILE"
    notify-send -u low -t 4000 \
      "$ICON_OFF  Anonimato OFF" \
      "Conexión directa restaurada · tráfico sin enmascarar"
  fi
else
  # ----- ACTIVAR -----
  notify-send -u normal -t 3000 \
    "$ICON_ON  Activando anonimato..." \
    "Conectando a la red Tor (puede tardar 10-15s)"
  # anonsurf start también pregunta "kill dangerous apps? [Y/n]"; sin un
  # 'y' en stdin aborta con EOFError y tor nunca arranca.
  yes y | sudo -n anonsurf start > /dev/null 2>&1
  sleep 5

  if ! pgrep -x tor > /dev/null; then
    notify-send -u critical -t 5000 \
      "$ICON_OFF  Error al activar" \
      "Tor no arrancó. Intenta manualmente: sudo anonsurf start"
    exit 1
  fi

  # Tor está vivo → endurecer capas que anonsurf no cubre
  harden_up

  # Validación real contra check.torproject.org. Si falla, ROLLBACK completo.
  if verify_tor; then
    echo "on" > "$STATE_FILE"
    notify-send -u critical -t 5000 \
      "$ICON_ON  Anonimato ON · verificado" \
      "Todo el tráfico via Tor (IPv6 bloqueado, ICMP bloqueado, IsTor:true)"
  else
    # Bootstrap incompleto o leak detectado: revertir TODO
    harden_down
    yes y | sudo -n anonsurf stop > /dev/null 2>&1
    echo "off" > "$STATE_FILE"
    notify-send -u critical -t 7000 \
      "$ICON_OFF  Error: no se confirmó salida por Tor" \
      "check.torproject.org no devolvió IsTor:true. Rollback aplicado."
  fi
fi
