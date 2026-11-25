[English](SECURITY.md) | **Español**

# Seguridad

## Versiones con soporte

Solo el último commit de `main` recibe arreglos. Cada versión está en
[`CHANGELOG.es.md`](CHANGELOG.es.md).

## Reportar una vulnerabilidad

No abras un issue público. Repórtala en privado en GitHub: en este repositorio, abre
**Security**, luego **Report a vulnerability**, y rellena el formulario.

Incluye qué se ve afectado (un script, la regla sudoers, una configuración enlazada, el workflow
de CI), los pasos para reproducirlo y el impacto que ves. Recibes una respuesta que confirma el
reporte, y se te informa hasta que esté arreglado. Cuando el arreglo se publica, el reporte se
hace público con tu crédito, salvo que prefieras lo contrario.

## Alcance

- **Dentro:** los scripts (`bootstrap.sh`, `install.sh`, `uninstall.sh`, `tools/`,
  `githooks/`), lo que `70-system/setup.sh` instala como root (la regla sudoers, `anon-harden`,
  los ajustes de apt y del greeter), que el toggle de anonimato deje salir tráfico fuera de Tor,
  el workflow de CI, y cualquier cosa de este repositorio que pueda filtrar un secreto, descargar
  algo sin verificar o ejecutar código que el usuario no esperaba.
- **Fuera:** las vulnerabilidades de las herramientas que instala (paquetes de Parrot OS,
  AnonSurf, Tor, Neovim, oh-my-posh, Node.js, Claude Code), que van a sus propios proyectos.
