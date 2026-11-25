[English](comments.md) | **Español**

# Comentarios de código

Cómo se escriben los comentarios en este repo: scripts de shell, zsh, Lua
(Neovim), los `.ini` de polybar, `picom.conf`, `kitty.conf`, `sxhkdrc`, los
`.rasi` de rofi, XKB, GTK, JSON con comentarios, YAML y el `user.js` de Firefox.
Se escriben en inglés, para que el código se lea igual para cualquiera que lo
abra.

La guía es la de
[dotfiles-windows](https://github.com/M1gu3l4ngel/dotfiles-windows/blob/main/docs/contributing/comments.es.md),
que compara cinco guías de estilo (Google Shell y JavaScript, PowerShell
Practice and Style, Microsoft, el kernel de Linux). Esta página se queda con lo
que aplica aquí y añade lo que necesitan los formatos de Parrot.

## Cabecera del archivo

Cada archivo empieza con una cabecera corta: qué es, quién lo carga y cómo
recargarlo. De dos a seis líneas.

- Va después de lo que tiene que ir primero: el shebang.
- No repite el nombre del archivo ni su ruta: el archivo ya los tiene, y
  `lib/links.sh` dice dónde se enlaza.
- No copia el README (uso, requisitos) ni guarda historia (fechas, autores,
  «antes hacía…»): eso vive en el README y en git.

```bash
#!/usr/bin/env sh
# Starts every polybar bar, after closing the running ones over IPC.
#
# bspwmrc runs it at login and on every bspwm restart (Super+Alt+R); it can also
# be run by hand to reload the bars.
```

## Comentarios dentro del cuerpo

Solo el **porqué**: la decisión detrás de una línea, un límite, un rodeo, el
incidente que evita. Nunca el **qué**: el código ya lo dice, y un comentario que
lo repite queda desfasado la primera vez que el código cambia.

```ini
;; Never 0 in a custom/script: polybar reruns it in a loop with no pause (it
;; reached 30 % of CPU). 86400 for static icons.
interval = 86400
```

- Encima del código que explica, no al final de la línea, salvo una nota
  corta.
- Un comentario por bloque, no uno por línea.
- Una sección de un archivo largo es una línea en blanco y un comentario de una
  línea, nunca un banner.
- Una función de shell lleva comentario cuando su nombre no dice todo lo que
  necesita quien la llama: un efecto, un límite, el código de salida.

## Forma

- Inglés, frases completas, en presente, con palabras sencillas.
- Dentro del límite de línea del código: 100 columnas (`.editorconfig`).
- Sin banners (`# ----- X -----`, `# =====`), recuadros, emojis ni mayúsculas
  decorativas.
- Sin código comentado: git lo guarda.
- `TODO` solo con la condición que lo cierra (`TODO: remove when …`); el trabajo
  pendiente va a `docs/tasks.md`.
- Los iconos de Nerd Font nunca se escriben como caracteres literales, tampoco
  en un comentario: se nombran por su código (`U+F329 nf-linux-parrot`).

| Formato | Prefijo del comentario |
|---|---|
| Shell, zsh, `bspwmrc`, `sxhkdrc`, `picom.conf`, `kitty.conf`, YAML, `.gitignore` | `#` |
| `.ini` de polybar | `;;` |
| Lua | `--` |
| XKB, `.rasi` de rofi, `.css` de GTK, JSON con comentarios, `user.js` | `//` o `/* */` |

## Otros textos del código

| Texto | Idioma | Por qué |
|---|---|---|
| Salida de los scripts (`install.sh`, `uninstall.sh`, `bootstrap.sh`, `70-system/setup.sh`, `tools/`) y nombres de los pasos del CI | Inglés | Un solo texto que los dos idiomas de la documentación citan tal cual |
| Nombres de los tests | Inglés | Son código, y el CI los imprime |
| Texto que muestra el escritorio (notificaciones, menús de rofi, etiquetas de polybar) | Español | Es la interfaz que lee su usuario, no código |
| Texto del panel de tareas y los títulos que lee de `docs/tasks.md` | Español | `docs/tasks.md` se escribe en español |

## Qué no se comenta

- Lo que ya dicen el código, un nombre o un tipo.
- La historia: qué hacía antes el código, quién lo cambió, cuándo. Eso es git.
- Datos personales o de la máquina (usuarios, rutas, hosts, IPs): el repo es
  público.
- Lo que el comentario no pueda mantener cierto: un comentario que contradice
  el código es peor que ninguno, así que un cambio actualiza sus comentarios en
  el mismo commit.

## El check

`./tools/check.sh` ejecuta el check que dotfiles-windows comparte a través de
`~/.claude/tools`:

```bash
node ~/.claude/tools/check-comments.mjs .
```

Falla ante un comentario o un nombre de test en español. Lo que no sabe
clasificar solo vive en `.claude/comments.json`: el archivo de símbolos de XKB,
cuyos comentarios usan `//`, y las exenciones, que se imprimen en cada
ejecución.
