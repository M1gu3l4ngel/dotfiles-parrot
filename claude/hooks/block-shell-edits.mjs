#!/usr/bin/env node
// Hook PreToolUse (global) de Bash y PowerShell: bloquea las ediciones de archivos por shell.
//
// La regla "Editar con Edit o Write" vive en ~/.claude/CLAUDE.md. Como instruccion es
// orientativa (un plugin o el modo automatico pueden proponer editar con sed a mitad de
// sesion); aqui se vuelve determinista para los casos claros: editores in-place, redirecciones
// a un archivo, heredocs hacia un interprete, cmdlets de escritura y codigo inline que escribe.
//
// Lo que va a un directorio temporal (logs, scratchpad, D:\Dev\scratch, /tmp) o a /dev/null
// pasa: la regla protege los archivos de trabajo, no la salida de un comando. Ejecutar un
// script ya escrito con Write (`node scratchpad/barrido.mjs`) tambien pasa.
//
// Portable Windows/Linux: TEMP_TARGET cubre $TEMP/$TMP/$TMPDIR, /tmp, \temp\, scratchpad,
// .../dev/scratch/ y /dev/null. Solo la ruta de este archivo en settings.json cambia por maquina.

const TEMP_TARGET =
	/^(\/dev\/null|\$null|nul)$|\$\{?(env:)?(TEMP|TMP|TMPDIR)\b|(^|[\\/])(tmp|temp)[\\/]|scratchpad|[\\/]dev[\\/]scratch[\\/]/i;

const IN_PLACE = /\bsed\s+(-[a-zA-Z]*i|--in-place)|\bperl\s+-[a-zA-Z]*i|\b(g?awk)\s+-i\s+inplace/;
const HEREDOC_INTERPRETER = /\b(python3?|node|perl|ruby|tsx|deno|bun)\b[^|;&\n]*<<<?/;
const INLINE_CODE = /\b(node|python3?|perl|ruby)\s+(-e|--eval|-c|-p)\b/;
const INLINE_WRITE = /writeFile|appendFile|createWriteStream|WriteAllText|open\([^)]*['"][wa]['"]/;
const PS_WRITERS = /\b(Set-Content|Add-Content|Out-File|Clear-Content)\b|\[(System\.)?IO\.File\]::(Write|Append)/i;

/**
 * Tapa el contenido de las comillas con `_`, conservando la longitud: un `>` o un `<<` dentro
 * de un string no es shell, y los indices siguen apuntando al mismo sitio del comando original.
 */
function unquoted(command) {
	return command.replaceAll(/'[^']*'|"(?:[^"\\]|\\.)*"/g, (m) => `${m[0]}${"_".repeat(m.length - 2)}${m.at(-1)}`);
}

/** Los destinos de cada `>` / `>>` fuera de comillas, sin contar `2>&1` ni `>&2`. */
function redirectTargets(command) {
	const targets = [];
	for (const match of unquoted(command).matchAll(/(\d|&)?>>?/g)) {
		// El destino se lee del original: en la version tapada su texto entre comillas no existe.
		const rest = command.slice(match.index + match[0].length);
		// Sin `(` ni `)`: en `$(cmd 2>/dev/null)` el `)` cierra la sustitucion, no es del nombre.
		const target = rest.match(/^\s*(&\d|"[^"]*"|'[^']*'|[^\s;|&<>()]+)?/)?.[1] ?? "";
		if (target.startsWith("&")) continue;
		targets.push(target.replaceAll(/^["']|["']$/g, ""));
	}
	return targets;
}

function psWriteTargetIsTemp(command) {
	const path = command.match(/-(?:Path|FilePath|LiteralPath)\s+("[^"]*"|'[^']*'|\S+)/i)?.[1] ?? "";
	return TEMP_TARGET.test(path.replaceAll(/^["']|["']$/g, ""));
}

function findViolation(command) {
	const masked = unquoted(command);
	if (IN_PLACE.test(masked)) return "edicion in-place (sed -i, perl -i, awk -i inplace)";
	if (HEREDOC_INTERPRETER.test(masked)) return "heredoc hacia un interprete";
	if (INLINE_CODE.test(masked) && INLINE_WRITE.test(command)) return "codigo inline que escribe archivos";
	if (PS_WRITERS.test(masked) && !psWriteTargetIsTemp(command)) return "cmdlet que escribe un archivo";
	const target = redirectTargets(command).find((t) => t && !TEMP_TARGET.test(t));
	if (target) return `redireccion a ${target}`;
	const tee = masked.match(/\|\s*tee\s+(?:-a\s+)?([^\s;|&()]+)/);
	if (tee && !TEMP_TARGET.test(tee[1])) return `tee hacia ${tee[1]}`;
	return null;
}

let input = "";
for await (const chunk of process.stdin) input += chunk;

let command = "";
try {
	command = String(JSON.parse(input).tool_input?.command ?? "");
} catch {
	process.exit(0);
}

const violation = findViolation(command);
if (violation) {
	process.stdout.write(
		JSON.stringify({
			hookSpecificOutput: {
				hookEventName: "PreToolUse",
				permissionDecision: "deny",
				permissionDecisionReason:
					`Bloqueado por ~/.claude/hooks/block-shell-edits.mjs (${violation}). Los archivos se ` +
					"modifican con Edit o Write (ver ~/.claude/CLAUDE.md). Si la salida es un log, " +
					"escribela en el scratchpad, en D:\\Dev\\scratch o en $TEMP.",
			},
		}),
	);
}
process.exit(0);
