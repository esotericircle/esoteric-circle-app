#!/usr/bin/env node
const fs = require('fs');
const path = require('path');
const mode = process.argv[2] || 'reminder';
const REGOLA = [
  '=== PROTOCOLLO VERITA E MEMORIA, ESOTERIC CIRCLE ===',
  'Prima di affermare cosa e fatto, cosa manca, cosa esiste o quanti sono: VERIFICA sul filesystem e sul repo.',
  'Apri il file. Conta la cartella. Guarda il branch. Non rispondere mai a memoria ne a stima.',
  'La verita viva e sovrana sta in docs/STATO_VIVO.md. Se qualcosa cambia, aggiornalo integrando nella sezione giusta, senza condensare.',
  'Per i controlli di stato pesanti usa l agente custode-memoria. Per un audit indipendente usa l agente revisore-stato.',
  '===================================================='
].join('\n');
const CHIUSURA = [
  '=== CHIUSURA, CONTROLLO DI SCRITTURA ===',
  'Se in questa sessione hai cambiato lo stato reale del progetto (codice, asset, deploy, conteggi, funzioni live),',
  'aggiorna docs/STATO_VIVO.md e committalo INSIEME al lavoro, prima di considerare finito.',
  'Se non hai cambiato nulla di stato, ignora questo avviso.',
  '========================================'
].join('\n');
function leggiStato() {
  try { return fs.readFileSync(path.join(process.cwd(), 'docs', 'STATO_VIVO.md'), 'utf8'); }
  catch (e) { return '(docs/STATO_VIVO.md non trovato ora: leggilo appena disponibile e verifica sul repo prima di affermare.)'; }
}
if (mode === 'full') { process.stdout.write(REGOLA + '\n\nStato vivo corrente del progetto:\n\n' + leggiStato() + '\n'); }
else if (mode === 'chiusura') { process.stdout.write(CHIUSURA + '\n'); }
else { process.stdout.write(REGOLA + '\n'); }
