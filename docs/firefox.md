# Perfiles de Firefox

Dos perfiles aislados para no mezclar tu identidad personal con el trabajo de
pentesting: cookies, sesiones, historial y extensiones no se comparten.

## Perfiles

| Perfil | Abrir | Polybar | Uso |
|---|---|---|---|
| `default-esr` | `Super+Shift+F` | Icono rojo de Firefox | Personal: correo, GitHub, uso diario |
| `pentest` | `Super+Shift+P` | Icono verde de bicho | Targets, labs, OSINT, enlaces sospechosos |

Los dos pueden estar abiertos a la vez: los lanzadores usan `--no-remote`.

## Crear el perfil pentest

Una sola vez tras la instalación, como usuario normal:

1. Crear el perfil (no muestra ningún mensaje si todo va bien):

    ```bash
    firefox -CreateProfile pentest
    ```

2. Copiarle el `user.js`. Desde `~/dotfiles`, requiere sudo:

    ```bash
    sudo ./system/setup.sh
    ```

    En el paso `[6/9]` debe aparecer `Copiado al perfil pentest`.

3. Abrirlo con `Super+Shift+P`.

Para aplicar cambios futuros del `user.js`: volver a ejecutar el paso 2 y
reabrir Firefox.

## Qué protege el perfil pentest

Configuración en `system/firefox/pentest.user.js` (validada en Firefox ESR 140):

| Bloque | Qué hace | Porqué |
|---|---|---|
| Sin fugas a terceros | Sin sugerencias de búsqueda, sin Safe Browsing, sin telemetría ni comprobaciones de conectividad | Lo que escribes o visitas (hostnames de clientes incluidos) no sale hacia buscadores, Google ni Mozilla. Evita problemas de NDA |
| Sin tráfico no solicitado | Sin precarga de enlaces, DNS anticipado ni conexiones especulativas | Firefox no toca un target sin que lo pidas; evita peticiones fuera de alcance |
| Esquema sin reescribir | HTTPS-Only y HTTPS-First desactivados | En labs casi todo es HTTP (`http://box.htb`); reescribir a HTTPS alteraría la petición que quieres probar |
| WebRTC | Desactivado | Evita que JavaScript obtenga tu IP real aunque uses VPN |
| Credenciales | No guarda contraseñas ni autocompleta formularios | Las credenciales de pruebas no se quedan en el perfil y tus datos no acaban en un formulario del target |
| Limpieza al cerrar | Borra cookies, almacenamiento, caché, historial, descargas y formularios | Perfil limpio en cada sesión. Se conservan marcadores y extensiones |

## Lo que Parrot ya aplica a los dos perfiles

Parrot configura Firefox para todo el sistema en `/etc/firefox-esr/00parrot.js`
y `/etc/firefox-esr/policies/policies.json`:

- `privacy.resistFingerprinting` activado: la misma protección contra huella
  digital que Tor Browser. Entre otras cosas, reporta la zona horaria
  `Atlantic/Reykjavik` (UTC+0) a todos sus usuarios.
- Telemetría bloqueada (`lockPref`) y sugerencias de búsqueda desactivadas por
  política.

El `user.js` del perfil pentest no depende de esto: si Parrot cambiara su
configuración, el perfil seguiría protegido. Por el mismo motivo el lanzador
del perfil pentest añade `TZ=UTC`, como respaldo de la zona horaria.

## Comprobar que el perfil pentest está aplicado

En cada perfil, escribe `about:config` en la barra de direcciones, acepta el
aviso y busca `media.peerconnection.enabled`:

| Perfil | Valor esperado |
|---|---|
| pentest | `false` (en negrita: modificado por el `user.js`) |
| personal | `true` |

Para comprobar las fugas desde fuera (IP, DNS, WebRTC, zona horaria), ver la
auditoría externa de [anonimato.md](anonimato.md).

## Limitaciones

- Reduce la huella, pero no te hace indistinguible: para eso, Tor Browser.
- Iniciar sesión en tus cuentas personales desde el perfil pentest te
  identifica, sea cual sea la IP.
