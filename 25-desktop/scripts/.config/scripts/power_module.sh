#!/bin/bash
# polybar's power button ([module/power] in current.ini); a click opens powermenu.sh. A static
# icon: polybar runs it once a day (interval = 86400).

# power-off (U+F011) as a UTF-8 escape: editing tools drop private use glyphs (PUA) written
# literally.
ICON=$'\xef\x80\x91'
# shellcheck source=palette.sh
. "${0%/*}/palette.sh"
# The neutral text color: it is neither a state (grey, green) nor an alert (red). %{O4} (a 4 px
# offset) centers the icon in its square card: the glyph takes a letter's width (9.4 px at 12 pt)
# but is drawn ~13.8 px wide, and 9.4 + 4 is about 13.8.
echo "%{F${TEXT}}${ICON}%{O4}%{F-}"
