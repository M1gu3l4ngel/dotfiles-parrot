[English](README.md) | **Español**

# 15-git

La identidad de git y la firma de commits, y el agente de GPG que mantiene la clave desbloqueada.

| Ruta | Se enlaza en | Qué es |
|---|---|---|
| `gitconfig` | `~/.gitconfig` | Commits y tags firmados y `main` como rama por defecto, lo que puede ser público; incluye `~/.gitconfig.local` |
| `gnupg/.gnupg/gpg-agent.conf` | `~/.gnupg/gpg-agent.conf` | Agente de GPG: diálogo gráfico de la passphrase y caché (10 minutos sin uso, 2 horas como máximo) |

`install.sh` crea los enlaces. Solo se enlaza el archivo del agente: `~/.gnupg` guarda las claves
privadas y sigue siendo una carpeta real con permisos 700, fuera de cualquier repo.

## Qué no va aquí

- La identidad (nombre y email noreply), la clave de firma y cualquier cuenta de trabajo: son de
  cada persona o máquina y van en `~/.gitconfig.local`, que el repo nunca ve. Quien haga un fork
  del repo hace sus commits con su propio nombre. `bootstrap.sh` escribe ahí la identidad si la
  máquina no tiene una, desde `--git-name` y `--git-email` (por defecto, los del dueño), e
  `install.sh --check` avisa si falta. `install.sh` lleva la clave allí desde un
  `~/.gitconfig` antiguo.
- `git config --global`: escribiría en el repo a través del enlace. En su lugar,
  `git config --file ~/.gitconfig.local`.

Crear las claves y configurar la firma: [docs/keys-and-secrets.es.md](../docs/keys-and-secrets.es.md).

## Recargar

git lee `gitconfig` en cada comando. El agente, tras editar su archivo:

```bash
gpg-connect-agent reloadagent /bye
```
