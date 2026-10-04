import {onRequest} from "firebase-functions/v2/https";
import {getFirestore} from "firebase-admin/firestore";
import {codiceScritto, soloIlPubblico} from "./sociale";

/**
 * LA PAGINA DEL LINK D'INVITO, ordine EY voce 04 punto 2.
 *
 * Il link dell'invito vive sul dominio che il progetto usa gia', accanto a
 * `/entra` di `link_di_ingresso.dart`: `https://esotericircle.app/i/CODICE`.
 * Chi lo apre SENZA l'app arriva qui e vede chi lo ha chiamato, il codice da
 * incollare quando si registra, e la via per lo store quando gli store ci
 * saranno (`INDIRIZZI_DEGLI_STORE`, vuoti finche' l'app non e' pubblicata,
 * ordine EZ voce 07). Chi lo apre CON l'app
 * entra dritto nella richiesta di legame (App Links su Android, lo schema
 * `esotericircle://` dal pulsante qui sotto ovunque).
 *
 * **La pagina mostra solo cio' che il profilo pubblico gia' dice**: lo
 * pseudonimo. Mai il sigillo, mai altro: il codice e' opaco e il server e'
 * il solo che sa tradurlo. Un codice scaduto o inventato da' la stessa
 * pagina neutra, senza dire se il codice e' esistito.
 *
 * Nessuna chiamata al modello. Due letture per apertura: il codice e il
 * profilo pubblico di chi invita.
 */
export const paginaDellInvito = onRequest(
  {region: "europe-west1", timeoutSeconds: 15, memory: "256MiB"},
  async (req, res) => {
    const pezzi = req.path.split("/").filter((p) => p.length > 0);
    const grezzo = pezzi[pezzi.length - 1] ?? "";
    const corpo = grezzo.split(".")[0];
    const codice = codiceScritto(corpo);
    let nome: string | null = null;
    if (codice !== null) {
      try {
        const db = getFirestore();
        const c = await db.collection("codici_invito").doc(codice).get();
        const d = c.data();
        if (d && typeof d.uid === "string" && typeof d.scade === "number" &&
          d.scade > Date.now()) {
          const p = await db.collection("profili").doc(d.uid).get();
          if (p.exists) nome = soloIlPubblico(p.data() ?? {}).nome || null;
        }
      } catch (errore) {
        nome = null;
      }
    }
    res.set("Cache-Control", "private, max-age=60");
    res.set("Content-Type", "text/html; charset=utf-8");
    res.status(200).send(laPagina(nome, nome === null ? null : grezzo));
  }
);

/**
 * **GLI INDIRIZZI DEGLI STORE, in un dato solo, ordine EZ voce 07.** Vuoti
 * adesso: l'app non e' pubblicata, e un rimando a uno store che non esiste
 * sarebbe un vicolo cieco. Quando il fondatore li dara', si scrivono qui e
 * la pagina li mostra senza che nessuno riscriva altro. Vuoti, i pulsanti
 * non compaiono: non spenti, non con un avviso.
 */
export const INDIRIZZI_DEGLI_STORE: {android: string; iphone: string} = {
  android: "",
  iphone: "",
};

/** La riga sola della pagina, finche' l'invito vale. */
export const RIGA_DEL_CODICE =
  "Scarica Esoteric Circle e incolla questo codice quando ti registri";

/** Il testo che finisce nell'HTML, senza nessun carattere che lo apra. */
function pulito(testo: string): string {
  return testo.replace(/[&<>"']/g, (c) => ({
    "&": "&amp;", "<": "&lt;", ">": "&gt;", "\"": "&quot;", "'": "&#39;",
  }[c] ?? c));
}

export function laPagina(
  nome: string | null,
  codice: string | null,
  store: {android: string; iphone: string} = INDIRIZZI_DEGLI_STORE,
): string {
  const chi = nome === null ?
    "Il Cerchio ti chiama" :
    `${pulito(nome)} ti chiama nel suo Cerchio`;
  const blocco = codice === null ?
    `<p class="nota">Questo invito non vale più. Chiedine uno nuovo a chi te
    l’ha mandato, oppure entra nel Cerchio da solo.</p>` :
    `<p class="nota">${RIGA_DEL_CODICE}.</p>
    <div class="codice" id="codice">${pulito(codice)}</div>
    <button onclick="navigator.clipboard &amp;&amp; navigator.clipboard.writeText(
      document.getElementById('codice').textContent)">Copia il codice</button>
    <a class="pulsante" href="esotericircle://i/${pulito(codice)}">Ho già l’app: apri l’invito</a>`;
  return `<!doctype html>
<html lang="it"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="robots" content="noindex">
<title>Esoteric Circle, un invito</title>
<style>
:root{--fondo:#0b0a1a;--oro:#d8b25a;--testo:#efe8d6;--tenue:#a79f8c}
body{margin:0;background:var(--fondo);color:var(--testo);font-family:Georgia,serif;
display:flex;min-height:100vh;align-items:center;justify-content:center;padding:16px;box-sizing:border-box}
main{max-width:420px;text-align:center}
.cerchio{width:120px;height:120px;margin:0 auto 24px;border-radius:50%;
border:2px solid var(--oro);box-shadow:0 0 40px rgba(216,178,90,.35)}
h1{font-weight:normal;font-size:26px;line-height:1.3;margin:0 0 16px}
.nota{color:var(--tenue);font-size:16px;line-height:1.5}
.codice{font-family:monospace;font-size:30px;letter-spacing:6px;color:var(--oro);
margin:20px 0;padding:12px;border:1px solid rgba(216,178,90,.4);border-radius:12px}
button,.pulsante{display:block;width:100%;margin:12px 0;padding:14px;border-radius:28px;
border:1px solid var(--oro);background:transparent;color:var(--testo);font-size:16px;
text-decoration:none;box-sizing:border-box;font-family:inherit}
.store{color:var(--oro)}
</style></head>
<body><main>
<div class="cerchio" aria-hidden="true"></div>
<h1>${chi}</h1>
${blocco}
${store.android.length > 0 ?
    `<a class="pulsante store" href="${pulito(store.android)}">Scarica Esoteric Circle per Android</a>` : ""}
${store.iphone.length > 0 ?
    `<a class="pulsante store" href="${pulito(store.iphone)}">Scarica Esoteric Circle per iPhone</a>` : ""}
</main></body></html>`;
}
