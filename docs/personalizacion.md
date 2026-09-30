# Personalización

Cambios de aspecto habituales. Salvo que se indique otra cosa, se ejecutan
como usuario normal desde `~/dotfiles`. Los archivos de `~/.config/` son
enlaces al repo: editar uno es editar el repo.

## Fondo de pantalla

`~/.config/wallpaper.jpg` es un enlace al fondo por defecto del repo
(`assets/wallpaper.jpg`). No copies otra imagen encima con `cp`: escribiría a
través del enlace y sobrescribiría el archivo del repo. Apunta el enlace a tu
imagen:

```bash
ln -sfn /ruta/a/tu-fondo.jpg ~/.config/wallpaper.jpg
```

Aplica el cambio con `Super+Alt+R`.

## Prompt (oh-my-posh)

El prompt usa `oh-my-posh/capr4n.omp.json`. Para cambiarlo, edita ese archivo
o usa uno de los temas incluidos en oh-my-posh.

1. Ver los temas disponibles:

    ```bash
    ls ~/.cache/oh-my-posh/themes/
    ```

2. Probar uno solo en la terminal actual (no cambia nada del repo):

    ```bash
    eval "$(~/.local/bin/oh-my-posh init zsh --config ~/.cache/oh-my-posh/themes/agnoster.omp.json)"
    ```

3. Para dejarlo fijo, cambia la ruta de `--config` en la línea de oh-my-posh de
   `zsh/.zshrc` y ejecuta `exec zsh`.

## Colores de polybar

`colors.ini` es la paleta activa; `colors_dark.ini` y `colors_light.ini` son
alternativas. Para usar una, cópiala encima de la activa y recarga:

```bash
cp polybar/.config/polybar/colors_dark.ini polybar/.config/polybar/colors.ini
```

```bash
~/.config/polybar/launch.sh
```

Para volver a la paleta original: `git checkout polybar/.config/polybar/colors.ini`.

## Tema de rofi

Hay 25 temas en `rofi/.config/rofi/themes/`. En `rofi/.config/rofi/config.rasi`,
comenta la línea `@theme` activa (con `//` delante) y descomenta o escribe la
del tema que quieras:

```
@theme "themes/nord"
```

El cambio se ve al abrir rofi (`Super+D`). Si el tema pide una fuente que no
está instalada, rofi usará otra: ver la sección de fuentes.

## Tema de Neovim

- Probar temas: dentro de Neovim, `Espacio` + `t` + `h`.
- Dejarlo fijo: en `nvim/.config/nvim/lua/chadrc.lua`, cambia el valor de
  `theme` (por defecto `"monekai"`).

## Fuente de la terminal

kitty usa `CaskaydiaCove Nerd Font`, tamaño 11 (`font_family` y `font_size`
en `kitty/.config/kitty/kitty.conf`). Recarga con `Ctrl+Shift+F5` dentro de
kitty.

`bootstrap.sh` instala solo las fuentes que usa el setup (Iosevka, Hack y
CaskaydiaCove). Para usar otra, añádela en `bootstrap.sh` con su versión y su
SHA-256, igual que las existentes; no copies archivos de fuentes al repo.

## Notificaciones

Colores, posición y tiempos en `dunst/.config/dunst/dunstrc`. Aplica y prueba:

```bash
dunstctl reload
```

```bash
notify-send -u critical "Prueba" "Así se ven los errores"
```

## Atajos de teclado

Los atajos están en `sxhkd/.config/sxhkd/sxhkdrc`. Formato: la combinación en
una línea y el comando en la siguiente, indentado con un tabulador:

```
super + shift + n
	notify-send "hola"
```

Recarga con `Super+Escape`. Antes de usar una combinación, comprueba que no
existe ya en el archivo: una combinación duplicada hace que solo funcione una.
