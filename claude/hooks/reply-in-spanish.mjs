#!/usr/bin/env node
// Hook Stop (global): si la respuesta que acaba de cerrar el turno esta escrita en ingles, la
// bloquea y pide reescribirla en espanol.
//
// `language: "Español"` en settings.json y la regla de CLAUDE.md son orientativos: tras una
// tarea larga, con muchas herramientas de por medio, el reporte final a veces sale en ingles.
// Aqui se mide el texto que ve el usuario y, si domina el ingles, el turno no termina.
//
// Se mide el texto del asistente desde el ultimo mensaje del usuario, sin bloques de codigo,
// codigo inline, rutas ni URLs: un reporte en espanol cita comandos e identificadores en ingles
// y no debe contar en contra. La decision compara palabras funcionales (articulos, preposiciones,
// pronombres) de cada idioma, que no aparecen en identificadores.
//
// `stop_hook_active` evita el bucle: si el turno ya viene de un bloqueo de este hook, pasa.

import { readFileSync } from "node:fs";

const ENGLISH = new Set(
	("the and of to is are was were be been this that these those with for from into on in it its " +
		"you your we our they their there here what which who when where why how not but or if then " +
		"than so can will would should could have has had do does did done just also now all any " +
		"each both only after before about because while still already yet let i'm it's don't " +
		"i'll we'll you'll there's that's isn't doesn't won't can't")
		.split(" "),
);
const SPANISH = new Set(
	("el la los las un una unos unas de del al y o que en es son fue ser está están estaba con " +
		"por para sin sobre entre como pero si ya no lo le les se su sus mi tu este esta estos estas " +
		"ese esa eso aquí ahí también cuando donde porque mientras todavía hay muy más menos cada " +
		"todo todos nada algo qué cómo cuál dónde quedó queda hace hizo puedes tienes")
		.split(" "),
);
const MIN_ENGLISH = 12;

/** El texto que se lee como prosa: fuera bloques de codigo, codigo inline, URLs y rutas. */
function prose(text) {
	return text
		.replaceAll(/```[\s\S]*?```/g, " ")
		.replaceAll(/`[^`\n]*`/g, " ")
		.replaceAll(/https?:\/\/\S+/g, " ")
		.replaceAll(/\S*[\\/]\S*/g, " ");
}

/** Cuantas palabras funcionales de cada idioma hay en el texto. */
function count(text) {
	let en = 0;
	let es = 0;
	for (const word of prose(text).toLowerCase().match(/[\p{L}']+/gu) ?? []) {
		if (ENGLISH.has(word)) en++;
		if (SPANISH.has(word)) es++;
	}
	return { en, es };
}

/** Si la entrada es un mensaje que escribio el usuario, no el resultado de una herramienta. */
function isUserPrompt(entry) {
	if (entry.type !== "user" || entry.isMeta) return false;
	const content = entry.message?.content;
	if (typeof content === "string") return true;
	return Array.isArray(content) && content.some((block) => block.type === "text");
}

/** El texto del asistente desde el ultimo mensaje del usuario, leido del transcript. */
function turnText(transcriptPath) {
	const lines = readFileSync(transcriptPath, "utf8").split("\n");
	const parts = [];
	for (let i = lines.length - 1; i >= 0; i--) {
		if (!lines[i].trim()) continue;
		let entry;
		try {
			entry = JSON.parse(lines[i]);
		} catch {
			continue;
		}
		if (isUserPrompt(entry)) break;
		if (entry.type !== "assistant" || entry.isSidechain) continue;
		for (const block of entry.message?.content ?? []) {
			if (block.type === "text") parts.unshift(block.text);
		}
	}
	return parts.join("\n");
}

let input = "";
for await (const chunk of process.stdin) input += chunk;

let text = "";
try {
	const data = JSON.parse(input);
	if (data.stop_hook_active) process.exit(0);
	text = data.transcript_path ? turnText(data.transcript_path) : String(data.last_assistant_message ?? "");
} catch {
	process.exit(0);
}

const { en, es } = count(text);
if (en >= MIN_ENGLISH && en > es * 2) {
	process.stdout.write(
		JSON.stringify({
			decision: "block",
			reason:
				`Bloqueado por ~/.claude/hooks/reply-in-spanish.mjs: tu respuesta esta en ingles ` +
				`(${en} palabras funcionales en ingles frente a ${es} en espanol). Reescribela entera ` +
				"en espanol, con acentos. Comandos, rutas e identificadores van tal cual.",
		}),
	);
}
process.exit(0);
