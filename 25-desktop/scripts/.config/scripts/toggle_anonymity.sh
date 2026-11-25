#!/bin/bash
# Hardened anonymity toggle, run by Super+A (sxhkdrc), a left click on polybar's anon_status module
# or by hand. Turning it on:
#   1. anonsurf start sends TCP and DNS through Tor with iptables.
#   2. IPv6 output goes to DROP: anonsurf covers IPv4 only, and on a network with IPv6 that traffic
#      would leave outside Tor.
#   3. ICMP output goes to DROP, so ping or traceroute cannot reveal the real IP.
#   4. check.torproject.org/api/ip confirms the traffic really leaves through Tor, not just that a
#      `tor` process is alive; if not, everything is rolled back.
# Turning it off puts the policies back to ACCEPT and removes the ICMP rule.
#
# The state comes from the anonsurfd service, the one that routes through Tor, not from a `tor`
# process: Parrot can leave tor@default running at boot (anonsurf-recovery) with no anonymity, and
# the toggle then believed it was on and failed to turn it off.
#
# Needs `sudo ./70-system/setup.sh` (once, after install.sh), which installs
# /usr/local/sbin/anon-harden (the IPv6 and ICMP rules, run as root) and /etc/sudoers.d/anon_toggle
# (NOPASSWD only for `anonsurf start|stop` and `anon-harden up|down`, never iptables itself, which
# would be free root). Without them `sudo -n` fails and the toggle says AnonSurf did not start.

STATE_FILE="$HOME/.config/bin/anon_state"
mkdir -p "$(dirname "$STATE_FILE")"

# The same ghost as polybar's module (anon_module.sh), nf-md-ghost (U+F02A0) as a UTF-8 escape. In
# the notifications the text gives the state.
ICON=$'\xf3\xb0\x8a\xa0'

# The layers anonsurf leaves out (IPv6 and outgoing ICMP to DROP) live in
# /usr/local/sbin/anon-harden. Absolute paths because the sudoers rule allows these exact ones.
ANONSURF=/usr/bin/anonsurf
ANON_HARDEN=/usr/local/sbin/anon-harden

harden_up() {
  sudo -n "$ANON_HARDEN" up 2>/dev/null
}

harden_down() {
  sudo -n "$ANON_HARDEN" down 2>/dev/null
}

# check.torproject.org/api/ip answers {"IsTor":true,"IP":"x.x.x.x"}. It fails when tor has not
# finished bootstrapping, DNS is not going through Tor or something leaks: more reliable than
# `pgrep tor`.
verify_tor() {
  local resp
  resp=$(curl --max-time 15 -s https://check.torproject.org/api/ip 2>/dev/null)
  [ -z "$resp" ] && return 1
  echo "$resp" | grep -q '"IsTor":true'
}

anonsurf_active() {
  systemctl is-active --quiet anonsurfd
}

if anonsurf_active; then
  notify-send -u low -t 3000 \
    "$ICON  Desactivando anonimato..." \
    "Cerrando Tor y restaurando conexión directa"
  harden_down
  # `yes y` answers anonsurf's "kill dangerous apps? [Y/n]".
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
  notify-send -u normal -t 3000 \
    "$ICON  Activando anonimato..." \
    "Conectando a la red Tor (puede tardar 10-15s)"
  # anonsurf start asks "kill dangerous apps? [Y/n]" too; with no 'y' on stdin it aborts with
  # EOFError and tor never starts.
  yes y | sudo -n "$ANONSURF" start >/dev/null 2>&1
  sleep 5

  if ! anonsurf_active; then
    notify-send -u critical -t 5000 \
      "$ICON  Error al activar" \
      "AnonSurf no arrancó. Intenta manualmente: sudo anonsurf start"
    exit 1
  fi

  harden_up

  if verify_tor; then
    echo "on" >"$STATE_FILE"
    notify-send -u critical -t 5000 \
      "$ICON  Anonimato ON · verificado" \
      "Todo el tráfico via Tor (IPv6 bloqueado, ICMP bloqueado, IsTor:true)"
  else
    # Unfinished bootstrap or a leak: undo everything.
    harden_down
    yes y | sudo -n "$ANONSURF" stop >/dev/null 2>&1
    echo "off" >"$STATE_FILE"
    notify-send -u critical -t 7000 \
      "$ICON  Error: no se confirmó salida por Tor" \
      "check.torproject.org no devolvió IsTor:true. Rollback aplicado."
  fi
fi
