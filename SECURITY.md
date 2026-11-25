**English** | [Español](SECURITY.es.md)

# Security

## Supported versions

Only the latest commit on `main` receives fixes. Each release is listed in
[`CHANGELOG.md`](CHANGELOG.md).

## Report a vulnerability

Do not open a public issue. Report it privately on GitHub: in this repository, open
**Security**, then **Report a vulnerability**, and fill in the form.

Include what is affected (a script, the sudoers rule, a linked configuration, the CI workflow),
the steps to reproduce it and the impact you see. You get an answer that confirms the report, and
you are kept informed until it is fixed. Once the fix is published, the report is made public
with credit to you, unless you prefer otherwise.

## Scope

- **In scope:** the scripts (`bootstrap.sh`, `install.sh`, `uninstall.sh`, `tools/`,
  `githooks/`), what `70-system/setup.sh` installs as root (the sudoers rule, `anon-harden`, the
  apt and greeter settings), the anonymity toggle letting traffic leave outside Tor, the CI
  workflow, and anything in this repository that could leak a secret, download something
  unverified or run code a user did not expect.
- **Out of scope:** vulnerabilities in the tools it installs (Parrot OS packages, AnonSurf, Tor,
  Neovim, oh-my-posh, Node.js, Claude Code), which go to their own projects.
