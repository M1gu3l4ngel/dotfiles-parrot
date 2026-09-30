# system/

Configuración y hardening fuera de `$HOME` que el `install.sh` principal
**no puede manejar** porque requiere root (sudoers, ufw, `/etc/...`). Aquí
no se usan symlinks: son copias con dueño root (ver al final por qué).

## Contenido

- `sbin/anon-harden` — kill switch del toggle de anonimato (IPv6 a DROP e
  ICMP saliente a DROP). Solo acepta `up` o `down`. Se instala en
  `/usr/local/sbin/` como `root:root 0755`.
- `sudoers.d/anon_toggle` — regla NOPASSWD para que
  `~/.config/scripts/toggle_anonymity.sh` ejecute **solo** estos comandos
  exactos: `anonsurf start`, `anonsurf stop`, `anon-harden up` y
  `anon-harden down`.
- `firefox/pentest.user.js` — hardening del perfil pentest de Firefox: sin
  fugas de targets a terceros (sugerencias de búsqueda, Safe Browsing,
  telemetría), sin tráfico no solicitado (precargas, conexiones
  especulativas), WebRTC off y todo borrado al cerrar. HTTPS-Only desactivado
  a propósito: el pentester controla el esquema de cada petición.
- `apt/52parrot-hardening.conf` — override de unattended-upgrades: solo se
  auto-instala `parrot-security` (kernel y Tor incluidos) y se excluyen las
  herramientas de pentest que no conviene actualizar a mitad de un engagement.
- `apt/20auto-upgrades` — activa la ejecución diaria de unattended-upgrades.
- `lightdm/slick-greeter.conf` — pantalla de login y de bloqueo con el mismo
  fondo que el escritorio (`assets/wallpaper.jpg`), sin la rejilla de puntos.
- `setup.sh` — instala todo lo anterior y aplica el baseline del sistema.

## Cómo usar

Después del `install.sh` principal y de instalar `ufw`, `anonsurf` y
`unattended-upgrades` con `apt`, desde la raíz del repo:

```bash
sudo ./system/setup.sh
```

El script:

1. Instala `sbin/anon-harden` en `/usr/local/sbin/`.
2. Genera `anon_toggle` sustituyendo `__USER__` por `$SUDO_USER`, lo valida
   con `visudo -c` **sobre una copia temporal** y solo si es válido lo
   instala en `/etc/sudoers.d/` con permisos `0440`.
3. Aplica el baseline de ufw (deny incoming, allow outgoing, allow en `lo` y
   `tun+`), fuerza `IPV6=yes` y lo activa.
4. Restaura `/etc/profile` desde `base-files` si su `PATH` tiene una entrada
   vacía (equivale al directorio actual), guardando copia de la versión previa.
5. Quita al usuario del grupo `docker` si el daemon de Docker no está
   instalado (ese grupo equivale a root). Si Docker sí está, solo avisa.
6. Copia `firefox/pentest.user.js` al perfil `*.pentest` si existe.
7. Instala `apt/52parrot-hardening.conf` y crea `20auto-upgrades` si falta.
8. **Solo en VMware:** monta la carpeta compartida `VMShare` del host en
   `/mnt/vmshare` (acceso directo `~/VMShare`), accesible solo para tu
   usuario. Si no hay carpeta compartida configurada, lo indica y sigue.
9. Copia el fondo a `/usr/share/backgrounds/dotfiles-wallpaper.jpg` e instala
   `lightdm/slick-greeter.conf`. La config original de Parrot se guarda una
   vez en `/etc/lightdm/slick-greeter.conf.parrot`.

Es **idempotente**: se puede ejecutar varias veces sin efectos colaterales.

## Carpeta compartida Windows ↔ Linux (VMware)

Para pasar archivos entre el host y la VM en ambos sentidos:

1. En el host, crea una carpeta **dedicada** (p. ej. `C:\VMShare`). Nunca
   compartas el disco entero: si la VM se compromete, solo alcanza esa carpeta.
2. En VMware: **VM → Settings → Options → Shared Folders → Always enabled →
   Add…**, con esa carpeta y el nombre `VMShare`.
3. En la VM: `sudo ./system/setup.sh` (paso 8).

Todo lo que dejes en `C:\VMShare` aparece en `~/VMShare` y viceversa. Para
secretos (claves, backups), bórralos de la carpeta en ambos lados en cuanto
los hayas movido a su destino.

## Verificación

```bash
sudo ufw status verbose
sudo -l -U "$USER"                  # NOPASSWD solo para anonsurf/anon-harden
sudo unattended-upgrade --dry-run --debug
```

## Decisiones de seguridad

- **Nunca NOPASSWD sobre `iptables`/`ip6tables` directos.** Aceptan
  `--modprobe=<programa>`, que ejecuta ese programa como root: una regla así
  equivale a root sin contraseña para cualquier proceso del usuario. Por eso
  las reglas viven en `anon-harden`, con argumentos fijos.
- **`allow in on tun+` abre todos los puertos en la VPN.** Hace falta para
  recibir reverse shells en cualquier puerto, pero en labs compartidos (HTB)
  los demás usuarios de la VPN también pueden alcanzarte: no dejes servicios
  sensibles escuchando mientras estés conectado.

## Por qué no symlinks

Un archivo de `/etc` enlazado a un repo del usuario le daría a ese usuario
control sobre algo que ejecuta root. Además, sudo ignora los archivos de
`/etc/sudoers.d/` que no son de root con modo `0440`.

`/etc/ufw/user.rules` y `user6.rules` los genera ufw a partir de los comandos
`ufw allow ...`; no son archivos de config "humanos", así que se reconstruyen
con los comandos en vez de copiarlos.

## Qué NO está aquí

- La instalación de paquetes del sistema (`apt install ufw anonsurf ...`):
  este script solo configura. La instalación la hará `bootstrap.sh`.
- Hooks de pre/post engagement (van como scripts en `~/.config/scripts/`).
