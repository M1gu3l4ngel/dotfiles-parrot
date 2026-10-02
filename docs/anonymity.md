**English** | [Español](anonymity.es.md)

# Anonymity through Tor

Sends all system traffic through the Tor network with one shortcut, blocks
what Tor cannot carry and checks that the exit really is Tor.

## Requirements

Once, after installing. From `~/dotfiles`, requires sudo:

```bash
sudo ./system/setup.sh
```

It installs the sudoers rule that lets the toggle run, without a password,
only `anonsurf start|stop` and `/usr/local/sbin/anon-harden up|down`. Without
it, the toggle fails with "Tor no arrancó".

## Turn it on and off

1. Press `Super+A` or click the ghost in polybar, next to the Firefox
   icons.
2. Wait 15 to 20 seconds: Tor connects to the network and the script checks
   the exit.
3. Result:
    - Success: notification "Anonimato ON · verificado" and a green ghost.
    - Error: red notification. If the exit could not be confirmed as Tor, the
      script undoes every change and goes back to the direct connection.
4. To turn it off, press `Super+A` again: notification "Anonimato OFF" and a
   gray ghost.

The state comes from AnonSurf (`systemctl is-active anonsurfd`), not from
whether a `tor` process exists: Parrot may leave Tor running after boot
without anonymity being active (`anonsurf status` shows `AnonSurf: inactive`).

## What it does when turned on

| Layer | What it does | Why |
|---|---|---|
| `anonsurf start` | Redirects TCP and DNS to Tor | Hides the real IP |
| IPv6 to DROP | Blocks all IPv6 traffic | anonsurf only redirects IPv4 |
| Outgoing ICMP to DROP | Blocks ping and traceroute | Tor only carries TCP |
| Check | Queries `check.torproject.org` and requires `IsTor: true` | Verify the real exit, not just that Tor is running |

The IPv6 and ICMP rules live in `system/sbin/anon-harden`. The sudoers rule
allows that script with fixed arguments and never `iptables` directly:
`iptables --modprobe=<program>` would run any program as root.

## Check for leaks

With anonymity on, from a terminal as a regular user (any directory).
Expected result of each command:

1. The exit is Tor (`"IsTor":true` and an IP that is not yours):

    ```bash
    curl -s https://check.torproject.org/api/ip
    ```

2. IPv6 blocked (it must fail without showing any IP):

    ```bash
    curl -6 -s --max-time 8 https://api64.ipify.org
    ```

3. Ping blocked (it must fail):

    ```bash
    ping -c1 -W3 8.8.8.8
    ```

4. No DNS leaks, even when forcing an external server. The answer is the IP
   of the resolver the server sees: it must be a Tor node, not your ISP's
   DNS:

    ```bash
    dig +short @1.1.1.1 whoami.akamai.net
    ```

## External audit from Firefox

The checks above are our own. To confirm with independent tools, open the
pentest Firefox (`Super+Shift+P`) and visit these sites twice: first with
anonymity off (baseline) and then on, closing and reopening Firefox between
the two rounds.

| Site | Anonymity off | Anonymity on |
|---|---|---|
| `https://check.torproject.org` | "You are not using Tor" | "Congratulations. This browser is configured to use Tor" |
| `https://ipleak.net` (top) | Your real IP | An IP that is not yours |
| `https://ipleak.net` ("DNS Addresses" section, wait until it finishes) | Your ISP's DNS servers | 0 servers detected: your real DNS does not show up |
| `https://browserleaks.com/webrtc` | "No Leak" | "No Leak" |
| `https://browserleaks.com/javascript` | Time zone `Atlantic/Reykjavik` | Time zone `Atlantic/Reykjavik` |

If with anonymity off the sites do detect your real IP, the test works; if
with anonymity on they do not, the protection works too.

The `Atlantic/Reykjavik` time zone is not a mistake: Parrot enables
`privacy.resistFingerprinting` in Firefox system-wide, and that mode (the same
as Tor Browser) reports that zone (UTC+0 with no daylight saving time) for all
its users. Since the value is shared, it does not set you apart from others.

## Check that it turned off cleanly

After turning it off, the rules must go back to normal. Requires sudo, from
any directory:

```bash
sudo ip6tables -S
```

The first three lines must be `-P INPUT ACCEPT`, `-P FORWARD ACCEPT` and
`-P OUTPUT ACCEPT`.

```bash
sudo iptables -S OUTPUT
```

No rule with the comment `anon_toggle_icmp` must show up.

## Limitations

- It hides the IP, not the identity: logging into your accounts or using a
  browser with a unique fingerprint identifies you all the same. For strong
  anonymity, use Tor Browser (it makes all its users look alike).
- The Tor exit node sees traffic that is not encrypted: always use HTTPS.
- It adds latency and many services block Tor nodes. It is a tool for
  specific moments (see [pentesting.md](pentesting.md)).
- It is not for attacking targets: that breaks the rules of labs and
  engagements, and the HTB and THM VPN does not work over Tor. Turn it off
  before connecting the VPN.

## Common problems

| Symptom | Cause | Fix |
|---|---|---|
| "Tor no arrancó" | The sudoers rule is missing | `sudo ./system/setup.sh` from `~/dotfiles` |
| "No se confirmó salida por Tor" | Tor did not finish connecting or the network blocks it | Wait a minute and turn it on again |
| The button does not change color | polybar is not reading the state | `~/.config/polybar/launch.sh` |

To see which commands the toggle can run without a password:

```bash
sudo -l
```

Only the four anonsurf and anon-harden commands must show up as
`NOPASSWD`.
