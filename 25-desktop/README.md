**English** | [Español](README.es.md)

# 25-desktop

The graphical session: window manager, shortcuts, bars, compositor, launcher, notifications,
keyboard and the scripts behind the polybar modules. Everything uses the Monokai Soda palette, the
same values in every file.

| Path | Linked to | What it is | Reload |
|---|---|---|---|
| `bspwm/.config/bspwm/bspwmrc` | `~/.config/bspwm/bspwmrc` | Window manager: gaps, borders, rules, and the session start (keymap, picom, dunst, polybar, sxhkd) | `Super+Alt+R` |
| `bspwm/.config/bspwm/scripts/` | `~/.config/bspwm/scripts/` | `bspwm_resize`, which `Super+Alt+Arrows` call | `Super+Alt+R` |
| `sxhkd/.config/sxhkd/sxhkdrc` | `~/.config/sxhkd/sxhkdrc` | Every keyboard shortcut ([README](../README.md#shortcuts)) | `Super+Escape` |
| `polybar/.config/polybar/` | `~/.config/polybar/` | `current.ini` (status bars), `workspace.ini` (workspaces), `colors.ini` (active palette, with `colors_dark.ini` and `colors_light.ini` as variants) and `launch.sh` | `Super+Alt+R`, or `~/.config/polybar/launch.sh` |
| `picom/.config/picom/picom.conf` | `~/.config/picom/` (the folder) | Compositor: shadows, transparency, blur and rounded corners, with the `glx` backend | On save |
| `rofi/.config/rofi/` | `~/.config/rofi/` | Launcher (`Super+D`) and the power menu; the active theme is `themes/monokai-soda.rasi` | Next time it opens |
| `dunst/.config/dunst/dunstrc` | `~/.config/dunst/` (the folder) | Notifications, bottom right | `dunstctl reload` |
| `gtk/.config/gtk-4.0/` | `gtk.css` and `settings.ini` in `~/.config/gtk-4.0/` | Colors and settings of the GTK4 apps (Nautilus) | Close and reopen the app |
| `xkb/.config/xkb/` | `~/.config/xkb/` | Keymap: us and latam layouts (`Alt+Shift`) and the Caps Lock fix (`symbols/capsfix`) | `Super+Alt+R` |
| `scripts/.config/scripts/` | `~/.config/scripts/` | polybar modules (network, VPN, target, anonymity, Firefox, power), `palette.sh`, `powermenu.sh` and `toggle_anonymity.sh` | With polybar |

`install.sh` creates the links. In `gtk-4.0` only the two files are linked: other apps keep their
state in that folder.

## What not to touch

- `interval = 0` in a polybar `custom/script` module: polybar runs it again with no pause and
  holds a CPU core.
- Nerd Font icons as literal characters: editing tools drop them. They live in the scripts as UTF-8
  escapes (`$'\xef\x8c\xa9'`), which is why polybar's icons are in `scripts/` and not in the `.ini`
  files.
- The keymap is loaded with `xkbcomp`, not `setxkbmap`: `setxkbmap` cannot load the custom
  `capsfix` symbol.
- Never reload with `kill`, `killall` or `pkill`: use the reloads in the table.

Colors, fonts and wallpaper: [docs/customization.md](../docs/customization.md).
