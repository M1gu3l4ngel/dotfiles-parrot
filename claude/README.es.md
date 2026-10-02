[English](README.md) | **Español**

# Capa global de Claude Code

Comportamiento **universal** de Claude Code, igual en cualquier proyecto, máquina y sistema
operativo. Lo específico de un proyecto vive en el repo de ese proyecto; lo específico de una
máquina se queda local (no se versiona). La misma capa existe en
[dotfiles-windows](https://github.com/M1gu3l4ngel/dotfiles-windows): los dos repos son
independientes y cada máquina funciona sola.

## Qué hay aquí (genérico, sin datos personales)

| Archivo | Enlazado a | Qué es |
|---|---|---|
| `CLAUDE.md` | `~/.claude/CLAUDE.md` | Reglas universales: idioma, disco, editar con Edit/Write, confirmar antes de borrar, interacción, compactación |
| `statusline.mjs` | `~/.claude/statusline.mjs` | Barra de estado (modelo, contexto en tokens, carpeta) |
| `hooks/block-shell-edits.mjs` | `~/.claude/hooks/block-shell-edits.mjs` | Hook `PreToolUse` que impone editar con Edit/Write (bloquea `sed -i`, redirecciones, heredocs… y deja pasar temporales). Portable Windows/Linux |
| `settings.template.json` | — (plantilla) | Base portable de `settings.json`: `deny`/`ask` de secretos genéricos + registro del hook + `skillOverrides` |
| `check-budget.mjs` | — (script) | Guarda de presupuesto: cuenta líneas de `CLAUDE.md`/`statusline`/`hook` y falla si exceden. Lo ejecuta `tools/check.sh` |

`statusline.mjs`, `hooks/block-shell-edits.mjs`, `check-budget.mjs` y
`settings.template.json` son idénticos a los de Windows. `CLAUDE.md` comparte el núcleo y
cambia solo lo propio de Linux: el disco (`~/Dev`, `/tmp` en RAM), el borrado (`rm` sin
papelera) y que cada comando indique si va como usuario normal o con `sudo`.

## Qué NO se versiona (queda local, por máquina)

- **`~/.claude/entorno.md`** — detalle físico de la máquina (disco, VM, rutas, usuario) y datos
  privados. Cada máquina tiene el suyo. **Nunca** va a un repo público.
- **`~/.claude/settings.json`** — tiene rutas con tu usuario, `autoMode` (lo genera cada
  máquina, nunca a mano) y plugins. Se copia de la plantilla, no se enlaza.
- Historial, sesiones, memoria (`~/.claude/projects/**`), cachés, `file-history`.

## Montar en una máquina nueva

1. `./bootstrap.sh` (o solo `./install.sh`): enlaza los 3 archivos de arriba a `~/.claude/`
   y, si `~/.claude/settings.json` no existe, lo crea desde la plantilla con tu `$HOME` en
   lugar de `REEMPLAZA_RUTA_HOME` y con la barra de estado registrada. Si ya existe, no lo
   toca: fusiona a mano lo que falte (la plantilla y `statusLine`).
2. Crea tu `~/.claude/entorno.md` local con el detalle de esa máquina (no se versiona).
3. Crea las carpetas de trabajo:

    ```bash
    mkdir -p ~/Dev/projects ~/Dev/scratch
    ```

Los patrones de secretos usan `**/` (portables Windows/Linux) y no contienen ningún dato
personal. El `deny` bloquea en seco claves/credenciales; `.env*` queda en `ask` (pregunta
antes de leer, para poder guiar sin exponer valores en el contexto).
