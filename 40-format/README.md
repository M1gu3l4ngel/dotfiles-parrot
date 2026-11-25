**English** | [Español](README.es.md)

# 40-format

The global code style: it applies only to projects that bring no `.prettierrc` or `.editorconfig`
of their own. A copy of the one in
[dotfiles-windows](https://github.com/M1gu3l4ngel/dotfiles-windows), so both machines format the
same way.

| File | Linked to | What it is |
|---|---|---|
| `prettierrc.json` | `~/.prettierrc.json` | Prettier style |
| `editorconfig` | `~/.editorconfig` | Indentation and line endings for what Prettier does not format |

No leading dot in the repo, or the files would apply to this repo itself. A change here goes to
dotfiles-windows too, so the two copies stay identical.

Which configuration wins and how VSCodium formats on save:
[docs/customization.md](../docs/customization.md).
