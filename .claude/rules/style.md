# Estilo de los archivos de configuración

## Comentarios

- En español.
- Explican el porqué, no el qué.
    - Mal: `# Set border width`
    - Bien: `# Ancho del borde en píxeles: más alto, más feedback visual al
      hacer focus.`
- No mencionar autores, cursos ni fuentes de inspiración: cada decisión se
  justifica por sí misma.
- Cada archivo de config empieza con una cabecera: ruta, qué hace, quién lo
  carga y cómo recargarlo.
- Secciones con `# ----- SECCIÓN -----` (`;; ` en `.ini`, `-- ` en Lua,
  `// ` en XKB y apt). Para bloques grandes, además `# ==== TÍTULO ====`.

## Formato

- Máximo una línea en blanco consecutiva.
- Indentación según la convención de cada formato:

| Formato | Indentación |
|---|---|
| Shell (`.sh`, `bspwmrc`, scripts sin extensión) | 2 espacios |
| Lua (Neovim) | 2 espacios (lo fuerza `.stylua.toml`) |
| Markdown | 4 espacios en listas anidadas |
| `sxhkdrc` | Tabulador (convención de sxhkd) |
| `picom.conf`, `.rasi`, `.ini` de polybar, XKB | 2 espacios |
