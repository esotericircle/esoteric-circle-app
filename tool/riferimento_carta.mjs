// IL MOTORE DEL RIFERIMENTO: Swiss Ephemeris, in WebAssembly.
//
// **PERCHE' NON E' pyswisseph, come chiedeva l'ordine 2170.** Su questa
// macchina `pip install pyswisseph` non arriva in fondo: il pacchetto pubblica
// solo il sorgente, la compilazione vuole Microsoft Visual C++ 14 o superiore,
// e i Build Tools installati qui non hanno il componente C++ (esiste
// `BuildTools\Common7` ma non `VC`). Nessuna versione di pyswisseph pubblica
// una wheel per Windows, verificato con `pip install --only-binary :all:` su
// tutte e tre le versioni disponibili.
//
// **IL MOTORE E' LO STESSO.** `swisseph-wasm` e' la libreria Swiss Ephemeris
// di Astrodienst compilata in WebAssembly: stesse funzioni, stessi numeri.
// Che siano gli stessi non e' un'opinione: `riferimento_carta.py --controllo`
// li confronta con quelli dell'ordine 2170, presi a monte con pyswisseph, e
// pretende che coincidano alla quarta cifra decimale su tutte e ventisette le
// quantita'.
//
// **LICENZA, ed e' la stessa regola dell'ordine.** Swiss Ephemeris e' AGPL e
// questo involucro e' GPL 3. Restano sul PC di sviluppo: **non entrano
// nell'app e non vengono distribuiti**. Nel repository entrano solo i NUMERI,
// che sono fatti sul cielo e non codice. Per questo la dipendenza vive in
// `tool/package.json` e non nel `pubspec.yaml`, e `tool/node_modules` non e'
// versionato.
//
// Uso, tutto in UTC:
//   node tool/riferimento_carta.mjs <anno> <mese> <giorno> <ora> <minuto> <lat> <lon>
import SwissEph from 'swisseph-wasm';

const [anno, mese, giorno, ora, minuto, lat, lon] = process.argv
  .slice(2)
  .map(Number);

if ([anno, mese, giorno, ora, minuto, lat, lon].some(Number.isNaN)) {
  console.error(
    'uso: node riferimento_carta.mjs <anno> <mese> <giorno> <ora> <minuto> <lat> <lon>  (tempo UTC)',
  );
  process.exit(2);
}

const swe = new SwissEph();
await swe.initSwissEph();

// MODALITA' MOSHIER: nessun file di effemeridi da scaricare, e la precisione
// resta dentro il secondo d'arco per i corpi che ci servono. E' la stessa
// modalita' con cui sono stati presi i numeri di controllo dell'ordine.
const flag = swe.SEFLG_SWIEPH | swe.SEFLG_MOSEPH;

const jd = swe.julday(anno, mese, giorno, ora + minuto / 60.0, 1);

// I dodici corpi che la carta dell'app porta, col nome che usa il motore
// remoto: cosi' i numeri si confrontano senza tradurre niente per strada.
const corpi = [
  ['sun', 0],
  ['moon', 1],
  ['mercury', 2],
  ['venus', 3],
  ['mars', 4],
  ['jupiter', 5],
  ['saturn', 6],
  ['uranus', 7],
  ['neptune', 8],
  ['pluto', 9],
  ['north_node', 10], // Nodo MEDIO, come il motore remoto
  ['lilith', 12], // Luna Nera media
];

const fuori = { jd_ut: jd, corpi: {}, angoli: {}, cuspidi: [] };

for (const [nome, id] of corpi) {
  const p = swe.calc_ut(jd, id, flag);
  fuori.corpi[nome] = p[0];
}

// CHIRONE NON C'E', e si dichiara invece di ometterlo in silenzio: in
// modalita' Moshier Swiss Ephemeris non lo calcola, perche' e' un asteroide e
// non un pianeta dei polinomi analitici. Il motore remoto lo restituisce, ma
// qui non c'e' niente con cui confrontarlo.
fuori.chirone = null;

const case_ = swe.houses(jd, lat, lon, 'P'); // P: Placidus
for (let i = 1; i <= 12; i++) {
  fuori.cuspidi.push(case_.cusps[i]);
}
fuori.angoli.asc = case_.ascmc[0];
fuori.angoli.mc = case_.ascmc[1];
fuori.angoli.vertex = case_.ascmc[3];

console.log(JSON.stringify(fuori, null, 2));
