**English** | [Español](README.es.md)

# 10-shell

The shell and its prompt. zsh loads the same oh-my-posh theme as PowerShell in
[dotfiles-windows](https://github.com/M1gu3l4ngel/dotfiles-windows), so the prompt looks the same
on both machines.

| Path | Linked to | What it is |
|---|---|---|
| `zsh/.zshrc` | `~/.zshrc` | Interactive zsh: history, apt plugins (autosuggestions and syntax highlighting), `bat` and `lsd` aliases, `settarget` and `cleartarget` for the polybar target, `demo` for screenshots and nvm loaded on first use |
| `oh-my-posh/capr4n.omp.json` | Read in place | Prompt theme, shared with dotfiles-windows |

`install.sh` creates the link. `.zshrc` finds the theme through its own link, so the repo works
cloned in any folder.

## Reload

In each open terminal (each one keeps what it loaded when it opened):

```bash
exec zsh
```
