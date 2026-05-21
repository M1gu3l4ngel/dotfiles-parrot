# 🦜 dotfiles

> Setup de **Parrot Security** con bspwm + polybar + kitty + zsh + Neovim.
> Pensado para pentesting (HTB / THM), rice limpio y productividad en VM.
> Prompt unificado con [dotfiles-windows](https://github.com/M1gu3l4ngel/dotfiles-windows) vía oh-my-posh + tema capr4n.

![Preview](assets/preview.png)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![Platform](https://img.shields.io/badge/platform-Parrot%20%7C%20Debian%20%7C%20Ubuntu-blue)
![Shell](https://img.shields.io/badge/shell-zsh-89e051)
![Status](https://img.shields.io/badge/status-mantenido-success)

---

## ✨ Stack

| Componente | Para qué sirve |
|---|---|
| **bspwm** | Tiling window manager (binary space partitioning) |
| **sxhkd** | Daemon de atajos de teclado |
| **polybar** | Barra de estado modular (múltiples mini-barras flotantes) |
| **picom** | Compositor (sombras, transparencia, esquinas redondeadas) |
| **rofi** | Lanzador de aplicaciones y menús (powermenu, drun) |
| **kitty** | Emulador de terminal con soporte GPU |
| **zsh + oh-my-posh (capr4n)** | Shell interactiva + prompt cross-platform con git, exit status, etc. |
| **Neovim + NvChad** | Editor con LSP, autocompletado y formateadores |
| **feh** | Wallpaper |
| **dunst** | Notificaciones de escritorio |
| **keychain** | Reuso del ssh-agent entre sesiones |

---

## 📸 Demo

Lo que verás al iniciar sesión:

- Paleta **Monokai Soda** unificada con [dotfiles-windows](https://github.com/M1gu3l4ngel/dotfiles-windows) (fondo `#1A1A1A`, mismo en kitty, polybar y Windows Terminal).
- Barras flotantes en lugar de una sola barra: workspaces (centro-arriba), VPN status (izquierda), Ethernet IP (izquierda), target de pentest (derecha) y botón de power-menu (esquina derecha).
- Workspaces con indicador visual: dot azul si estás ahí, **amarillo** si tiene ventanas abiertas pero no estás, gris si vacío.
- Esquinas redondeadas, transparencias y sombras a través de picom.
- Prompt oh-my-posh con tema capr4n: indicador de exit status (`✓`/`✗`), rama git con cambios pendientes (`✎`), commits ahead/behind (`↑ N` / `↓ N`).
- Aliases para reemplazar `cat`/`ls` con `bat`/`lsd` (colores e iconos Nerd Font).
- Funciones `settarget` y `cleartarget` integradas con la barra: la IP/nombre del objetivo aparece en polybar mientras estás resolviendo una máquina.

---

## 🔄 Migración rápida (si ya tienes el stack instalado)

¿Tu Parrot ya tiene bspwm, polybar, kitty, zsh, Neovim y los demás componentes funcionando, y solo quieres aplicar **mis configs** encima de las tuyas?

**Salta los Pre-requisitos y arranca directo en el [Paso 1](#paso-1--clonar-el-repo)**. El `install.sh` es seguro para este caso porque:

- Detecta cada archivo de config existente (bspwmrc, sxhkdrc, kitty.conf, .zshrc, etc.)
- Le hace **backup automático** con sufijo `.pre-dotfiles.bak` antes de tocarlo
- Crea un symlink hacia el archivo del repo

Si después algo no te gusta, revertir es renombrar el `.pre-dotfiles.bak` de vuelta a su nombre original. No reinstala paquetes ni toca tus herramientas, solo cambia los archivos de configuración.

---

## 📋 Pre-requisitos

Si vas desde cero (instalación nueva de Parrot o no tienes el stack todavía), sigue estos pasos. **Si ya lo tienes** (caso de migración arriba), salta directo al Paso 1.

### 1. Paquetes del sistema (apt)

```bash
sudo apt update && sudo apt install -y \
  bspwm sxhkd polybar picom rofi kitty zsh feh dunst \
  bat lsd tmux git stow keychain \
  zsh-autosuggestions zsh-syntax-highlighting \
  ufw anonsurf \
  fzf
```

### 2. Neovim (binario oficial, **no** el de apt)

El de apt suele estar desactualizado. Quitamos el viejo e instalamos el oficial:

```bash
sudo apt purge -y neovim
curl -L -o /tmp/nvim-linux-x86_64.tar.gz \
  https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo tar -C /opt -xzf /tmp/nvim-linux-x86_64.tar.gz
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
```

> El `.zshrc` añade `/opt/nvim-linux-x86_64/bin` al PATH automáticamente.

### 3. oh-my-posh + fzf

```bash
# Prompt cross-platform (mismo binario y tema en Windows y Parrot)
curl -s https://ohmyposh.dev/install.sh | bash -s

# Fuzzy finder (Ctrl+R en historial)
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all
```

> oh-my-posh queda en `~/.local/bin/oh-my-posh`. El `.zshrc` lo invoca por path absoluto y solo si el binario existe, así que funciona también para root sin reconfiguración.

### 4. Hack Nerd Font o CaskaydiaCove Nerd Font

El tema capr4n usa iconos Nerd Font. Cualquiera de las dos funciona, pero **CaskaydiaCove** es la usada por dotfiles-windows, así que para mantener match visual recomendado:

```bash
wget -P /tmp \
  https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip
sudo unzip -o /tmp/CascadiaCode.zip -d /usr/local/share/fonts/
sudo fc-cache -fv
```

Las fuentes de polybar (Iosevka, Hurmit, Helvetica, Montserrat) ya están incluidas en `polybar/.config/polybar/fonts/`.

### 5. (Opcional) i3lock-fancy

Para el atajo Super+Shift+X (bloquear pantalla con blur):

```bash
sudo apt install -y i3lock-fancy
```

### 6. (Opcional) Llave SSH

El `.zshrc` incluye una línea condicional que cachea tu llave SSH con `keychain` (solo se ejecuta si la llave existe). Sirve para no escribir la passphrase en cada `git push` o ssh remoto.

¿Para qué se usa la llave SSH?

- **GitHub / GitLab:** clonar repos privados con `git clone git@github.com:...`, hacer push sin pedir credenciales cada vez.
- **Servers remotos:** SSH a VPS, máquinas de laboratorio, etc.

Si **no tienes una llave todavía**, créala con:

```bash
ssh-keygen -t ed25519 -C "tu_email@example.com"
# Se guarda en ~/.ssh/id_ed25519 (privada) y ~/.ssh/id_ed25519.pub (pública).
# La pública es la que pegas en GitHub → Settings → SSH and GPG keys.
```

Si tu llave **se llama distinto** (`id_rsa` por ejemplo), edita la línea de `keychain` en `zsh/.zshrc` con el nombre correcto.

---

## 🚀 Instalación

### Paso 1 — Clonar el repo

```bash
git clone https://github.com/M1gu3l4ngel/dotfiles-parrot.git ~/dotfiles
cd ~/dotfiles
```

### Paso 2 — Ejecutar el instalador

```bash
./install.sh
```

El script:

- Hace **backup automático** de tus configs actuales con sufijo `.pre-dotfiles.bak`.
- Crea symlinks desde `~/.config/` y `~/` hacia los archivos del repo.
- Enlaza el wallpaper por defecto del repo a `~/.config/wallpaper.jpg` **solo si no tienes ya uno** (no pisa wallpapers personales).
- Crea `~/.config/bin/target` vacío para que el módulo de target en polybar no falle la primera vez.
- Es **idempotente**: corre N veces sin romper nada.

### Paso 3 — Configurar firewall y anonimato (opcional pero recomendado)

Si querés el firewall baseline (`ufw`) y la regla `sudoers` para el toggle de anonimato (`Super+A`), corré:

```bash
sudo ./system/setup.sh
```

El script:

- Instala `/etc/sudoers.d/anon_toggle` con permisos 0440, sustituye el placeholder `__USER__` por tu usuario actual, y valida con `visudo -c`.
- Aplica reglas baseline de `ufw`: `default deny incoming`, `default allow outgoing`, `allow in on lo`, `allow in on tun+` (para VPNs HTB/THM).
- Verifica que `IPV6=yes` esté en `/etc/default/ufw` (lo fuerza si no).
- Activa `ufw` con start-on-boot.

Es **idempotente**: correrlo varias veces no rompe nada. Detalles en [`system/README.md`](system/README.md).

### Paso 4 — Cambiar el shell a zsh

```bash
chsh -s $(which zsh)
```

Cierra sesión y vuelve a entrar para que el cambio tenga efecto. La primera vez que abras zsh, oh-my-posh cargará el tema capr4n directamente desde `~/dotfiles/oh-my-posh/capr4n.omp.json` (no requiere wizard ni configuración inicial).

### Paso 5 — Probar dentro de bspwm

Cierra sesión gráfica, elige **bspwm** en el login manager, y vuelve a entrar. Atajos clave para empezar:

- **Super + Enter** → abrir kitty
- **Super + D** → lanzador de apps (rofi)
- **Super + Shift + R** → reiniciar bspwm
- **Super + Escape** → recargar sxhkd (después de editar atajos)

---

## ⌨️ Atajos esenciales

> Lista completa en [`sxhkd/.config/sxhkd/sxhkdrc`](sxhkd/.config/sxhkd/sxhkdrc).

### Apps y sistema

| Atajo | Acción |
|---|---|
| `Super + Enter` | Abrir terminal (kitty) |
| `Super + D` | Lanzador rofi |
| `Super + A` | Toggle anonimato (Tor + anonsurf) |
| `Super + Shift + F` | Firefox personal (profile default-esr, intacto) |
| `Super + Shift + P` | Firefox pentest (profile aislado + user.js hardening) |
| `Super + Shift + X` | Bloquear pantalla (i3lock-fancy) |
| `Super + Escape` | Recargar sxhkd |
| `Super + Shift + R` | Reiniciar bspwm |
| `Super + Shift + Q` | Salir de bspwm (cierra sesión) |

### Manejo de ventanas

| Atajo | Acción |
|---|---|
| `Super + Q` | Cerrar ventana (amable) |
| `Super + Shift + Q` | Matar ventana (forzado) |
| `Super + ←/↓/↑/→` | Mover foco |
| `Super + Shift + ←/↓/↑/→` | Mover ventana flotante |
| `Super + Alt + ←/↓/↑/→` | Redimensionar ventana |
| `Super + T` | Modo tiled |
| `Super + S` | Modo floating |
| `Super + F` | Fullscreen |
| `Super + M` | Alternar monocle / tiled |
| `Super + G` | Intercambiar con la ventana más grande |

### Workspaces

| Atajo | Acción |
|---|---|
| `Super + 1..9, 0` | Saltar al workspace N |
| `Super + Shift + 1..9, 0` | Enviar ventana al workspace N |
| `Super + [` / `Super + ]` | Workspace anterior / siguiente |
| `Super + Tab` | Último workspace visitado |

### Kitty (dentro del terminal)

| Atajo | Acción |
|---|---|
| `Ctrl + Shift + Enter` | Nueva ventana en el mismo directorio |
| `Ctrl + Shift + T` | Nueva pestaña en el mismo directorio |
| `Ctrl + Shift + Z` | Alternar layout (stack) |
| `Ctrl + Shift + F5` | Recargar config de kitty |

---

## 🎯 Workflow de pentesting

El setup tiene integración nativa para tracking del target activo (útil para HTB/THM).

### `settarget` y `cleartarget`

```bash
# Establecer máquina como target activo:
settarget 10.10.11.42 Cerberus

# Limpiar el target:
cleartarget
```

`settarget` escribe la IP + nombre en `~/.config/bin/target`. El script `victim_to_hack.sh` (corriendo cada 2s vía polybar) lee ese archivo y muestra la info en la barra superior derecha:

```
🎯 10.10.11.42 - Cerberus
```

Si no hay target, muestra `🎯 No target`.

### VPN status (HTB / THM)

La barra izquierda muestra el estado de la VPN. Detecta automáticamente la interfaz `tun0` (la que crea OpenVPN):

- **Conectada:** `📡 10.10.14.x`
- **Desconectada:** `📡 Disconnected`

Si tu VPN usa otra interfaz (WireGuard, varios túneles), ajusta el script en `scripts/.config/scripts/vpn_status.sh`.

### Ethernet status

La otra mini-barra de la izquierda muestra la IP de la interfaz Ethernet (por defecto `ens33`, típica en VMs). Para cambiarla, edita `scripts/.config/scripts/ethernet_status.sh`.

### Anonimato (Tor + anonsurf)

`Super + A` activa/desactiva todo el tráfico vía Tor. El script `scripts/.config/scripts/toggle_anonymity.sh` orquesta:

1. `anonsurf start` redirige TCP + DNS a Tor vía iptables.
2. `ip6tables -P OUTPUT DROP` bloquea IPv6 (anonsurf solo cubre IPv4).
3. `iptables OUTPUT -p icmp -j DROP` bloquea ping/traceroute leaks.
4. `curl https://check.torproject.org/api/ip` valida `"IsTor":true` antes de declarar éxito. Si falla, rollback automático completo.

El módulo `anon_status` en polybar cambia entre power-off gris (OFF) y user-secret verde (ON). Click izquierdo también funciona como toggle.

**Pre-requisitos:** correr una vez `sudo ./system/setup.sh` para instalar la regla sudoers que permite al script ejecutar `anonsurf`/`ip6tables`/`iptables` sin password.

**Verificación manual:**

```bash
curl --max-time 15 -s https://check.torproject.org/api/ip
# {"IsTor":true,"IP":"x.x.x.x"} si todo OK
```

### Aislamiento de Firefox (profile pentest)

Para evitar correlación entre tu identidad personal (Gmail, GitHub personal) y trabajo de pentest hay 2 profiles de Firefox separados:

| Profile | Atajo | Polybar | Cuándo usarlo |
|---|---|---|---|
| `default-esr` | `Super + Shift + F` |  zorro rojo | Personal (mail, GitHub, banking, daily) |
| `pentest` | `Super + Shift + P` |  bug verde | Targets, OSINT, links sospechosos, lab |

El profile `pentest` aplica un `user.js` (en `system/firefox/pentest.user.js`) con hardening light:

- WebRTC deshabilitado (previene leak de IP vía JS aún con VPN).
- Telemetría de Mozilla off.
- No guarda passwords ni autofill.
- HTTPS-Only mode.
- Limpia cookies, cache e historial al cerrar Firefox.

`--no-remote` en los lanzadores permite que ambos profiles corran simultáneamente sin que Firefox abra nueva pestaña en la primera instancia.

**Setup inicial (correr una vez):**

```bash
firefox -CreateProfile pentest          # crea el profile vacío
sudo ./system/setup.sh                  # paso 5 copia el user.js al profile
```

Los 2 íconos en la barra `launchers` de polybar (a la izquierda del target) también disparan los profiles vía click.

**Combo full anonimato:** `Super + A` (toggle ON) seguido de `Super + Shift + P` (Firefox pentest) = tráfico vía Tor + profile aislado + hardening. Es el stack más fuerte sin entrar en Tor Browser.

**Para anonimato real (dark web, target nation-state):** Tor Browser, no Firefox normal. El profile pentest no resiste fingerprinting agresivo a propósito (`resistFingerprinting` rompe muchos sitios target).

### Flujo de uso real

`Super+A` no se queda siempre encendido. Tor agrega 3 hops (latencia 500-2000ms), muchos sitios bloquean exit nodes (Cloudflare, bancos, Google), HTB/THM VPN no funciona sobre Tor, y `apt update` se vuelve glacial. Es una herramienta puntual, no un escudo 24/7. (Para "always-on" la arquitectura correcta es Whonix/Tails, no anonsurf en una VM.)

| Lo que vas a hacer | Anonimato | Profile Firefox | VPN |
|---|---|---|---|
| Gmail, GitHub personal, banking, daily browse | OFF | Personal | — |
| Lab HTB / THM (boxes pedagógicas) | OFF | Personal o Pentest | HTB VPN (tun0) |
| OSINT contra una persona/empresa real | **ON** | Pentest | — |
| Engagement real con cliente firmado | OFF | Pentest | VPN del cliente si pidieron IP fija |
| Click sospechoso / phishing / malware sandbox-ish | **ON** | Pentest | — |
| Investigar dark web | **ON** + Tor Browser | (no Firefox normal) | — |
| `apt update`, descargar herramientas | OFF | — | — |

**Regla simple para activar `Super+A`:**

- El target no debe ver tu IP real, **Y**
- No tenés VPN específica del engagement, **Y**
- Lo que vas a hacer no requiere latencia baja o ancho de banda alto.

En todo lo demás: anonimato OFF. El error común es ver Tor como "ON = seguro, OFF = inseguro" — en realidad es "ON = ocultá la IP a costa de velocidad/funcionalidad". Lo elegís en cada momento según el contexto.

---

## 🎨 Personalización rápida

### Cambiar tema de oh-my-posh (prompt)

Edita `~/dotfiles/oh-my-posh/capr4n.omp.json` directamente, o sustituye por otro tema:

```bash
# Listar temas built-in:
ls ~/.cache/oh-my-posh/themes/

# Probar un tema sin tocar el repo:
eval "$(oh-my-posh init zsh --config ~/.cache/oh-my-posh/themes/dracula.omp.json)"

# Cambiar permanentemente:
# Edita ~/dotfiles/zsh/.zshrc y cambia la ruta en la línea del eval de oh-my-posh.
```

### Cambiar wallpaper

```bash
cp /ruta/a/tu/wallpaper.jpg ~/.config/wallpaper.jpg
# Recargar bspwm:
bspc wm -r
```

### Cambiar tema de polybar (dark ↔ light ↔ default)

```bash
# Cambiar a dark:
cp ~/dotfiles/polybar/.config/polybar/colors_dark.ini \
   ~/dotfiles/polybar/.config/polybar/colors.ini
~/.config/polybar/launch.sh

# Cambiar a light:
cp ~/dotfiles/polybar/.config/polybar/colors_light.ini \
   ~/dotfiles/polybar/.config/polybar/colors.ini
~/.config/polybar/launch.sh
```

### Cambiar tema de rofi

Hay 25+ temas en `rofi/.config/rofi/themes/`. Edita `rofi/.config/rofi/config.rasi` y reemplaza el nombre tras `@theme`:

```rasi
@theme "themes/spotlight-dark"   // ejemplo
```

### Cambiar tema de Neovim

```vim
:Telescope themes
" o desde mappings: <leader>th
```

O permanentemente en `nvim/.config/nvim/lua/chadrc.lua`:

```lua
M.base46 = { theme = "monekai" }  -- cambia por: tokyonight, gruvbox, etc.
```

### Cambiar fuente del terminal

Edita `kitty/.config/kitty/kitty.conf`:

```conf
font_family    JetBrains Mono Nerd Font
font_size      14
```

### Añadir un keybind nuevo

Edita `sxhkd/.config/sxhkd/sxhkdrc` siguiendo el formato:

```
super + shift + n
    notify-send "hola"
```

Recarga con `Super + Escape`. No necesitas reiniciar la sesión.

---

## 📂 Estructura del repo

```
dotfiles/
├── bspwm/               → ~/.config/bspwm/  (bspwmrc + scripts/)
├── sxhkd/               → ~/.config/sxhkd/  (sxhkdrc)
├── polybar/             → ~/.config/polybar/
│   ├── current.ini      → bars activos (log, vpn, ethernet, target, launchers, primary)
│   ├── workspace.ini    → bar central de workspaces
│   ├── colors.ini       → paleta activa (Monokai Soda — sobrescribir con colors_dark/light si quieres)
│   ├── launch.sh        → mata y relanza todas las barras
│   ├── scripts/         → launcher, powermenu (no scripts pentest)
│   └── fonts/           → Iosevka, Hurmit, Helvetica, etc.
├── picom/               → ~/.config/picom/
├── rofi/                → ~/.config/rofi/  (config.rasi + themes/)
├── kitty/               → ~/.config/kitty/  (kitty.conf + color.ini)
├── nvim/                → ~/.config/nvim/  (NvChad como base)
├── oh-my-posh/          → ~/dotfiles/oh-my-posh/  (capr4n.omp.json, sincronizado con dotfiles-windows)
├── scripts/             → ~/.config/scripts/
│   ├── ethernet_status.sh         → IP Ethernet (polybar)
│   ├── vpn_status.sh              → estado VPN (polybar)
│   ├── victim_to_hack.sh          → lee target activo (polybar)
│   ├── toggle_anonymity.sh        → toggle Tor + anonsurf (Super+A)
│   ├── anon_module.sh             → estado anon para polybar
│   ├── firefox_personal_module.sh → icono launcher Firefox personal
│   └── firefox_pentest_module.sh  → icono launcher Firefox pentest
├── zsh/.zshrc           → ~/.zshrc
├── assets/              → preview.png + wallpaper.jpg default
├── system/              → configs de /etc + hardening de Firefox
│   ├── README.md
│   ├── setup.sh         → instalador idempotente (sudoers + ufw + Firefox user.js)
│   ├── sudoers.d/
│   │   └── anon_toggle  → template con __USER__ placeholder
│   └── firefox/
│       └── pentest.user.js → hardening para profile Firefox "pentest"
├── install.sh           → instalador idempotente
├── CONTRIBUTING.md      → convenciones del proyecto (guía para PRs)
├── LICENSE              → MIT
└── README.md            → este archivo
```

---

## 🩺 Troubleshooting

### "El prompt no aparece o sale plano"

Verifica que oh-my-posh está instalado y accesible:

```bash
ls -la ~/.local/bin/oh-my-posh
oh-my-posh --version
```

Si no existe, reinstala:

```bash
curl -s https://ohmyposh.dev/install.sh | bash -s
```

### "Los iconos del prompt salen como cuadraditos"

Tu fuente no tiene glyphs Nerd Font. Instala CaskaydiaCove o Hack:

```bash
wget -P /tmp \
  https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip
sudo unzip -o /tmp/CascadiaCode.zip -d /usr/local/share/fonts/
sudo fc-cache -fv
```

Luego configura kitty para usarla en `kitty/.config/kitty/kitty.conf`:

```conf
font_family    CaskaydiaCove Nerd Font
```

### "polybar no muestra los workspaces"

Verifica que `bspwm` esté corriendo (`bspc query -W`) y reinicia polybar:

```bash
~/.config/polybar/launch.sh
```

### "El target no aparece en la barra"

Comprueba que el archivo existe y se está actualizando:

```bash
cat ~/.config/bin/target
settarget 10.10.10.1 TestMachine
cat ~/.config/bin/target   # debe mostrar "10.10.10.1 TestMachine"
```

Si el módulo sigue mostrando "No target", revisa que polybar tiene permisos de lectura (no debería ser un problema en uso normal).

### "VPN status dice Disconnected aunque la VPN está activa"

El script asume que la interfaz se llama `tun0`. Verifica con `ip link`:

```bash
ip link | grep -i 'tun\|wg'
```

Si tu VPN usa otra interfaz (ej. `wg0`, `tun1`), edita `~/.config/scripts/vpn_status.sh` y reemplaza `tun0`.

### "keychain me pide la passphrase en cada terminal"

Verifica que la llave existe:

```bash
ls ~/.ssh/id_ed25519
```

Si tienes otra llave (`id_rsa`, etc.), edita el `.zshrc`:

```bash
[ -f "$HOME/.ssh/id_rsa" ] && eval $(keychain --eval --quiet id_rsa)
```

### "Como root no se ve el tema capr4n"

Por defecto root no tiene oh-my-posh instalado (vive en `~/.local/bin/` del usuario, no del root). El `.zshrc` detecta esto y skipea el init silenciosamente. Para que root también tenga el tema:

```bash
# Symlink al binario del usuario:
sudo mkdir -p /root/.local/bin
sudo ln -sfn /home/$USER/.local/bin/oh-my-posh /root/.local/bin/oh-my-posh

# Symlink al repo de dotfiles:
sudo ln -sfn /home/$USER/dotfiles /root/dotfiles
```

### "El cursor de kitty es una barra, no un underline (o viceversa)"

`kitty.conf` lo establece a `beam` (barra), sobrescribiendo el `Underline` que pone `color.ini`. Si quieres `Underline`, comenta la línea `cursor_shape beam` en `kitty.conf`.

### "Super + Alt + Flechas no redimensiona"

Verifica que el script existe y tiene permisos de ejecución:

```bash
ls -la ~/.config/bspwm/scripts/bspwm_resize
```

Si no aparece, vuelve a correr `./install.sh` (es un symlink al repo).

### "Me equivoqué editando un archivo y no enciende bspwm"

Tu config previa está respaldada con sufijo `.pre-dotfiles.bak`:

```bash
ls -la ~/.config/bspwm/*.bak ~/.zshrc.pre-dotfiles.bak 2>/dev/null
```

Renombra el `.bak` al nombre original si quieres restaurar.

---

## 📐 Convenciones del proyecto

Si vas a contribuir, adaptar el repo o abrir un PR, las reglas de estilo, formato de commits y archivos protegidos están documentadas en [`CONTRIBUTING.md`](CONTRIBUTING.md). El `.editorconfig` de la raíz hace además que tu editor respete la indentación correcta automáticamente.

---

## 🙏 Créditos

Setup originalmente basado en el curso de personalización de Linux de **[S4vitar](https://github.com/s4vitar)**. Las configuraciones de **bspwm**, **sxhkd**, **polybar** y **picom** parten de su estilo y enfoque pedagógico.

El prompt y la paleta visual (Monokai Soda + tema capr4n) están alineados con mi setup paralelo de Windows en [dotfiles-windows](https://github.com/M1gu3l4ngel/dotfiles-windows) — mismo prompt cross-platform usando oh-my-posh.

Adaptado y mantenido por **[M1gu3l4ng3l](https://github.com/M1gu3l4ngel)** para flujo personal de pentesting.

---

## 📜 Licencia

[MIT](LICENSE) — usa, copia, modifica libremente. Si te resulta útil, una ⭐ siempre se agradece.

---

Hecho con 🦜 por **[M1gu3l4ng3l](https://github.com/M1gu3l4ngel)**
