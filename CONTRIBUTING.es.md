[English](CONTRIBUTING.md) | **Español**

# Contribuir

Gracias por ayudar. Es un repo personal, pero sigue un flujo estándar para mantenerlo limpio y
reproducible en cualquier máquina con Parrot OS.

## Antes de empezar

- **Un error o un arreglo pequeño:** abre un pull request directamente, o un issue con el
  [formulario de error](https://github.com/M1gu3l4ngel/dotfiles-parrot/issues/new/choose).
- **Un paquete nuevo, una carpeta nueva o un cambio en lo que instalan `bootstrap.sh` o
  `70-system/setup.sh`:** abre antes un issue y describe el problema que resuelve. Cambia todas
  las máquinas que hacen pull del repo, así que se acuerda antes de escribirlo.
- **Una vulnerabilidad:** nunca en un issue público; sigue [`SECURITY.es.md`](SECURITY.es.md).
- **Conducta:** todo el que participa sigue el [código de conducta](CODE_OF_CONDUCT.es.md).

## Preparar

Necesita Parrot OS 7 en x86_64, git y un usuario con sudo; el
[README](README.es.md#requisitos-previos) explica el resto. Clona el repo, crea una rama desde
`main` y ejecuta las comprobaciones desde su raíz como usuario normal. Son las mismas que ejecuta
el CI:

```bash
./tools/check.sh
```

Las comprobaciones de la documentación, del panel de tareas y de los tests de instalación
necesitan dotfiles-windows clonado en `~/dotfiles-windows` (`bootstrap.sh` lo clona); sin él se
omiten en local y solo las ejecuta el CI.

Para ver qué cambiaría el instalador en tu máquina sin cambiar nada:

```bash
./bootstrap.sh --dry-run
./install.sh --check
```

## Qué tiene que mantener un cambio

- **Nada personal ni de una empresa:** ni nombre de usuario local, email, IP, hostname,
  fingerprint de clave, ID de perfil de Firefox ni nombre de cliente. Usa placeholders
  (`__USER__`) o valores calculados al ejecutar (`$HOME`, `$SUDO_USER`). Detalle en
  `.claude/rules/security.md`.
- **Descargas verificadas:** los paquetes vienen de apt; lo demás se descarga en una versión
  fijada y se verifica con SHA-256 (ver `bootstrap.sh`). Nunca `curl ... | bash`, y las
  acciones de GitHub se fijan por SHA de commit.
- **Mínimo privilegio:** los archivos de `/etc` los instala `70-system/setup.sh` como copias
  `root:root`, nunca como enlaces al repo, y una regla sudoers `NOPASSWD` nombra comandos exactos
  con argumentos fijos.
- **Scripts idempotentes:** cada paso comprueba si ya está hecho, así que un script puede
  volver a ejecutarse sin romper nada.
- **Documentos en pareja:** `X.md` en inglés y `X.es.md` en español, con las mismas secciones,
  bloques de código idénticos y el selector de idioma en la línea 1. `./tools/check.sh`
  (`check-docs.mjs` de dotfiles-windows) lo comprueba, enlaces y anclas incluidos.
- **Inglés** en los comentarios de código, la salida de los scripts y los nombres de los pasos
  del CI y de los tests, según [docs/contributing/comments.es.md](docs/contributing/comments.es.md).
  El texto que muestra el escritorio (notificaciones, menús de rofi), las reglas de
  `.claude/rules/` y las listas de tareas (`docs/tasks.md`, `docs/backlog.md`) van solo en
  español.
- **Iconos como escapes:** los glifos de Nerd Font se escriben como escapes UTF-8
  (`$'\xef\x8c\xa9'`), nunca como caracteres literales, que las herramientas de edición pierden.
- **Documentación sobria:** sin emojis, comandos que se copian y funcionan tal cual.

Las convenciones viven en `.claude/rules/` (en español). Son Markdown normal: sirven igual para
las personas y para Claude Code, que las carga solo.

| Archivo | Qué define |
|---|---|
| [security.md](.claude/rules/security.md) | Datos personales y secretos, descargas verificadas, mínimo privilegio |
| [style.md](.claude/rules/style.md) | Comentarios en inglés que explican el porqué, indentación por formato |
| [git.md](.claude/rules/git.md) | Formato de commits y qué comandos de git no se ejecutan nunca |
| [shell.md](.claude/rules/shell.md) | Scripts de shell y zsh |
| [documentation.md](.claude/rules/documentation.md) | Estilo de la documentación y la regla de los dos idiomas |
| [file-edits.md](.claude/rules/file-edits.md) | Iconos de Nerd Font y archivos protegidos |
| [environment.md](.claude/rules/environment.md) | Particularidades del entorno (X11, VMware, polybar, fuentes) |

## Commits y pull requests

Los commits siguen [Conventional Commits](https://www.conventionalcommits.org/es/v1.0.0/): un
título de 72 caracteres como máximo, una línea en blanco y un cuerpo con un guion por cambio
concreto (sin cuerpo solo si el título lo dice todo), en inglés y en imperativo:

```
type(scope): summary in the imperative

- One line per concrete change.
```

- `type`: `feat`, `fix`, `docs`, `style`, `refactor`, `chore`, `ci`.
- `scope` opcional: el componente afectado (`polybar`, `zsh`, `system`...).
- **Un commit por cambio verificado**: dos cambios independientes van en dos commits, para que
  cada uno se pueda revisar y revertir por separado.
- Añade los archivos por ruta, nunca con `git add -A` ni `git add .`.
- El repo es público y cada commit publica el email del autor: usa el **email noreply** de
  GitHub y **firma los commits con GPG**, como explica
  [docs/keys-and-secrets.es.md](docs/keys-and-secrets.es.md).

Un pull request hace una sola cosa y rellena su plantilla. Un cambio que se nota añade su línea
en "Sin publicar" de [CHANGELOG.es.md](CHANGELOG.es.md) y en "Unreleased" de su pareja en
inglés. El CI tiene que pasar: las mismas comprobaciones que `./tools/check.sh`, más el escaneo
de secretos.

## Licencia

Al contribuir, aceptas que tu contribución se licencie con [MIT](LICENSE), como el resto del
repo.
