# Seguridad

El repo es público en GitHub. Todo lo que entra en un commit queda publicado
para siempre en el historial.

## Datos personales y secretos

- Nunca incluir datos que identifiquen a una persona o una máquina: nombre de
  usuario local, emails, IPs reales, hostnames, fingerprints o IDs de claves,
  IDs de perfiles de Firefox, nombres de clientes o targets.
- Usar placeholders (`__USER__`, `<tu-fingerprint>`) o valores calculados en
  tiempo de ejecución (`$HOME`, `$SUDO_USER`, `id -u`, `getent`).
- Los commits se firman con GPG y usan el email noreply de GitHub, no el
  personal: el email del autor queda publicado en cada commit.
- `./tools/check.sh` ejecuta gitleaks sobre todo el historial. Revisar el diff
  antes de proponer un commit, no solo confiar en la herramienta.

## Descargas externas

- Todo lo que no viene de apt se descarga en una versión fijada y se verifica
  con un SHA-256 guardado en el repo (ver `bootstrap.sh`). Porqué: una
  descarga corrupta o manipulada se detecta antes de ejecutarse.
- Nunca `curl ... | bash`: ejecuta código remoto sin revisarlo ni verificarlo.
- En GitHub Actions, fijar las acciones por SHA de commit, no por etiqueta: una
  etiqueta puede moverse a otro código.
- No versionar binarios de terceros (fuentes, ejecutables): inflan el repo y
  pueden violar su licencia (ya ocurrió con Helvetica).

## Mínimo privilegio

- Reglas sudoers NOPASSWD solo para comandos exactos con argumentos fijos. Nunca
  para binarios que aceptan argumentos libres: `iptables --modprobe=<programa>`
  ejecuta cualquier programa como root.
- Los archivos de `/etc` se instalan como copias `root:root` con `install -m`,
  nunca como symlinks al repo: el usuario controlaría algo que ejecuta root.
- Validar antes de instalar (p. ej. `visudo -c` sobre una copia temporal): un
  sudoers roto en su sitio puede dejar sudo inutilizable.
- El grupo `docker` equivale a root (`docker run -v /:/host`): no añadir
  usuarios a él. `system/setup.sh` lo retira si el daemon no está instalado.

## .gitignore

- Deben quedar fuera del repo: `CLAUDE.local.md`, `.claude/settings.local.json`,
  claves (`*.key`, `*.pem`, `*_ed25519`), `.env` y cualquier `secrets/`.
- `.claude/rules/` y `CLAUDE.md` sí se versionan: son las instrucciones del
  proyecto, y por eso tampoco pueden contener datos personales.
