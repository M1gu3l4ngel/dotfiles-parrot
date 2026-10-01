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
# El estado se toma del servicio anonsurfd (el que enruta el tráfico por Tor),
# no de si hay un proceso `tor`: Parrot puede dejar tor@default corriendo
# suelto al arrancar (anonsurf-recovery) sin que haya anonimato, y entonces el
# toggle creía que estaba activo e intentaba desactivarlo sin éxito.
#
# Uso:
#   - Atajo Super+A (configurado en sxhkdrc)
#   - Click izquierdo en el módulo "anon_status" de polybar
#   - Manual: ~/.config/scripts/toggle_anonymity.sh
#
# Requisitos: `sudo ./system/setup.sh` (una vez tras install.sh) instala
#   - /usr/local/sbin/anon-harden: las reglas de IPv6/ICMP, ejecutadas como root
#   - /etc/sudoers.d/anon_toggle: NOPASSWD SOLO para `anonsurf start|stop` y
#     `anon-harden up|down` (nunca para iptables directo: sería root gratis)
# Sin eso, `sudo -n` falla y el toggle avisa "Tor no arrancó".

STATE_FILE="$HOME/.config/bin/anon_state"
mkdir -p "$(dirname "$STATE_FILE")"

# Mismo fantasma que el módulo de polybar (anon_module.sh), nf-md-ghost
# (U+F02A0) como escape UTF-8. En las notificaciones el estado lo da el texto.
ICON=$'\xf3\xb0\x8a\xa0'

# ----- HARDENING: IPv6 + ICMP -----
# Capas que anonsurf no cubre (IPv6 a DROP, ICMP saliente a DROP). Las reglas
# viven en /usr/local/sbin/anon-harden (ver su cabecera); aquí solo se invoca.
# Rutas absolutas porque la regla sudoers autoriza esas rutas exactas.
ANONSURF=/usr/bin/anonsurf
ANON_HARDEN=/usr/local/sbin/anon-harden

harden_up() {
  sudo -n "$ANON_HARDEN" up 2>/dev/null
}

harden_down() {
  sudo -n "$ANON_HARDEN" down 2>/dev/null
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

# ¿Está AnonSurf enrutando el tráfico por Tor? (ver la cabecera)
anonsurf_active() {
  systemctl is-active --quiet anonsurfd
}

if anonsurf_active; then
  # ----- DESACTIVAR -----
  notify-send -u low -t 3000 \
    "$ICON  Desactivando anonimato..." \
    "Cerrando Tor y restaurando conexión directa"
  harden_down
  # `yes y |` auto-confirma el prompt "kill dangerous apps? [Y/n]"
  yes y | sudo -n "$ANONSURF" stop >/dev/null 2>&1
  sleep 2

  if anonsurf_active; then
    notify-send -u critical -t 5000 \
      "$ICON  Error al desactivar" \
      "AnonSurf sigue activo. Intenta manualmente: sudo anonsurf stop"
  else
    echo "off" >"$STATE_FILE"
    notify-send -u low -t 4000 \
      "$ICON  Anonimato OFF" \
      "Conexión directa restaurada · tráfico sin enmascarar"
  fi
else
  # ----- ACTIVAR -----
  notify-send -u normal -t 3000 \
    "$ICON  Activando anonimato..." \
    "Conectando a la red Tor (puede tardar 10-15s)"
  # anonsurf start también pregunta "kill dangerous apps? [Y/n]"; sin un
  # 'y' en stdin aborta con EOFError y tor nunca arranca.
  yes y | sudo -n "$ANONSURF" start >/dev/null 2>&1
  sleep 5

  if ! anonsurf_active; then
    notify-send -u critical -t 5000 \
      "$ICON  Error al activar" \
      "AnonSurf no arrancó. Intenta manualmente: sudo anonsurf start"
    exit 1
  fi

  # AnonSurf activo → endurecer capas que anonsurf no cubre
  harden_up

  # Validación real contra check.torproject.org. Si falla, ROLLBACK completo.
  if verify_tor; then
    echo "on" >"$STATE_FILE"
    notify-send -u critical -t 5000 \
      "$ICON  Anonimato ON · verificado" \
      "Todo el tráfico via Tor (IPv6 bloqueado, ICMP bloqueado, IsTor:true)"
  else
    # Bootstrap incompleto o leak detectado: revertir TODO
    harden_down
    yes y | sudo -n "$ANONSURF" stop >/dev/null 2>&1
    echo "off" >"$STATE_FILE"
    notify-send -u critical -t 7000 \
      "$ICON  Error: no se confirmó salida por Tor" \
      "check.torproject.org no devolvió IsTor:true. Rollback aplicado."
  fi
fi
