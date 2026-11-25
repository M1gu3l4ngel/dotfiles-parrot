[English](CHANGELOG.md) | **Español**

# Changelog

Cambios relevantes del proyecto. El formato sigue
[Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) y las versiones
siguen [versionado semántico](https://semver.org/lang/es/).

## [Sin publicar]

### Añadido

- `SECURITY` y `CODE_OF_CONDUCT` en inglés y español, una plantilla de pull
  request y formularios de issues para errores y mejoras, sin issues en blanco
  y con un enlace al reporte privado de vulnerabilidades.

### Cambiado

- El README sigue el estándar de documentación compartido con dotfiles-windows:
  Estructura, Cómo funciona, Cómo empezar, Uso, Solución de problemas,
  Documentación, Contribuir, Seguridad y Licencia, con los enlaces de la
  cabecera con esos mismos nombres. `CONTRIBUTING` usa las secciones estándar.
- La identidad de git sale del repo público: `15-git/gitconfig` guarda solo lo
  que puede ser público, y `bootstrap.sh` escribe el nombre y el email en
  `~/.gitconfig.local` desde `--git-name` y `--git-email` (por defecto, los del
  dueño) si la máquina no tiene. Un fork hace commits con su propio nombre, e
  `install.sh --check` avisa si falta la identidad.
- `tools/check.sh` falla si falta un archivo que lleva un repo público
  (`check-docs --community public`), y el CI descarga el commit de
  dotfiles-windows que lo añade.

- El toggle de anonimato pregunta en rofi antes de que anonsurf cierre un
  navegador o cliente abierto, comprueba la salida por Tor durante hasta un
  minuto en vez de una sola vez y hace un solo cambio a la vez. El fantasma se
  pone naranja mientras Tor conecta.
- `anon-harden down` devuelve las políticas de IPv6 que había antes de `up`
  en vez de forzar `ACCEPT`.
- El target de `settarget` y el modo `demo` viven en `~/.local/state/dotfiles`
  en vez de `~/.config/bin`: son estado, no configuración. `install.sh` mueve
  un target existente y borra el `anon_state` que ya no se usa.
- `docs/anonymity` explica lo que no protege: navegar sin Tor Browser, Tor en
  la misma máquina (Whonix como alternativa) y la MAC tras el NAT de VMware.

### Corregido

- El fantasma de polybar leía un archivo de estado que sobrevivía a un
  reinicio o a un `sudo anonsurf stop` manual, así que podía quedarse verde sin
  anonimato. Ahora lee de systemd el estado de `anonsurfd`.

## [2.0.0] - 2026-11-25

Los componentes pasan a carpetas numeradas, así que las rutas de un clon de la
1.0.0 cambian: tras `git pull`, ejecuta `./install.sh` una vez para volver a
enlazarlas.

### Añadido

- Cabecera del README con el logo de Dotfiles Parrot (tema claro y oscuro),
  enlaces a las secciones y badges, con la misma receta que dotfiles-windows.
- `tools/test-install.sh`: ejecuta `install.sh` y `uninstall.sh` con un
  `HOME` temporal (estados de enlace, copias de seguridad, restauración tras un
  `ln` fallido, clave de firma, idempotencia). `tools/check.sh` lo ejecuta, y
  también el check de formato del panel de tareas.
- `.github/dependabot.yml`: un único pull request mensual y agrupado para las
  acciones del CI, con 7 días de espera, como en dotfiles-windows.
- `install.sh --dry-run` muestra qué enlazaría, respaldaría o cambiaría sin
  tocar nada; `install.sh --check` informa del estado de cada enlace y de
  `~/.claude/settings.json` y sale con 1 si algo está mal.
- `15-git/gitconfig`, enlazado como `~/.gitconfig`: identidad y firma
  compartidas con Windows. `install.sh` pasa la clave de firma que ya hubiera
  a `~/.gitconfig.local` antes de enlazar.
- `githooks/post-merge`: cada `git pull` con cambios vuelve a ejecutar `install.sh`.
- `bootstrap.sh --dry-run`, un paso que clona dotfiles-windows, `gh` desde apt,
  y pnpm y Claude Code en versiones fijadas.
- `.gitattributes` mantiene los finales de línea LF en cualquier clon, y
  `tools/check.sh` falla si hay CRLF.
- Documentación completa en inglés y español: cada documento `X.md` (inglés,
  el que muestra GitHub) tiene su pareja `X.es.md`, con selector de idioma.
  Incluye el README, `CONTRIBUTING`, este changelog, `docs/` y los README de
  `system/` y `claude/`. `tools/check.sh` (`tools/check-docs.py`) falla si
  falta una pareja o si difieren en estructura, enlaces o bloques de código.
- Capa global de Claude Code (`claude/`), la misma que en dotfiles-windows:
  `CLAUDE.md` con las costuras de Linux, barra de estado, hook que impone
  editar con Edit/Write y plantilla de `settings.json` (secretos en
  `deny`/`ask`). `install.sh` la enlaza y crea `settings.json` si falta;
  `tools/check.sh` vigila su presupuesto de líneas.
- `uninstall.sh`: quita los enlaces del repo y restaura las copias
  `.pre-dotfiles.bak`; `--dry-run` muestra qué haría sin tocar nada. La lista
  de enlaces pasa a `lib/links.sh`, compartida con `install.sh`.
- polybar: botón de apagado, solo en la esquina derecha. Abre un menú de
  rofi (apagar, reiniciar, cerrar sesión) que usa `systemctl`, para no apagar
  la VM de golpe (un corte así dejó objetos de git vacíos).
- Gestor de archivos Nautilus con la paleta Monokai Soda (`gtk/`): se abre
  con `Super+E` o con click en el logo de Parrot. Indexador de archivos
  desactivado, sin animaciones y con `VMShare` en la barra lateral.
- Ajustes de VSCodium versionados (`vscodium/`): código con Monokai,
  interfaz con la paleta del sistema, sin telemetría y con la confianza del
  espacio de trabajo activa.
- `bootstrap.sh` instala VSCodium y sus 28 extensiones desde Open VSX
  (`vscodium/extensions.txt`), solo las que falten.
- Estilo de formato global (`format/`): `~/.prettierrc.json` y
  `~/.editorconfig` para los proyectos sin configuración propia
  (tabuladores, comillas dobles, 100 columnas). Un proyecto con la suya nunca
  usa la global. El repo tiene su propio `.prettierrc.json` y `.prettierignore`.
- Modo demo para capturas y vídeos: `demo on` hace que polybar (Ethernet,
  VPN, target) y el prompt de todas las terminales abiertas muestren datos
  falsos; `demo off` vuelve a los reales.
- Prompt con `POSH_NAME`, igual que en Windows: muestra ese nombre en lugar
  del usuario, también en el título de la ventana.
- Hook global `block-forbidden-commands` de Claude Code, el mismo que en
  dotfiles-windows: deniega el git de escritura y `prettier --write` con un
  glob, y pide confirmación antes de un borrado recursivo fuera de temporales.
- El resto de la capa de Claude Code de dotfiles-windows: el hook
  `reply-in-spanish` (bloquea una respuesta escrita en inglés), la plantilla
  del artefacto de tareas, límites de salida en la plantilla de
  `settings.json` y reglas nuevas en `CLAUDE.md` (contexto y delegación,
  hallazgos, artefacto de tareas, nombres).
- VSCodium formatea el shell con shfmt y el SQL con SQLTools, y lee
  `.editorconfig` (extensión EditorConfig).
- Un README en pareja en cada carpeta numerada: qué es cada archivo, dónde se
  enlaza, cómo se recarga y qué no tocar. El README raíz los enlaza y añade un
  diagrama del montaje, una tabla de recargas y cómo mantener otra PC al día.
- `bootstrap.sh` se detiene antes de cambiar nada en una arquitectura distinta
  de x86_64, porque Neovim y oh-my-posh están fijados a builds de x86_64.

### Cambiado

- Los comentarios del código, la salida de los scripts, los nombres de los
  pasos del CI y de los tests y los mensajes de commit pasan a inglés, según
  la nueva `docs/contributing/comments.es.md`; el texto que muestra el
  escritorio sigue en español. `.claude/comments.json` dice al check
  compartido qué archivos no sabe clasificar solo, y `tools/check.sh` falla
  ante un comentario en español. `install.sh --check` etiqueta los enlaces
  como `ok`, `MISSING`, `STALE` y `FOREIGN`.
- `docs/getting-started` empieza con un diagrama de los pasos, ejecuta
  `bootstrap.sh --dry-run` antes de instalar e `install.sh --check` al final,
  y cubre Parrot sin VMware.
- `docs/keys-and-secrets` sigue la guía de firma de Windows (clave nueva o UID
  añadido, subida, verificación, caché, copia de seguridad) y explica cómo
  verificar commits firmados en otra máquina.
- polybar: `launch.sh` cierra las barras por IPC (`polybar-msg cmd quit`,
  `enable-ipc` en cada barra) en vez de con `killall`, y espera como mucho
  5 s: una barra sin IPC que quede de una config anterior lo para con un
  aviso en lugar de duplicar las barras.
- Pasos y comentarios del CI en inglés; el checkout de dotfiles-windows pasa
  al commit cuyo check de docs valida también `href`, `src` y `srcset` de HTML.
- Las configuraciones viven en capas numeradas, como en dotfiles-windows:
  `10-shell`, `15-git`, `20-terminal`, `25-desktop`, `30-editor`, `40-format`,
  `60-apps` y `70-system`. `install.sh` (o el hook `post-merge`) rehace los
  enlaces a las rutas viejas sin copias de seguridad. La lista de apt pasa de
  `bootstrap.sh` a `60-apps/apt.txt`.
- La capa de Claude Code sale de `50-claude/` del clon de dotfiles-windows
  (`links.json`), e `install.sh` fusiona `~/.claude/settings.json` con su
  `install-settings.mjs` en vez de copiar una plantilla.
- `tools/check.sh` revisa la documentación bilingüe con `check-docs.mjs` de
  dotfiles-windows, que el CI descarga en un commit fijado.
- Prompt: el título de la ventana muestra `~` en la carpeta de inicio en
  lugar de su nombre, para que el título de la pestaña no enseñe el usuario
  real. Igual que en dotfiles-windows.
- Estilo global de Prettier: los `*.jsonc` se formatean sin coma final
  (`trailingComma: "none"`), porque varias herramientas no la aceptan en
  JSONC. Igual que en dotfiles-windows.
- Guías de `docs/` con nombres en inglés (`getting-started`,
  `customization`, `anonymity`, `keys-and-secrets`) y ejemplos de código con
  placeholders en inglés (`<your-noreply>`, `<user>`), iguales en los dos
  idiomas.
- Igual que en Windows: kitty a 12 pt (como PowerShell en Windows Terminal),
  atajo `Ctrl+/` del teclado numérico para comentar bloques en VSCodium
  (`vscodium/keybindings.json`) y colores de git del explorador de Monokai
  Night. Código de VSCodium en SemiBold: Linux dibuja el trazo más fino.
- zsh como PowerShell en Windows: texto entre comillas en cian y selección
  con fondo claro. `Ctrl+Shift+←/→` selecciona palabras también en la
  terminal de VSCodium.
- polybar: colores con significado (gris = apagado, color = activo) desde una
  paleta única, `scripts/.config/scripts/palette.sh`.
- polybar: texto en CaskaydiaCove SemiBold de 12 pt, la misma familia que
  kitty, dunst y rofi.
- polybar: barras con anchos ajustados al contenido y 12 px de separación
  entre ellas y con los bordes, alineadas con el `window_gap` de bspwm.
- polybar: workspaces con jerarquía clara (activo `●` naranja, con ventanas
  en color de texto, vacíos atenuados).
- Radios de esquina más discretos: ventanas 10 px (antes 20), barras,
  notificaciones y rofi 8 px.
- Borde de 1 px `#555555` en la ventana con foco y en las barras.
- rofi: tema `monokai-soda` con la paleta del escritorio; `Super+D` abre las
  aplicaciones con icono (`Ctrl+Tab` cambia al modo de ejecutables).
- Bloqueo de pantalla (`Super+Shift+X`) con `dm-tool lock`: la pantalla de
  login de LightDM, instantánea y sin paquetes extra.
- Fondo de pantalla nuevo en 4K (casi negro, degradado suave), compartido por
  el escritorio y la pantalla de login/bloqueo (`system/setup.sh`, paso 9).
- Anonimato con un fantasma como icono (verde activado, gris desactivado),
  ahora junto a los lanzadores de Firefox.

### Corregido

- `install.sh` y `uninstall.sh` daban por suyo cualquier enlace que empezara
  por la ruta del repo (también `~/dotfiles-windows`), no rehacían los enlaces
  a rutas viejas del repo y perdían el original si `ln` fallaba tras el backup.
- Arranque sin errores: `system/setup.sh` (paso 10) desactiva los servicios
  de pentest que Parrot activa sin configuración (`hostapd-wpe`,
  `isc-dhcp-server`, `sslh`, `cpupower-gui`), que fallaban en cada arranque.
- `system/README`: el bloque de verificación llevaba un comentario `#` que
  zsh rechaza al pegarlo (sin `interactivecomments`).
- Hook de Claude Code: bloqueaba `$(cmd 2>/dev/null)` porque tomaba el `)`
  como parte del destino de la redirección.
- El toggle de anonimato decidía el estado por si había un proceso `tor`:
  con el Tor que Parrot deja corriendo al arrancar, creía que el anonimato
  estaba activo y fallaba al desactivarlo. Ahora usa el estado de AnonSurf
  (`anonsurfd`).

### Eliminado

- `claude/` y `tools/check-docs.py`: la copia de la capa de Claude Code y sus
  comprobaciones viven ya solo en dotfiles-windows.
- Iosevka: ya no la usa ninguna configuración y `bootstrap.sh` no la descarga.
- i3lock-fancy e imagemagick: sustituidos por `dm-tool lock`.
- 26 temas de rofi de terceros sin uso, que venían sin su licencia: solo queda
  `monokai-soda`, y los temas propios de rofi en `/usr/share/rofi/themes/` se
  cargan por su nombre.

## [1.0.0] - 2026-09-30

Primera versión publicada.

### Instalación

- `bootstrap.sh`: instalación completa en un comando, idempotente, con
  descargas en versión fijada y verificadas por SHA-256. Solo instala lo que
  falta y muestra una salida breve en español.
- `install.sh`: enlaces de configuración desde cualquier carpeta, con copia de
  seguridad de lo existente (sin sobrescribir copias anteriores).
- `system/setup.sh`: hardening del sistema, idempotente.
- Fuentes Nerd Fonts (Iosevka, Hack, CaskaydiaCove) instaladas por el
  bootstrap; el repo no incluye binarios de fuentes.

### Entorno

- bspwm, sxhkd, polybar, picom (backend `glx`), rofi, kitty, dunst y zsh con
  la paleta Monokai Soda; Neovim con NvChad y LSP de Lua y bash.
- Prompt oh-my-posh con el tema capr4n, compartido con dotfiles-windows.
- zsh arranca en unos 70 ms: nvm se carga al usarlo por primera vez.
- Keymap XKB us/latam con Caps Lock que se apaga al pulsar.
- Selección de texto con `Shift+Flechas` en zsh.
- Barras de Ethernet y VPN que detectan la interfaz solas (incluido WireGuard).

### Pentesting y privacidad

- Target activo en polybar con `settarget` (valida la IPv4) y `cleartarget`.
- Anonimato con Tor (`Super+A`) con kill switch de IPv6 e ICMP y verificación
  de la salida.
- Perfiles de Firefox personal y pentest; el pentest sin fugas de targets a
  terceros ni tráfico no solicitado (Firefox ESR 140).
- Configuración del agente GPG, firma de commits y guía de `pass`.
- Carpeta compartida con el host en VMware.

### Seguridad

- Regla sudoers limitada a comandos exactos (nunca `iptables` directo) y
  validada antes de instalarse.
- Firewall ufw con entrada bloqueada salvo loopback y VPN, en IPv4 e IPv6.
- Parches de seguridad automáticos (kernel y Tor incluidos).
- Reparación de `/etc/profile` si su `PATH` incluye el directorio actual.
- Retirada del grupo `docker` (equivale a root) si Docker no está instalado.

### Calidad

- CI en GitHub Actions y `tools/check.sh`: sintaxis, shellcheck, formato con
  shfmt, Lua, JSON, sudoers, XKB, higiene del repo público y gitleaks en todo
  el historial.
- Documentación en `docs/` y reglas para Claude Code en `.claude/rules/`.

[Sin publicar]: https://github.com/M1gu3l4ngel/dotfiles-parrot/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/M1gu3l4ngel/dotfiles-parrot/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/M1gu3l4ngel/dotfiles-parrot/releases/tag/v1.0.0
