**English** | [Español](comments.es.md)

# Code comments

How comments are written in this repo: shell scripts, zsh, Lua (Neovim), the
polybar `.ini` files, `picom.conf`, `kitty.conf`, `sxhkdrc`, rofi `.rasi`, XKB,
GTK, JSON with comments, YAML and Firefox's `user.js`. They are written in
English, so that the code reads the same for anyone who opens it.

The guide is the one in
[dotfiles-windows](https://github.com/M1gu3l4ngel/dotfiles-windows/blob/main/docs/contributing/comments.md),
which compares five style guides (Google Shell and JavaScript, PowerShell
Practice and Style, Microsoft, the Linux kernel). This page keeps what applies
here and adds what the formats of Parrot need.

## File header

Every file starts with a short header: what it is, who loads it and how to
reload it. Two to six lines.

- It goes after what has to come first: the shebang.
- It does not repeat the file name or its path: the file already has them,
  and `lib/links.sh` says where it is linked.
- It does not copy the README (usage, requirements) or keep a history (dates,
  authors, "before it did…"): that lives in the README and in git.

```bash
#!/usr/bin/env sh
# Starts every polybar bar, after closing the running ones over IPC.
#
# bspwmrc runs it at login and on every bspwm restart (Super+Alt+R); it can also
# be run by hand to reload the bars.
```

## Comments inside the body

Only **why**: the decision behind a line, a limit, a workaround, the incident it
prevents. Never **what**: the code already says it, and a comment that repeats it
goes stale the first time the code changes.

```ini
;; Never 0 in a custom/script: polybar reruns it in a loop with no pause (it
;; reached 30 % of CPU). 86400 for static icons.
interval = 86400
```

- Above the code it explains, not at the end of the line, unless it is a short
  note.
- One comment for a block, not one per line.
- A section in a long file is a blank line and a one-line comment, never a
  banner.
- A shell function gets a comment when its name does not say everything a
  caller needs: an effect, a limit, the exit code.

## Form

- English, complete sentences, present tense, plain words.
- Within the code's line limit: 100 columns (`.editorconfig`).
- No banners (`# ----- X -----`, `# =====`), boxes, emojis or decorative
  capitals.
- No commented-out code: git keeps it.
- `TODO` only with the condition that ends it (`TODO: remove when …`); the
  pending work itself goes to `docs/tasks.md`.
- Nerd Font icons are never written as literal characters, not even in a
  comment: they are named by code point (`U+F329 nf-linux-parrot`).

| Format | Comment prefix |
|---|---|
| Shell, zsh, `bspwmrc`, `sxhkdrc`, `picom.conf`, `kitty.conf`, YAML, `.gitignore` | `#` |
| polybar `.ini` | `;;` |
| Lua | `--` |
| XKB, rofi `.rasi`, GTK `.css`, JSON with comments, `user.js` | `//` or `/* */` |

## Other text in the code

| Text | Language | Why |
|---|---|---|
| Script output (`install.sh`, `uninstall.sh`, `bootstrap.sh`, `70-system/setup.sh`, `tools/`) and CI step names | English | One text for both documentation languages to quote as is |
| Test names | English | They are code, and CI prints them |
| Text the desktop shows (notifications, rofi menus, polybar labels) | Spanish | It is the interface its user reads, not code |
| Task panel text and the headings it reads from `docs/tasks.md` | Spanish | `docs/tasks.md` is written in Spanish |

## What is not commented

- What the code, a name or a type already says.
- History: what the code did before, who changed it, when. That is git.
- Personal or machine data (users, paths, hosts, IPs): the repo is public.
- Anything the comment cannot keep true: a comment that contradicts the code is
  worse than none, so a change updates its comments in the same commit.

## The check

`./tools/check.sh` runs the check that dotfiles-windows shares through
`~/.claude/tools`:

```bash
node ~/.claude/tools/check-comments.mjs .
```

It fails on a comment or test name in Spanish. What it cannot classify on its
own lives in `.claude/comments.json`: the XKB symbols file, whose comments use
`//`, and the exemptions, which print on every run.
