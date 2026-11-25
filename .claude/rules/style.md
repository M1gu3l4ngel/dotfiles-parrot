# Estilo de los archivos de configuración

## Comentarios

La guía completa es `docs/contributing/comments.md`; aquí, lo esencial.

- En inglés, frases completas, en presente y con palabras llanas.
- Explican el porqué, no el qué: la decisión, el límite, el incidente que evitan.
    - Mal: `# Set border width`
    - Bien: `# 1 px, the same as the window border: bars and windows read as one system.`
- No mencionar autores, cursos ni fuentes de inspiración: cada decisión se
  justifica por sí misma.
- Cada archivo empieza con una cabecera corta: qué es, quién lo carga y cómo
  recargarlo. Sin repetir su nombre ni su ruta.
- Una sección de un archivo largo es una línea en blanco y un comentario de una
  línea, nunca un banner (`# ----- X -----`, `# ==== X ====`).
- Sin código comentado (lo guarda git). `TODO` solo con la condición que lo cierra.
- Prefijo según el formato: `#` (shell, conf, kitty, picom, sxhkdrc), `;;` en los
  `.ini` de polybar, `--` en Lua, `//` en XKB, `.rasi`, JSONC y `user.js`.

## Formato

- Máximo una línea en blanco consecutiva.
- Hasta 100 columnas, como el código (`.editorconfig`).
- Indentación según la convención de cada formato:

| Formato | Indentación |
|---|---|
| Shell (`.sh`, `bspwmrc`, scripts sin extensión) | 2 espacios |
| Lua (Neovim) | 2 espacios (lo fuerza `.stylua.toml`) |
| Markdown | 4 espacios en listas anidadas |
| `sxhkdrc` | Tabulador (convención de sxhkd) |
| `picom.conf`, `.rasi`, `.ini` de polybar, XKB | 2 espacios |
