#!/bin/bash
# The Parrot OS logo in the `log` bar (left corner), run by [module/parrot] in current.ini once a
# day: the logo is static.
#
# %{T2} picks current.ini's font-1 (Hack Nerd Font Mono): nf-linux-parrot (U+F329) exists only in
# Nerd Fonts v3+, and Hack is the installed font that has it; without Hack the logo does not show.
# A UTF-8 escape rather than the literal character: editing tools drop private use glyphs (PUA).

ICON=$'\xef\x8c\xa9' # U+F329 nf-linux-parrot
echo "%{T2}${ICON}%{T-}"
