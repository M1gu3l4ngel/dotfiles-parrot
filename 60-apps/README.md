**English** | [Español](README.es.md)

# 60-apps

The apt packages of the environment, kept out of `bootstrap.sh`: what is installed changes far more
often than how.

| File | What it is |
|---|---|
| `apt.txt` | One package per line, grouped by area (desktop, shell and terminal tools, development, security, pentesting, fonts and downloads); `#` starts a comment |

`bootstrap.sh` reads it and installs only the missing packages, in a single apt transaction. With
nothing missing it skips `apt-get update`, the slowest part of a second run. Inside VMware it adds
`open-vm-tools-desktop`, which is not in the list.

What does not come from apt (Nerd Fonts, Neovim, oh-my-posh, nvm and Node) is downloaded by
`bootstrap.sh` at a pinned version and checked against its SHA-256.

## Add a package

1. Add its name to `apt.txt`, in its group.
2. From `~/dotfiles`, as a regular user (it asks for sudo):

    ```bash
    ./bootstrap.sh
    ```
