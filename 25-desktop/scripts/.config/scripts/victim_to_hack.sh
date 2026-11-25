#!/bin/bash
# Shows the active target's IP and name in polybar's target_module (bar/target_to_hack). zsh sets
# it with the .zshrc functions: `settarget 10.10.11.42 machine_name` writes "IP name" to
# TARGET_FILE, and `cleartarget` leaves it at 0 bytes.
#
# polybar runs it every second (current.ini, [module/target_module]), so it starts no external
# process: bash's builtin `read`, no cat or awk.

# The state shared by the shell and the bar; settarget and cleartarget in .zshrc use the same path.
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"
TARGET_FILE="$STATE_DIR/target"

# nf-md-target (U+F04FE) as a UTF-8 escape: editing tools drop private use glyphs (PUA) written
# literally.
ICON=$'\xf3\xb0\x93\xbe'

# shellcheck source=palette.sh
. "${0%/*}/palette.sh"

# `read` fails on a missing file and leaves the variables empty on an empty one: both end in "No
# target" below. `2>/dev/null` goes before `<`: redirections apply in order, and after it the
# missing file error would already be printed.
ip_address="" machine_name=""
# With `demo on` (ethernet_status.sh) the fake target is the third and fourth field, and the real
# one stays untouched.
DEMO_FILE="$STATE_DIR/demo"
if [ -r "$DEMO_FILE" ]; then
  read -r _ _ ip_address machine_name _ <"$DEMO_FILE"
else
  read -r ip_address machine_name _ 2>/dev/null <"$TARGET_FILE"
fi

# With a target: a red icon (alert, there is an active target), the IP highlighted and the name in
# plain text. Without one: all grey, with no red to alarm.
if [ -n "$ip_address" ] && [ -n "$machine_name" ]; then
  echo "%{F${ERROR}}${ICON} %{F${STRONG}}${ip_address} %{F${TEXT}}- ${machine_name}%{F-}"
else
  echo "%{F${MUTED}}${ICON} No target%{F-}"
fi
