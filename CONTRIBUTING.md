**English** | [Español](CONTRIBUTING.es.md)

# Contributing

Thank you for helping. It is a personal repo, but it follows a standard flow to keep it clean and
reproducible on any Parrot OS machine.

## Before you start

- **A bug or a small fix:** open a pull request directly, or an issue with the
  [bug report form](https://github.com/M1gu3l4ngel/dotfiles-parrot/issues/new/choose).
- **A new package, a new folder or a change to what `bootstrap.sh` or `70-system/setup.sh`
  installs:** open an issue first and describe the problem it solves. It changes every machine
  that pulls the repo, so it is agreed before it is written.
- **A vulnerability:** never in a public issue; follow [`SECURITY.md`](SECURITY.md).
- **Conduct:** everyone who takes part follows the [code of conduct](CODE_OF_CONDUCT.md).

## Set up

It needs Parrot OS 7 on x86_64, git and a user with sudo; the
[README](README.md#prerequisites) explains the rest. Clone the repo, make a branch from `main`
and run the checks from its root as a normal user. They are the same ones CI runs:

```bash
./tools/check.sh
```

The docs, task panel and install test checks need dotfiles-windows cloned in
`~/dotfiles-windows` (`bootstrap.sh` clones it); without it they are skipped locally and only CI
runs them.

To see what the installer would change on your machine without changing anything:

```bash
./bootstrap.sh --dry-run
./install.sh --check
```

## What a change has to keep

- **Nothing personal or from a company:** no local user name, email, IP, hostname, key
  fingerprint, Firefox profile ID or client name. Use placeholders (`__USER__`) or values read
  at run time (`$HOME`, `$SUDO_USER`). Details in `.claude/rules/security.md`.
- **Verified downloads:** packages come from apt; anything else is downloaded at a pinned
  version and verified with SHA-256 (see `bootstrap.sh`). Never `curl ... | bash`, and GitHub
  Actions are pinned by commit SHA.
- **Least privilege:** files under `/etc` are installed by `70-system/setup.sh` as `root:root`
  copies, never as links to the repo, and a `NOPASSWD` sudoers rule names exact commands with
  fixed arguments.
- **Idempotent scripts:** each step checks whether it is already done, so a script can run
  again without breaking anything.
- **Documents in pairs:** `X.md` in English and `X.es.md` in Spanish, with the same sections,
  identical code blocks and the language selector on line 1. `./tools/check.sh`
  (`check-docs.mjs` from dotfiles-windows) checks it, links and anchors included.
- **English** in code comments, script output, CI step names and test names, following
  [docs/contributing/comments.md](docs/contributing/comments.md). The text the desktop shows
  (notifications, rofi menus), the rules in `.claude/rules/` and the task lists
  (`docs/tasks.md`, `docs/backlog.md`) are Spanish only.
- **Icons as escapes:** Nerd Font glyphs are written as UTF-8 escapes (`$'\xef\x8c\xa9'`),
  never as literal characters, which editing tools drop.
- **Plain documentation:** no emojis, commands that copy and work as they are.

The conventions live in `.claude/rules/` (in Spanish). They are plain Markdown: they work the
same for people and for Claude Code, which loads them automatically.

| File | What it defines |
|---|---|
| [security.md](.claude/rules/security.md) | Personal data and secrets, verified downloads, least privilege |
| [style.md](.claude/rules/style.md) | English comments that explain the why, indentation per format |
| [git.md](.claude/rules/git.md) | Commit format and which git commands never run |
| [shell.md](.claude/rules/shell.md) | Shell and zsh scripts |
| [documentation.md](.claude/rules/documentation.md) | Documentation style and the two-language rule |
| [file-edits.md](.claude/rules/file-edits.md) | Nerd Font icons and protected files |
| [environment.md](.claude/rules/environment.md) | Environment quirks (X11, VMware, polybar, fonts) |

## Commits and pull requests

Commits follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/): a title
of 72 characters at most, a blank line and a body with one dash per concrete change (no body
only when the title says it all), in English and in the imperative:

```
type(scope): summary in the imperative

- One line per concrete change.
```

- `type`: `feat`, `fix`, `docs`, `style`, `refactor`, `chore`, `ci`.
- `scope` optional: the affected component (`polybar`, `zsh`, `system`...).
- **One commit per verified change**: two independent changes go in two commits, so each one
  can be reviewed and reverted on its own.
- Add files by path, never with `git add -A` or `git add .`.
- The repo is public and every commit publishes the author's email: use the GitHub **noreply
  email** and **sign commits with GPG**, as [docs/keys-and-secrets.md](docs/keys-and-secrets.md)
  explains.

A pull request does one thing and fills in its template. A change people notice adds its line
under "Unreleased" in [CHANGELOG.md](CHANGELOG.md) and under "Sin publicar" in its Spanish
pair. CI has to pass: the same checks as `./tools/check.sh`, plus the secrets scan.

## License

By contributing, you agree that your contribution is licensed under [MIT](LICENSE), like the
rest of the repo.
