# VMware

Requisitos y ajustes para ejecutar el setup en una VM de VMware.

## Configuración de la VM

Con la VM apagada, en VM -> Settings:

1. Hardware -> Display: marcar "Accelerate 3D graphics" y asignar 2 GB o más
   de "Graphics memory".
2. Al iniciar sesión en Parrot, elegir la sesión `bspwm` (X11). bspwm no
   funciona en Wayland.

`bootstrap.sh` instala `open-vm-tools-desktop` (portapapeles compartido,
resolución automática y carpetas compartidas) cuando detecta VMware.

## Comprobar la aceleración gráfica

```bash
glxinfo -B | grep -E "renderer|Accelerated"
```

| Resultado | Significado |
|---|---|
| Renderer `SVGA3D` | La GPU virtual funciona |
| Renderer `llvmpipe` | Renderizado por software: activar "Accelerate 3D graphics" |

La línea `Accelerated: no` aparece aunque la GPU funcione: es un falso
positivo del driver `vmwgfx`. El dato fiable es el renderer.

picom usa el backend `glx` (composición en la GPU). Con `xrender` componía en
la CPU y cambiar de workspace iba lento.

## Carpeta compartida con el host

Para pasar archivos entre Windows y Linux en ambos sentidos.

1. En Windows, crea una carpeta dedicada, por ejemplo `C:\VMShare`. No
   compartas el disco entero: si la VM se compromete, solo alcanza esa carpeta.
2. En VMware, con la VM encendida: VM -> Settings -> Options -> Shared Folders.
   Marca "Always enabled", pulsa "Add...", elige la carpeta y ponle el nombre
   `VMShare` (con esa mayúscula). Deja "Read-only" sin marcar.
3. Comprueba que la VM la ve (debe responder `VMShare`):

    ```bash
    vmware-hgfsclient
    ```

4. Móntala. Desde `~/dotfiles`, requiere sudo:

    ```bash
    sudo ./system/setup.sh
    ```

    El paso `[8/8]` la monta en `/mnt/vmshare`, crea el acceso directo
    `~/VMShare` y la añade a `/etc/fstab`. Solo tu usuario puede leerla, y si
    la desactivas en VMware el sistema arranca igual.

Todo lo que pongas en `C:\VMShare` aparece en `~/VMShare`, y al revés.

### Pasar un archivo sensible sin dejar copias

Para claves o backups: copiar, verificar que llegó intacto y borrar el
original. Ejemplo con `archivo.asc`:

1. Copiar:

    ```bash
    cp ~/archivo.asc ~/VMShare/
    ```

2. Comparar las huellas: las dos líneas deben mostrar el mismo hash:

    ```bash
    sha256sum ~/archivo.asc ~/VMShare/archivo.asc
    ```

3. Borrar el original:

    ```bash
    rm ~/archivo.asc
    ```

4. En Windows, mover el archivo de `C:\VMShare` a su destino y vaciar la
   papelera. La carpeta compartida es un punto de paso, no un almacén.
