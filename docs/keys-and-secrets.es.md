[English](keys-and-secrets.md) | **Español**

# Claves y secretos

Claves SSH (autenticación en GitHub), GPG (firma de commits y cifrado) y
`pass` (gestor de secretos). Todo se ejecuta como usuario normal, desde
cualquier directorio, salvo que se indique otra cosa.

Usa una clave SSH y una GPG distintas en cada equipo: si pierdes uno, borras
solo sus claves de GitHub y los demás siguen funcionando.

## Antes de empezar: email privado de GitHub

Cada commit publica el email del autor. En GitHub, Settings -> Emails:

1. Marca "Keep my email addresses private".
2. Marca "Block command line pushes that expose my email".
3. Copia tu dirección `<id>+<user>@users.noreply.github.com`. En esta guía
   aparece como `<your-noreply>`; `<user>` es tu usuario de GitHub.

El commit y el UID de la clave GPG tienen que usar los dos `<your-noreply>`
para que GitHub muestre "Verified".

## SSH

1. Crear la clave. Acepta la ruta por defecto (`~/.ssh/id_ed25519`) y pon una
   passphrase:

    ```bash
    ssh-keygen -t ed25519 -C "<user>@<machine>"
    ```

    Guarda la passphrase en tu lugar seguro. Si la olvidas, no se recupera:
    habría que crear otra clave.

2. Cargarla en keychain. `.zshrc` lo hace solo si existe `~/.ssh/id_ed25519`;
   pedirá la passphrase una vez por arranque:

    ```bash
    exec zsh
    ```

3. Comprobar que está cargada:

    ```bash
    ssh-add -l
    ```

4. Mostrar la clave pública y copiarla:

    ```bash
    cat ~/.ssh/id_ed25519.pub
    ```

5. En GitHub, Settings -> SSH and GPG keys -> New SSH key: título con el nombre
   del equipo, tipo "Authentication Key", pega la clave y guarda.

6. Conectar por primera vez. Antes de aceptar, compara la huella que muestra
   con la oficial de GitHub para ED25519
   (`SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU`):

    ```bash
    ssh -T git@github.com
    ```

    Debe responder `Hi <user>! You've successfully authenticated`.

7. Usar SSH en el repo en vez de HTTPS. Desde `~/dotfiles`:

    ```bash
    git remote set-url origin git@github.com:<user>/dotfiles-parrot.git
    ```

## GPG

La clave firma cada commit y etiqueta (integridad, y la insignia "Verified" en
GitHub) y cifra los secretos de `pass`. Su fingerprint es la línea de 40
caracteres bajo `sec` en `gpg --list-secret-keys`; el Key ID que a veces
muestran GitHub y git son sus últimos 16 caracteres, la misma clave. En esta
guía aparece como `<fingerprint>`, y `<name>` es el nombre que quieres en la
clave.

### 1. La clave

**Caso A, una clave nueva (lo recomendado).** Se crea solo con la dirección
noreply, así que nunca lleva tu email personal: ed25519 para firmar y cv25519
para cifrar, con caducidad a 2 años. Pedirá la passphrase en un diálogo:

```bash
gpg --quick-generate-key "<name> <your-noreply>" default default 2y
```

Guarda la passphrase en tu lugar seguro.

**Caso B, una clave que ya tienes con tu email personal.** Añádele el UID
noreply:

```bash
gpg --quick-add-uid <fingerprint> "<name> <your-noreply>"
```

Después deja el email personal fuera de la clave pública: borra su UID
([Quitar el email personal de la clave](#quitar-el-email-personal-de-la-clave))
o fíltralo en cada exportación (paso 3).

### 2. Configurar git para firmar

El nombre, el email noreply y la firma de cada commit y etiqueta ya vienen de
`15-git/gitconfig`, enlazado como `~/.gitconfig`. La clave es de esta máquina,
así que va en `~/.gitconfig.local`, fuera del repo. Nunca uses
`git config --global`, que la escribiría en el repo público a través del
enlace:

```bash
git config --file ~/.gitconfig.local user.signingkey <fingerprint>
```

### 3. Subir la clave pública a GitHub

1. Comprobar que el único `uid` de la clave es el noreply:

    ```bash
    gpg --list-keys <fingerprint>
    ```

2. Copiar la clave pública al portapapeles:

    ```bash
    gpg --armor --export <fingerprint> | xclip -selection clipboard
    ```

    Si la clave aún tiene tu email personal (caso B con el filtro), exporta en
    su lugar solo el UID noreply:

    ```bash
    gpg --armor --export --export-filter keep-uid='mbox = <your-noreply>' <fingerprint> | xclip -selection clipboard
    ```

3. En GitHub, Settings -> SSH and GPG keys. Si ya hay una versión anterior de
   esta clave (mismo Key ID), bórrala antes: GitHub rechaza dos claves con el
   mismo fingerprint. Después New GPG key: pega el bloque (`Ctrl+V`) y guarda.

### 4. Verificar

Haz un commit y comprueba la firma (`G` = firma válida):

```bash
git log -1 --format='%G? %GK %s'
```

En GitHub, el commit aparece como "Verified". Los commits anteriores a
configurar la clave siguen sin firmar.

### Verificar commits hechos en otra máquina

Un commit firmado en otra máquina (Windows) sale con `E` hasta que importas la
clave pública de esa máquina. GitHub publica todas las claves públicas de una
cuenta en `github.com/<user>.gpg`:

```bash
curl -fsS https://github.com/<user>.gpg | gpg --import
```

```bash
git log -1 --format='%G? %GK %s' <commit>
```

`U` significa una firma válida de una clave que no has certificado tú. Para
marcarla como tuya (una firma local que nunca se publica):

```bash
gpg --quick-lsign-key <fingerprint-of-the-other-key>
```

A partir de ahí el mismo `git log` muestra `G`.

### La caché de la passphrase

`15-git/gnupg/.gnupg/gpg-agent.conf`, enlazado por `install.sh`, configura el
agente ([15-git/README.es.md](../15-git/README.es.md)):

- `pinentry-gnome3` pide la passphrase en un diálogo gráfico, y en la
  terminal si no hay sesión gráfica (por SSH).
- `default-cache-ttl 600`: 10 minutos desde el último uso; cada firma
  reinicia la cuenta.
- `max-cache-ttl 7200`: 2 horas desde que la escribiste, aunque se siga usando.

Los mismos valores que en Windows. Tras editar el archivo, recarga el agente:

```bash
gpg-connect-agent reloadagent /bye
```

### Copia de seguridad (obligatoria)

`pass` cifra con esta clave: si la pierdes, pierdes todos los secretos.

1. Exportar la clave privada (va cifrada con tu passphrase):

    ```bash
    gpg --armor --export-secret-keys <fingerprint> > ~/gpg-private.asc
    ```

    ```bash
    chmod 600 ~/gpg-private.asc
    ```

2. Copiar el certificado de revocación que GnuPG generó al crear la clave.
   Sirve para invalidar la clave públicamente si te la roban:

    ```bash
    cp ~/.gnupg/openpgp-revocs.d/<fingerprint>.rev ~/gpg-revocation.rev
    ```

3. Llevar los dos archivos a tu lugar seguro (por ejemplo, con la carpeta
   compartida de [vmware.es.md](vmware.es.md)) y guardar la passphrase por separado.
4. Borrarlos del home cuando estén a salvo:

    ```bash
    rm ~/gpg-private.asc ~/gpg-revocation.rev
    ```

### Renovar antes de que caduque

Amplía la caducidad de la clave principal y de las subclaves sin cambiar la
clave:

```bash
gpg --quick-set-expire <fingerprint> 2y
```

```bash
gpg --quick-set-expire <fingerprint> 2y '*'
```

Después, vuelve a subirla ([paso 3](#3-subir-la-clave-pública-a-github)).

### Quitar el email personal de la clave

Si la clave tiene también un UID con tu email personal, GitHub lo publica en
`github.com/<user>.gpg`. Borrar ese UID deja la clave limpia para siempre, y
la firma no cambia (los commits siguen "Verified" porque usan el noreply).
Como usuario normal, en cualquier directorio:

1. Hacer antes la [copia de seguridad](#copia-de-seguridad-obligatoria).
2. Abrir el editor de la clave:

    ```bash
    gpg --edit-key <fingerprint>
    ```

3. En el prompt `gpg>`, una línea cada vez: `uid N` (N = posición del UID
   personal en la lista; comprueba que el `*` queda en esa línea, nunca en la
   del noreply), `deluid`, `y` y `save`.
4. Comprobar que el único `uid` es el noreply:

    ```bash
    gpg --list-keys <fingerprint>
    ```

5. Rehacer la copia de seguridad (la anterior aún tiene el UID personal) y
   volver a subir la clave ([paso 3](#3-subir-la-clave-pública-a-github)).

Borrar el UID solo afecta a tu copia y a lo que vuelvas a publicar: si la
clave ya estaba en un servidor de claves público, allí sigue con el UID.

### Solución de problemas

| Síntoma | Causa | Solución |
|---|---|---|
| GitHub muestra "Unverified: the email in this signature doesn't match the committer email" | La clave no tiene un UID con `<your-noreply>` | Añádelo (caso B) y vuelve a subir la clave |
| `gpg failed to sign the data` por SSH | `GPG_TTY` no está definido, y el agente no sabe en qué terminal preguntar | `.zshrc` lo define: abre de nuevo la shell con `exec zsh` |
| Pide la passphrase en cada commit | El agente no lee `gpg-agent.conf` | `gpg-connect-agent reloadagent /bye`, y `./install.sh --check` para ver el enlace |
| `git log` muestra `E` en un commit de otra máquina | Su clave pública no está importada | [Verificar commits hechos en otra máquina](#verificar-commits-hechos-en-otra-máquina) |

## pass (gestor de secretos)

Cada secreto es un archivo cifrado con tu clave GPG en `~/.password-store/`.
Así los tokens no quedan en texto plano en `.zshrc`, en backups ni en el
historial.

1. Inicializar con tu fingerprint completo:

    ```bash
    pass init <fingerprint>
    ```

2. Activar el historial de cambios (los commits de `pass` también se firman):

    ```bash
    pass git init
    ```

3. Uso diario:

| Comando | Qué hace |
|---|---|
| `pass insert <nombre>` | Pide el valor dos veces y lo guarda cifrado |
| `pass <nombre>` | Lo descifra y lo muestra |
| `pass -c <nombre>` | Lo copia al portapapeles; se borra a los 45 segundos |
| `pass ls` | Lista todos los secretos |
| `pass edit <nombre>` | Lo edita y lo vuelve a cifrar |
| `pass rm <nombre>` | Lo borra |

Organización sugerida: `api/` (tokens de servicios), `htb/` (credenciales de
labs), `clients/` (engagements; borrar al cerrarlos), `personal/`.

Para usar un secreto sin escribirlo en la terminal:

```bash
curl -H "Authorization: Bearer $(pass api/github-token)" https://api.github.com/user
```

`.zshrc` excluye del historial las líneas con `Authorization`, `Bearer`,
`TOKEN=`, `SECRET=`, `PASSWORD=` o `API_KEY`, y las que empiezan con un espacio.

Si sincronizas el almacén con un repo remoto (`pass git remote add origin
<repo>`), debe ser privado: el contenido va cifrado, pero los nombres de los
archivos no (`clients/empresa-x/vpn` revelaría a quién auditas).
