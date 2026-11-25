# Tareas pendientes — dotfiles-parrot

Solo lo que falta: lo hecho se borra, no se marca. El formato lo describe el README de
`~/.claude/panel/` (en dotfiles-windows, `50-claude/panel/README.es.md`); el panel de tareas
es una vista de este archivo.

Objetivo: dejar el repo al nivel de dotfiles-windows y hacerlo el cerebro de Parrot, de modo que
un clon en cualquier PC con Parrot instale y funcione todo, sin romper lo que ya funciona en esta
máquina. Lo que puede romper algo se prueba antes en modo de prueba.

# Por probar

## README de cada carpeta

**Plataforma:** Repositorio.

- [ ] Tras el push, cada carpeta numerada muestra su README en GitHub, con el selector de idioma y las tablas bien formadas
- [ ] Tras el push, el diagrama de «How it works» del README raíz se dibuja en GitHub, en inglés y en español
- [ ] Los enlaces de la tabla de carpetas del README raíz abren el README de cada carpeta en su idioma
- [ ] Tras el push, el diagrama de `docs/getting-started` se dibuja en GitHub
- [ ] [PC nueva] Seguir `docs/getting-started` de principio a fin en una VM limpia: `./bootstrap.sh --dry-run` no pide sudo ni cambia nada, y `./install.sh --check` acaba en «All installed»
- [ ] [PC nueva] En Parrot sin VMware, `./bootstrap.sh` no instala `open-vm-tools-desktop` y `sudo ./70-system/setup.sh` dice «Not a VMware VM; skipped» en el paso 8
- [ ] Lo que dice cada README (adónde se enlaza, cómo se recarga) coincide con lo que ves en esta PC

## Comentarios y salida de los scripts en inglés

**Plataforma:** Repositorio.

- [ ] [Esta PC] `sudo ./70-system/setup.sh` desde `~/dotfiles` muestra sus 10 pasos en inglés y acaba en «Setup complete»
- [ ] [Esta PC] Firmar un commit tras `gpg-connect-agent reloadagent /bye` sigue abriendo el diálogo de la passphrase (el `gpg-agent.conf` nuevo)
- [ ] [Esta PC] Las notificaciones, los menús de rofi y polybar siguen en español
- [ ] [Esta PC] Neovim y VSCodium abren con los mismos ajustes que antes

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

- [ ] [Esta PC] `./install.sh --check` desde `~/dotfiles` lista los 30 enlaces en `ok`, los hooks y las reglas de Claude, y acaba en «All installed»
- [ ] [Esta PC] `./install.sh --dry-run` dice «0 changes to make» sin tocar nada
- [ ] [Esta PC] `./install.sh` dice «Nothing to change» y el escritorio, zsh y Claude Code siguen igual
- [ ] [Esta PC] `./uninstall.sh --dry-run` lista 31 enlaces y las copias que restauraría, sin tocar nada
- [ ] [PC nueva] `./install.sh` sin `~/dotfiles-windows` avisa de que omite la capa de Claude Code y enlaza el resto
- [ ] [PC nueva] Con `~/dotfiles-windows` clonado y sin `~/.claude/settings.json`, `./install.sh` lo crea con los hooks, las reglas y la barra de estado

## Hook post-merge que rehace los enlaces

**Plataforma:** Instalación.

- [ ] [Esta PC] El próximo `git pull` con cambios en `~/dotfiles` termina con la salida de `install.sh` («Nothing to change» o los enlaces nuevos)
- [ ] [PC nueva] Tras `./install.sh`, `git -C ~/dotfiles config --get core.hooksPath` devuelve `githooks`

## Modo de prueba en bootstrap.sh y clon de dotfiles-windows

**Plataforma:** Instalación.

- [ ] [Esta PC] `./bootstrap.sh --dry-run` desde `~/dotfiles` no pide sudo y solo marca con `~` el paso de hardening
- [ ] [PC nueva] `./bootstrap.sh --dry-run` antes de instalar nada lista los paquetes, fuentes, Neovim, oh-my-posh, Node, el clon de dotfiles-windows y los enlaces que faltan
- [ ] [PC nueva] `./bootstrap.sh` clona dotfiles-windows en `~/dotfiles-windows` y Claude Code arranca con la capa enlazada

## Lista de paquetes en 60-apps

**Plataforma:** Instalación.

- [ ] [PC nueva] `./bootstrap.sh --dry-run` lista los paquetes de `60-apps/apt.txt` que faltan

## Recarga de polybar por IPC

**Plataforma:** Escritorio.

- [ ] [Esta PC] Cerrar sesión y volver a entrar en bspwm: aparecen las 7 barras una sola vez
- [ ] [Esta PC] Después, `Super+Alt+R` recarga las barras sin duplicarlas y sin el aviso «bars without IPC did not close»
- [ ] [Esta PC] `ls /run/user/$(id -u)/polybar/` muestra un socket por barra

## CI con tests de instalación y Dependabot

**Plataforma:** Repositorio.

- [ ] Tras el push, el CI de GitHub pasa en verde, con los pasos en inglés y las líneas «panel/check» y «test-install» en `✓`
- [ ] Al mes del push, Dependabot abre un único PR `chore(ci)` con las acciones que tengan versión nueva (o ninguno si están al día)

## Cabecera del README con los logos de Parrot

**Plataforma:** Repositorio.

- [ ] Tras el push, ver `README.md` en GitHub con tema claro: logo con texto oscuro, descripción, enlaces y badges centrados
- [ ] Tras el push, ver `README.md` en GitHub con tema oscuro: logo con texto blanco
- [ ] Tras el push, lo mismo en `README.es.md` con los dos temas, y que cada enlace de la fila lleva a su sección en español

## Configuración de git versionada

**Plataforma:** Shell.

- [ ] [Esta PC] `git -C ~/dotfiles log -1 --format='%G? %an'` muestra `G M1gu3l4ngel` en el próximo commit
- [ ] [PC nueva] Tras `./bootstrap.sh` y crear la clave GPG, `git config --file ~/.gitconfig.local user.signingkey <fingerprint>` basta para que los commits salgan firmados

## Carpetas numeradas por capa

**Plataforma:** Escritorio, Shell.

- [ ] [Esta PC] Tras `exec zsh`, el prompt de oh-my-posh sale igual que antes
- [ ] [Esta PC] `Super+Alt+R` recarga bspwm y polybar sin errores, con los módulos y colores de siempre
- [ ] [Esta PC] kitty (`Ctrl+Shift+F5`), rofi, dunst (`notify-send "Prueba" "Texto"`), Neovim y VSCodium abren con su configuración
- [ ] [Esta PC] Caps Lock se apaga al pulsarlo (keymap `capsfix` desde `25-desktop/xkb`)
- [ ] [PC nueva] En un clon anterior a este cambio, tras `git pull` el hook `post-merge` rehace los enlaces sin copias de seguridad, y `./install.sh --check` sale en verde

## Copia claude/ quitada y check de docs compartido

**Plataforma:** Repositorio.

- [ ] Tras el push, el CI pasa con el paso «Descargar la capa de Claude Code (dotfiles-windows)» y «Documentación bilingüe» en verde (no «omitida»)

## Versiones fijadas de pnpm y Claude Code, y gh

**Plataforma:** Instalación.

- [ ] [Esta PC] `./bootstrap.sh` desde `~/dotfiles`, como usuario normal (pide sudo una vez), instala solo `gh` y termina sin errores; `gh --version` responde
- [ ] [PC nueva] Tras `./bootstrap.sh`, `pnpm --version` dice `12.8.1` y `claude --version` dice `2.1.332` o una posterior (Claude Code se actualiza solo)

## Finales de línea en LF en cualquier clon

**Plataforma:** Repositorio.

- [ ] En el clon de Windows (`~\dotfiles-parrot`), tras `git pull`, `git ls-files --eol` muestra `w/lf` en los scripts (puede hacer falta `git checkout -- .` una vez, sin cambios pendientes)
- [ ] Tras el push, el CI pasa con el paso «LF line endings» en verde

# Fase 2 — Instalador sin pérdidas

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

# Fase 4 — Carpetas numeradas por capa

## Paquetes opcionales en bootstrap.sh

**Plataforma:** Instalación.
**Prioridad:** Mejora.
**Requiere:** nada.

Windows separa `60-apps/essential.json` y `optional.json`; aquí todo está en `60-apps/apt.txt`.

- [ ] Separar lo esencial de lo opcional (pentesting) en dos listas si `bootstrap.sh` gana una opción para omitir lo opcional



# Fase 7 — Documentación

## Guía de firma GPG y SSH

**Plataforma:** Repositorio.
**Prioridad:** P2.
**Requiere:** «Configuración de git versionada».

- [ ] `docs/keys-and-secrets` con la estructura de `docs/gpg-signing` de Windows: email noreply, clave nueva o UID añadido, `~/.gitconfig.local`, subir la clave filtrando UIDs, verificar «Verified», caché del agente y backup
- [ ] Importar la clave pública de Windows para que `git log --show-signature` verifique los commits hechos allí (hoy `8b1869f` sale `E`)


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
**Requiere:** nada.

- [ ] Seguir `docs/getting-started` en un Parrot recién instalado y anotar cada paso que falte o falle
- [ ] Publicar la versión en `CHANGELOG` con su etiqueta firmada (`git tag -s`)

---

# Lo hace el dueño

- [ ] Crear en GitHub el ruleset de `main` sin borrado ni push forzado (`deletion` y `non_fast_forward`, como `protect-main.json` de dotfiles-windows): hoy el repo no tiene ninguno
- [ ] Corregir los topics de GitHub `neovi` → `neovim` y `ric` → `ricing`

# Aplazado — cada uno con el evento que lo dispara

- [ ] Estado de `settarget` y del anonimato en `~/.local/state` en vez de `~/.config/bin` (4 scripts, `.zshrc`, `install.sh` y `.gitignore` juntos) — al tocar los scripts de polybar
- [ ] Medir el arranque de zsh (`zmodload zsh/zprof`) y pasar de nvm a fnm como Windows si nvm es lo lento — cuando se note la espera al abrir kitty
