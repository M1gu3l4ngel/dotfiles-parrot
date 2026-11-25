# Git

- Claude hace el commit firmado de cada bloque verificado (check en verde y
  prueba real), sin preguntar, y da el hash al cerrar. Nunca `--no-gpg-sign`:
  si la firma falla, se para y se pide al usuario que desbloquee la clave.
- Nunca `push`, `pull` ni `--force`: el `push` solo si el usuario lo pide (cada
  uno gasta minutos de Actions), y el `pull` lo ejecuta el usuario.
- Formato Conventional Commits en inglés e imperativo: título
  `type(scope): summary` de hasta 72 caracteres, línea en blanco y un cuerpo con
  un guion por cambio concreto (sin cuerpo solo si el título lo dice todo).
  `type`: `feat`, `fix`, `docs`, `style`, `refactor`, `chore`, `ci`; `scope`
  opcional, el componente afectado. Sin trailers de atribución.
- Un solo commit por bloque de trabajo, aunque toque varios archivos: un único
  `git add` con los archivos implicados (rutas explícitas, nunca `-A` ni `.`).
- Validar, añadir al índice y hacer el commit en pasos separados, no
  encadenados: un check que falla no debe dejar pasar el commit.
- Antes del commit: `./tools/check.sh` debe pasar y el diff no debe contener
  datos personales (ver `security.md`).
- Los archivos nuevos no aparecen en `git diff`: revisarlos aparte.
- `15-git/gitconfig` es la parte que puede ser pública: firma y rama por
  defecto. Lo de cada persona o máquina (identidad, clave de firma,
  organizaciones) vive en `~/.gitconfig.local`, nunca en el repo; `bootstrap.sh`
  escribe ahí la identidad (`--git-name`, `--git-email`). Nunca
  `git config --global`: `~/.gitconfig` es el enlace al repo público.
- Para borrar archivos versionados: confirmarlo antes con el usuario, `rm` de
  los archivos y `git add` de sus rutas (el hook global bloquea `git rm`), y
  comprobar después con `git show --stat HEAD` que el borrado entró en el commit.
