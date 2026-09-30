# shellcheck shell=sh
# ~/.config/scripts/palette.sh
# Paleta Monokai Soda (la de kitty) con un rol fijo para cada color. La cargan
# los módulos de polybar con `. "${0%/*}/palette.sh"`: cambiar un color aquí
# lo cambia en todas las barras. Los mismos valores están en
# polybar/.config/polybar/colors.ini para la configuración de las barras.
#
# Regla de diseño: el color comunica estado. Gris (MUTED) = apagado o vacío;
# color = activo. Contraste de texto verificado (WCAG, mínimo 4.5:1 sobre el
# fondo de las barras, #1A1A1A); ERROR (4.15:1) solo se usa en iconos.
#
# Formato: valores para el tag de color de polybar %{F#...}.

# shellcheck disable=SC2034 # Las variables se usan en los scripts que cargan este archivo.
TEXT='#C4C5B5'       # texto normal
STRONG='#F6F6EF'     # datos importantes (IPs)
MUTED='#8F8B7A'      # apagado, vacío, desconectado
ACCENT='#FA8419'     # foco y elemento seleccionado
SUCCESS='#98E024'    # conectado, activo, correcto
ERROR='#F4005F'      # target activo, fallos (solo iconos)
INFO='#58D1EB'       # red local
EXTRA='#9D65FF'      # Firefox pentest
