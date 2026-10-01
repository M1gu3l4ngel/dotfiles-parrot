# Personalización

Cambios de aspecto habituales. Salvo que se indique otra cosa, se ejecutan
como usuario normal desde `~/dotfiles`. Los archivos de `~/.config/` son
enlaces al repo: editar uno es editar el repo.

## Sistema de diseño

Reglas que siguen todos los componentes. Al cambiar algo, respétalas para que
el escritorio siga viéndose como un conjunto.

| Elemento | Valor | Dónde |
|---|---|---|
| Paleta | Monokai Soda (la de kitty) | `scripts/.config/scripts/palette.sh`, `polybar/.config/polybar/colors.ini`, `rofi/.config/rofi/themes/monokai-soda.rasi`, `gtk/.config/gtk-4.0/gtk.css`, `vscodium/settings.json` |
| Fuente | CaskaydiaCove Nerd Font en todo; Hack solo en el logo de Parrot | `kitty.conf`, `current.ini`, `workspace.ini`, `dunstrc`, `monokai-soda.rasi` |
| Tamaño de texto | 12 pt (16 px) en barras y menú; 11 pt en kitty | |
| Radios | Ventanas 10 px; barras, notificaciones y menú 8 px; elementos internos 4 px | `picom.conf`, `current.ini`, `dunstrc`, `monokai-soda.rasi` |
| Bordes | 1 px `#555555` en la ventana con foco y en las barras | `bspwmrc`, `current.ini` |
| Espaciado | 12 px entre barras, con los bordes de pantalla y entre ventanas | `current.ini`, `bspwmrc` (`window_gap`) |

Significado de los colores en polybar:

| Color | Uso |
|---|---|
| Gris (`#8F8B7A`) | Apagado, vacío, desconectado |
| Verde (`#98E024`) | Conectado, activo (VPN, anonimato) |
| Naranja (`#FA8419`) | Foco: workspace activo, opción seleccionada en rofi |
| Rojo (`#F4005F`) | Target activo, algo que pide atención (solo iconos) |
| Cian (`#58D1EB`) | Red local |

Sin animaciones ni fades a propósito: cada animación retrasa la aparición de
las ventanas y, con `vsync = false` en picom, produce tearing en VMware.

## Fondo de pantalla

`~/.config/wallpaper.jpg` es un enlace al fondo por defecto del repo
(`assets/wallpaper.jpg`). No copies otra imagen encima con `cp`: escribiría a
través del enlace y sobrescribiría el archivo del repo. Apunta el enlace a tu
imagen:

```bash
ln -sfn /ruta/a/tu-fondo.jpg ~/.config/wallpaper.jpg
```

Aplica el cambio con `Super+Alt+R`.

La pantalla de login y de bloqueo (`Super+Shift+X`) usa una copia de
`assets/wallpaper.jpg` instalada por `system/setup.sh` (paso 9), porque el
login no puede leer tu home. El enlace de arriba solo cambia el escritorio.

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

Los colores están en dos archivos con los mismos valores:

- `polybar/.config/polybar/colors.ini`: fondo, texto, bordes y workspaces.
- `scripts/.config/scripts/palette.sh`: colores de estado de los módulos
  (VPN, target, anonimato, lanzadores).

`colors_dark.ini` y `colors_light.ini` son alternativas a `colors.ini`. Para
usar una, cópiala encima de la activa y recarga:

```bash
cp polybar/.config/polybar/colors_dark.ini polybar/.config/polybar/colors.ini
```

```bash
~/.config/polybar/launch.sh
```

Para volver a la paleta original: `git checkout polybar/.config/polybar/colors.ini`.

## Tema de rofi

El tema activo es `monokai-soda`, con la paleta del resto del escritorio. Hay
otros 25 en `rofi/.config/rofi/themes/`. En `rofi/.config/rofi/config.rasi`,
comenta la línea `@theme` activa (con `//` delante) y descomenta o escribe la
del tema que quieras:

```
@theme "themes/nord"
```

El cambio se ve al abrir rofi (`Super+D`). Si el tema pide una fuente que no
está instalada, rofi usará otra: ver la sección de fuentes.

`Super+D` abre las aplicaciones con su icono; `Ctrl+Tab` cambia al modo de
ejecutables del `$PATH`, para herramientas de terminal sin entrada de menú.

## Tema de Neovim

- Probar temas: dentro de Neovim, `Espacio` + `t` + `h`.
- Dejarlo fijo: en `nvim/.config/nvim/lua/chadrc.lua`, cambia el valor de
  `theme` (por defecto `"monekai"`).

## Editor (VSCodium)

Los ajustes están en `vscodium/settings.json`, enlazado por `install.sh`. El
código usa el tema Monokai; la interfaz, la paleta del sistema, definida en
`workbench.colorCustomizations` bajo `"[Monokai]"`. Los cambios se aplican al
guardar el archivo.

- Cambiar un color de la interfaz: edita su valor en ese bloque.
- Usar otro tema: cambia `workbench.colorTheme`. El bloque `"[Monokai]"` solo
  afecta a Monokai, así que el tema nuevo se verá con sus colores originales.
- Añadir una extensión: búscala en [Open VSX](https://open-vsx.org) (el
  catálogo de VSCodium), añade su identificador a `vscodium/extensions.txt` y
  ejecuta `./bootstrap.sh`, que instala solo las que falten.

La confianza del espacio de trabajo queda activa: al abrir material de labs o
repos descargados, VSCodium los abre en modo restringido (sin tareas ni
extensiones que ejecuten código) hasta que lo confirmes.

## Fuente de la terminal

kitty usa `CaskaydiaCove Nerd Font`, tamaño 11 (`font_family` y `font_size`
en `kitty/.config/kitty/kitty.conf`). Recarga con `Ctrl+Shift+F5` dentro de
kitty.

`bootstrap.sh` instala solo las fuentes que usa el setup: CaskaydiaCove para
todo el texto y Hack para el logo de Parrot en polybar. Para usar otra,
añádela en `bootstrap.sh` con su versión y su SHA-256, igual que las
existentes; no copies archivos de fuentes al repo.

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
