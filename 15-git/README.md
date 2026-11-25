**English** | [Español](README.es.md)

# 15-git

git's identity and commit signing, and the GPG agent that keeps the key unlocked.

| Path | Linked to | What it is |
|---|---|---|
| `gitconfig` | `~/.gitconfig` | Public identity (name and noreply email, the same as dotfiles-windows), signed commits and tags, `main` as the default branch; it includes `~/.gitconfig.local` |
| `gnupg/.gnupg/gpg-agent.conf` | `~/.gnupg/gpg-agent.conf` | GPG agent: graphical passphrase dialog and cache (10 minutes idle, 2 hours at most) |

`install.sh` creates the links. Only the agent's file is linked: `~/.gnupg` holds the private keys
and stays a real folder with mode 700, outside any repo.

## What does not go here

- The signing key and any work account: they belong to each machine and go in
  `~/.gitconfig.local`, which the repo never sees. `install.sh` carries the key there from an old
  `~/.gitconfig`.
- `git config --global`: it would write into the repo through the link. Use
  `git config --file ~/.gitconfig.local` instead.

Creating the keys and setting up signing: [docs/keys-and-secrets.md](../docs/keys-and-secrets.md).

## Reload

git reads `gitconfig` on every command. The agent, after editing its file:

```bash
gpg-connect-agent reloadagent /bye
```
