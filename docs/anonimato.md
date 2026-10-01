# Anonimato con Tor

Envía todo el tráfico del sistema a través de la red Tor con un atajo, bloquea
lo que Tor no puede transportar y verifica que la salida es realmente Tor.

## Requisitos

Una sola vez, tras la instalación. Desde `~/dotfiles`, requiere sudo:

```bash
sudo ./system/setup.sh
```

Instala la regla sudoers que permite al toggle ejecutar sin contraseña solo
`anonsurf start|stop` y `/usr/local/sbin/anon-harden up|down`. Sin ella, el
toggle falla con "Tor no arrancó".

## Activar y desactivar

1. Pulsa `Super+A` o haz clic en el fantasma de polybar, junto a los iconos
   de Firefox.
2. Espera entre 15 y 20 segundos: Tor se conecta a la red y el script
   comprueba la salida.
3. Resultado:
    - Correcto: notificación "Anonimato ON · verificado" y fantasma verde.
    - Error: notificación roja. Si la salida no se pudo confirmar como Tor, el
      script deshace todos los cambios y vuelve a la conexión directa.
4. Para desactivar, pulsa `Super+A` otra vez: notificación "Anonimato OFF" y
   fantasma gris.

El estado se toma de AnonSurf (`systemctl is-active anonsurfd`), no de si
hay un proceso `tor`: Parrot puede dejar Tor corriendo tras arrancar sin que
el anonimato esté activo (`anonsurf status` muestra `AnonSurf: inactive`).

## Qué hace al activarse

| Capa | Qué hace | Porqué |
|---|---|---|
| `anonsurf start` | Redirige TCP y DNS a Tor | Oculta la IP real |
| IPv6 a DROP | Bloquea todo el tráfico IPv6 | anonsurf solo redirige IPv4 |
| ICMP saliente a DROP | Bloquea ping y traceroute | Tor solo transporta TCP |
| Verificación | Consulta `check.torproject.org` y exige `IsTor: true` | Comprobar la salida real, no solo que Tor esté arrancado |

Las reglas de IPv6 e ICMP están en `system/sbin/anon-harden`. La regla sudoers
autoriza ese script con argumentos fijos y nunca `iptables` directamente:
`iptables --modprobe=<programa>` ejecutaría cualquier programa como root.

## Comprobar que no hay fugas

Con el anonimato activado, desde una terminal como usuario normal (cualquier
directorio). Resultado esperado de cada comando:

1. La salida es Tor (`"IsTor":true` y una IP que no es la tuya):

    ```bash
    curl -s https://check.torproject.org/api/ip
    ```

2. IPv6 bloqueado (debe fallar sin mostrar ninguna IP):

    ```bash
    curl -6 -s --max-time 8 https://api64.ipify.org
    ```

3. Ping bloqueado (debe fallar):

    ```bash
    ping -c1 -W3 8.8.8.8
    ```

4. DNS sin fugas, aunque se fuerce un servidor externo. La respuesta es la IP
   del resolver que ve el servidor: debe ser un nodo de Tor, no el DNS de tu
   proveedor:

    ```bash
    dig +short @1.1.1.1 whoami.akamai.net
    ```

## Auditoría externa desde Firefox

Las comprobaciones anteriores son propias. Para confirmarlo con herramientas
independientes, abre el Firefox pentest (`Super+Shift+P`) y visita estas webs
dos veces: primero con el anonimato apagado (línea base) y después encendido,
cerrando y reabriendo Firefox entre ambas rondas.

| Web | Anonimato apagado | Anonimato encendido |
|---|---|---|
| `https://check.torproject.org` | "You are not using Tor" | "Congratulations. This browser is configured to use Tor" |
| `https://ipleak.net` (arriba) | Tu IP real | Una IP que no es la tuya |
| `https://ipleak.net` (sección "DNS Addresses", esperar a que termine) | Servidores DNS de tu proveedor | 0 servidores detectados: tu DNS real no aparece |
| `https://browserleaks.com/webrtc` | "No Leak" | "No Leak" |
| `https://browserleaks.com/javascript` | Zona horaria `Atlantic/Reykjavik` | Zona horaria `Atlantic/Reykjavik` |

Si con el anonimato apagado las webs sí detectan tu IP real, el test funciona;
si con el anonimato encendido no la detectan, la protección también.

La zona horaria `Atlantic/Reykjavik` no es un error: Parrot activa
`privacy.resistFingerprinting` en Firefox para todo el sistema, y ese modo
(el mismo de Tor Browser) reporta esa zona (UTC+0 sin horario de verano) a
todos sus usuarios. Al ser un valor compartido, no te distingue de los demás.

## Comprobar que se desactivó limpio

Tras desactivar, las reglas deben volver a su estado normal. Requiere sudo,
desde cualquier directorio:

```bash
sudo ip6tables -S
```

Las tres primeras líneas deben ser `-P INPUT ACCEPT`, `-P FORWARD ACCEPT` y
`-P OUTPUT ACCEPT`.

```bash
sudo iptables -S OUTPUT
```

No debe aparecer ninguna regla con el comentario `anon_toggle_icmp`.

## Limitaciones

- Oculta la IP, no la identidad: iniciar sesión en tus cuentas o usar un
  navegador con huella única te identifica igual. Para anonimato fuerte, Tor
  Browser (hace que todos sus usuarios parezcan iguales).
- El nodo de salida de Tor ve el tráfico que no va cifrado: usa siempre HTTPS.
- Añade latencia y muchos servicios bloquean los nodos de Tor. Es una
  herramienta puntual (ver [pentesting.md](pentesting.md)).
- No sirve para atacar targets: va contra las normas de los labs y de los
  engagements, y la VPN de HTB y THM no funciona sobre Tor. Apágalo antes de
  conectar la VPN.

## Problemas frecuentes

| Síntoma | Causa | Solución |
|---|---|---|
| "Tor no arrancó" | Falta la regla sudoers | `sudo ./system/setup.sh` desde `~/dotfiles` |
| "No se confirmó salida por Tor" | Tor no terminó de conectar o hay bloqueo de red | Esperar un minuto y volver a activar |
| El botón no cambia de color | polybar no está leyendo el estado | `~/.config/polybar/launch.sh` |

Para ver qué comandos puede ejecutar el toggle sin contraseña:

```bash
sudo -l
```

Solo deben aparecer como `NOPASSWD` los cuatro comandos de anonsurf y
anon-harden.
