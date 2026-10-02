// Barra de estado de Claude Code: modelo, contexto usado y carpeta.
//
// El contexto se muestra en tokens y no solo en porcentaje porque el objetivo medido
// (`pnpm claude:usage` en base-template) es un contexto mediano por debajo de 120k, y con
// ventanas de 1M el porcentaje esconde ese umbral. Verde hasta 120k, amarillo hasta 300k,
// rojo por encima: a partir de ahí conviene cerrar el objetivo y abrir sesión nueva.

let input = "";
for await (const chunk of process.stdin) input += chunk;

let data = {};
try {
	data = JSON.parse(input);
} catch {
	// Sin datos se pinta la barra vacía antes que romperla.
}

const model = data.model?.display_name ?? "?";
const folder = String(data.workspace?.current_dir ?? data.cwd ?? "").split(/[\\/]/).at(-1) ?? "";
const usage = data.context_window?.current_usage;
const tokens = usage
	? (usage.input_tokens ?? 0) + (usage.cache_creation_input_tokens ?? 0) + (usage.cache_read_input_tokens ?? 0)
	: 0;
const pct = Math.round(data.context_window?.used_percentage ?? 0);

const color = tokens < 120_000 ? "\u001B[32m" : tokens < 300_000 ? "\u001B[33m" : "\u001B[31m";
const reset = "\u001B[0m";
const context = usage ? `${color}${Math.round(tokens / 1000)}k (${pct}%)${reset}` : "sin datos aún";

process.stdout.write(`[${model}] contexto ${context} · ${folder}`);
