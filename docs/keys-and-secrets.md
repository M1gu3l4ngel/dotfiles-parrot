**English** | [Español](keys-and-secrets.es.md)

# Keys and secrets

SSH keys (GitHub authentication), GPG (commit signing and encryption) and
`pass` (secrets manager). Everything runs as a regular user, from any
directory, unless noted otherwise.

Use a different SSH key and GPG key on each machine: if you lose one, you
only remove its keys from GitHub and the others keep working.

## Before you start: private GitHub email

Every commit publishes the author's email. On GitHub, Settings -> Emails:

1. Check "Keep my email addresses private".
2. Check "Block command line pushes that expose my email".
3. Copy your `<id>+<user>@users.noreply.github.com` address. In this guide it
   shows up as `<your-noreply>`; `<user>` is your GitHub user name.

The commit and the GPG key's UID must both use `<your-noreply>` for GitHub to
show "Verified".

## SSH

1. Create the key. Accept the default path (`~/.ssh/id_ed25519`) and set a
   passphrase:

    ```bash
    ssh-keygen -t ed25519 -C "<user>@<machine>"
    ```

    Store the passphrase in your safe place. If you forget it, it cannot be
    recovered: you would have to create another key.

2. Load it into keychain. `.zshrc` does it on its own if `~/.ssh/id_ed25519`
   exists; it asks for the passphrase once per boot:

    ```bash
    exec zsh
    ```

3. Check that it is loaded:

    ```bash
    ssh-add -l
    ```

4. Show the public key and copy it:

    ```bash
    cat ~/.ssh/id_ed25519.pub
    ```

5. On GitHub, Settings -> SSH and GPG keys -> New SSH key: a title with the
   machine name, type "Authentication Key", paste the key and save.

6. Connect for the first time. Before accepting, compare the fingerprint it
   shows with GitHub's official one for ED25519
   (`SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU`):

    ```bash
    ssh -T git@github.com
    ```

    It must answer `Hi <user>! You've successfully authenticated`.

7. Use SSH for the repo instead of HTTPS. From `~/dotfiles`:

    ```bash
    git remote set-url origin git@github.com:<user>/dotfiles-parrot.git
    ```

## GPG

The key signs every commit and tag (integrity, and the "Verified" badge on
GitHub) and encrypts the `pass` secrets. Its fingerprint is the 40-character
line under `sec` in `gpg --list-secret-keys`; the Key ID that GitHub and git
sometimes show is its last 16 characters, the same key. In this guide it shows
up as `<fingerprint>`, and `<name>` is the name you want on the key.

### 1. The key

**Case A, a new key (recommended).** Created with the noreply address only,
so it never carries your personal email: ed25519 for signing and cv25519 for
encryption, expiring in 2 years. It asks for the passphrase in a dialog:

```bash
gpg --quick-generate-key "<name> <your-noreply>" default default 2y
```

Store the passphrase in your safe place.

**Case B, a key you already have with your personal email.** Add the noreply
UID:

```bash
gpg --quick-add-uid <fingerprint> "<name> <your-noreply>"
```

Then keep the personal email out of the public key: delete its UID
([Remove the personal email from the key](#remove-the-personal-email-from-the-key))
or filter it out on every export (step 3).

### 2. Configure git to sign

Signing on every commit and tag already comes from `15-git/gitconfig`, linked
as `~/.gitconfig`, and `bootstrap.sh` wrote the name and the noreply email to
`~/.gitconfig.local`. The key belongs to this machine, so it goes in that same
file, outside the repo. Never use
`git config --global`, which would write it into the public repo through the
link:

```bash
git config --file ~/.gitconfig.local user.signingkey <fingerprint>
```

### 3. Upload the public key to GitHub

1. Check that the key's only `uid` is the noreply one:

    ```bash
    gpg --list-keys <fingerprint>
    ```

2. Copy the public key to the clipboard:

    ```bash
    gpg --armor --export <fingerprint> | xclip -selection clipboard
    ```

    If the key still has your personal email (case B with the filter), export
    only the noreply UID instead:

    ```bash
    gpg --armor --export --export-filter keep-uid='mbox = <your-noreply>' <fingerprint> | xclip -selection clipboard
    ```

3. On GitHub, Settings -> SSH and GPG keys. If an older version of this key is
   there (same Key ID), delete it first: GitHub rejects two keys with the same
   fingerprint. Then New GPG key: paste the block (`Ctrl+V`) and save.

### 4. Verify

Make a commit and check the signature (`G` = valid signature):

```bash
git log -1 --format='%G? %GK %s'
```

On GitHub, the commit shows as "Verified". Commits made before the key was set
up stay unsigned.

### Verify commits made on another machine

A commit signed on another machine (Windows) shows `E` until you import that
machine's public key. GitHub publishes every public key of an account at
`github.com/<user>.gpg`:

```bash
curl -fsS https://github.com/<user>.gpg | gpg --import
```

```bash
git log -1 --format='%G? %GK %s' <commit>
```

`U` means a good signature from a key you have not certified yourself. To mark
it as yours (a local signature that is never published):

```bash
gpg --quick-lsign-key <fingerprint-of-the-other-key>
```

From then on the same `git log` shows `G`.

### The passphrase cache

`15-git/gnupg/.gnupg/gpg-agent.conf`, linked by `install.sh`, sets up the
agent ([15-git/README.md](../15-git/README.md)):

- `pinentry-gnome3` asks for the passphrase in a graphical dialog, and in the
  terminal when there is no graphical session (over SSH).
- `default-cache-ttl 600`: 10 minutes from the last use; every signature
  restarts the count.
- `max-cache-ttl 7200`: 2 hours since you typed it, even while in use.

The same values as on Windows. After editing the file, reload the agent:

```bash
gpg-connect-agent reloadagent /bye
```

### Backup (mandatory)

`pass` encrypts with this key: if you lose it, you lose every secret.

1. Export the private key (it is encrypted with your passphrase):

    ```bash
    gpg --armor --export-secret-keys <fingerprint> > ~/gpg-private.asc
    ```

    ```bash
    chmod 600 ~/gpg-private.asc
    ```

2. Copy the revocation certificate GnuPG generated when it created the key.
   It lets you invalidate the key publicly if it gets stolen:

    ```bash
    cp ~/.gnupg/openpgp-revocs.d/<fingerprint>.rev ~/gpg-revocation.rev
    ```

3. Move both files to your safe place (for example, through the shared folder
   in [vmware.md](vmware.md)) and store the passphrase separately.
4. Delete them from your home once they are safe:

    ```bash
    rm ~/gpg-private.asc ~/gpg-revocation.rev
    ```

### Renew before it expires

Extends the expiry of the primary key and the subkeys without changing the
key:

```bash
gpg --quick-set-expire <fingerprint> 2y
```

```bash
gpg --quick-set-expire <fingerprint> 2y '*'
```

Then upload it again ([step 3](#3-upload-the-public-key-to-github)).

### Remove the personal email from the key

If the key also has a UID with your personal email, GitHub publishes it at
`github.com/<user>.gpg`. Deleting that UID leaves the key clean for good, and
the signature does not change (commits stay "Verified" because they use the
noreply). As a regular user, from any directory:

1. Make the [backup](#backup-mandatory) first.
2. Open the key editor:

    ```bash
    gpg --edit-key <fingerprint>
    ```

3. At the `gpg>` prompt, one line at a time: `uid N` (N = position of the
   personal UID in the list; check that the `*` lands on that line, never on
   the noreply one), `deluid`, `y` and `save`.
4. Check that the only `uid` is the noreply one:

    ```bash
    gpg --list-keys <fingerprint>
    ```

5. Redo the backup (the previous one still has the personal UID) and upload
   the key again ([step 3](#3-upload-the-public-key-to-github)).

Deleting the UID only affects your copy and what you publish from now on: if
the key was already on a public keyserver, it stays there with the UID.

### Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| GitHub shows "Unverified: the email in this signature doesn't match the committer email" | The key has no UID with `<your-noreply>` | Add it (case B) and upload the key again |
| `gpg failed to sign the data` over SSH | `GPG_TTY` is not set, so the agent does not know which terminal to ask on | `.zshrc` sets it: open the shell again with `exec zsh` |
| It asks for the passphrase on every commit | The agent is not reading `gpg-agent.conf` | `gpg-connect-agent reloadagent /bye`, and `./install.sh --check` to see the link |
| `git log` shows `E` on a commit from another machine | Its public key is not imported | [Verify commits made on another machine](#verify-commits-made-on-another-machine) |

## pass (secrets manager)

Each secret is a file encrypted with your GPG key in `~/.password-store/`.
That way tokens are not left in plain text in `.zshrc`, in backups or in the
history.

1. Initialize it with your full fingerprint:

    ```bash
    pass init <fingerprint>
    ```

2. Turn on the change history (`pass` commits are signed too):

    ```bash
    pass git init
    ```

3. Daily use:

| Command | What it does |
|---|---|
| `pass insert <name>` | Asks for the value twice and stores it encrypted |
| `pass <name>` | Decrypts and shows it |
| `pass -c <name>` | Copies it to the clipboard; cleared after 45 seconds |
| `pass ls` | Lists every secret |
| `pass edit <name>` | Edits it and encrypts it again |
| `pass rm <name>` | Deletes it |

Suggested layout: `api/` (service tokens), `htb/` (lab credentials),
`clients/` (engagements; delete when they close), `personal/`.

To use a secret without typing it in the terminal:

```bash
curl -H "Authorization: Bearer $(pass api/github-token)" https://api.github.com/user
```

`.zshrc` keeps out of the history the lines with `Authorization`, `Bearer`,
`TOKEN=`, `SECRET=`, `PASSWORD=` or `API_KEY`, and those starting with a
space.

If you sync the store with a remote repo (`pass git remote add origin
<repo>`), it must be private: the content is encrypted, but the file names are
not (`clients/company-x/vpn` would reveal who you are auditing).
