[English](CONTRIBUTING.md) | **Español**

# Contribuir

## Flujo

1. Crea una rama desde `main`.
2. Haz los cambios siguiendo las convenciones de abajo.
3. Ejecuta las comprobaciones desde la raíz del repo. Deben pasar todas:

    ```bash
    ./tools/check.sh
    ```

    Los checks de la documentación, del panel de tareas y los tests de
    instalación necesitan dotfiles-windows clonado en `~/dotfiles-windows`
    (lo clona `bootstrap.sh`); sin él se omiten en local y solo los ejecuta
    el CI.

4. Haz commit siguiendo el formato de commits.
5. Abre un pull request. El CI ejecuta las mismas comprobaciones y marca el
   resultado en GitHub.

Si el cambio es visible para el usuario, añádelo a `CHANGELOG.md`
("Unreleased") y a `CHANGELOG.es.md` ("Sin publicar").

## Documentación en dos idiomas

Toda la documentación existe en inglés (`X.md`) y en español (`X.es.md`), con
el selector de idioma en la primera línea. Al cambiar un documento, cambia
también su pareja en el mismo commit. `./tools/check.sh` falla si no tienen
la misma estructura (secciones, tablas, listas, enlaces) o si sus bloques de
código difieren: los comandos no se traducen.

Los comentarios del código, la salida de los scripts, los nombres de los pasos
del CI y de los tests y los mensajes de commit se escriben solo en inglés,
según [docs/contributing/comments.es.md](docs/contributing/comments.es.md). Las
reglas de `.claude/rules/` y `CLAUDE.md` van solo en español.

## Commits

Formato [Conventional Commits](https://www.conventionalcommits.org/es/v1.0.0/),
en inglés y en imperativo: un título de 72 caracteres como máximo, una línea en
blanco y un cuerpo con un guion por cambio concreto.

```
type(scope): summary in the imperative

- One line per concrete change.
```

- `type`: `feat`, `fix`, `docs`, `style`, `refactor`, `chore`, `ci`.
- `scope` opcional: el componente afectado (`polybar`, `zsh`, `system`...).
- Un commit por cambio lógico, aunque toque varios archivos.

Ejemplo:

```
refactor(polybar): close the bars over IPC instead of killall

- Every bar sets enable-ipc so launch.sh can close it with polybar-msg.
```

El repo es público y cada commit publica el email del autor: usa el email
noreply de GitHub y firma los commits con GPG. Cómo configurarlo:
[docs/keys-and-secrets.es.md](docs/keys-and-secrets.es.md).

## Convenciones

Están en `.claude/rules/`. Son Markdown normal: sirven igual para personas y
para Claude Code, que las carga automáticamente.

| Archivo | Qué define |
|---|---|
| [security.md](.claude/rules/security.md) | Datos personales y secretos, descargas verificadas, mínimo privilegio |
| [style.md](.claude/rules/style.md) | Comentarios en inglés que explican el porqué, indentación por formato |
| [git.md](.claude/rules/git.md) | Formato de los commits y qué comandos de git no se ejecutan nunca |
| [shell.md](.claude/rules/shell.md) | Scripts de shell y zsh |
| [documentation.md](.claude/rules/documentation.md) | Estilo de la documentación y la regla de los dos idiomas |
| [file-edits.md](.claude/rules/file-edits.md) | Iconos Nerd Font y archivos protegidos |
| [environment.md](.claude/rules/environment.md) | Particularidades del entorno (X11, VMware, polybar, fuentes) |

Lo más importante:

- Nunca incluyas datos personales ni secretos: usuario local, emails, IPs,
  fingerprints, nombres de clientes.
- Todo lo que no venga de apt se descarga en versión fijada y se verifica con
  SHA-256 (ver `bootstrap.sh`). Nunca `curl ... | bash`.
- Los iconos Nerd Font se escriben como escapes (`$'\xef\x8c\xa9'`), nunca como
  caracteres literales.

## Reportar problemas

Abre un issue con:

- Qué esperabas y qué pasó.
- Versión de Parrot (`cat /etc/os-release`) y si es una VM.
- Los pasos para reproducirlo y, si es visual, una captura.
