# Edición de archivos

- Todo cambio en archivos del repo se hace con las herramientas Edit/Write,
  nunca con `sed`, `awk` ni scripts. Porqué: el cambio queda explícito y
  revisable, sin efectos colaterales de un patrón mal escrito.
- Leer el archivo completo (o la sección afectada) antes de editarlo.
- Tras editar, validar con la herramienta del formato (`./tools/check.sh` o la
  validación específica de `CLAUDE.md`).

## Glifos de iconos (Nerd Font, feather)

Los caracteres de uso privado de Unicode (PUA, `U+E000`-`U+F8FF` y planos
superiores) que usan los iconos desaparecen o se sustituyen por otros al pasar
por las herramientas de edición.

- Nunca escribirlos como caracteres literales en ningún archivo.
- En scripts de shell, escribirlos como escapes UTF-8:
  `ICON=$'\xef\x8c\xa9' # U+F329 nf-linux-parrot`.
- Para obtener los bytes de un glifo existente: `xxd` o `iconv -t utf-32be`.
- Por eso los iconos de polybar viven en `scripts/.config/scripts/*_module.sh`
  y no en los `.ini`.

## Archivos protegidos

No modificar sin permiso explícito del usuario:

- `LICENSE`
- `assets/`
- `nvim/.config/nvim/lazy-lock.json`: lock file de lazy.nvim.
- `nvim/.config/nvim/LICENSE` y `nvim/.config/nvim/README.md`: heredados de
  la plantilla de NvChad.
