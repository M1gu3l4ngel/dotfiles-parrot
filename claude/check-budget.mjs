#!/usr/bin/env node
// check-budget.mjs — guarda de presupuesto de la capa global de Claude Code.
// Evita que CLAUDE.md (y los archivos de la capa) crezcan sin control.
// Portable Windows/Linux: mismo runtime que el hook. Correr: `node claude/check-budget.mjs`
// Sale 0 si todo cumple, 1 si algo excede (apto para git pre-commit).

import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const HERE = dirname(fileURLToPath(import.meta.url));

// Presupuestos. CLAUDE.md es el que de verdad cuesta contexto en cada sesión;
// el resto son topes de cordura para que la capa no se infle.
const BUDGETS = [
  { file: 'CLAUDE.md', maxLines: 50 },
  { file: 'statusline.mjs', maxLines: 120 },
  { file: 'hooks/block-shell-edits.mjs', maxLines: 160 },
];

let failed = false;
for (const { file, maxLines } of BUDGETS) {
  let lines;
  try {
    lines = readFileSync(join(HERE, file), 'utf8').split(/\r?\n/).length;
  } catch {
    console.log(`  ?  ${file} — no encontrado`);
    continue;
  }
  const ok = lines <= maxLines;
  if (!ok) failed = true;
  console.log(`  ${ok ? 'OK ' : 'XX '} ${file} — ${lines}/${maxLines} líneas`);
}

console.log(failed
  ? '\nPresupuesto EXCEDIDO: recorta antes de commitear (la capa global es solo comportamiento universal).'
  : '\nPresupuesto OK.');
process.exit(failed ? 1 : 0);
