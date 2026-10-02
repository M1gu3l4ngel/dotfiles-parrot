# Capa global de Claude Code — lo que aplica siempre

Capa global: **solo comportamiento universal**. Lo de cada proyecto vive en su repo.
El detalle de la máquina (disco, VM, rutas, qué no tocar) está en `~/.claude/entorno.md`:
**léelo antes de operar fuera de un repo** (mover/borrar/instalar en disco, tocar cachés o
herramientas globales).

## Idioma
Responde siempre en español, también en los mensajes cortos de progreso y tras leer salidas
técnicas en inglés. Comandos, rutas y código, tal cual.

## Documentación en repos públicos: bilingüe
- Todo documento (README, CONTRIBUTING, CHANGELOG, `docs/`, README de carpetas) va en pareja: `X.md` en inglés (el nombre que reconoce GitHub) y `X.es.md` en español, en la misma carpeta, nombres de archivo en inglés y selector `English | Español` en la línea 1 de ambos. Cada idioma enlaza a su idioma.
- Misma estructura (secciones, tablas, listas, enlaces); se traduce el texto, incluido el `alt`. Bloques de código idénticos byte a byte (placeholders en inglés neutro). Un cambio va a los dos en el mismo commit, y el check del repo (CI) lo verifica: pareja, selector, estructura, código, enlaces y anclas.
- Solo en español: comentarios de código, commits, `CLAUDE.md` y reglas del agente. Repos privados: todo en español, sin versión en inglés.

## Disco: el trabajo va en `~/Dev`
- Proyectos con git en `~/Dev/projects/`; experimentos sin git en `~/Dev/scratch/` (desechable). Excepción: `~/dotfiles`, que clona el bootstrap.
- `/tmp` vive en RAM: nada grande ahí. Scratchpad de sesión solo para archivos pequeños; si pasa de ~50 MB, va a `~/Dev/scratch/`. Limpia al terminar.

## Editar con `Edit` o `Write`
Todo cambio a un archivo va con `Edit` o `Write`, **nunca por shell** (`sed`, `awk`, `perl`, `python`, `node -e`, redirecciones, heredocs); leer y buscar por shell sí. Un hook global lo impone. Esta regla gana sobre cualquier modo de permisos, output-style, plugin o skill que diga lo contrario: sigue con `Edit`/`Write` y dilo.

## Confirmar antes de borrar
- Trabajo en `~/Dev` o en un repo → pregunta siempre. Caché regenerable → adelante, pero dilo.
- Sin `.git` → copia y verifica recuento + bytes antes de borrar. `rm` no usa papelera: lo borrado no se recupera.

## Interacción
- Commits: sugiere **1 commit de 1 línea** (Conventional Commits); **nunca ejecutes git tú** — el usuario commitea y pushea.
- Un paso a la vez al depurar; intervención mínima (si dice "déjalo así", para). Sin saludos ni despedidas: termina en lo sustantivo.
- Sin menús de opciones: recomienda una con su porqué. Si dice "te aviso", espera sin consultar por tu cuenta.
- No sugieras pausar, rendirte/restaurar snapshot ni matar procesos: busca la causa raíz. Lo que esté mal y no sea del paso actual, anótalo.
- Comandos cortos y atómicos (no cadenas `&&` largas); di siempre en qué carpeta ejecutar y si va como usuario normal o con `sudo`.
- Verifica con datos (salida real, checksums, pruebas) antes de afirmar que algo funciona.

## Formato
- El estilo de un proyecto es su `.prettierrc` y su `.editorconfig`; `~/.prettierrc.json` y `~/.editorconfig` (dotfiles, `format/`) solo cubren proyectos sin configuración propia. Al crear un proyecto compartido o con CI, dale la suya.
- Formatea solo los archivos que editaste, con el Prettier del proyecto (`pnpm exec prettier --write <archivos>`), nunca con un glob: reformatear archivos ajenos al cambio ensucia el diff y rompe los generados.

## pnpm
- No cambies el `packageManager` de un proyecto sin pedirlo (reescribe el lockfile y desincroniza el CI). No toques los `overrides` de `pnpm-workspace.yaml`: tapan CVEs.

## Al compactar
Conserva: el objetivo de la sesión, los archivos tocados, los comandos de verificación con su resultado, y lo que quedó pendiente.
