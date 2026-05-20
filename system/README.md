# system/

Configuración fuera de `$HOME` que el `install.sh` principal **no puede
manejar** porque requiere root (sudoers, ufw, /etc/...). El layout de
symlinks de `~/.config/` no aplica aquí.

## Contenido

- `sudoers.d/anon_toggle` — regla NOPASSWD para que
  `~/.config/scripts/toggle_anonymity.sh` ejecute `anonsurf`,
  `ip6tables` y `iptables` sin pedir password.
- `setup.sh` — script idempotente que instala lo de esta carpeta más
  el baseline de ufw (default deny incoming + allow on lo/tun+).

## Cómo usar

Después del `install.sh` principal y de haber instalado `ufw` y
`anonsurf` vía `apt`:

```bash
sudo ./system/setup.sh
```

El script:

1. Copia `sudoers.d/anon_toggle` a `/etc/sudoers.d/` con permisos `0440`
   y lo valida con `visudo -c`.
2. Aplica las 4 reglas baseline de ufw.
3. Verifica que `IPV6=yes` esté en `/etc/default/ufw` (lo fuerza si no).
4. Activa ufw (start on boot incluido).

Es **idempotente** — se puede correr varias veces sin efectos
colaterales.

## Por qué no symlinks

`/etc/sudoers.d/` no acepta archivos en symlinks que apunten a paths de
usuario (sudo se niega por seguridad). Se copia con `install -m 0440`.

`/etc/ufw/user.rules` y `user6.rules` los autogenera ufw a partir de los
comandos `ufw allow ...`, no son archivos de config "humanos" — mejor
reconstruirlos con los comandos que copiarlos.

## Qué NO está acá

- Paquetes del sistema (`apt install ufw anonsurf ...`). Deberían
  documentarse aparte; este script solo configura, no instala.
- Hooks de pre/post engagement (esos van como scripts en `~/.config/scripts/`).
