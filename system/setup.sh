#!/bin/bash
# system/setup.sh
# Configuración y hardening a nivel sistema (fuera de $HOME) que install.sh no
# puede manejar: requiere root y son copias, no symlinks (un archivo de /etc
# enlazado a un repo del usuario le daría a ese usuario control sobre root).
#
# Idempotente: correr varias veces es seguro. Cada paso comprueba el estado y
# solo aplica lo que falta.
#
# Qué hace:
#   1. Instala /usr/local/sbin/anon-harden (kill switch IPv6/ICMP del toggle)
#   2. Instala /etc/sudoers.d/anon_toggle (NOPASSWD solo para comandos exactos)
#   3. Aplica las reglas baseline de ufw, con IPv6 incluido, y lo activa
#   4. Repara /etc/profile si mete el directorio actual en el PATH
#   5. Saca al usuario del grupo docker si el daemon de Docker no está instalado
#   6. Copia user.js al perfil de Firefox "pentest" si existe
#   7. Instala la config de unattended-upgrades (solo parches de seguridad)
#   8. En VMware: monta la carpeta compartida con el host en /mnt/vmshare
#   9. Pantalla de login/bloqueo (slick-greeter) con el fondo del escritorio
#
# Uso (desde la raíz del repo):
#   sudo ./system/setup.sh

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# ----- 0. COMPROBACIONES PREVIAS -----
if [ "$EUID" -ne 0 ]; then
  echo "ERROR: este script requiere root. Ejecutar con: sudo $0"
  exit 1
fi

# El usuario de la regla sudoers sale de SUDO_USER. Ejecutado como root
# directo no hay forma fiable de saber para quién es: fallar explícito.
if [ -z "${SUDO_USER:-}" ]; then
  echo "ERROR: ejecutar con 'sudo ./system/setup.sh', no como root directo."
  echo "       Hace falta \$SUDO_USER para escribir la regla sudoers."
  exit 1
fi
TARGET_USER="$SUDO_USER"
TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)

for bin in ufw anonsurf visudo install; do
  if ! command -v "$bin" >/dev/null; then
    echo "ERROR: '$bin' no está instalado. Instálalo primero (apt install $bin)."
    exit 1
  fi
done

# Archivo temporal para validar sudoers antes de instalarlo; se borra al salir
# pase lo que pase.
TMP_SUDOERS=$(mktemp)
trap 'rm -f "$TMP_SUDOERS"' EXIT

# ----- 1. KILL SWITCH DEL ANONIMATO -----
# root:root 0755: el usuario puede ejecutarlo (vía sudo) pero no modificarlo.
# Si pudiera editarlo, la restricción de la regla sudoers no serviría de nada.
echo "[1/9] Instalando /usr/local/sbin/anon-harden"
install -m 0755 -o root -g root "$REPO_DIR/sbin/anon-harden" /usr/local/sbin/anon-harden

# ----- 2. SUDOERS DEL TOGGLE DE ANONIMATO -----
# El template usa __USER__ para no publicar el nombre de usuario en el repo.
# Se valida con visudo sobre una copia temporal ANTES de instalarla: un
# sudoers con errores de sintaxis en /etc/sudoers.d/ puede dejar sudo
# inutilizable. 0440 es obligatorio (sudo ignora el archivo con otro modo).
echo "[2/9] Instalando /etc/sudoers.d/anon_toggle (usuario: $TARGET_USER)"
sed "s/__USER__/$TARGET_USER/g" "$REPO_DIR/sudoers.d/anon_toggle" >"$TMP_SUDOERS"
if ! visudo -c -q -f "$TMP_SUDOERS"; then
  echo "ERROR: la regla sudoers no es válida; no se ha instalado nada."
  exit 1
fi
install -m 0440 -o root -g root "$TMP_SUDOERS" /etc/sudoers.d/anon_toggle

# ----- 3. FIREWALL (UFW) -----
# deny incoming        -> se descarta cualquier conexión entrante no pedida.
# allow outgoing       -> tráfico saliente libre (anonsurf filtra encima).
# allow in on lo       -> loopback: apps locales que hablan entre sí.
# allow in on tun+     -> VPN (HTB/THM): reverse shells y callbacks en
#                         cualquier puerto. OJO: en labs compartidos otros
#                         usuarios de la VPN también pueden alcanzarte; no
#                         dejes servicios sensibles escuchando mientras estés
#                         conectado.
# IPV6=yes             -> sin esto ufw solo filtra IPv4.
# Cada `ufw allow` es idempotente: si la regla existe no la duplica.
# Su salida normal se descarta: ufw repite avisos como "be sure to update your
# rules accordingly" en cada ejecución aunque no cambie nada. Los errores van
# a stderr, se siguen viendo, y `set -e` detiene el script.
echo "[3/9] Aplicando reglas baseline de ufw"
ufw default deny incoming >/dev/null
ufw default allow outgoing >/dev/null
ufw allow in on lo >/dev/null
ufw allow in on tun+ from any >/dev/null
if ! grep -q "^IPV6=yes" /etc/default/ufw; then
  echo "      IPV6 no estaba en yes, lo aplico"
  sed -i 's/^IPV6=.*/IPV6=yes/' /etc/default/ufw
fi
# --force evita el prompt "may disrupt ssh sessions [y|n]".
ufw --force enable >/dev/null
echo "      Activo: entrada bloqueada salvo loopback y VPN (tun+), IPv4 e IPv6"

# ----- 4. PATH DE /etc/profile -----
# Una entrada vacía en PATH (`::`) equivale al directorio actual: ejecutar
# `ls` dentro de una carpeta con un `ls` malicioso lo lanzaría a él. Se
# restaura la versión del paquete base-files, dejando copia de la actual.
echo "[4/9] Revisando PATH de /etc/profile"
if grep -qE '^PATH=.*(::|=":|:")' /etc/profile; then
  BACKUP="/etc/profile.bak-$(date +%Y%m%d%H%M%S)"
  cp -p /etc/profile "$BACKUP"
  install -m 0644 -o root -g root /usr/share/base-files/profile /etc/profile
  echo "      Tenía una entrada vacía en PATH. Restaurado (copia en $BACKUP)"
else
  echo "      Correcto, sin entradas vacías"
fi

# ----- 5. GRUPO DOCKER -----
# Pertenecer al grupo docker equivale a root (`docker run -v /:/host`). Si el
# daemon no está instalado (p. ej. se usa podman, que no necesita grupo), no
# aporta nada y es un riesgo latente: se quita. Si Docker está instalado solo
# se avisa, para no romper un flujo de trabajo que lo use.
echo "[5/9] Revisando pertenencia al grupo docker"
if id -nG "$TARGET_USER" | tr ' ' '\n' | grep -qx docker; then
  if command -v dockerd >/dev/null; then
    echo "      AVISO: $TARGET_USER está en el grupo docker (equivale a root)."
    echo "      Considera usar 'sudo docker' o podman rootless en su lugar."
  else
    gpasswd -d "$TARGET_USER" docker >/dev/null
    echo "      Quitado del grupo docker (daemon no instalado). Efectivo al"
    echo "      volver a iniciar sesión."
  fi
else
  echo "      Correcto, no pertenece al grupo docker"
fi

# ----- 6. FIREFOX: USER.JS DEL PERFIL PENTEST -----
# Si existe un perfil *.pentest (creado con `firefox -CreateProfile pentest`)
# se le copia el user.js endurecido. Si no existe aún, se indica cómo crearlo;
# no es un error fatal.
echo "[6/9] Firefox: user.js del perfil pentest"
USERJS_SRC="$REPO_DIR/firefox/pentest.user.js"
# Glob en vez de parsear `ls`: soporta rutas con espacios o caracteres raros.
PENTEST_PROFILE=""
for dir in "$TARGET_HOME"/.mozilla/firefox/*.pentest; do
  [ -d "$dir" ] && {
    PENTEST_PROFILE="$dir"
    break
  }
done
if [ -z "$PENTEST_PROFILE" ]; then
  echo "      INFO: no existe el perfil *.pentest todavía."
  echo "      Créalo con: firefox -CreateProfile pentest"
  echo "      Y vuelve a ejecutar: sudo ./system/setup.sh"
else
  install -m 0644 -o "$TARGET_USER" -g "$TARGET_USER" \
    "$USERJS_SRC" "$PENTEST_PROFILE/user.js"
  echo "      Copiado al perfil pentest"
fi

# ----- 7. UNATTENDED-UPGRADES -----
# 52parrot-hardening.conf: qué se auto-instala (solo parrot-security) y qué no.
# 20auto-upgrades: activa la ejecución diaria. Solo se crea si falta, para
# respetar un valor que el usuario haya cambiado a propósito.
echo "[7/9] Configurando unattended-upgrades"
if ! command -v unattended-upgrade >/dev/null; then
  echo "      INFO: 'unattended-upgrades' no está instalado."
  echo "      Instálalo con: sudo apt install unattended-upgrades"
  echo "      Y vuelve a ejecutar: sudo ./system/setup.sh"
else
  install -m 0644 -o root -g root "$REPO_DIR/apt/52parrot-hardening.conf" \
    /etc/apt/apt.conf.d/52parrot-hardening.conf
  if [ ! -f /etc/apt/apt.conf.d/20auto-upgrades ]; then
    install -m 0644 -o root -g root "$REPO_DIR/apt/20auto-upgrades" \
      /etc/apt/apt.conf.d/20auto-upgrades
    echo "      Creado /etc/apt/apt.conf.d/20auto-upgrades"
  fi
  echo "      Activo: parches de seguridad diarios (kernel y Tor incluidos)"
fi

# ----- 8. CARPETA COMPARTIDA CON EL HOST (SOLO VMWARE) -----
# Intercambio rápido de archivos Windows <-> Linux mediante Shared Folders de
# VMware. Requisito en el host: VM Settings -> Options -> Shared Folders ->
# Always enabled -> Add, con una carpeta DEDICADA (p. ej. C:\VMShare) y el
# nombre de SHARE_NAME. Nunca compartir el disco entero: si la VM se
# compromete (malware, targets hostiles), solo alcanza esa carpeta.
# Opciones de montaje:
#   nofail + x-systemd.automount -> se monta al primer acceso; si el share se
#                                   desactiva en VMware el arranque no se cuelga.
#   allow_other + uid/gid        -> el montaje lo hace root, pero los archivos
#                                   son del usuario.
#   umask=077                    -> nadie más que ese usuario puede leerlos.
SHARE_NAME="VMShare"
SHARE_MNT="/mnt/vmshare"
echo "[8/9] Carpeta compartida de VMware"
if [ "$(systemd-detect-virt 2>/dev/null || true)" != "vmware" ]; then
  echo "      No es una VM de VMware; se omite"
elif ! command -v vmhgfs-fuse >/dev/null; then
  echo "      INFO: falta vmhgfs-fuse. Instálalo con: sudo apt install open-vm-tools-desktop"
elif ! vmware-hgfsclient 2>/dev/null | grep -qx "$SHARE_NAME"; then
  echo "      INFO: VMware no comparte ninguna carpeta llamada '$SHARE_NAME'."
  echo "      Configúrala en VM Settings -> Options -> Shared Folders y vuelve a ejecutar."
else
  TARGET_UID=$(id -u "$TARGET_USER")
  TARGET_GID=$(id -g "$TARGET_USER")
  mkdir -p "$SHARE_MNT"
  if ! grep -q "^\.host:/$SHARE_NAME " /etc/fstab; then
    cp -p /etc/fstab "/etc/fstab.bak-$(date +%Y%m%d%H%M%S)"
    echo ".host:/$SHARE_NAME $SHARE_MNT fuse.vmhgfs-fuse nofail,x-systemd.automount,allow_other,uid=$TARGET_UID,gid=$TARGET_GID,umask=077 0 0" >>/etc/fstab
    echo "      Añadido a /etc/fstab (copia de la versión previa en /etc/fstab.bak-*)"
  fi
  systemctl daemon-reload
  systemctl start "$(systemd-escape -p --suffix=automount "$SHARE_MNT")"
  # Acceso directo en el home para no tener que recordar la ruta de montaje.
  sudo -u "$TARGET_USER" ln -sfn "$SHARE_MNT" "$TARGET_HOME/VMShare"
  echo "      Disponible en $SHARE_MNT (acceso directo: ~/VMShare)"
fi

# ----- 9. PANTALLA DE LOGIN Y BLOQUEO (SLICK-GREETER) -----
# Mismo fondo que el escritorio (ver lightdm/slick-greeter.conf). El fondo se
# copia a /usr/share/backgrounds porque el usuario lightdm no puede leer los
# home. La config de Parrot se guarda una sola vez en .parrot: al repetir el
# script no se sobrescribe con la nuestra.
GREETER_CONF=/etc/lightdm/slick-greeter.conf
echo "[9/9] Pantalla de login y bloqueo"
if ! command -v slick-greeter >/dev/null; then
  echo "      slick-greeter no está instalado; se omite"
else
  install -m 0644 -o root -g root "$REPO_DIR/../assets/wallpaper.jpg" \
    /usr/share/backgrounds/dotfiles-wallpaper.jpg
  if [ -f "$GREETER_CONF" ] && [ ! -f "$GREETER_CONF.parrot" ]; then
    cp -p "$GREETER_CONF" "$GREETER_CONF.parrot"
    echo "      Config original guardada en $GREETER_CONF.parrot"
  fi
  install -m 0644 -o root -g root "$REPO_DIR/lightdm/slick-greeter.conf" "$GREETER_CONF"
  echo "      Fondo del escritorio aplicado (se ve en el próximo login o bloqueo)"
fi

echo
echo "Setup completo. Verificar con:"
echo "  sudo ufw status verbose"
echo "  sudo -l -U $TARGET_USER          # debe listar solo anonsurf/anon-harden como NOPASSWD"
echo "  sudo unattended-upgrade --dry-run --debug"
