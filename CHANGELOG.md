# Changelog

Cambios relevantes del proyecto. El formato sigue
[Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) y las versiones
siguen [versionado semántico](https://semver.org/lang/es/).

## [Sin publicar]

### Añadido

- README bilingüe: `README.md` en inglés (portada de GitHub) y
  `README.es.md` en español, con selector de idioma. `tools/check.sh`
  verifica que tengan la misma estructura y los mismos comandos.
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
- `bootstrap.sh` instala VSCodium y sus 26 extensiones desde Open VSX
  (`vscodium/extensions.txt`), solo las que falten.

### Cambiado

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

- Hook de Claude Code: bloqueaba `$(cmd 2>/dev/null)` porque tomaba el `)`
  como parte del destino de la redirección.
- El toggle de anonimato decidía el estado por si había un proceso `tor`:
  con el Tor que Parrot deja corriendo al arrancar, creía que el anonimato
  estaba activo y fallaba al desactivarlo. Ahora usa el estado de AnonSurf
  (`anonsurfd`).

### Eliminado

- Iosevka: ya no la usa ninguna configuración y `bootstrap.sh` no la descarga.
- i3lock-fancy e imagemagick: sustituidos por `dm-tool lock`.

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

[Sin publicar]: https://github.com/M1gu3l4ngel/dotfiles-parrot/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/M1gu3l4ngel/dotfiles-parrot/releases/tag/v1.0.0
