# shellcheck shell=sh
# The Monokai Soda palette (kitty's) with a fixed role per color, loaded by the polybar modules with
# `. "${0%/*}/palette.sh"`: a color changed here changes in every bar. The same values are in
# 25-desktop/polybar/.config/polybar/colors.ini for the bars themselves.
#
# Color means state: grey (MUTED) is off or empty, color is active. Text contrast checked against
# WCAG (at least 4.5:1 on the bars' #1A1A1A background); ERROR (4.15:1) is for icons only. Values
# for polybar's %{F#...} color tag.

# shellcheck disable=SC2034 # The scripts that load this file use the variables.
TEXT='#C4C5B5'    # normal text
STRONG='#F6F6EF'  # important data (IPs)
MUTED='#8F8B7A'   # off, empty, disconnected
ACCENT='#FA8419'  # focus and selected item
SUCCESS='#98E024' # connected, active, fine
ERROR='#F4005F'   # active target, failures (icons only)
INFO='#58D1EB'    # local network
EXTRA='#9D65FF'   # pentest Firefox
