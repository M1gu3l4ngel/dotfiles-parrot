#!/bin/bash
# polybar's personal Firefox icon ([module/firefox_personal] in current.ini); a left click runs
# `firefox -P default-esr --no-remote`. The icon is a UTF-8 escape, not the literal character, which
# the editing tools replace with a CJK look-alike that has no glyph.

ICON=$'\xef\x89\xa9' # U+F269 firefox
# shellcheck source=palette.sh
. "${0%/*}/palette.sh"
# Orange (ACCENT): Firefox's brand color, within the Monokai Soda palette. The space after the icon
# makes up for its overflow to the right (the glyph is drawn wider than the room it takes);
# module-margin in bar/launchers spaces the icons.
echo "%{F${ACCENT}}${ICON} %{F-}"
