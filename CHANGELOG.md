# Changelog

Cambios relevantes del proyecto. El formato sigue
[Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) y las versiones
siguen [versionado semántico](https://semver.org/lang/es/).

## [Sin publicar]

Reinstalación completa y profesionalización del repo. Se publicará como 2.0.0.

### Cambios incompatibles

- `Super+Shift+R` y `Super+Shift+Q` (recargar y salir de bspwm) pasan a
  `Super+Alt+R` y `Super+Alt+Q`: `Super+Shift+Q` ya cerraba ventanas.
- Mover una ventana flotante pasa de `Super+Shift+Flechas` a
  `Super+Ctrl+Flechas`; `Super+Shift+Flechas` intercambia ventanas.
- Se elimina el menú de energía de polybar y sus scripts (no se mostraba en
  ninguna barra).
- Las fuentes dejan de estar en el repo: las instala `bootstrap.sh`.
- La regla sudoers del anonimato ya no autoriza `iptables` directamente.

### Añadido

- `bootstrap.sh`: instalación completa en un comando, idempotente, con
  descargas en versión fijada y verificadas por SHA-256.
- CI en GitHub Actions y `tools/check.sh`: sintaxis, shellcheck, Lua, JSON,
  sudoers, XKB, higiene del repo público y gitleaks en todo el historial.
- Keymap XKB versionado: Caps Lock se apaga al pulsar, no al soltar.
- Selección de texto con `Shift+Flechas` en zsh.
- LSP de Lua y bash, shfmt y shellcheck en Neovim.
- Configuración del agente GPG (pinentry de terminal) y firma de commits.
- Carpeta compartida con el host en VMware.
- `settarget` valida la IPv4 antes de escribirla.
- Guías en `docs/`: pentesting, anonimato, Firefox, claves y secretos, VMware
  y personalización.
- Reglas modulares para Claude Code en `.claude/rules/`.

### Cambiado

- picom usa el backend `glx` (composición en la GPU).
- Notificaciones abajo a la derecha, con la paleta Monokai Soda.
- `user.js` del perfil pentest actualizado para Firefox ESR 140: sin fugas de
  targets a terceros y sin tráfico no solicitado.
- unattended-upgrades aplica también los parches de seguridad del kernel y de
  Tor.
- kitty se lanza desde el paquete de apt (`/usr/bin/kitty`).
- README reescrito: instalación en un comando y guías en `docs/`.

### Corregido

- polybar consumía un 30 % de CPU constante por un módulo con `interval = 0`.
- `polybar/launch.sh` no esperaba a que se cerraran las barras anteriores.
- `Super+Alt+R` escribía caracteres en la terminal (no estaba asignado).
- Atajos duplicados en sxhkd.
- dunst no se enlazaba y usaba la configuración por defecto.
- Las esquinas de las notificaciones se cortaban por el redondeo de picom.
- `cat` fallaba: en Debian el binario de bat se llama `batcat`.
- Iconos de los scripts perdidos al editarlos; ahora se escriben como escapes.
- rofi usaba una fuente no instalada.

### Seguridad

- La regla sudoers permitía obtener root sin contraseña con
  `iptables --modprobe`. Ahora solo autoriza comandos exactos.
- `system/setup.sh` valida la regla sudoers antes de instalarla.
- Se repara `/etc/profile` cuando su `PATH` incluye el directorio actual.
- Se saca al usuario del grupo `docker` (equivale a root) si Docker no está
  instalado.
- Se eliminan las fuentes Helvetica, cuya licencia no permite redistribuirlas.
- Los commits se firman con GPG y usan el email noreply de GitHub.

## [1.0.0] - 2026-05-22

Primera versión publicada.

### Añadido

- Configuración de bspwm, sxhkd, polybar, picom, rofi, kitty, dunst y zsh con
  la paleta Monokai Soda, y Neovim con NvChad.
- Prompt oh-my-posh con el tema capr4n, compartido con dotfiles-windows.
- `install.sh`: enlaces de configuración con copia de seguridad de lo existente.
- Target activo en polybar con `settarget` y `cleartarget`.
- Anonimato con Tor (`Super+A`) con kill switch de IPv6 e ICMP.
- `system/setup.sh`: sudoers, firewall ufw y unattended-upgrades.
- Perfiles de Firefox personal y pentest.
- keychain para el agente SSH y exclusión de secretos del historial de zsh.

[Sin publicar]: https://github.com/M1gu3l4ngel/dotfiles-parrot/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/M1gu3l4ngel/dotfiles-parrot/releases/tag/v1.0.0
