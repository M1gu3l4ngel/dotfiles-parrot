# Git

- No ejecutar comandos git que modifiquen el repo (`add`, `commit`, `push`,
  `pull`, `rm`): proponerlos para que el usuario los ejecute. Porqué: el
  usuario revisa y firma cada commit él mismo.
- Formato Conventional Commits en una sola línea de 72 caracteres como máximo:
  `type(scope): descripción en español`. `type` en inglés (`feat`, `fix`,
  `docs`, `style`, `refactor`, `chore`, `ci`); `scope` opcional, el
  componente afectado.
- Un solo commit por bloque de trabajo, aunque toque varios archivos: un único
  `git add` con los archivos implicados (rutas explícitas, no `git add .`) y un
  único mensaje que resuma el conjunto.
- Antes de proponer el commit: `./tools/check.sh` debe pasar y el diff no debe
  contener datos personales (ver `security.md`).
- Los archivos nuevos no aparecen en `git diff`: revisarlos aparte.
- Para borrar archivos versionados, proponer `git rm`, y comprobar después con
  `git show --stat HEAD` que el borrado entró en el commit.
