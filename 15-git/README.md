**English** | [Español](README.es.md)

# 15-git

git's identity and commit signing, and the GPG agent that keeps the key unlocked.

| Path | Linked to | What it is |
|---|---|---|
| `gitconfig` | `~/.gitconfig` | Signed commits and tags and `main` as the default branch, what can be public; it includes `~/.gitconfig.local` |
| `gnupg/.gnupg/gpg-agent.conf` | `~/.gnupg/gpg-agent.conf` | GPG agent: graphical passphrase dialog and cache (10 minutes idle, 2 hours at most) |

`install.sh` creates the links. Only the agent's file is linked: `~/.gnupg` holds the private keys
and stays a real folder with mode 700, outside any repo.

## What does not go here

- The identity (name and noreply email), the signing key and any work account: they belong to
  each person or machine and go in `~/.gitconfig.local`, which the repo never sees. Whoever forks
  the repo commits under their own name. `bootstrap.sh` writes the identity there when the
  machine has none, from `--git-name` and `--git-email` (the owner's by default), and
  `install.sh --check` reports it if it is missing. `install.sh` carries the key there from an
  old `~/.gitconfig`.
- `git config --global`: it would write into the repo through the link. Use
  `git config --file ~/.gitconfig.local` instead.

Creating the keys and setting up signing: [docs/keys-and-secrets.md](../docs/keys-and-secrets.md).

## Reload

git reads `gitconfig` on every command. The agent, after editing its file:

```bash
gpg-connect-agent reloadagent /bye
```
