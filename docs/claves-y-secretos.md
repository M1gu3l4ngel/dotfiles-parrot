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
3. Copia tu dirección `<id>+<usuario>@users.noreply.github.com`. En esta guía
   aparece como `<tu-noreply>`.

## SSH

1. Crear la clave. Acepta la ruta por defecto (`~/.ssh/id_ed25519`) y pon una
   passphrase:

    ```bash
    ssh-keygen -t ed25519 -C "<usuario>@<equipo>"
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

    Debe responder `Hi <usuario>! You've successfully authenticated`.

7. Usar SSH en el repo en vez de HTTPS. Desde `~/dotfiles`:

    ```bash
    git remote set-url origin git@github.com:<usuario>/dotfiles-parrot.git
    ```

## GPG

`gnupg/.gnupg/gpg-agent.conf` (enlazado por `install.sh`) configura el agente
para pedir la passphrase en un diálogo gráfico (en la terminal si no hay sesión
gráfica, p. ej. por SSH) y recordarla 10 minutos desde el último uso, 2 horas
como máximo: los mismos valores que en Windows.

1. Crear la clave (ed25519 para firmar y cv25519 para cifrar, caduca en 2
   años). Pedirá la passphrase en un diálogo:

    ```bash
    gpg --quick-generate-key "<nombre> <tu-noreply>" default default 2y
    ```

    Guarda la passphrase en tu lugar seguro.

2. Ver el fingerprint (la línea larga de 40 caracteres bajo `sec`). En esta
   guía aparece como `<fingerprint>`:

    ```bash
    gpg --list-secret-keys
    ```

3. Configurar git para firmar siempre:

    ```bash
    git config --global user.email "<tu-noreply>"
    ```

    ```bash
    git config --global user.signingkey <fingerprint>
    ```

    ```bash
    git config --global commit.gpgsign true
    ```

    ```bash
    git config --global tag.gpgsign true
    ```

4. Copiar la clave pública al portapapeles. Comprueba antes con
   `gpg --list-keys <fingerprint>` que su único `uid` es el noreply; si
   también aparece tu email personal, sigue antes
   [Quitar el email personal de la clave](#quitar-el-email-personal-de-la-clave):

    ```bash
    gpg --armor --export <fingerprint> | xclip -selection clipboard
    ```

5. En GitHub, Settings -> SSH and GPG keys -> New GPG key: pega el bloque
   (`Ctrl+V`) y guarda.

6. Hacer un commit y comprobar la firma (`G` = firma válida):

    ```bash
    git log -1 --format='%G? %GK %s'
    ```

    En GitHub, el commit aparece como "Verified".

### Copia de seguridad (obligatoria)

`pass` cifra con esta clave: si la pierdes, pierdes todos los secretos.

1. Exportar la clave privada (va cifrada con tu passphrase):

    ```bash
    gpg --armor --export-secret-keys <fingerprint> > ~/gpg-privada.asc
    ```

    ```bash
    chmod 600 ~/gpg-privada.asc
    ```

2. Copiar el certificado de revocación que GnuPG generó al crear la clave.
   Sirve para invalidar la clave públicamente si te la roban:

    ```bash
    cp ~/.gnupg/openpgp-revocs.d/<fingerprint>.rev ~/gpg-revocacion.rev
    ```

3. Llevar los dos archivos a tu lugar seguro (por ejemplo, con la carpeta
   compartida de [vmware.md](vmware.md)) y guardar la passphrase por separado.
4. Borrarlos del home cuando estén a salvo:

    ```bash
    rm ~/gpg-privada.asc ~/gpg-revocacion.rev
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

Después, vuelve a exportarla (paso 4) y reemplázala en GitHub.

### Quitar el email personal de la clave

Si la clave tiene también un UID con tu email personal, GitHub lo publica en
`github.com/<usuario>.gpg`. Lo recomendado es borrar ese UID: la clave queda
limpia para siempre y la firma no cambia (los commits siguen "Verified"
porque usan el noreply). Como usuario normal, en cualquier directorio:

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
   reemplazar la clave en GitHub: borra la entrada antigua (GitHub rechaza dos
   claves con el mismo fingerprint) y sube la nueva (pasos 4 y 5).

Borrar el UID solo afecta a tu copia y a lo que vuelvas a publicar: si la
clave ya estaba en un servidor de claves público, allí sigue con el UID.

Alternativa sin modificar la clave: exportar filtrando el UID. Hay que
recordar el filtro en cada exportación; si se olvida, se publica el email:

```bash
gpg --armor --export --export-filter keep-uid='mbox = <tu-noreply>' <fingerprint>
```

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
