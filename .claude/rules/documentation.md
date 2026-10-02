---
paths:
  - "**/*.md"
---

# Documentación

Aplica a `README.md`, `README.es.md`, `CONTRIBUTING.md`, `CHANGELOG.md`,
`docs/` y a los `README.md` de cada carpeta.

## Idioma

- El README de la raíz es bilingüe: `README.md` en inglés (la portada que ve
  GitHub) y `README.es.md` en español, con el selector `English | Español`
  arriba en ambos. Mismo contenido: secciones, tablas, comandos y enlaces.
  Se traduce el texto, incluido el `alt` de imágenes y badges (lo leen los
  lectores de pantalla); comandos, rutas y URLs quedan idénticos.
- Cualquier cambio en uno se hace también en el otro, en el mismo commit.
  `tools/check.sh` falla si no tienen el mismo número de secciones y filas de
  tabla o si sus bloques de comandos difieren.
- El resto (`docs/`, `CONTRIBUTING.md`, `CHANGELOG.md`, comentarios) sigue en
  español. Desde `README.md`, los enlaces a guías indican "(in Spanish)".

## Estilo

- Sin iconos ni emojis. Texto sobrio.
- Lenguaje directo y simple. Sin relleno ni marketing.
- En español (salvo `README.md`, ver arriba). Términos técnicos, comandos y
  rutas tal cual.
- Escaneable: secciones cortas, títulos claros, lo importante arriba.
- El lector debe poder reproducir el setup sin leerlo todo.

## Instrucciones

- Pasos numerados, en el orden exacto de ejecución, cada uno autocontenido.
- Cada bloque de comandos se copia y funciona tal cual: sin `$` delante, sin
  salida mezclada, sin placeholders sin explicar.
- Indicar en cada paso si requiere `sudo` y desde qué directorio se ejecuta.
- Nunca documentar de memoria: ejecutar cada comando antes de escribirlo.

## Consistencia

- Mismos nombres en todo el repo: los de los atajos reales (`Super+Alt+R`), las
  rutas reales y los nombres de script reales.
- Una información vive en un solo sitio; el resto enlaza. Si algo cambia en el
  código, actualizar su documentación en el mismo commit.
- Markdown: listas anidadas con 4 espacios; bloques de código con el lenguaje
  indicado (`bash`, `conf`, `ini`).
