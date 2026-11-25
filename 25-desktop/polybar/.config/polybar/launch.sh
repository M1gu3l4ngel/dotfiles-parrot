#!/usr/bin/env sh
# Starts every polybar bar, after closing the running ones over IPC.
#
# bspwmrc runs it at login and on every bspwm restart (Super+Alt+R); it can also be run by hand to
# reload the bars: ~/.config/polybar/launch.sh

# Over IPC (enable-ipc in every bar) each bar closes itself and cleans up its socket, with no
# process killed. With no bar running polybar-msg fails, which is not an error.
polybar-msg cmd quit >/dev/null 2>&1

# Waits for them to exit before starting again, or old and new bars overlap for a moment (they look
# duplicated). Every 0.2 s, up to 5 s. `id -u` and not `$UID`: this runs under sh (dash), which has
# no UID, and with an empty `$UID` pgrep failed and the loop never waited.
tries=0
while pgrep -u "$(id -u)" -x polybar >/dev/null; do
  # A bar still alive has no IPC (it started with an older config): stop here rather than duplicate
  # it. It closes when the session ends.
  if [ "$tries" -ge 25 ]; then
    echo "polybar: bars without IPC did not close; log out and back in" >&2
    exit 1
  fi
  tries=$((tries + 1))
  sleep 0.2
done

# The first argument is the [bar/<name>] block inside the file that -c points to.
polybar log -c ~/.config/polybar/current.ini &
polybar ethernet_bar -c ~/.config/polybar/current.ini &
polybar vpn_bar -c ~/.config/polybar/current.ini &
polybar target_to_hack -c ~/.config/polybar/current.ini &
polybar launchers -c ~/.config/polybar/current.ini &
polybar primary -c ~/.config/polybar/current.ini &

# The workspaces bar, in its own file: another font and no module shared with the status bars.
polybar primary -c ~/.config/polybar/workspace.ini &
