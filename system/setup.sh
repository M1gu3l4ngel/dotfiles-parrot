#!/bin/bash
# system/setup.sh
# Configuración a nivel sistema (fuera de $HOME) que el install.sh principal
# no puede manejar — sudoers, ufw, etc. requieren root y no se symlinkean.
#
# Idempotente: correr múltiples veces es seguro. Cada paso valida estado
# previo y solo aplica lo que falta.
#
# Qué hace:
#   1. Instala /etc/sudoers.d/anon_toggle (NOPASSWD para anonsurf + iptables)
#   2. Aplica las 4 reglas baseline de ufw
#   3. Verifica/fuerza IPV6=yes en /etc/default/ufw
#   4. Activa ufw
#
# Uso:
#   sudo ./system/setup.sh
#
# Requiere: ufw y anonsurf instalados previamente.

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# ----- 0. Sanity checks -----
if [ "$EUID" -ne 0 ]; then
  echo "ERROR: este script requiere root. Ejecutar con: sudo $0"
  exit 1
fi

# Necesitamos saber qué usuario va dentro de la regla sudoers. Si se
# corrió via 'sudo', SUDO_USER tiene el usuario original. Si se corrió
# como root directo, no hay forma de adivinar — fallar explícito.
if [ -z "$SUDO_USER" ]; then
  echo "ERROR: ejecutar via 'sudo ./setup.sh', no como root directo."
  echo "       Necesitamos \$SUDO_USER para escribir la regla sudoers."
  exit 1
fi
TARGET_USER="$SUDO_USER"

for bin in ufw anonsurf visudo install sed; do
  if ! command -v "$bin" > /dev/null; then
    echo "ERROR: '$bin' no está instalado. Instalalo primero (apt install $bin)."
    exit 1
  fi
done

# ----- 1. SUDOERS para anonsurf + iptables -----
# El template tiene __USER__ como placeholder para no comprometer el
# username en el repo público. Lo sustituimos por $SUDO_USER al instalar.
# Se instala con permisos 0440 (sudo se niega a leer el archivo en otro
# modo) y se valida con visudo -c antes de dejarlo en su lugar final.
SUDOERS_SRC="$REPO_DIR/sudoers.d/anon_toggle"
SUDOERS_DST="/etc/sudoers.d/anon_toggle"

if [ ! -f "$SUDOERS_SRC" ]; then
  echo "ERROR: no encuentro $SUDOERS_SRC"
  exit 1
fi

echo "[1/4] Instalando $SUDOERS_DST (usuario: $TARGET_USER)"
sed "s/__USER__/$TARGET_USER/g" "$SUDOERS_SRC" \
  | install -m 0440 -o root -g root /dev/stdin "$SUDOERS_DST"
visudo -c -f "$SUDOERS_DST"

# ----- 2. UFW reglas baseline -----
# default deny incoming   → dropear conexiones entrantes no esperadas
# default allow outgoing  → tráfico saliente libre (anonsurf filtra encima)
# allow in on lo          → loopback (apps locales que hablan entre sí)
# allow in on tun+        → reverse shells / responses de VPN (HTB, THM)
# Cada `ufw allow` es idempotente — si la regla ya existe no la duplica.
echo "[2/4] Aplicando reglas baseline de ufw"
ufw default deny incoming
ufw default allow outgoing
ufw allow in on lo
ufw allow in on tun+ from any

# ----- 3. Verificar IPV6=yes -----
# Si IPV6=no, ufw solo protege IPv4 y el hardening de ip6tables del toggle
# queda como única defensa contra leaks v6.
echo "[3/4] Verificando IPV6=yes en /etc/default/ufw"
if ! grep -q "^IPV6=yes" /etc/default/ufw; then
  echo "      IPV6 no estaba en yes, lo aplico"
  sed -i 's/^IPV6=.*/IPV6=yes/' /etc/default/ufw
fi

# ----- 4. Activar ufw -----
# --force evita el prompt "may disrupt ssh sessions [y|n]"
echo "[4/4] Activando ufw"
ufw --force enable

echo
echo "Setup completo. Verificar con:"
echo "  sudo ufw status verbose"
echo "  sudo -n ip6tables -L OUTPUT -n   # debe correr sin password"
