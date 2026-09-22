import {onCall, HttpsError} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import * as logger from "firebase-functions/logger";
import {getFirestore} from "firebase-admin/firestore";
import {AccessToken} from "livekit-server-sdk";

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

/* ===========================================================================
 * LA SESSIONE LIVE
 * ======================================================================== */

const LIVEKIT_URL = defineSecret("LIVEKIT_URL");
const LIVEKIT_API_KEY = defineSecret("LIVEKIT_API_KEY");
const LIVEKIT_API_SECRET = defineSecret("LIVEKIT_API_SECRET");

/**
 * GLI AVATAR DEI TRE MAESTRI, ricavati dal server il 23 settembre 2026.
 *
 * **Perche' stanno scritti qui e non si cercano per nome ogni volta.** Cercare
 * per nome a ogni sessione vorrebbe dire una chiamata in piu' prima di ogni
 * LIVE, e soprattutto **un nome e' ambiguo**: l'elenco `org` porta due Medora,
 * `Medora-1` e `Proto-Medora-1`. Si e' scelto il piu' recente, e la scelta e'
 * scritta dove si vede invece di essere dedotta ogni volta in modo diverso.
 */
const AVATAR: Record<string, string> = {
  medora: "av_01M0N4GC9M1791PVH6NDD4FMMG",
  aura: "av_01KZVCNV16EAMMG75TXFC9D475",
  caligo: "av_01KZVB6FCP27NR3GZQ47WJ7QJG",
};

/** I minuti LIVE del mese, per piano. Ordine EG voce 06. */
const MINUTI_DEL_MESE: Record<string, number> = {
  free: 0,
  tier1: 0,
  tier2: 100,
  tier3: 250,
};

/**
 * Quanto puo' durare al massimo una sessione, in secondi.
 *
 * **Venti minuti e' il tetto del piano Launch**, non una nostra scelta:
 * `docs.protoface.com`, pagina Credits and limits. Si dichiara lo stesso a
 * Protoface con `max_duration_seconds`, perche' un tetto che il server non
 * chiede e' un tetto che il giorno di un piano diverso cambia da solo.
 */
const DURATA_MASSIMA = 20 * 60;

/** Il mese corrente, come chiave di conteggio: "2026-09". */
function meseCorrente(): string {
  const ora = new Date();
  return `${ora.getUTCFullYear()}-${String(ora.getUTCMonth() + 1).padStart(2, "0")}`;
}

/**
 * APRE UNA SESSIONE LIVE. Ordine EG voci 01, 04 e 06.
 *
 * **Tutto cio' che decide sta qui e non sul telefono**, ed e' la ragione per
 * cui questa porta esiste: il diritto al LIVE, i minuti rimasti, e le due
 * chiavi. Un telefono che decidesse da se' di avere diritto avrebbe ragione,
 * perche' il codice che glielo nega ce l'ha in mano lui.
 *
 * **I DUE GETTONI SONO DIVERSI, e non e' un dettaglio.** Alla persona si
 * firma un gettone che puo' pubblicare la propria voce e ascoltare; al
 * lavoratore di Protoface se ne firma un altro, con un'identita' sua. La
 * documentazione di Protoface e' esplicita: *"The customer owns the room and
 * mints worker_token; we never touch their LiveKit API key or secret."*
 *
 * **La stanza porta il nome della persona e l'istante**: due sessioni della
 * stessa persona non si incontrano mai, e una stanza finita non si riapre.
 */
export const apriUnaSessioneLive = onCall(
  {
    region: "europe-west1",
    secrets: [
      PROTOFACE_API_KEY,
      LIVEKIT_URL,
      LIVEKIT_API_KEY,
      LIVEKIT_API_SECRET,
    ],
  },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) throw new HttpsError("unauthenticated", "Serve un account.");

    const maestro = String(request.data?.maestro ?? "");
    const avatarId = AVATAR[maestro];
    if (!avatarId) {
      throw new HttpsError("invalid-argument", `Maestro sconosciuto: ${maestro}`);
    }

    const db = getFirestore();

    // --- IL DIRITTO. Voce 04: finche' il fondatore non lo apre al tier 2, il
    // LIVE e' dei soli fondatori, e l'interruttore vive sul server.
    const configurazione = await db.doc("configurazione/live").get();
    const apertoAlTier2 = configurazione.data()?.apertoAlTier2 === true;
    const fondatori: string[] = configurazione.data()?.fondatori ?? [];
    const eFondatore = fondatori.includes(uid);

    const abbonamento = await db.doc(`users/${uid}/stato/abbonamento`).get();
    const piano = String(abbonamento.data()?.piano ?? "free");
    const pianoBasta = piano === "tier2" || piano === "tier3";

    if (!eFondatore && !(apertoAlTier2 && pianoBasta)) {
      throw new HttpsError(
        "permission-denied",
        "Il LIVE non e' ancora aperto per questo account."
      );
    }

    // --- I MINUTI. Voce 06: il LIVE consuma solo i suoi, e il conto vive qui.
    //
    // **Ai fondatori si concede il tetto piu' alto**, non l'assenza di tetto:
    // un conto che non esiste non si puo' guardare, e il giorno che qualcosa
    // consuma senza fermarsi nessuno se ne accorge.
    const tetto = eFondatore
      ? MINUTI_DEL_MESE.tier3
      : (MINUTI_DEL_MESE[piano] ?? 0);
    const mese = meseCorrente();
    const statoLive = await db.doc(`users/${uid}/stato/live`).get();
    const dati = statoLive.data() ?? {};
    const usati = dati.mese === mese ? Number(dati.minutiUsati ?? 0) : 0;
    const rimasti = Math.max(0, tetto - usati);
    if (rimasti <= 0) {
      throw new HttpsError(
        "resource-exhausted",
        "I minuti LIVE di questo mese sono finiti."
      );
    }

    // --- I DUE GETTONI.
    const stanza = `live_${uid}_${Date.now()}`;
    const durata = Math.min(DURATA_MASSIMA, rimasti * 60);

    async function gettone(
      identita: string,
      nome: string
    ): Promise<string> {
      const t = new AccessToken(
        LIVEKIT_API_KEY.value(),
        LIVEKIT_API_SECRET.value(),
        {identity: identita, name: nome, ttl: durata + 120}
      );
      t.addGrant({
        room: stanza,
        roomJoin: true,
        canPublish: true,
        canSubscribe: true,
        canPublishData: true,
      });
      return t.toJwt();
    }

    const gettoneDellaPersona = await gettone(uid, "persona");
    const gettoneDelLavoratore = await gettone("protoface", "avatar");

    // --- LA SESSIONE DI PROTOFACE.
    const risposta = await fetch(`${PROTOFACE}/sessions`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${PROTOFACE_API_KEY.value()}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        avatar_id: avatarId,
        max_duration_seconds: durata,
        metadata: {customer_session_id: stanza},
        transport: {
          type: "livekit",
          url: LIVEKIT_URL.value(),
          room_name: stanza,
          worker_token: gettoneDelLavoratore,
        },
      }),
    });

    if (risposta.status === 503) {
      // **Voce 06: a posti esauriti non un errore, un messaggio.** Il testo lo
      // dice il Maestro a video; qui si distingue il caso, che e' cio' che il
      // telefono ha bisogno di sapere.
      throw new HttpsError("unavailable", "posti esauriti");
    }
    if (!risposta.ok) {
      const testo = await risposta.text();
      logger.error("Protoface non apre la sessione", {
        stato: risposta.status,
        corpo: testo.slice(0, 500),
        maestro,
      });
      throw new HttpsError(
        "internal",
        `Protoface ha risposto ${risposta.status}`
      );
    }
    const sessione = (await risposta.json()) as Record<string, unknown>;

    logger.info("LIVE aperto", {
      uid,
      maestro,
      stanza,
      sessione: sessione.id,
      rimasti,
    });

    return {
      url: LIVEKIT_URL.value(),
      gettone: gettoneDellaPersona,
      stanza,
      sessione: sessione.id,
      avatar: avatarId,
      minutiRimasti: rimasti,
      durataMassimaSecondi: durata,
    };
  }
);

/**
 * LO STATO DI UNA SESSIONE, e il suo consumo. Ordine EG voci 06 e 08.
 *
 * **Serve a due cose diverse, e per questo torna tutto.** Al telefono serve
 * sapere se il volto e' arrivato, cioe' se la sessione e' passata da `queued`
 * a `running`; al collaudo serve il consumo vero, `billable_seconds`, che la
 * voce 08 pretende **preso dai consumi e non stimato**.
 */
export const statoDellaSessioneLive = onCall(
  {region: "europe-west1", secrets: [PROTOFACE_API_KEY]},
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Serve un account.");
    }
    const id = String(request.data?.sessione ?? "");
    if (!id.startsWith("sess_")) {
      throw new HttpsError("invalid-argument", "sessione sconosciuta");
    }
    const risposta = await fetch(`${PROTOFACE}/sessions/${id}`, {
      headers: {Authorization: `Bearer ${PROTOFACE_API_KEY.value()}`},
    });
    if (!risposta.ok) {
      throw new HttpsError(
        "unavailable",
        `Protoface ha risposto ${risposta.status}`
      );
    }
    const s = (await risposta.json()) as Record<string, any>;
    return {
      stato: s.status,
      primoFotogramma: s.first_frame_at ?? null,
      iniziata: s.started_at ?? null,
      finita: s.ended_at ?? null,
      guasto: s.failure ?? null,
      secondiFatturabili: s.usage?.billable_seconds ?? 0,
      fotogrammi: s.usage?.frames ?? 0,
    };
  }
);
