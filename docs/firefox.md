**English** | [Español](firefox.es.md)

# Firefox profiles

Two isolated profiles so your personal identity does not mix with pentesting
work: cookies, sessions, history and extensions are not shared.

## Profiles

| Profile | Open | Polybar | Use |
|---|---|---|---|
| `default-esr` | `Super+Shift+F` | Red Firefox icon | Personal: email, GitHub, daily use |
| `pentest` | `Super+Shift+P` | Green bug icon | Targets, labs, OSINT, suspicious links |

Both can be open at the same time: the launchers use `--no-remote`.

## Create the pentest profile

Once after installing, as a regular user:

1. Create the profile (it prints nothing if all goes well):

    ```bash
    firefox -CreateProfile pentest
    ```

2. Copy the `user.js` into it. From `~/dotfiles`, requires sudo:

    ```bash
    sudo ./system/setup.sh
    ```

    Step `[6/9]` must show `Copiado al perfil pentest`.

3. Open it with `Super+Shift+P`.

To apply future changes to the `user.js`: run step 2 again and reopen
Firefox.

## What the pentest profile protects

Settings in `system/firefox/pentest.user.js` (validated on Firefox ESR 140):

| Block | What it does | Why |
|---|---|---|
| No leaks to third parties | No search suggestions, no Safe Browsing, no telemetry or connectivity checks | What you type or visit (client hostnames included) does not go out to search engines, Google or Mozilla. Avoids NDA problems |
| No unrequested traffic | No link prefetching, DNS prefetching or speculative connections | Firefox does not touch a target unless you ask it to; avoids out-of-scope requests |
| Scheme left as is | HTTPS-Only and HTTPS-First disabled | In labs almost everything is HTTP (`http://box.htb`); rewriting to HTTPS would change the request you want to test |
| WebRTC | Disabled | Keeps JavaScript from getting your real IP even behind a VPN |
| Credentials | Does not save passwords or autofill forms | Test credentials do not stay in the profile and your data does not end up in a target's form |
| Cleanup on close | Deletes cookies, storage, cache, history, downloads and forms | A clean profile every session. Bookmarks and extensions are kept |

## What Parrot already applies to both profiles

Parrot sets up Firefox system-wide in `/etc/firefox-esr/00parrot.js` and
`/etc/firefox-esr/policies/policies.json`:

- `privacy.resistFingerprinting` enabled: the same fingerprinting protection
  as Tor Browser. Among other things, it reports the `Atlantic/Reykjavik`
  time zone (UTC+0) for all its users.
- Telemetry locked (`lockPref`) and search suggestions disabled by policy.

The pentest profile's `user.js` does not depend on this: if Parrot changed
its settings, the profile would stay protected. For the same reason the
pentest profile launcher adds `TZ=UTC`, as a fallback for the time zone.

## Check that the pentest profile is applied

In each profile, type `about:config` in the address bar, accept the warning
and search for `media.peerconnection.enabled`:

| Profile | Expected value |
|---|---|
| pentest | `false` (in bold: changed by the `user.js`) |
| personal | `true` |

To check for leaks from the outside (IP, DNS, WebRTC, time zone), see the
external audit in [anonymity.md](anonymity.md).

## Limitations

- It reduces the fingerprint, but does not make you indistinguishable: use
  Tor Browser for that.
- Logging into your personal accounts from the pentest profile identifies
  you, whatever the IP.
