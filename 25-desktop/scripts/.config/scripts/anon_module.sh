#!/bin/bash
# polybar's anonymity module ([module/anon_status] in current.ini, every second): a ghost read from
# the state file toggle_anonymity.sh writes; a left click runs the toggle. The icon is the same in
# both states and the color changes, as in the other modules.

STATE_FILE="$HOME/.config/bin/anon_state"
# The builtin `read` rather than `cat`: polybar runs this every second and no process starts. A
# missing file leaves the state "off".
state="off"
read -r state 2>/dev/null <"$STATE_FILE"

# shellcheck source=palette.sh
. "${0%/*}/palette.sh"

# nf-md-ghost (U+F02A0) as a UTF-8 escape: editing tools drop private use glyphs (PUA) written
# literally.
ICON=$'\xf3\xb0\x8a\xa0'

# On: green (success). Off: grey, drawing no attention. The space after the icon makes up for its
# overflow to the right (the glyph is drawn wider than the room it takes); module-margin in
# bar/launchers spaces it from the Firefox icons.
if [ "$state" = "on" ]; then
  echo "%{F${SUCCESS}}${ICON} %{F-}"
else
  echo "%{F${MUTED}}${ICON} %{F-}"
fi
