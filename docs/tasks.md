# Tareas pendientes — dotfiles-parrot

Solo lo que falta: lo hecho se borra, no se marca. El formato lo describe el README de
`~/.claude/panel/` (en dotfiles-windows, `50-claude/panel/README.es.md`); el panel de tareas
es una vista de este archivo.

Objetivo: dejar el repo al nivel de dotfiles-windows y hacerlo el cerebro de Parrot, de modo que
un clon en cualquier PC con Parrot instale y funcione todo, sin romper lo que ya funciona en esta
máquina. Lo que puede romper algo se prueba antes en modo de prueba.

# Por probar

## Reglas de secretos en el settings.json de esta máquina

**Plataforma:** Claude Code.

- [ ] [Esta PC] En una sesión nueva de Claude Code, pedirle que lea un archivo de `~/.gnupg` o de `~/.password-store` responde «Permission denied»
- [ ] [Esta PC] Claude Code arranca sin errores de `settings.json` (copia previa en `~/.claude/settings.json.pre-dotfiles.bak.20261125124350`)

## Capa de Claude enlazada desde dotfiles-windows

**Plataforma:** Claude Code.

- [ ] [Esta PC] Al abrir una sesión nueva en `~/dotfiles`, Claude dice si el panel está al día (hook `SessionStart`)
- [ ] [Esta PC] Editar `docs/tasks.md` hace que Claude avise de regenerar el panel (hook de `Edit|Write`)
- [ ] [Esta PC] `git push` pregunta en vez de ejecutarse, y `git add -A` se deniega
- [ ] [Esta PC] Claude escribe en inglés los comentarios nuevos y responde en español
- [ ] [Esta PC] `/new-repo` aparece entre los skills

## Instalador que distingue cada enlace

**Plataforma:** Instalación.

- [ ] [Esta PC] `./install.sh --check` desde `~/dotfiles` lista los 29 enlaces en `ok`, los hooks y las reglas de Claude, y acaba en «Todo instalado»
- [ ] [Esta PC] `./install.sh --dry-run` dice «0 cambios por hacer» sin tocar nada
- [ ] [Esta PC] `./install.sh` dice «Nada que cambiar» y el escritorio, zsh y Claude Code siguen igual
- [ ] [Esta PC] `./uninstall.sh --dry-run` lista 30 enlaces y las copias que restauraría, sin tocar nada
- [ ] [PC nueva] `./install.sh` sin `~/dotfiles-windows` avisa de que omite la capa de Claude Code y enlaza el resto
- [ ] [PC nueva] Con `~/dotfiles-windows` clonado y sin `~/.claude/settings.json`, `./install.sh` lo crea con los hooks, las reglas y la barra de estado

## Hook post-merge que rehace los enlaces

**Plataforma:** Instalación.

- [ ] [Esta PC] El próximo `git pull` con cambios en `~/dotfiles` termina con la salida de `install.sh` («Nada que cambiar» o los enlaces nuevos)
- [ ] [PC nueva] Tras `./install.sh`, `git -C ~/dotfiles config --get core.hooksPath` devuelve `githooks`

## Modo de prueba en bootstrap.sh y clon de dotfiles-windows

**Plataforma:** Instalación.

- [ ] [Esta PC] `./bootstrap.sh --dry-run` desde `~/dotfiles` no pide sudo y solo marca con `~` el paso de hardening
- [ ] [PC nueva] `./bootstrap.sh --dry-run` antes de instalar nada lista los paquetes, fuentes, Neovim, oh-my-posh, Node, el clon de dotfiles-windows y los enlaces que faltan
- [ ] [PC nueva] `./bootstrap.sh` clona dotfiles-windows en `~/dotfiles-windows` y Claude Code arranca con la capa enlazada

## Finales de línea en LF en cualquier clon

**Plataforma:** Repositorio.

- [ ] En el clon de Windows (`~\dotfiles-parrot`), tras `git pull`, `git ls-files --eol` muestra `w/lf` en los scripts (puede hacer falta `git checkout -- .` una vez, sin cambios pendientes)
- [ ] Tras el push, el CI pasa con el paso «LF line endings» en verde

# Fase 2 — Instalador sin pérdidas

## Versiones fijadas en bootstrap.sh

**Plataforma:** Instalación.
**Prioridad:** P2.
**Requiere:** nada.
**Estado:** en curso.

- [ ] `pnpm` y `@anthropic-ai/claude-code` se instalan sin versión: fijarlas como Neovim y oh-my-posh
- [ ] Instalar `gh` (repositorio de Parrot o release verificado por SHA-256): hoy no está y lo piden el skill `new-repo` y el ruleset de `main`
- [ ] Paso de identidad de git como el paso 6 de `bootstrap.ps1`, en vez de imprimir los `git config --global` al final

## Arquitecturas distintas de x86_64

**Plataforma:** Instalación.
**Prioridad:** Mejora.
**Requiere:** nada.

- [ ] Neovim (`nvim-linux-x86_64`) y oh-my-posh (`posh-linux-amd64`) solo se descargan para x86_64: detectar `uname -m` y fijar el SHA-256 de arm64, o salir con un mensaje claro

# Fase 3 — Capa de Claude desde dotfiles-windows

## Recordatorio de español local en settings.json

**Plataforma:** Claude Code.
**Prioridad:** P2.
**Requiere:** nada.

`install.sh` ya fusiona `settings.json` con `install-settings.mjs`. Queda un hook que solo existe
en esta máquina.

- [ ] Decidir si el `UserPromptSubmit` local (recordatorio de español con `printf`) se queda o se borra porque ya lo cubre `reply-in-spanish.mjs`

## Quitar la copia claude/ del repo

**Plataforma:** Claude Code, Repositorio.
**Prioridad:** P2.
**Requiere:** nada.

- [ ] `git rm` de `claude/` (incluida `tasks-artifact.template.html`, que el panel sustituye) tras comprobar `./install.sh --check` en verde
- [ ] `.prettierignore` deja de listar `claude/`; `tools/check.sh` ya no llama a `claude/check-budget.mjs`
- [ ] `git rm` de `tools/check-docs.py`: `tools/check.sh` llama a `node ~/.claude/tools/check-docs.mjs . --exclude nvim/.config/nvim/README.md` (protegido, heredado de NvChad)
- [ ] `~/.claude/entorno.md` rehecho con las secciones de `50-claude/entorno.template.md`, con lo de Linux que el `CLAUDE.md` global ya no dice (`~/Dev`, `/tmp` en RAM, `rm` sin papelera)

# Fase 4 — Carpetas numeradas por capa

## Reorganizar en carpetas numeradas

**Plataforma:** Repositorio, Instalación.
**Prioridad:** P2.
**Requiere:** «Quitar la copia claude/ del repo».

Propuesta: `10-shell/` (zsh, oh-my-posh), `15-git/` (gitconfig, gnupg), `20-terminal/` (kitty),
`25-desktop/` (bspwm, sxhkd, polybar, picom, rofi, dunst, gtk, xkb, scripts), `30-editor/`
(nvim, vscodium), `40-format/`, `60-apps/` (lista de apt) y `70-system/` (system). Los enlaces
instalados quedan en `stale` y `install.sh` los rehace solos; en otras PC, el `post-merge`.

- [ ] `git mv` de cada carpeta y `lib/links.sh` actualizado en el mismo commit
- [ ] Antes del commit, `./install.sh --dry-run` muestra solo enlaces `stale` que se rehacen, sin backups
- [ ] Rutas internas actualizadas: `bspwmrc`, `polybar/launch.sh`, `.zshrc` (tema de oh-my-posh), `tools/check.sh`, `.shellcheckrc`, `.prettierignore`, `.editorconfig` y `.claude/rules/shell.md` (`paths:`)
- [ ] La lista de apt pasa de `bootstrap.sh` a `60-apps/` y `bootstrap.sh` la lee

## Configuración de git versionada

**Plataforma:** Shell, Instalación.
**Prioridad:** P2.
**Requiere:** «Reorganizar en carpetas numeradas».

`~/.gitconfig` es un archivo real sin versionar. Windows versiona la parte pública en `15-git/` y
deja la clave de firma y las organizaciones privadas en `~/.gitconfig.local`.

- [ ] `15-git/gitconfig` (nombre, email noreply, firma de commits y etiquetas) enlazado en `~/.gitconfig`, que incluye `~/.gitconfig.local`
- [ ] Mover `user.signingkey` de esta máquina a `~/.gitconfig.local` antes de enlazar (hoy no nombra ninguna organización)

# Fase 5 — Calidad y CI

## CI completo con acciones fijadas

**Plataforma:** Repositorio.
**Prioridad:** P2.
**Requiere:** «Quitar la copia claude/ del repo».

- [ ] El CI corre lo mismo que `./tools/check.sh`: shellcheck, shfmt, tests, docs bilingües, check del panel, check de comentarios y gitleaks
- [ ] Segundo `actions/checkout` de dotfiles-windows, fijado por SHA, para las herramientas compartidas
- [ ] Node del runner sin versión escrita en el YAML (no hay `package.json`: se usa el del runner)
- [ ] `.github/dependabot.yml` mensual para `github-actions`, agrupado y con `cooldown` de 7 días, como en Windows
- [ ] Nombres de los pasos del CI en inglés

## Tests de install.sh y uninstall.sh

**Plataforma:** Instalación, Repositorio.
**Prioridad:** P2.
**Requiere:** nada.

- [ ] `tools/test-install.sh`: ejecuta `install.sh` y `uninstall.sh` con un `HOME` temporal y comprueba los cuatro estados, el backup, la restauración tras un fallo y que una segunda ejecución no cambia nada (hay un borrador con 19 casos en el scratchpad de la sesión que se puede partir)
- [ ] `tools/check.sh` y el CI lo ejecutan

## Recarga de polybar sin killall

**Plataforma:** Escritorio.
**Prioridad:** Mejora.
**Requiere:** nada.

- [ ] `polybar/launch.sh` cierra las barras con `polybar-msg cmd quit` (con `enable-ipc = true` en las barras) en vez de `killall -q polybar`

# Fase 6 — Comentarios en inglés

## Regla de idioma del código en el repo

**Plataforma:** Repositorio, Claude Code.
**Prioridad:** P2.
**Requiere:** «Quitar la copia claude/ del repo».

`docs/contributing/comments.md` de dotfiles-windows es la guía. `.claude/rules/style.md`,
`documentation.md`, `CONTRIBUTING` y `claude/CLAUDE.md` dicen hoy «comentarios en español».

- [ ] Sección «Idioma del código: inglés» en `CLAUDE.md`, como la de dotfiles-windows, antes de migrar nada
- [ ] `.claude/rules/documentation.md` deja de decir «solo en español: la salida de los scripts»: el `CLAUDE.md` global pide en inglés comentarios, salida de los scripts, `reason` de los hooks y nombres de los tests
- [ ] `.claude/rules/style.md`: banners `# ----- X -----` fuera (la guía los prohíbe) y comentarios en inglés
- [ ] `docs/contributing/comments.md` y `.es.md` adaptados a los formatos de Parrot (shell, zsh, Lua, `.ini`, `.rasi`, `.conf`, XKB, sxhkdrc)

## Migrar los comentarios por carpeta

**Plataforma:** Repositorio.
**Prioridad:** P2.
**Requiere:** «Regla de idioma del código en el repo», «Reorganizar en carpetas numeradas».

Unas 1860 líneas de comentario en 70 archivos; el check compartido (dotfiles-windows `87a6791`) encuentra hoy 454 en español y ningún nombre de test, porque el repo no tiene tests todavía.

- [ ] `.claude/comments.json` con lo que el check no reconoce solo (`xkb/.config/xkb/symbols/capsfix`, de estilo `//`)
- [ ] Un commit por carpeta numerada, con la salida de los scripts en inglés en el mismo paso
- [ ] `tools/check.sh` ejecuta `node ~/.claude/tools/check-comments.mjs .`, estricto y con sus exenciones impresas
- [ ] Tras la migración, el check no encuentra ningún comentario en español

# Fase 7 — Documentación

## README raíz al nivel de dotfiles-windows

**Plataforma:** Repositorio.
**Prioridad:** P2.
**Requiere:** «Reorganizar en carpetas numeradas».

- [ ] Badges de CI y licencia, tabla de carpetas numeradas con enlace a su README y tabla de recargas (hoy solo en `CLAUDE.md`)
- [ ] Diagrama Mermaid: `bootstrap.sh` → apt, fuentes, Neovim, oh-my-posh, Node → `install.sh` → enlaces → programas, la capa de Claude desde dotfiles-windows y `git pull` → `post-merge`
- [ ] Secciones de `--check`, `--dry-run` y «Mantener otra PC al día», como en Windows

## README de cada carpeta

**Plataforma:** Repositorio.
**Prioridad:** P2.
**Requiere:** «Reorganizar en carpetas numeradas».

- [ ] Un README en pareja por carpeta numerada: qué contiene, adónde se enlaza cada archivo, cómo se recarga y qué no tocar (hoy solo `system/` y `claude/`)

## Guía de PC nueva de principio a fin

**Plataforma:** Instalación.
**Prioridad:** P2.
**Requiere:** nada.

- [ ] `docs/getting-started` con diagrama del flujo, `./bootstrap.sh --dry-run` antes de instalar y `./install.sh --check` al final
- [ ] Cubrir también Parrot instalado sin VMware: hoy la guía da por hecha la VM
- [ ] Ejecutar cada comando antes de escribirlo

## Guía de firma GPG y SSH

**Plataforma:** Repositorio.
**Prioridad:** P2.
**Requiere:** «Configuración de git versionada».

- [ ] `docs/keys-and-secrets` con la estructura de `docs/gpg-signing` de Windows: email noreply, clave nueva o UID añadido, `~/.gitconfig.local`, subir la clave filtrando UIDs, verificar «Verified», caché del agente y backup
- [ ] Importar la clave pública de Windows para que `git log --show-signature` verifique los commits hechos allí (hoy `8b1869f` sale `E`)

## Documentos desfasados

**Plataforma:** Repositorio.
**Prioridad:** P2.
**Requiere:** «Quitar la copia claude/ del repo».

- [ ] `claude/README` dice que los tres hooks y `tasks-artifact.template.html` son iguales a los de Windows: ya no lo son (se resuelve al quitar la copia)
- [ ] `CONTRIBUTING`: commits en una línea y en español; el modelo pide título en inglés en imperativo y cuerpo con un guion por cambio
- [ ] `README`, «What bootstrap.sh does»: añadir los pasos nuevos (clon de dotfiles-windows, identidad de git, `gh`)
- [ ] `docs/README` indexa `docs/contributing/comments.md`

# Fase 8 — Limpieza

## Temas de rofi sin uso

**Plataforma:** Escritorio.
**Prioridad:** Mejora.
**Requiere:** nada.

`config.rasi` solo usa `monokai-soda`. Los otros 26 temas son de terceros (con autor en la
cabecera) y el repo no incluye su licencia.

- [ ] Borrar los temas sin uso, o conservarlos con la licencia de su origen en `rofi/.config/rofi/themes/`

# Cierre — Instalación desde cero

## Prueba en una PC limpia

**Plataforma:** Instalación.
**Requiere:** «Guía de PC nueva de principio a fin», «Migrar los comentarios por carpeta».

- [ ] Seguir `docs/getting-started` en un Parrot recién instalado y anotar cada paso que falte o falle
- [ ] Publicar la versión en `CHANGELOG` con su etiqueta firmada (`git tag -s`)

---

# Lo hace el dueño

- [ ] Crear en GitHub el ruleset de `main` sin borrado ni push forzado (`deletion` y `non_fast_forward`, como `protect-main.json` de dotfiles-windows): hoy el repo no tiene ninguno
- [ ] Corregir los topics de GitHub `neovi` → `neovim` y `ric` → `ricing`

# Aplazado — cada uno con el evento que lo dispara

- [ ] Estado de `settarget` y del anonimato en `~/.local/state` en vez de `~/.config/bin` (4 scripts, `.zshrc`, `install.sh` y `.gitignore` juntos) — al tocar los scripts de polybar
- [ ] Medir el arranque de zsh (`zmodload zsh/zprof`) y pasar de nvm a fnm como Windows si nvm es lo lento — cuando se note la espera al abrir kitty
