# tools/check-docs.py
# Comprueba que la documentación bilingüe esté sincronizada. Lo ejecuta
# tools/check.sh (y por tanto el CI); también se puede lanzar solo, desde la
# raíz del repo:
#
#   python3 tools/check-docs.py
#
# Cada documento X.md (inglés) tiene su pareja X.es.md (español). El texto
# traducido no se puede comparar, así que se compara todo lo que no cambia
# entre idiomas:
#   1. Que exista la pareja y que cada uno lleve el selector de idioma arriba
#   2. Mismo número de títulos, filas de tabla y elementos de lista
#   3. Bloques de código idénticos (los comandos no se traducen)
#   4. Mismos enlaces relativos, en el mismo orden, cada uno a su idioma
#   5. Enlaces que existen y anclas (#sección) que existen en su destino
#
# Sale con 1 si algo falla, con la lista de problemas.

import os
import re
import subprocess
import sys

# ----- ALCANCE -----
# Instrucciones para Claude Code (no documentación para el lector) y archivos
# heredados de la plantilla de NvChad: solo en español o intocables.
EXCLUDED_PREFIXES = (".claude/", "nvim/")
EXCLUDED_FILES = {"CLAUDE.md", "claude/CLAUDE.md"}

ES_SUFFIX = ".es.md"


def doc_files():
    # --others incluye los documentos nuevos aún sin `git add`: el check debe
    # verlos antes del commit, no después.
    out = subprocess.run(
        ["git", "ls-files", "--cached", "--others", "--exclude-standard", "*.md"],
        capture_output=True, text=True, check=True,
    ).stdout.split()
    return sorted(
        f for f in set(out)
        if os.path.exists(f)
        and f not in EXCLUDED_FILES
        and not f.startswith(EXCLUDED_PREFIXES)
    )


def slug(heading, seen):
    # Mismo algoritmo que GitHub: minúsculas, sin puntuación (las letras con
    # tilde se conservan), espacios a guiones y sufijo -1, -2... si se repite.
    base = re.sub(r"[^\w\- ]", "", heading.strip().lower()).replace(" ", "-")
    n = seen.get(base, 0)
    seen[base] = n + 1
    return base if n == 0 else f"{base}-{n}"


def parse(path):
    with open(path, encoding="utf-8") as fh:
        lines = fh.read().splitlines()
    doc = {"first": lines[0] if lines else "", "headings": 0, "rows": 0,
           "items": 0, "code": [], "links": [], "anchors": set()}
    seen = {}
    inside = False
    # La línea 1 es el selector de idioma: se valida aparte.
    for line in lines[1:]:
        stripped = line.strip()
        if stripped.startswith("```"):
            inside = not inside
            doc["code"].append("```")
            continue
        if inside:
            # Sin la sangría: un bloque dentro de una lista la lleva.
            doc["code"].append(stripped)
            continue
        if re.match(r"#{1,6} ", line):
            doc["headings"] += 1
            doc["anchors"].add(slug(line.lstrip("#"), seen))
        elif stripped.startswith("|"):
            doc["rows"] += 1
        elif re.match(r"\s*([-*]|\d+\.) ", line):
            doc["items"] += 1
        for target in re.findall(r"\]\(([^)\s]+)\)", line):
            if not re.match(r"[a-z]+:", target):
                doc["links"].append(target)
    return doc


def main():
    files = doc_files()
    docs = {f: parse(f) for f in files}
    problems = []

    def check_links(path, doc, spanish):
        for target in doc["links"]:
            file_part, _, anchor = target.partition("#")
            dest = os.path.normpath(os.path.join(os.path.dirname(path), file_part)) if file_part else path
            if not os.path.exists(dest):
                problems.append(f"{path}: enlace roto a {target}")
                continue
            if dest.endswith(".md"):
                is_es = dest.endswith(ES_SUFFIX)
                if spanish and not is_es and dest[:-3] + ES_SUFFIX in docs:
                    problems.append(f"{path}: {target} apunta a la versión en inglés")
                if not spanish and is_es:
                    problems.append(f"{path}: {target} apunta a la versión en español")
            if anchor and dest in docs and anchor not in docs[dest]["anchors"]:
                problems.append(f"{path}: el ancla #{anchor} no existe en {dest}")

    pairs = 0
    for en in files:
        if en.endswith(ES_SUFFIX):
            if en[: -len(ES_SUFFIX)] + ".md" not in docs:
                problems.append(f"{en}: falta su versión en inglés")
            continue
        es = en[:-3] + ES_SUFFIX
        if es not in docs:
            problems.append(f"{en}: falta su versión en español ({es})")
            continue
        pairs += 1
        a, b = docs[en], docs[es]
        name = os.path.basename(en)
        if a["first"] != f"**English** | [Español]({name[:-3]}{ES_SUFFIX})":
            problems.append(f"{en}: la línea 1 debe ser el selector de idioma")
        if b["first"] != f"[English]({name}) | **Español**":
            problems.append(f"{es}: la línea 1 debe ser el selector de idioma")
        for key, label in (("headings", "títulos"), ("rows", "filas de tabla"),
                           ("items", "elementos de lista")):
            if a[key] != b[key]:
                problems.append(f"{en} / {es}: {label} {a[key]} / {b[key]}")
        if a["code"] != b["code"]:
            problems.append(f"{en} / {es}: los bloques de código difieren")
        # Mismo destino quitando el idioma y el ancla (las anclas se traducen
        # con el título).
        norm = [re.sub(r"\.es\.md$", ".md", t.partition("#")[0]) for t in b["links"]]
        if [t.partition("#")[0] for t in a["links"]] != norm:
            problems.append(f"{en} / {es}: los enlaces no coinciden")

    for path, doc in docs.items():
        check_links(path, doc, path.endswith(ES_SUFFIX))

    if problems:
        print("\n".join(problems))
        return 1
    print(f"Documentación bilingüe: {pairs} parejas sincronizadas")
    return 0


if __name__ == "__main__":
    sys.exit(main())
