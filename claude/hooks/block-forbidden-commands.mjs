#!/usr/bin/env node
// @ts-check
// Hook PreToolUse (global) de Bash y PowerShell: corta los comandos que ~/.claude/CLAUDE.md prohibe.
//
// Lo que aqui se bloquea ya esta escrito en CLAUDE.md, pero como instruccion es orientativa:
// una sesion larga, un subagente o un modo automatico la olvidan. Un hook corre siempre,
// tambien dentro de un subagente.
//
// Va en un hook y no en `permissions.deny` porque un patron de permisos casa por prefijo: no ve
// un `git commit` detras de un `cd x &&`, ni dentro de PowerShell, ni un `/MIR` en mitad de un
// `robocopy`.
//
// Solo reglas universales. Lo propio de un proyecto (su gestor de paquetes, sus puertos) va en
// un hook de ese proyecto. `ask` no bloquea: le pasa la decision al usuario, para lo que la
// regla dice "pregunta siempre".
//
// Portable Windows/Linux. Solo la ruta de este archivo en settings.json cambia por maquina.

/**
 * @typedef {object} CommandRule
 * @property {RegExp} pattern Se prueba contra el comando con el contenido de las comillas tapado.
 * @property {(command: string) => boolean} [applies] Condicion extra, sobre el comando original.
 * @property {"deny" | "ask"} decision
 * @property {string} reason
 */

// Temporales y caches regenerables: borrarlos no pide confirmacion.
const TEMP_TARGET =
	/\$\{?(env:)?(TEMP|TMP|TMPDIR)\b|(^|[\s"'\\/])(tmp|temp)[\\/]|scratchpad|[\\/]dev[\\/]scratch[\\/]|node_modules|[\\/]\.next\b|[\\/]coverage\b/i;

const GIT_WRITE =
	/\bgit\s+(?:-[cC]\s+\S+\s+)*(add|commit|push|pull|reset|rebase|merge|checkout|switch|restore|clean|stash|cherry-pick|revert|tag|mv|rm|apply|am)\b/;

/** @type {readonly CommandRule[]} */
const RULES = [
	{
		pattern: GIT_WRITE,
		decision: "deny",
		reason:
			"git de escritura: el commit, el push y todo lo que cambia el arbol los hace el usuario " +
			"(~/.claude/CLAUDE.md, Interaccion). Sugiere el comando; de lectura valen status, log, diff y show.",
	},
	{
		pattern: /\brobocopy\b/i,
		applies: (command) => /\/MIR\b/i.test(command) && !/\/XJ\b/i.test(command),
		decision: "deny",
		reason: "robocopy /MIR sin /XJ atraviesa las junctions y vacia la carpeta real del otro lado. Anade /XJ.",
	},
	{
		pattern: /\bprettier\b[^;&|]*--write\b/,
		applies: (command) => /--write[^;&|]*(\*|\$\(|`)|xargs[^;&|]*prettier/.test(command),
		decision: "deny",
		reason:
			"prettier --write con un glob o una lista calculada reformatea archivos ajenos al cambio. " +
			"Escribe en el comando las rutas de los archivos editados (~/.claude/CLAUDE.md, Formato).",
	},
	{
		pattern: /\brm\s+-[a-zA-Z]*[rR]|\bRemove-Item\b[^;&|]*-Recurse|\brmdir\s+\/s\b|\brd\s+\/s\b/i,
		applies: (command) => !TEMP_TARGET.test(command),
		decision: "ask",
		reason:
			"borrado recursivo fuera de un temporal: el trabajo se confirma siempre antes de borrar, y " +
			"`Remove-Item -Force` no usa papelera y atraviesa junctions (~/.claude/CLAUDE.md, Confirmar antes de borrar).",
	},
];

/**
 * Tapa el contenido de las comillas con `_`, conservando la longitud: un `git commit` dentro de
 * un patron de busqueda o de un mensaje no es un comando.
 *
 * @param {string} command
 */
function unquoted(command) {
	return command.replaceAll(/'[^']*'|"(?:[^"\\]|\\.)*"/g, (m) => `${m[0]}${"_".repeat(m.length - 2)}${m.at(-1)}`);
}

/** @param {string} command */
function findRule(command) {
	const masked = unquoted(command);
	return RULES.find((rule) => rule.pattern.test(masked) && (rule.applies?.(command) ?? true));
}

let input = "";
for await (const chunk of process.stdin) input += chunk;

let command = "";
try {
	command = String(JSON.parse(input).tool_input?.command ?? "");
} catch {
	process.exit(0);
}

const rule = findRule(command);
if (rule) {
	process.stdout.write(
		JSON.stringify({
			hookSpecificOutput: {
				hookEventName: "PreToolUse",
				permissionDecision: rule.decision,
				permissionDecisionReason: `~/.claude/hooks/block-forbidden-commands.mjs: ${rule.reason}`,
			},
		}),
	);
}
process.exit(0);
