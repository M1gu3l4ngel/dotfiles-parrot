**English** | [Español](CONTRIBUTING.es.md)

# Contributing

## Workflow

1. Create a branch from `main`.
2. Make your changes following the conventions below.
3. Run the checks from the repo root. They must all pass:

    ```bash
    ./tools/check.sh
    ```

4. Commit following the commit format.
5. Open a pull request. CI runs the same checks and reports the result on
   GitHub.

If the change is visible to users, add it to `CHANGELOG.md` ("Unreleased")
and to `CHANGELOG.es.md` ("Sin publicar").

## Documentation in two languages

All documentation exists in English (`X.md`) and Spanish (`X.es.md`), with
the language selector on the first line. When you change a document, change
its pair in the same commit. `./tools/check.sh` fails if they do not share
the same structure (sections, tables, lists, links) or if their code blocks
differ: commands are not translated.

Code comments, commit messages and the rules in `.claude/rules/` are written
in Spanish only.

## Commits

[Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) format,
on a single line of at most 72 characters, with the description in Spanish:

```
type(scope): descripción en español
```

- `type` in English: `feat`, `fix`, `docs`, `style`, `refactor`, `chore`, `ci`.
- Optional `scope`: the affected component (`polybar`, `zsh`, `system`...).
- One commit per logical change, even if it touches several files.

Example:

```
fix(polybar): esperar a que se cierren las barras antes de relanzarlas
```

The repo is public and every commit publishes the author's email: use your
GitHub noreply email and sign your commits with GPG. How to set it up:
[docs/keys-and-secrets.md](docs/keys-and-secrets.md).

## Conventions

They live in `.claude/rules/` (in Spanish). They are plain Markdown: they work
the same for people and for Claude Code, which loads them automatically.

| File | What it defines |
|---|---|
| [security.md](.claude/rules/security.md) | Personal data and secrets, verified downloads, least privilege |
| [style.md](.claude/rules/style.md) | Spanish comments that explain the why, indentation per format |
| [shell.md](.claude/rules/shell.md) | Shell and zsh scripts |
| [documentation.md](.claude/rules/documentation.md) | Documentation style and the two-language rule |
| [file-edits.md](.claude/rules/file-edits.md) | Nerd Font icons and protected files |
| [environment.md](.claude/rules/environment.md) | Environment quirks (X11, VMware, polybar, fonts) |

The most important:

- Never include personal data or secrets: local user name, emails, IPs,
  fingerprints, client names.
- Everything that does not come from apt is downloaded at a pinned version and
  verified with SHA-256 (see `bootstrap.sh`). Never `curl ... | bash`.
- Nerd Font icons are written as escapes (`$'\xef\x8c\xa9'`), never as
  literal characters.

## Reporting issues

Open an issue with:

- What you expected and what happened.
- Parrot version (`cat /etc/os-release`) and whether it runs in a VM.
- The steps to reproduce it and, if it is visual, a screenshot.
