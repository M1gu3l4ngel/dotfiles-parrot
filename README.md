# dotfiles-parrot

Entorno de trabajo para pentesting sobre Parrot OS: bspwm, polybar, kitty, zsh
y Neovim, con hardening del sistema e instalación en un comando.

![Escritorio](assets/preview.png)

## Reproducir en un comando

¿Empiezas desde cero, sin VM? Sigue [docs/primeros-pasos.md](docs/primeros-pasos.md):
crear la VM, instalar Parrot, el entorno, comprobarlo y la snapshot.

En un Parrot OS 7 recién instalado, como usuario normal (pedirá la contraseña
de sudo una vez):

```bash
git clone https://github.com/M1gu3l4ngel/dotfiles-parrot.git ~/dotfiles
```

```bash
cd ~/dotfiles
```

```bash
./bootstrap.sh
```

Después, reinicia y en la pantalla de login elige la sesión `bspwm`.

## Requisitos previos

- Parrot OS 7 (basado en Debian 13). `anonsurf` solo existe en Parrot.
- Usuario con permisos de sudo y conexión a internet.
- Sesión X11: bspwm no funciona en Wayland.
- En VMware: "Accelerate 3D graphics" activado y 2 GB o más de memoria de
  vídeo. Ver [docs/vmware.md](docs/vmware.md).

## Qué hace bootstrap.sh

Cada paso comprueba si ya está hecho, así que se puede ejecutar varias veces
sin efectos colaterales (por ejemplo, tras un fallo de red).

| Paso | Qué instala o configura |
|---|---|
| 1 | Paquetes de apt: entorno gráfico, herramientas de terminal, seguridad, openvpn |
| 2 | Fuentes Nerd Fonts (CaskaydiaCove y Hack) en `~/.local/share/fonts/` |
| 3 | Neovim oficial en `/opt`, enlazado en `/usr/local/bin/nvim` |
| 4 | oh-my-posh (prompt) en `~/.local/bin/` |
| 5 | nvm, Node 24, pnpm y Claude Code |
| 6 | Enlaces de las configuraciones en `~/.config/` (`install.sh`) |
| 7 | Hardening del sistema (`system/setup.sh`): firewall, sudoers, parches automáticos, pantalla de login |
| 8 | zsh como shell por defecto |
| 9 | Muestra los pasos manuales pendientes |

Todo lo que no viene de apt se descarga en una versión fijada y se verifica
con SHA-256 antes de instalarse.

## Pasos manuales tras la instalación

Implican secretos, así que no se automatizan:

1. Claves SSH y GPG, firma de commits y `pass`:
   [docs/claves-y-secretos.md](docs/claves-y-secretos.md).
2. Perfil de Firefox para pentesting: [docs/firefox.md](docs/firefox.md).

## Instalar sobre una configuración existente

Si ya tienes el entorno instalado y solo quieres estas configuraciones, desde
`~/dotfiles`:

```bash
./install.sh
```

Antes de crear cada enlace, `install.sh` renombra lo que haya en el destino
(archivo, carpeta o enlace propio) con el sufijo `.pre-dotfiles.bak`. Para volver atrás, ver [Desinstalar](#desinstalar).

## Desinstalar

`uninstall.sh` revierte `install.sh`: quita los enlaces que apuntan a este
repo y devuelve a su sitio las copias `.pre-dotfiles.bak` de tus archivos
originales. Como usuario normal, desde `~/dotfiles`:

1. Ver qué haría, sin tocar nada:

    ```bash
    ./uninstall.sh --dry-run
    ```

2. Aplicarlo:

    ```bash
    ./uninstall.sh
    ```

3. Cerrar sesión y volver a entrar para usar la configuración original.

Solo quita enlaces de este repo: si en un destino hay un archivo tuyo, lo deja
y avisa. No desinstala paquetes ni revierte el hardening de `system/setup.sh`,
ni los ajustes que `install.sh` aplica sin enlaces (modo oscuro de GTK4,
Nautilus como gestor de carpetas e indexador desactivado). Las copias con
fecha (`.pre-dotfiles.bak.<fecha>`), de reinstalaciones, no se restauran: el
script las lista para que elijas a mano.

La lista de enlaces vive en `lib/links.sh` y la comparten los dos scripts:
para añadir una configuración nueva basta con sumar una línea allí.

## Estructura del repo

| Directorio | Contenido | Se instala en |
|---|---|---|
| `bspwm/` | Gestor de ventanas y script de redimensionado | `~/.config/bspwm/` |
| `sxhkd/` | Atajos de teclado | `~/.config/sxhkd/` |
| `polybar/` | Barras, paleta de colores y lanzador | `~/.config/polybar/` |
| `picom/` | Compositor (esquinas, transparencias) | `~/.config/picom/` |
| `rofi/` | Lanzador de aplicaciones y temas | `~/.config/rofi/` |
| `kitty/` | Terminal | `~/.config/kitty/` |
| `dunst/` | Notificaciones | `~/.config/dunst/` |
| `gtk/` | Colores y ajustes del gestor de archivos (GTK4) | `~/.config/gtk-4.0/` |
| `vscodium/` | Ajustes del editor VSCodium | `~/.config/Visual Studio Code/User/` |
| `xkb/` | Distribución de teclado (us y latam) | `~/.config/xkb/` |
| `zsh/` | Shell | `~/.zshrc` |
| `nvim/` | Neovim (NvChad) | `~/.config/nvim/` |
| `gnupg/` | Configuración del agente GPG | `~/.gnupg/gpg-agent.conf` |
| `oh-my-posh/` | Tema del prompt | Se lee desde el repo |
| `claude/` | Capa global de Claude Code ([claude/README.md](claude/README.md)) | `~/.claude/` (y `settings.json` desde la plantilla) |
| `scripts/` | Módulos de polybar, target y anonimato | `~/.config/scripts/` |
| `system/` | Hardening, sudoers, Firefox, apt | `/etc`, `/usr/local/sbin` (copias) |
| `assets/` | Captura del escritorio y fondo por defecto | `~/.config/wallpaper.jpg` (el fondo) |
| `docs/` | Guías detalladas | No se instala |
| `lib/` | Lista de enlaces compartida por `install.sh` y `uninstall.sh` | No se instala |
| `tools/` | Comprobaciones del repo (`check.sh`) | No se instala |

## Atajos

### Sistema y aplicaciones

| Atajo | Acción |
|---|---|
| `Super+Enter` | Terminal (kitty) |
| `Super+D` | Lanzador de aplicaciones (rofi) |
| `Super+E` | Gestor de archivos (Nautilus); también con click en el logo de Parrot |
| `Super+Shift+F` | Firefox personal |
| `Super+Shift+P` | Firefox pentest |
| `Super+A` | Activar o desactivar el anonimato con Tor |
| `Super+Shift+X` | Bloquear la pantalla |
| `Super+Escape` | Recargar los atajos |
| `Super+Alt+R` | Recargar bspwm (y polybar) |
| `Super+Alt+Q` | Cerrar la sesión |
| Botón de apagado (polybar, esquina derecha) | Menú: apagar, reiniciar o cerrar sesión de forma ordenada |
| `Alt+Shift` | Cambiar la distribución de teclado (us / latam) |

### Ventanas

| Atajo | Acción |
|---|---|
| `Super+Q` | Cerrar la ventana |
| `Super+Shift+Q` | Forzar el cierre de la ventana |
| `Super+Flechas` | Mover el foco |
| `Super+Shift+Flechas` | Intercambiar con la ventana vecina |
| `Super+Alt+Flechas` | Redimensionar |
| `Super+Ctrl+Flechas` | Mover una ventana flotante |
| `Super+T` / `Super+S` / `Super+F` | Modo mosaico / flotante / pantalla completa |
| `Super+M` | Alternar entre mosaico y una sola ventana |
| `Super+G` | Intercambiar con la ventana más grande |

### Escritorios

| Atajo | Acción |
|---|---|
| `Super+1` ... `Super+0` | Ir al escritorio 1 a 10 |
| `Super+Shift+1` ... `Super+Shift+0` | Enviar la ventana a ese escritorio |
| `Super+[` / `Super+]` | Escritorio anterior / siguiente |
| `Super+Tab` | Último escritorio visitado |

### Terminal (kitty y zsh)

| Atajo | Acción |
|---|---|
| `Ctrl+Shift+Enter` | Nueva ventana de kitty en el mismo directorio |
| `Ctrl+Shift+T` | Nueva pestaña en el mismo directorio |
| `Ctrl+Tab` | Cambiar de pestaña |
| `Ctrl+Flechas` | Mover el foco entre ventanas de kitty |
| `Ctrl+Shift+V` | Pegar |
| `Shift+Flechas` / `Ctrl+Shift+Flechas` | Seleccionar texto por carácter / por palabra |
| `Ctrl+U` | Borrar la línea |
| `Ctrl+R` / `Ctrl+T` | Buscar en el historial / buscar archivos (fzf) |
| `Esc` `Esc` | Añadir o quitar `sudo` al comando |

Para el flujo de pentesting (VPN, target, qué IP usar) ver
[docs/pentesting.md](docs/pentesting.md).

## Solución de problemas

| Síntoma | Causa | Solución |
|---|---|---|
| Pantalla negra o bspwm no arranca al iniciar sesión | Sesión Wayland | Elegir la sesión `bspwm` en el login |
| El escritorio va lento al cambiar de workspace | VM sin aceleración 3D | Activarla en VMware ([docs/vmware.md](docs/vmware.md)) |
| `glxinfo` dice `Accelerated: no` | Falso positivo del driver de VMware | Mirar el renderer: `SVGA3D` es correcto |
| Iconos como cuadrados | Faltan las fuentes Nerd Font | Volver a ejecutar `./bootstrap.sh` |
| Un cambio en `.zshrc` no se aplica | Cada terminal conserva lo que cargó al abrirse | `exec zsh` en esa terminal |
| keychain pide la passphrase en cada terminal | La clave SSH no se llama `id_ed25519` | Ajustar el nombre en la línea de keychain de `zsh/.zshrc` |
| El anonimato falla con "Tor no arrancó" | Falta la regla sudoers | `sudo ./system/setup.sh` desde `~/dotfiles` |
| Las notificaciones salen arriba y en azul | dunst arrancó antes de existir su configuración | `dunstctl reload` |
| polybar consume mucha CPU | Un módulo con `interval = 0` | Usar un intervalo mayor que 0 |

Para restaurar la configuración anterior a los dotfiles, ver
[Desinstalar](#desinstalar).

## Documentación

Guías detalladas en [docs/](docs/README.md): pentesting, anonimato, Firefox,
claves y secretos, VMware y personalización.

Para contribuir o modificar el repo: [CONTRIBUTING.md](CONTRIBUTING.md).

## Créditos y licencia

El prompt y la paleta de colores son compartidos con
[dotfiles-windows](https://github.com/M1gu3l4ngel/dotfiles-windows).

Licencia [MIT](LICENSE).
