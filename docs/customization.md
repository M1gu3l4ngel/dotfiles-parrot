**English** | [Español](customization.es.md)

# Customization

Common look-and-feel changes. Unless noted otherwise, run them as a regular
user from `~/dotfiles`. The files in `~/.config/` are links to the repo:
editing one edits the repo.

## Design system

Rules that every component follows. When you change something, keep to them
so the desktop still looks like one piece.

| Element | Value | Where |
|---|---|---|
| Palette | Monokai Soda (kitty's) | `scripts/.config/scripts/palette.sh`, `polybar/.config/polybar/colors.ini`, `rofi/.config/rofi/themes/monokai-soda.rasi`, `gtk/.config/gtk-4.0/gtk.css`, `vscodium/settings.json` |
| Font | CaskaydiaCove Nerd Font everywhere; Hack only for the Parrot logo | `kitty.conf`, `current.ini`, `workspace.ini`, `dunstrc`, `monokai-soda.rasi` |
| Text size | 12 pt (16 px) in bars, menu and kitty (same as Windows Terminal) | |
| Radii | Windows 10 px; bars, notifications and menu 8 px; inner elements 4 px | `picom.conf`, `current.ini`, `dunstrc`, `monokai-soda.rasi` |
| Borders | 1 px `#555555` on the focused window and on the bars | `bspwmrc`, `current.ini` |
| Spacing | 12 px between bars, from the screen edges and between windows | `current.ini`, `bspwmrc` (`window_gap`) |

Meaning of the colors in polybar:

| Color | Use |
|---|---|
| Gray (`#8F8B7A`) | Off, empty, disconnected |
| Green (`#98E024`) | Connected, active (VPN, anonymity) |
| Orange (`#FA8419`) | Focus: active workspace, selected option in rofi |
| Red (`#F4005F`) | Active target, something that needs attention (icons only) |
| Cyan (`#58D1EB`) | Local network |

No animations or fades, on purpose: every animation delays windows from
showing up and, with `vsync = false` in picom, causes tearing on VMware.

## Wallpaper

`~/.config/wallpaper.jpg` is a link to the repo's default wallpaper
(`assets/wallpaper.jpg`). Do not copy another image over it with `cp`: it
would write through the link and overwrite the repo file. Point the link at
your image instead:

```bash
ln -sfn /path/to/your-wallpaper.jpg ~/.config/wallpaper.jpg
```

Apply the change with `Super+Alt+R`.

The login and lock screen (`Super+Shift+X`) uses a copy of
`assets/wallpaper.jpg` installed by `system/setup.sh` (step 9), because the
login screen cannot read your home. The link above only changes the desktop.

## Prompt (oh-my-posh)

The prompt uses `oh-my-posh/capr4n.omp.json`. To change it, edit that file or
use one of the themes bundled with oh-my-posh.

1. List the available themes:

    ```bash
    ls ~/.cache/oh-my-posh/themes/
    ```

2. Try one in the current terminal only (it changes nothing in the repo):

    ```bash
    eval "$(~/.local/bin/oh-my-posh init zsh --config ~/.cache/oh-my-posh/themes/agnoster.omp.json)"
    ```

3. To keep it, change the `--config` path in the oh-my-posh line of
   `zsh/.zshrc` and run `exec zsh`.

## polybar colors

The colors live in two files with the same values:

- `polybar/.config/polybar/colors.ini`: background, text, borders and
  workspaces.
- `scripts/.config/scripts/palette.sh`: status colors of the modules (VPN,
  target, anonymity, launchers).

`colors_dark.ini` and `colors_light.ini` are alternatives to `colors.ini`. To
use one, copy it over the active one and reload:

```bash
cp polybar/.config/polybar/colors_dark.ini polybar/.config/polybar/colors.ini
```

```bash
~/.config/polybar/launch.sh
```

To go back to the original palette: `git checkout polybar/.config/polybar/colors.ini`.

## rofi theme

The active theme is `monokai-soda`, with the same palette as the rest of the
desktop. There are 25 more in `rofi/.config/rofi/themes/`. In
`rofi/.config/rofi/config.rasi`, comment out the active `@theme` line (with
`//` in front) and uncomment or write the one for the theme you want:

```
@theme "themes/nord"
```

The change shows the next time rofi opens (`Super+D`). If the theme asks for
a font that is not installed, rofi uses another one: see the font section.

`Super+D` opens applications with their icons; `Ctrl+Tab` switches to the
`$PATH` executables mode, for terminal tools without a menu entry.

## Neovim theme

- Try themes: inside Neovim, `Space` + `t` + `h`.
- Keep one: in `nvim/.config/nvim/lua/chadrc.lua`, change the value of
  `theme` (`"monekai"` by default).

## Editor (VSCodium)

The settings are in `vscodium/settings.json` and the shortcuts in
`vscodium/keybindings.json`, linked by `install.sh`. The code uses the
Monokai theme; the interface uses the system palette, defined in
`workbench.colorCustomizations` under `"[Monokai]"`. Changes apply when you
save the file.

- Change an interface color: edit its value in that block.
- Use another theme: change `workbench.colorTheme`. The `"[Monokai]"` block
  only affects Monokai, so the new theme shows its original colors.
- Add an extension: look it up on [Open VSX](https://open-vsx.org)
  (VSCodium's catalog), add its identifier to `vscodium/extensions.txt` and
  run `./bootstrap.sh`, which installs only the missing ones.

Workspace trust stays on: when you open lab material or downloaded repos,
VSCodium opens them in restricted mode (no tasks or extensions that run code)
until you confirm.

## Code formatting

The style lives in two files that every tool reads (VSCodium, the Prettier
CLI, CI), not in the editor settings:

| File | Linked to | What it formats |
|---|---|---|
| `format/prettierrc.json` | `~/.prettierrc.json` | Prettier: JS, TS, JSON, CSS, HTML, Markdown and YAML |
| `format/editorconfig` | `~/.editorconfig` | Indentation and line endings of everything else (shell, SQL, TOML, `.env`) |

The configuration closest to the file wins, with no merging:

- A project with its own `.prettierrc` or `.editorconfig` (with
  `root = true`) uses its own and never the global one.
- The global one only applies to files under `~` that have no configuration.
- A shared project or one with CI must always carry its own: CI and other
  people do not have your home.

On save, VSCodium formats with Prettier; shell with shfmt (it reads the
`.editorconfig`), and SQL with SQLTools. It only saves when you switch tab or
window: time-based autosave does not format.

To change the style, edit both files with the same values.

## Terminal font

kitty uses `CaskaydiaCove Nerd Font`, size 12 (`font_family` and `font_size`
in `kitty/.config/kitty/kitty.conf`). Reload with `Ctrl+Shift+F5` inside
kitty.

`bootstrap.sh` installs only the fonts the setup uses: CaskaydiaCove for all
text and Hack for the Parrot logo in polybar. To use another one, add it to
`bootstrap.sh` with its version and SHA-256, like the existing ones; do not
copy font files into the repo.

## Notifications

Colors, position and timeouts in `dunst/.config/dunst/dunstrc`. Apply and
test:

```bash
dunstctl reload
```

```bash
notify-send -u critical "Test" "Critical notification"
```

## Keyboard shortcuts

The shortcuts are in `sxhkd/.config/sxhkd/sxhkdrc`. Format: the key
combination on one line and the command on the next, indented with a tab:

```
super + shift + n
	notify-send "hello"
```

Reload with `Super+Escape`. Before using a combination, check that it does
not already exist in the file: with a duplicated combination only one of them
works.
