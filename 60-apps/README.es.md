[English](README.md) | **Español**

# 60-apps

Los paquetes de apt del entorno, fuera de `bootstrap.sh`: lo que se instala cambia mucho más a
menudo que cómo se instala.

| Archivo | Qué es |
|---|---|
| `apt.txt` | Un paquete por línea, agrupados por área (escritorio, shell y herramientas de terminal, desarrollo, seguridad, pentesting, fuentes y descargas); `#` inicia un comentario |

`bootstrap.sh` lo lee e instala solo los paquetes que faltan, en una sola transacción de apt. Si no
falta ninguno se salta `apt-get update`, lo más lento de una segunda ejecución. Dentro de VMware
añade `open-vm-tools-desktop`, que no está en la lista.

Lo que no viene de apt (Nerd Fonts, Neovim, oh-my-posh, nvm y Node) lo descarga `bootstrap.sh` en
una versión fijada y lo verifica con su SHA-256.

## Añadir un paquete

1. Añade su nombre a `apt.txt`, en su grupo.
2. Desde `~/dotfiles`, como usuario normal (pedirá sudo):

    ```bash
    ./bootstrap.sh
    ```
