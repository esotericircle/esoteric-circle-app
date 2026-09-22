import {onCall, HttpsError} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import * as logger from "firebase-functions/logger";

/**
 * IL LIVE DEI MAESTRI, LATO SERVER. Ordine EG, 23 settembre 2026.
 *
 * **Perche' queste porte esistono, e perche' non possono stare sul telefono.**
 * La guida Authentication di Protoface e' netta: *"Keep API keys server-side.
 * Anything shipped to a browser is readable."* E vale doppio per LiveKit: la
 * documentazione di Protoface dice che **la stanza e' nostra e il gettone del
 * lavoratore lo firmiamo noi**, quindi il segreto di LiveKit sta qui dentro e
 * da nessun'altra parte. **Chi ha quel segreto puo' entrare in qualunque
 * stanza di qualunque persona**: non e' una chiave che costa soldi se esce,
 * e' una chiave che costa la riservatezza di una conversazione.
 *
 * **Lo scarto trovato nella documentazione, e sta nel manifesto.** L'ordine
 * lascia intendere che la sessione LiveKit la governi Protoface. La pagina
 * `sessions/create-a-session` dice il contrario, verbatim: *"The customer
 * owns the room and mints worker_token; we never touch their LiveKit API key
 * or secret. The worker publishes protoface-avatar video and
 * protoface-avatar-audio output tracks."*
 */

const PROTOFACE_API_KEY = defineSecret("PROTOFACE_API_KEY");

/** La radice dell'API di Protoface, dalla documentazione del 23/09/2026. */
const PROTOFACE = "https://api.protoface.com/v1";

/**
 * GLI AVATAR CHE LA NOSTRA CHIAVE PUO' VEDERE. Ordine EG voce 07.
 *
 * **Perche' e' una porta e non uno script sul PC.** L'ordine chiede che gli
 * identificativi dei tre avatar li ricavi Code appena la chiave e'
 * disponibile. Ricavarli dal PC vorrebbe dire **leggere la chiave fuori dal
 * server**, cioe' rompere la regola nella riga stessa in cui la si applica.
 * Qui la chiave non lascia mai Secret Manager: la porta torna solo gli
 * identificativi e i nomi, che non sono segreti.
 *
 * **Chiusa ai soli fondatori**: non serve a nessun altro, e una porta che non
 * serve a nessuno e' aperta a chiunque.
 */
export const gliAvatarDiProtoface = onCall(
  {region: "europe-west1", secrets: [PROTOFACE_API_KEY]},
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Serve un account.");
    }
    // **`scope` e `limit` dalla documentazione**, pagina `list-avatars`:
    // `org` torna **solo gli avatar nostri**, `platform` solo quelli di
    // serie, `all` tutti e due. Senza `scope` la prima chiamata ha reso venti
    // `av_stock_*` e nessuno dei tre Maestri, che e' esattamente il modo in
    // cui una porta risponde bene a una domanda sbagliata.
    const ambito = (request.data?.ambito as string) ?? "org";
    const quanti = Math.min(Number(request.data?.quanti ?? 100), 100);
    const risposta = await fetch(
      `${PROTOFACE}/avatars?scope=${encodeURIComponent(ambito)}&limit=${quanti}`,
      {headers: {Authorization: `Bearer ${PROTOFACE_API_KEY.value()}`}}
    );
    if (!risposta.ok) {
      const testo = await risposta.text();
      logger.error("Protoface non elenca gli avatar", {
        stato: risposta.status,
        corpo: testo.slice(0, 500),
      });
      throw new HttpsError(
        "unavailable",
        `Protoface ha risposto ${risposta.status}`
      );
    }
    const dati = (await risposta.json()) as {
      data?: Array<Record<string, unknown>>;
      has_more?: boolean;
    };
    const elenco = dati.data ?? [];
    // **Solo cio' che non e' segreto.** Identificativo, nome e stato bastano
    // per agganciare i tre Maestri; tutto il resto resta dove sta.
    return {
      ambito,
      altriDopo: dati.has_more ?? false,
      quanti: elenco.length,
      avatar: elenco.map((a) => ({
        id: a.id,
        nome: a.name ?? a.display_name ?? null,
        stato: a.status ?? null,
      })),
    };
  }
);
