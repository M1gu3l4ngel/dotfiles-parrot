#!/bin/bash
# polybar's anonymity module ([module/anon_status] in current.ini, every second): a ghost whose
# color gives the state; a left click runs toggle_anonymity.sh. The icon is the same in every state,
# as in the other modules.
#
# The state comes from systemd, not from a file the toggle writes: a file outlived a reboot or a
# manual `sudo anonsurf stop` and left the ghost green with no anonymity. systemd keeps the
# /run/systemd/units/invocation:<unit> link while a unit is active (anonsurfd included, a oneshot
# with RemainAfterExit), so a file test answers without starting a process every second as
# `systemctl is-active` would. The link is a systemd internal: if a release drops it, the ghost
# stays grey, never green by mistake.

set -u

ANONSURFD_ACTIVE=/run/systemd/units/invocation:anonsurfd.service
# toggle_anonymity.sh creates it while Tor connects and the exit is checked.
CONNECTING="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/anon_connecting"

# shellcheck source=palette.sh
. "${0%/*}/palette.sh"

# nf-md-ghost (U+F02A0) as a UTF-8 escape: editing tools drop private use glyphs (PUA) written
# literally.
ICON=$'\xf3\xb0\x8a\xa0'

# Connecting: orange (accent), not yet verified. On: green (success). Off: grey, drawing no
# attention. The space after the icon makes up for its overflow to the right (the glyph is drawn
# wider than the room it takes); module-margin in bar/launchers spaces it from the Firefox icons.
if [ -e "$CONNECTING" ]; then
  color=$ACCENT
elif [ -L "$ANONSURFD_ACTIVE" ]; then
  color=$SUCCESS
else
  color=$MUTED
fi
echo "%{F${color}}${ICON} %{F-}"
