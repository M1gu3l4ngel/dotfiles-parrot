#!/bin/bash
# Hardened anonymity toggle, run by Super+A (sxhkdrc), a left click on polybar's anon_status module
# or by hand. Turning it on:
#   1. If a browser or client anonsurf closes is open, rofi asks first (see confirm_close).
#   2. anonsurf start sends TCP and DNS through Tor, turns IPv6 off with sysctl and saves the
#      firewall to restore it on stop.
#   3. anon-harden up adds a second barrier of its own: IPv6 and outgoing ICMP to DROP.
#   4. check.torproject.org/api/ip must confirm the traffic really leaves through Tor, retrying for
#      up to a minute while Tor connects; if not, everything is rolled back.
# Turning it off asks the same question, undoes anon-harden and runs anonsurf stop.
#
# The state comes from the anonsurfd service, the one that routes through Tor, not from a `tor`
# process: Parrot can leave tor@default running at boot (anonsurf-recovery) with no anonymity.
# polybar's ghost reads the same service (anon_module.sh), so no state file can go stale.
#
# Needs `sudo ./70-system/setup.sh` (once, after install.sh), which installs
# /usr/local/sbin/anon-harden and /etc/sudoers.d/anon_toggle (NOPASSWD only for
# `anonsurf start|stop` and `anon-harden up|down`, never iptables itself, which would be free
# root). Without them `sudo -n` fails and the toggle says AnonSurf did not start.

set -u

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
# Exists while Tor connects and the exit is checked: anon_module.sh turns the ghost orange.
CONNECTING="$RUNTIME_DIR/anon_connecting"
LOCK="$RUNTIME_DIR/anon_toggle.lock"

# The same ghost as polybar's module, nf-md-ghost (U+F02A0) as a UTF-8 escape. In the notifications
# the text gives the state.
ICON=$'\xf3\xb0\x8a\xa0'

# Absolute paths because the sudoers rule allows these exact ones.
ANONSURF=/usr/bin/anonsurf
ANON_HARDEN=/usr/local/sbin/anon-harden

# Tor often needs 20 to 40 seconds to connect on a slow network: one check after a fixed wait rolled
# back a start that was only late.
VERIFY_SECONDS=60

# The programs anonsurf's safekill closes on start and stop, as process names for `pgrep -x`. It
# closes them on purpose: a connection opened before the switch would stay outside Tor, and the
# same cookies seen from the real IP and from Tor link both. Saying yes for the user without
# warning lost unsaved work.
CLOSED_APPS='firefox|firefox-esr|chromium|chrome|thunderbird|icedove|hexchat|xchat'
CLOSED_APPS+='|transmission-gtk|transmission-qt|dropbox'

# One run at a time: a second Super+A while Tor connects would turn it off halfway.
exec 9>"$LOCK"
if ! flock -n 9; then
  notify-send -u low -t 3000 "$ICON  Anonimato" "Ya hay un cambio en curso, espera a que termine"
  exit 0
fi

anonsurf_active() {
  systemctl is-active --quiet anonsurfd
}

harden_up() {
  sudo -n "$ANON_HARDEN" up 2>/dev/null
}

harden_down() {
  sudo -n "$ANON_HARDEN" down 2>/dev/null
}

# Returns 0 when nothing would be closed or the user accepts; 1 when they cancel (Esc included).
confirm_close() {
  local apps choice
  apps=$(pgrep -lx "$CLOSED_APPS" | awk '{print $2}' | sort -u | paste -sd ' ')
  [ -z "$apps" ] && return 0
  # The same rofi theme as the session menu (powermenu.sh): no search box, -no-custom so typed
  # text cannot answer.
  choice=$(printf '%s\n' "Cerrar y continuar" "Cancelar" |
    rofi -dmenu -i -no-custom -p "Anonimato" \
      -mesg "AnonSurf cerrará: $apps" \
      -theme-str 'window { width: 420px; } listview { lines: 2; } inputbar { enabled: false; }' ||
    true)
  [ "$choice" = "Cerrar y continuar" ]
}

# check.torproject.org/api/ip answers {"IsTor":true,"IP":"x.x.x.x"}. It fails when tor has not
# finished bootstrapping, DNS is not going through Tor or something leaks: more reliable than
# `pgrep tor`.
verify_tor() {
  local resp
  resp=$(curl --max-time 10 -s https://check.torproject.org/api/ip 2>/dev/null)
  [ -n "$resp" ] && echo "$resp" | grep -q '"IsTor":true'
}

wait_for_tor() {
  local deadline=$((SECONDS + VERIFY_SECONDS))
  while [ "$SECONDS" -lt "$deadline" ]; do
    verify_tor && return 0
    sleep 5
  done
  return 1
}

if anonsurf_active; then
  confirm_close || exit 0
  notify-send -u low -t 3000 \
    "$ICON  Desactivando anonimato..." \
    "Cerrando Tor y restaurando conexión directa"
  harden_down
  # `yes y` answers anonsurf's "kill dangerous apps? [Y/n]", already confirmed above.
  yes y | sudo -n "$ANONSURF" stop >/dev/null 2>&1
  for _ in 1 2 3 4 5 6 7 8 9 10; do
    anonsurf_active || break
    sleep 1
  done

  if anonsurf_active; then
    notify-send -u critical -t 5000 \
      "$ICON  Error al desactivar" \
      "AnonSurf sigue activo. Intenta manualmente: sudo anonsurf stop"
  else
    notify-send -u low -t 4000 \
      "$ICON  Anonimato OFF" \
      "Conexión directa restaurada · tráfico sin enmascarar"
  fi
else
  confirm_close || exit 0
  : >"$CONNECTING"
  trap 'rm -f "$CONNECTING"' EXIT
  notify-send -u normal -t 3000 \
    "$ICON  Activando anonimato..." \
    "Conectando a la red Tor (puede tardar hasta un minuto)"
  # anonsurf start asks "kill dangerous apps? [Y/n]" too; with no 'y' on stdin it aborts with
  # EOFError and tor never starts.
  yes y | sudo -n "$ANONSURF" start >/dev/null 2>&1
  # Up to 10 s for anonsurfd to show as active, in case anonsurf returns before systemd is done.
  for _ in 1 2 3 4 5 6 7 8 9 10; do
    anonsurf_active && break
    sleep 1
  done

  if ! anonsurf_active; then
    notify-send -u critical -t 5000 \
      "$ICON  Error al activar" \
      "AnonSurf no arrancó. Intenta manualmente: sudo anonsurf start"
    exit 1
  fi

  harden_up

  if wait_for_tor; then
    notify-send -u critical -t 5000 \
      "$ICON  Anonimato ON · verificado" \
      "Todo el tráfico via Tor (IPv6 bloqueado, ICMP bloqueado, IsTor:true)"
  else
    # Tor never connected or something leaks: undo everything.
    harden_down
    yes y | sudo -n "$ANONSURF" stop >/dev/null 2>&1
    notify-send -u critical -t 7000 \
      "$ICON  Error: no se confirmó salida por Tor" \
      "check.torproject.org no devolvió IsTor:true en un minuto. Rollback aplicado."
  fi
fi
