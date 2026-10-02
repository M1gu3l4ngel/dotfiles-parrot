**English** | [Español](CHANGELOG.es.md)

# Changelog

Notable changes to the project. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and versions follow
[semantic versioning](https://semver.org/).

## [Unreleased]

### Added

- Full documentation in English and Spanish: each `X.md` document (English,
  the one GitHub shows) has its `X.es.md` pair, with a language selector.
  This covers the README, `CONTRIBUTING`, this changelog, `docs/` and the
  READMEs of `system/` and `claude/`. `tools/check.sh` (`tools/check-docs.py`)
  fails if a pair is missing or if they differ in structure, links or code
  blocks.
- Global Claude Code layer (`claude/`), the same as in dotfiles-windows:
  `CLAUDE.md` with the Linux specifics, status line, a hook that enforces
  editing with Edit/Write and a `settings.json` template (secrets in
  `deny`/`ask`). `install.sh` links it and creates `settings.json` if it is
  missing; `tools/check.sh` watches its line budget.
- `uninstall.sh`: removes the repo's links and restores the
  `.pre-dotfiles.bak` copies; `--dry-run` shows what it would do without
  changing anything. The link list moves to `lib/links.sh`, shared with
  `install.sh`.
- polybar: power button, alone in the right corner. It opens a rofi menu
  (power off, reboot, log out) that uses `systemctl`, so the VM is never
  powered off abruptly (a cut like that left empty git objects).
- Nautilus file manager with the Monokai Soda palette (`gtk/`): it opens with
  `Super+E` or by clicking the Parrot logo. File indexer disabled, no
  animations and `VMShare` in the sidebar.
- Versioned VSCodium settings (`vscodium/`): code with Monokai, interface
  with the system palette, no telemetry and workspace trust enabled.
- `bootstrap.sh` installs VSCodium and its 28 extensions from Open VSX
  (`vscodium/extensions.txt`), only the missing ones.
- Global formatting style (`format/`): `~/.prettierrc.json` and
  `~/.editorconfig` for projects without their own configuration (tabs,
  double quotes, 100 columns). A project with its own never uses the global
  one. The repo has its own `.prettierrc.json` and `.prettierignore`.
- VSCodium formats shell with shfmt and SQL with SQLTools, and reads
  `.editorconfig` (EditorConfig extension).

### Changed

- `docs/` guides with English names (`getting-started`, `customization`,
  `anonymity`, `keys-and-secrets`) and code examples with English
  placeholders (`<your-noreply>`, `<user>`), the same in both languages.
- Same as on Windows: kitty at 12 pt (like PowerShell in Windows Terminal),
  the numeric keypad `Ctrl+/` shortcut to comment blocks in VSCodium
  (`vscodium/keybindings.json`) and Monokai Night's git colors in the
  explorer. VSCodium code in SemiBold: Linux draws a thinner stroke.
- zsh like PowerShell on Windows: quoted text in cyan and selection with a
  light background. `Ctrl+Shift+←/→` selects words in the VSCodium terminal
  too.
- polybar: colors with meaning (gray = off, color = active) from a single
  palette, `scripts/.config/scripts/palette.sh`.
- polybar: text in CaskaydiaCove SemiBold 12 pt, the same family as kitty,
  dunst and rofi.
- polybar: bars with widths fitted to their content and 12 px of spacing
  between them and from the edges, aligned with bspwm's `window_gap`.
- polybar: workspaces with a clear hierarchy (active `●` in orange, with
  windows in the text color, empty ones dimmed).
- Subtler corner radii: windows 10 px (was 20), bars, notifications and rofi
  8 px.
- 1 px `#555555` border on the focused window and on the bars.
- rofi: `monokai-soda` theme with the desktop palette; `Super+D` opens
  applications with icons (`Ctrl+Tab` switches to executables mode).
- Screen lock (`Super+Shift+X`) with `dm-tool lock`: LightDM's login screen,
  instant and with no extra packages.
- New 4K wallpaper (almost black, soft gradient), shared by the desktop and
  the login/lock screen (`system/setup.sh`, step 9).
- Anonymity with a ghost icon (green on, gray off), now next to the Firefox
  launchers.

### Fixed

- `system/README`: the verification block had a `#` comment that zsh rejects
  when pasted (without `interactivecomments`).
- Claude Code hook: it blocked `$(cmd 2>/dev/null)` because it took the `)`
  as part of the redirection target.
- The anonymity toggle decided the state by whether a `tor` process existed:
  with the Tor that Parrot leaves running after boot, it believed anonymity
  was on and failed to turn it off. It now uses AnonSurf's state
  (`anonsurfd`).

### Removed

- Iosevka: no configuration uses it anymore and `bootstrap.sh` no longer
  downloads it.
- i3lock-fancy and imagemagick: replaced by `dm-tool lock`.

## [1.0.0] - 2026-09-30

First published version.

### Installation

- `bootstrap.sh`: full install in one command, idempotent, with downloads at
  pinned versions verified by SHA-256. It only installs what is missing and
  prints a short output in Spanish.
- `install.sh`: config links from any folder, backing up what already exists
  (without overwriting previous backups).
- `system/setup.sh`: system hardening, idempotent.
- Nerd Fonts (Iosevka, Hack, CaskaydiaCove) installed by the bootstrap; the
  repo includes no font binaries.

### Environment

- bspwm, sxhkd, polybar, picom (`glx` backend), rofi, kitty, dunst and zsh
  with the Monokai Soda palette; Neovim with NvChad and Lua and bash LSP.
- oh-my-posh prompt with the capr4n theme, shared with dotfiles-windows.
- zsh starts in about 70 ms: nvm loads the first time it is used.
- us/latam XKB keymap with a Caps Lock that turns off on press.
- Text selection with `Shift+Arrows` in zsh.
- Ethernet and VPN bars that detect the interface on their own (WireGuard
  included).

### Pentesting and privacy

- Active target in polybar with `settarget` (validates the IPv4) and
  `cleartarget`.
- Anonymity through Tor (`Super+A`) with an IPv6 and ICMP kill switch and
  exit verification.
- Personal and pentest Firefox profiles; the pentest one without target leaks
  to third parties or unrequested traffic (Firefox ESR 140).
- GPG agent configuration, commit signing and a `pass` guide.
- Folder shared with the host in VMware.

### Security

- Sudoers rule limited to exact commands (never `iptables` directly) and
  validated before it is installed.
- ufw firewall with incoming traffic blocked except loopback and VPN, on IPv4
  and IPv6.
- Automatic security patches (kernel and Tor included).
- Repair of `/etc/profile` if its `PATH` includes the current directory.
- Removal of the `docker` group (equivalent to root) if Docker is not
  installed.

### Quality

- CI on GitHub Actions and `tools/check.sh`: syntax, shellcheck, shfmt
  formatting, Lua, JSON, sudoers, XKB, public repo hygiene and gitleaks over
  the whole history.
- Documentation in `docs/` and rules for Claude Code in `.claude/rules/`.

[Unreleased]: https://github.com/M1gu3l4ngel/dotfiles-parrot/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/M1gu3l4ngel/dotfiles-parrot/releases/tag/v1.0.0
