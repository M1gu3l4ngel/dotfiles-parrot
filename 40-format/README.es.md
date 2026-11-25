[English](README.md) | **Español**

# 40-format

El estilo de código global: solo se aplica a los proyectos que no traen su propio `.prettierrc` ni
`.editorconfig`. Una copia del de
[dotfiles-windows](https://github.com/M1gu3l4ngel/dotfiles-windows), para que las dos máquinas
formateen igual.

| Archivo | Se enlaza en | Qué es |
|---|---|---|
| `prettierrc.json` | `~/.prettierrc.json` | Estilo de Prettier |
| `editorconfig` | `~/.editorconfig` | Indentación y fin de línea de lo que Prettier no formatea |

Sin punto inicial en el repo, o los archivos se aplicarían a este mismo repo. Un cambio aquí va
también a dotfiles-windows, para que las dos copias sigan idénticas.

Qué configuración gana y cómo formatea VSCodium al guardar:
[docs/customization.es.md](../docs/customization.es.md).
