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

`gnupg/.gnupg/gpg-agent.conf` (linked by `install.sh`) sets up the agent to
ask for the passphrase in a graphical dialog (in the terminal when there is no
graphical session, e.g. over SSH) and to remember it for 10 minutes since the
last use, 2 hours at most: the same values as on Windows.

1. Create the key (ed25519 for signing and cv25519 for encryption, expires in
   2 years). It asks for the passphrase in a dialog:

    ```bash
    gpg --quick-generate-key "<name> <your-noreply>" default default 2y
    ```

    Store the passphrase in your safe place.

2. Show the fingerprint (the long 40-character line under `sec`). In this
   guide it shows up as `<fingerprint>`:

    ```bash
    gpg --list-secret-keys
    ```

3. Set up git to always sign:

    ```bash
    git config --global user.email "<your-noreply>"
    ```

    ```bash
    git config --global user.signingkey <fingerprint>
    ```

    ```bash
    git config --global commit.gpgsign true
    ```

    ```bash
    git config --global tag.gpgsign true
    ```

4. Copy the public key to the clipboard. First check with
   `gpg --list-keys <fingerprint>` that its only `uid` is the noreply one; if
   your personal email also shows up, first follow
   [Remove the personal email from the key](#remove-the-personal-email-from-the-key):

    ```bash
    gpg --armor --export <fingerprint> | xclip -selection clipboard
    ```

5. On GitHub, Settings -> SSH and GPG keys -> New GPG key: paste the block
   (`Ctrl+V`) and save.

6. Make a commit and check the signature (`G` = valid signature):

    ```bash
    git log -1 --format='%G? %GK %s'
    ```

    On GitHub, the commit shows as "Verified".

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

Then export it again (step 4) and replace it on GitHub.

### Remove the personal email from the key

If the key also has a UID with your personal email, GitHub publishes it at
`github.com/<user>.gpg`. The recommended fix is to delete that UID: the key
stays clean for good and the signature does not change (commits stay
"Verified" because they use the noreply). As a regular user, from any
directory:

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

5. Redo the backup (the previous one still has the personal UID) and replace
   the key on GitHub: delete the old entry (GitHub rejects two keys with the
   same fingerprint) and upload the new one (steps 4 and 5).

Deleting the UID only affects your copy and what you publish from now on: if
the key was already on a public keyserver, it stays there with the UID.

Alternative without changing the key: export while filtering the UID. You
have to remember the filter on every export; if you forget it, the email gets
published:

```bash
gpg --armor --export --export-filter keep-uid='mbox = <your-noreply>' <fingerprint>
```

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
