// Encrypts each page in src/ with the PIN (PBKDF2 + AES-GCM) into docs/ for GitHub Pages.
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { webcrypto as crypto } from "node:crypto";
const PIN = process.env.SITE_PIN;
if (!PIN) { console.error("Set SITE_PIN, e.g. SITE_PIN=xxxx node encrypt.mjs"); process.exit(1); }
const ITER = 600000;
const b64 = u => Buffer.from(u).toString("base64");
mkdirSync("docs", { recursive: true });
writeFileSync("docs/.nojekyll", "");
for (const page of ["index.html", "details.html"]) {
  const html = readFileSync("src/" + page);
  const salt = crypto.getRandomValues(new Uint8Array(16)), iv = crypto.getRandomValues(new Uint8Array(12));
  const base = await crypto.subtle.importKey("raw", new TextEncoder().encode(PIN), "PBKDF2", false, ["deriveKey"]);
  const key = await crypto.subtle.deriveKey({ name: "PBKDF2", salt, iterations: ITER, hash: "SHA-256" }, base, { name: "AES-GCM", length: 256 }, false, ["encrypt"]);
  const ct = new Uint8Array(await crypto.subtle.encrypt({ name: "AES-GCM", iv }, key, html));
  const shell = readFileSync("gate.html", "utf8").replace("__PAYLOAD__", JSON.stringify({ s: b64(salt), i: b64(iv), c: b64(ct), n: ITER }));
  writeFileSync("docs/" + page, shell);
  console.log(page, html.length, "->", shell.length);
}
