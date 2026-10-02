---
paths:
  - "**/*.md"
---

# Documentación

Aplica a los `README`, `CONTRIBUTING`, `CHANGELOG` y `docs/`. No a
`CLAUDE.md` ni a `.claude/rules/` (instrucciones para el agente, solo en
español) ni a `nvim/.config/nvim/README.md` (protegido).

## Idioma: toda la documentación es bilingüe

- Pareja por documento: `X.md` en inglés (el nombre que reconoce GitHub y el
  que ve el visitante) y `X.es.md` en español, en la misma carpeta. Nombres de
  archivo en inglés. Un documento nuevo nace con su pareja.
- Línea 1, el selector: `**English** | [Español](X.es.md)` en el inglés y
  `[English](X.md) | **Español**` en el español.
- Mismo contenido y misma estructura: secciones, tablas, listas y enlaces en
  el mismo orden. Cada idioma enlaza a su idioma (`x.es.md` desde el
  español); las anclas siguen al título traducido.
- Se traduce el texto, incluido el `alt` de imágenes y badges (lo leen los
  lectores de pantalla). Los bloques de código son idénticos byte a byte:
  comandos, rutas, URLs y placeholders en inglés neutro (`<user>`,
  `<your-noreply>`), explicados en el texto de cada idioma. Los textos que
  muestra el programa (notificaciones, salidas) se citan tal cual.
- Un cambio en uno va también al otro, en el mismo commit.
  `tools/check.sh` (`tools/check-docs.py`) falla si falta una pareja o un
  selector, si difieren títulos, filas de tabla, elementos de lista, enlaces
  o bloques de código, o si hay enlaces o anclas rotos.
- Solo en español: comentarios de código, mensajes de commit y la salida de
  los scripts.

## Estilo

- Sin iconos ni emojis. Texto sobrio.
- Lenguaje directo y simple. Sin relleno ni marketing.
- Términos técnicos, comandos y rutas tal cual.
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
