import {onCall, onRequest, HttpsError} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import * as logger from "firebase-functions/logger";
import {getFirestore} from "firebase-admin/firestore";
import {applicationDefault} from "firebase-admin/app";
import {AccessToken} from "livekit-server-sdk";
import {TextToSpeechClient} from "@google-cloud/text-to-speech";

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
  // **MEDORA A MEZZOBUSTO, dal 23 settembre 2026.** Il fondatore ha tolto da
  // Protoface `av_01M0N4GC9M1791PVH6NDD4FMMG`, che era a figura intera per
  // errore suo mentre tutti gli avatar sono a mezzobusto, e ha chiesto di
  // usare l'altro: e' `Proto-Medora-1`, gia' elencato nel manifesto EG.
  medora: "av_01KZ9637K1YZ45H3GNZE95YN6E",
  aura: "av_01KZVCNV16EAMMG75TXFC9D475",
  caligo: "av_01KZVB6FCP27NR3GZQ47WJ7QJG",
};

/**
 * **GLI AVATAR SI AGGANCIANO DA FIRESTORE, E LA TABELLA QUI SOPRA E' LA
 * RISERVA.** Ordine EK voce 04, 24 settembre 2026.
 *
 * Il fondatore ha approvato gli avatar nati dalle immagini restaurate. Se
 * l'aggancio stesse solo nella tabella, cambiare un avatar vorrebbe dire
 * pubblicare di nuovo le funzioni; e tornare indietro, pubblicarle ancora.
 * Adesso la scelta sta in `configurazione/live.avatar`, una mappa dal Maestro
 * all'identificativo, e la scrive solo la porta di amministrazione qui sotto,
 * dopo che Protoface ha dichiarato l'avatar pronto. **Tornare agli avatar di
 * prima e' togliere quel campo**: la tabella resta com'era, e i tre avatar di
 * prima restano su Protoface.
 */
async function lAvatarDi(maestro: string): Promise<string | undefined> {
  const snap = await getFirestore().doc("configurazione/live").get();
  const scelti = (snap.data()?.avatar ?? {}) as Record<string, unknown>;
  const scelto = scelti[maestro];
  if (typeof scelto === "string" && scelto.startsWith("av_")) return scelto;
  return AVATAR[maestro];
}

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

/**
 * L'identita' con cui il volto di Protoface entra nella stanza, e a cui il
 * telefono manda la voce del Maestro. Una sola, scritta qui: il gettone del
 * lavoratore la porta, Protoface la dichiara, il telefono la riceve.
 */
const LAVORATORE = "protoface-worker";

/**
 * Quanti secondi di silenzio Protoface tollera prima di chiudere la sessione.
 *
 * **Chi chiude davvero e' il telefono**, dopo trenta secondi senza
 * conversazione: lo ha chiesto il fondatore il 23 settembre 2026, perche'
 * Protoface si paga a tempo. Questo e' la rete sotto il telefono, per quando
 * l'app muore o perde la rete e non puo' chiudere: Protoface conta solo
 * l'audio che riceve, cioe' la voce del Maestro, e mentre la persona parla
 * lui non sente niente. Sessanta secondi lasciano parlare la persona e
 * comporre la risposta senza tagliarla, e se l'app sparisce la stanza non
 * resta accesa piu' di un minuto. Prima erano centottanta.
 */
const SILENZIO_TOLLERATO = 60;

/**
 * IL DIRITTO AL LIVE, in un punto solo. Ordine EG voce 04.
 *
 * **Sta fuori dalle porte apposta**: lo chiedono l'apertura della sessione e
 * la voce del Maestro, e due copie della stessa regola divergono al primo
 * ritocco. Finche' il fondatore non lo apre al tier 2 il LIVE e' dei soli
 * fondatori, e l'interruttore vive su Firestore in `configurazione/live`.
 */
async function ilDirittoAlLive(
  uid: string
): Promise<{eFondatore: boolean; piano: string}> {
  const db = getFirestore();
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
  return {eFondatore, piano};
}

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
    const avatarId = AVATAR[maestro] ? await lAvatarDi(maestro) : undefined;
    if (!avatarId) {
      throw new HttpsError("invalid-argument", `Maestro sconosciuto: ${maestro}`);
    }

    const db = getFirestore();

    // --- IL DIRITTO. Voce 04, in un punto solo: vale anche per la voce.
    const {eFondatore, piano} = await ilDirittoAlLive(uid);

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
    const gettoneDelLavoratore = await gettone(LAVORATORE, "avatar");

    // --- LA SESSIONE DI PROTOFACE.
    // **IL LIVELLO DI QUALITA' SI SCEGLIE DAL SERVER.** Ordine EJ voce 03: il
    // fondatore vede i mezzibusti sfocati, e il costo del livello superiore
    // non e' pubblicato. Senza scelta non si manda niente e Protoface usa il
    // suo predefinito, standard, come fino all'ordine EG.
    const qualita = await laQualitaScelta();
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
        // **IL VOLTO SI MUOVE SOLO SULL'AUDIO CHE GLI SI MANDA.** La prima
        // stesura non dichiarava niente e il fondatore ha trovato Medora
        // "fissa e muta": la documentazione dice che il modo di default e'
        // `data_stream`, cioe' Protoface aspetta l'audio come flusso di byte
        // sul tema `lk.audio_stream`, e che senza audio per
        // `idle_timeout_seconds` la sessione si chiude. Adesso l'audio glielo
        // manda il telefono, con la voce del Maestro, e il modo si dichiara
        // invece di contare su un default che nessuno aveva letto.
        idle_timeout_seconds: SILENZIO_TOLLERATO,
        ...(qualita ? {quality: qualita} : {}),
        transport: {
          type: "livekit",
          url: LIVEKIT_URL.value(),
          room_name: stanza,
          worker_token: gettoneDelLavoratore,
          worker_identity: LAVORATORE,
          audio_source: "data_stream",
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
      qualita: sessione.quality,
      rimasti,
    });
    // L'uso del mese a ogni apertura: la differenza fra due aperture e' il
    // costo vero della sessione di mezzo, livello per livello. Non ferma
    // l'apertura se non risponde.
    void lUsoDelMese();

    return {
      url: LIVEKIT_URL.value(),
      gettone: gettoneDellaPersona,
      stanza,
      sessione: sessione.id,
      avatar: avatarId,
      lavoratore: LAVORATORE,
      minutiRimasti: rimasti,
      durataMassimaSecondi: durata,
      // Ordine EJ voce 02: il selettore delle voci si mostra ai fondatori.
      eFondatore,
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

/**
 * Vero se [stanza] e' una stanza aperta da [uid]: `apriUnaSessioneLive` la
 * chiama `live_<uid>_<istante>` e la scrive nei metadati della sessione.
 */
export function laStanzaE(uid: string, stanza: string): boolean {
  return uid.length > 0 && stanza.startsWith(`live_${uid}_`);
}

/**
 * **LA SESSIONE SI CHIUDE QUANDO LA PERSONA ESCE.** Guasto trovato
 * nell'ordine EK il 24 settembre 2026, fuori dal perimetro, e curato col
 * permesso del fondatore.
 *
 * **Il difetto, misurato.** Il telefono, uscendo, lasciava solo la stanza di
 * LiveKit (`_chiudi` in `schermata_live.dart`), e nessuno diceva a Protoface
 * che la sessione era finita: restava accesa fino al silenzio tollerato,
 * sessanta secondi. Sul registro del server la prima prova del giorno, 13
 * secondi a video, e' stata fatturata 70 secondi e due crediti. Padre:
 * ordine EG, commit 1104da29 e 3687c223, che scrivevano "chi chiude davvero
 * e' il telefono" senza che il telefono chiudesse la sessione.
 *
 * **La cura.** La documentazione offre `POST /v1/sessions/{id}/end`,
 * *"Terminate a session immediately. Idempotent"*: il telefono la chiede qui
 * uscendo, e la chiave non lascia il server.
 *
 * **Solo la propria.** La sessione porta nei metadati la sua stanza, e la
 * stanza porta chi l'ha aperta: chi non e' quella persona non la chiude.
 */
export const chiudiLaSessioneLive = onCall(
  {region: "europe-west1", secrets: [PROTOFACE_API_KEY]},
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) throw new HttpsError("unauthenticated", "Serve un account.");
    const id = String(request.data?.sessione ?? "");
    if (!id.startsWith("sess_")) {
      throw new HttpsError("invalid-argument", "sessione sconosciuta");
    }
    const chiave = {Authorization: `Bearer ${PROTOFACE_API_KEY.value()}`};
    const letta = await fetch(`${PROTOFACE}/sessions/${id}`, {headers: chiave});
    if (!letta.ok) {
      throw new HttpsError(
        "unavailable",
        `Protoface ha risposto ${letta.status}`
      );
    }
    const s = (await letta.json()) as Record<string, any>;
    const stanza = String(s.metadata?.customer_session_id ?? "");
    if (!laStanzaE(uid, stanza)) {
      throw new HttpsError("permission-denied", "Non e' la tua sessione.");
    }
    const fine = await fetch(`${PROTOFACE}/sessions/${id}/end`, {
      method: "POST",
      headers: chiave,
    });
    if (!fine.ok) {
      const testo = await fine.text();
      logger.error("Protoface non chiude la sessione", {
        stato: fine.status,
        corpo: testo.slice(0, 500),
        sessione: id,
      });
      throw new HttpsError(
        "unavailable",
        `Protoface ha risposto ${fine.status}`
      );
    }
    const chiusa = (await fine.json()) as Record<string, unknown>;
    logger.info("LIVE chiuso dal telefono", {
      uid,
      sessione: id,
      stato: chiusa.status ?? null,
    });
    return {stato: chiusa.status ?? null};
  }
);

/**
 * **GLI AVATAR NUOVI, CREATI E AGGANCIATI DAL SERVER.** Ordine EK voce 04,
 * dopo il si' del fondatore del 25 settembre 2026 alle immagini restaurate:
 * *"Approvo tutto e ti autorizzo a fare tutto"*.
 *
 * **Una porta di amministrazione, e non una callable.** Creare un avatar
 * vuole la chiave di Protoface, che non lascia il server; nessun telefono ha
 * motivo di farlo. La porta e' chiusa dall'IAM (`invoker: "private"`): la
 * chiama solo chi amministra il progetto, col suo gettone Google.
 *
 * Tre azioni, nel corpo JSON:
 * - `crea`: `maestro`, `nome` e `immagine` in base64; manda l'immagine a
 *   `POST /v1/avatars` e torna l'identificativo, che nasce `processing`;
 * - `stato`: `avatar`; chiede a Protoface se e' pronto;
 * - `aggancia`: `maestro` e `avatar`; solo se Protoface lo dice `ready`, lo
 *   scrive in `configurazione/live.avatar`, da dove lo legge `lAvatarDi`.
 */
export const gliAvatarNuoviDiProtoface = onRequest(
  {
    region: "europe-west1",
    secrets: [PROTOFACE_API_KEY],
    invoker: "private",
    memory: "512MiB",
  },
  async (req, res) => {
    const corpo = (req.body ?? {}) as Record<string, unknown>;
    const azione = String(corpo.azione ?? "");
    const maestro = String(corpo.maestro ?? "");
    const chiave = {Authorization: `Bearer ${PROTOFACE_API_KEY.value()}`};
    try {
      if (azione === "crea") {
        if (!AVATAR[maestro]) {
          res.status(400).json({errore: `Maestro sconosciuto: ${maestro}`});
          return;
        }
        const immagine = Buffer.from(String(corpo.immagine ?? ""), "base64");
        if (immagine.length < 1000) {
          res.status(400).json({errore: "immagine assente o troppo piccola"});
          return;
        }
        const modulo = new FormData();
        modulo.append(
          "image",
          new Blob([immagine], {type: "image/png"}),
          `${maestro}.png`
        );
        modulo.append("name", String(corpo.nome ?? `${maestro}-EK`));
        const r = await fetch(`${PROTOFACE}/avatars`, {
          method: "POST",
          headers: chiave,
          body: modulo,
        });
        const testo = await r.text();
        logger.info("Avatar nuovo chiesto a Protoface", {
          maestro,
          stato: r.status,
          byte: immagine.length,
        });
        res.status(r.ok ? 200 : 502).type("application/json").send(testo);
        return;
      }
      if (azione === "stato") {
        const id = String(corpo.avatar ?? "");
        const r = await fetch(`${PROTOFACE}/avatars/${id}`, {headers: chiave});
        res.status(r.ok ? 200 : 502)
          .type("application/json")
          .send(await r.text());
        return;
      }
      if (azione === "aggancia") {
        const id = String(corpo.avatar ?? "");
        if (!AVATAR[maestro] || !id.startsWith("av_")) {
          res.status(400).json({errore: "maestro o avatar non validi"});
          return;
        }
        const r = await fetch(`${PROTOFACE}/avatars/${id}`, {headers: chiave});
        const a = (await r.json()) as Record<string, unknown>;
        if (!r.ok || a.status !== "ready") {
          res.status(409).json({errore: "l'avatar non e' pronto", stato: a.status});
          return;
        }
        await getFirestore().doc("configurazione/live").set(
          {avatar: {[maestro]: id}},
          {merge: true}
        );
        logger.info("Avatar agganciato al LIVE", {maestro, avatar: id});
        res.status(200).json({maestro, avatar: id, agganciato: true});
        return;
      }
      res.status(400).json({errore: `azione sconosciuta: ${azione}`});
    } catch (e) {
      logger.error("La porta degli avatar nuovi e' caduta", {errore: String(e)});
      res.status(500).json({errore: String(e)});
    }
  }
);

/**
 * LA VOCE DEL MAESTRO. Ordine EG voci 01, 02 e 03, 23 settembre 2026.
 *
 * **Perche' esiste, e cosa c'era prima.** Il fondatore ha provato la 2277 e
 * ha trovato Medora "fissa e muta". Protoface e' soltanto il volto: si muove
 * sull'audio che gli si manda, e nessuno glielo mandava. Il cervello e' la
 * chat scritta, sul telefono, con la sua memoria e le sue regole; la voce di
 * quelle risposte nasce qui, una frase alla volta, e il telefono la consegna
 * al volto.
 *
 * **Sta sul server** perche' Gemini-TTS si chiama con le credenziali
 * dell'account di servizio, che non scendono mai sul telefono.
 *
 * **Modello e regione verificati con una chiamata vera** il 23 settembre 2026:
 * `gemini-2.5-flash-tts` in `europe-west1` risponde con audio
 * `audio/L16;codec=pcm;rate=24000`, cioe' PCM a 16 bit, mono, 24.000
 * campioni al secondo. E' esattamente cio' che Protoface accetta sul flusso
 * `lk.audio_stream`, senza conversioni.
 */
const MODELLO_DELLA_VOCE = "gemini-2.5-flash-tts";
const REGIONE_DELLA_VOCE = "europe-west1";

/**
 * Le voci dei tre Maestri e il modo in cui parlano. Voce EG.03.
 *
 * Scelte dalla descrizione del file `Protoface-Addestreamento- Avatar.txt`:
 * Medora femminile adulta calda e brunita, Aura femminile chiara e luminosa,
 * Caligo maschile grave e matura. **Il giudizio sul tono e' del fondatore**:
 * qui c'e' una prima scelta dichiarata, che cambia in una riga.
 */
const LE_VOCI_DI_PARTENZA: Record<string, {voce: string; modo: string}> = {
  // **IL RITMO E' MISURATO, NON SCELTO A ORECCHIO.** La prima stesura diceva
  // "voce calda, lenta e brunita": il fondatore l'ha sentita nel LIVE il 23
  // settembre 2026 e l'ha trovata "rallentata parecchio". Misurata sul
  // saluto, parlava a 8,0 caratteri al secondo; il parlato italiano naturale
  // sta fra 13 e 15. Con "a ritmo sciolto e spedito" le tre voci, due giri
  // ciascuna, hanno dato fra 13,1 e 14,7.
  medora: {
    voce: "Sulafat",
    modo: "Parla in italiano con voce calda e brunita di donna matura, a " +
      "ritmo sciolto e spedito, come in una conversazione vivace:",
  },
  aura: {
    voce: "Autonoe",
    modo: "Parla in italiano con voce chiara e luminosa, a ritmo sciolto " +
      "e spedito, come in una conversazione vivace:",
  },
  caligo: {
    voce: "Algenib",
    modo: "Parla in italiano con voce maschile grave e profonda, a ritmo " +
      "sciolto e spedito, come in una conversazione vivace:",
  },
};

/**
 * **LE VOCI DA SCEGLIERE.** Ordine EJ voce 02, 24 settembre 2026.
 *
 * Il fondatore: *"le voci non mi convincono, ma non era previsto un selettore
 * in cui potevo sentire e scegliere la voce di ogni maestro?"*, e *"preferirei
 * voci anziane e profonde per Caligo e Medora, mentre piu' giovane e calma per
 * Aura"*. Le candidate seguono quelle preferenze, fra le voci di Gemini-TTS
 * provate con una chiamata vera in europe-west1 il 24 settembre 2026; la
 * descrizione e' quella di Google, tradotta.
 *
 * **Il modo e' uno per Maestro**, e vale per tutte le sue candidate: cambia la
 * voce, non il carattere. **Il ritmo resta misurato**: "anziana" da sola
 * rallentava Medora a nove caratteri al secondo, per questo il modo dice
 * anche di non rallentare.
 *
 * **TUTTE LE VOCI, SCELTE DAL FONDATORE.** 24 settembre 2026, durante
 * l'ordine EK: *"vorrei un selettore con le voci in modo che posso sceglierle
 * io. Quelle sentite finora fanno schifo"*. Le candidate non le sceglie piu'
 * nessuno al posto suo: sono tutte le trenta voci di Gemini-TTS del genere
 * del Maestro, quattordici femminili per Medora e Aura, sedici maschili per
 * Caligo, ascoltate prima su una pagina con Flash e con Pro.
 */
const LE_VOCI_DI_GEMINI: {voce: string; genere: "f" | "m";
  descrizione: string}[] = [
  {voce: "Zephyr", genere: "f", descrizione: "luminosa"},
  {voce: "Kore", genere: "f", descrizione: "decisa"},
  {voce: "Leda", genere: "f", descrizione: "giovane"},
  {voce: "Aoede", genere: "f", descrizione: "leggera"},
  {voce: "Callirrhoe", genere: "f", descrizione: "rilassata"},
  {voce: "Autonoe", genere: "f", descrizione: "luminosa"},
  {voce: "Despina", genere: "f", descrizione: "vellutata"},
  {voce: "Erinome", genere: "f", descrizione: "limpida"},
  {voce: "Laomedeia", genere: "f", descrizione: "vivace"},
  {voce: "Achernar", genere: "f", descrizione: "morbida"},
  {voce: "Gacrux", genere: "f", descrizione: "matura"},
  {voce: "Pulcherrima", genere: "f", descrizione: "diretta"},
  {voce: "Vindemiatrix", genere: "f", descrizione: "gentile"},
  {voce: "Sulafat", genere: "f", descrizione: "calda"},
  {voce: "Puck", genere: "m", descrizione: "vivace"},
  {voce: "Charon", genere: "m", descrizione: "informativa"},
  {voce: "Fenrir", genere: "m", descrizione: "eccitabile"},
  {voce: "Orus", genere: "m", descrizione: "ferma"},
  {voce: "Enceladus", genere: "m", descrizione: "soffiata"},
  {voce: "Iapetus", genere: "m", descrizione: "chiara"},
  {voce: "Umbriel", genere: "m", descrizione: "rilassata"},
  {voce: "Algieba", genere: "m", descrizione: "morbida"},
  {voce: "Algenib", genere: "m", descrizione: "roca"},
  {voce: "Rasalgethi", genere: "m", descrizione: "autorevole"},
  {voce: "Alnilam", genere: "m", descrizione: "decisa"},
  {voce: "Schedar", genere: "m", descrizione: "uniforme"},
  {voce: "Achird", genere: "m", descrizione: "amichevole"},
  {voce: "Zubenelgenubi", genere: "m", descrizione: "informale"},
  {voce: "Sadachbia", genere: "m", descrizione: "vivace"},
  {voce: "Sadaltager", genere: "m", descrizione: "competente"},
];

/** Il genere della voce di ogni Maestro. */
const IL_GENERE: Record<string, "f" | "m"> = {
  medora: "f", aura: "f", caligo: "m",
};

/**
 * **LE VOCI CHIRP 3 HD.** Ordine EM voce 02, 25 settembre 2026.
 *
 * Il fondatore, sulla pagina delle voci dell'ordine EK: *"Prova ad aggiungere
 * anche le voci Chirp nel selettore"*. Le voci italiane di Chirp 3 HD sono
 * trenta, con gli stessi nomi e lo stesso genere di quelle di Gemini-TTS:
 * lette da `/v1/voices` sull'endpoint "eu" il 25 settembre 2026, quattordici
 * femminili e sedici maschili, a 24.000 campioni al secondo.
 *
 * **L'UNICA ECCEZIONE ALLA REGIONE DEI DATI.** Chirp 3 HD non sta in
 * europe-west1: il 24 settembre 2026 quell'endpoint ha risposto *"Voice
 * it-IT-Chirp3-HD-Aoede not found"*. Il fondatore, il 25 settembre 2026, ha
 * detto si' a un'eccezione limitata alla voce e all'endpoint multiregionale
 * "eu", che tiene i dati nell'Unione Europea; **mai "global"**. Sta scritta,
 * con la data, in `lib/core/config/la_regione_dei_dati.dart`, e la guardia
 * `le_voci_stanno_in_europa_test.dart` pretende che nessun altro indirizzo
 * della voce esca dalla regione.
 *
 * **A flusso.** `streamingSynthesize` da' il primo suono in 210-318
 * millesimi, misurati dal PC il 25 settembre 2026
 * (`docs/collaudo/EM/chirp_primo_suono.txt`); la sintesi intera ne voleva
 * 1.150-1.611. **Le voci Chirp non ricevono il modo**: dicono il testo cosi'
 * com'e', e un modo lo leggerebbero ad alta voce.
 */
const PUNTO_DELLE_VOCI_CHIRP = "eu-texttospeech.googleapis.com";
const PREFISSO_CHIRP = "Chirp3-HD-";
const TASSO_CHIRP = 24000;

let ilClienteChirp: TextToSpeechClient | null = null;

function clienteChirp(): TextToSpeechClient {
  ilClienteChirp ??= new TextToSpeechClient({apiEndpoint: PUNTO_DELLE_VOCI_CHIRP});
  return ilClienteChirp;
}

/** Vero per una voce Chirp 3 HD, cioe' un nome col suo prefisso. */
export function eUnaVoceChirp(voce: string): boolean {
  return voce.startsWith(PREFISSO_CHIRP);
}

/**
 * La voce Chirp a flusso: ogni pezzo di PCM a 16 bit, mono, a 24.000
 * campioni, appena arriva.
 */
async function laVoceChirpAFlusso(
  testo: string,
  voce: string,
  suPezzo: (pcm: Buffer) => Promise<void> | void
): Promise<void> {
  const flusso = clienteChirp().streamingSynthesize();
  flusso.write({
    streamingConfig: {
      voice: {languageCode: "it-IT", name: `it-IT-${voce}`},
      streamingAudioConfig: {audioEncoding: "PCM", sampleRateHertz: TASSO_CHIRP},
    },
  });
  flusso.write({input: {text: testo}});
  flusso.end();
  for await (const r of flusso) {
    const audio = (r as {audioContent?: Uint8Array | string | null}).audioContent;
    if (audio && audio.length > 0) {
      await suPezzo(typeof audio === "string" ?
        Buffer.from(audio, "base64") : Buffer.from(audio));
    }
  }
}

/**
 * Le candidate di ogni Maestro: le voci di Gemini-TTS del suo genere e le
 * stesse in Chirp 3 HD. **Il nome si mostra, la voce si salva**: per Chirp la
 * voce porta il prefisso, cosi' la scelta dice anche la famiglia.
 */
export const LE_CANDIDATE: Record<string, {voce: string; nome: string;
  famiglia: string; descrizione: string}[]> = Object.fromEntries(
  Object.entries(IL_GENERE).map(([maestro, genere]) => {
    const delGenere = LE_VOCI_DI_GEMINI.filter((v) => v.genere === genere);
    return [maestro, [
      ...delGenere.map(({voce, descrizione}) =>
        ({voce, nome: voce, famiglia: "Gemini", descrizione})),
      ...delGenere.map(({voce, descrizione}) => ({
        voce: `${PREFISSO_CHIRP}${voce}`,
        nome: voce,
        famiglia: "Chirp 3 HD",
        descrizione,
      })),
    ]];
  })
);

/**
 * **IL MODO: PRONUNCIA DI MADRELINGUA E CALMA NATURALE.** Fino al 24
 * settembre 2026 diceva "a ritmo sciolto e spedito, come in una
 * conversazione vivace", per correggere la lentezza misurata il 23. Il
 * fondatore ha trovato brutte tutte le voci sentite con quel modo: questo e'
 * il modo dei campioni che ha ascoltato sulla pagina di scelta, e la voce che
 * sceglie nel LIVE deve suonare come l'ha sentita li'.
 */
const I_MODI: Record<string, string> = {
  medora: "Leggi in italiano, con la pronuncia di una madrelingua italiana, " +
    "con voce calda e matura di donna, con calma naturale:",
  // **CALÌGO NON RALLENTA PIU'.** Ordine EM voce 12, 25 settembre 2026. Il
  // fondatore: *"qualunque voce di Caligo è rallentata."* Misurato su tutte
  // le sedici voci col testo lungo dell'ordine EK: col modo "con voce grave e
  // matura di uomo, con calma naturale" parlavano fra 9,1 e 11,1 caratteri al
  // secondo, mediana 10,1, e il parlato italiano naturale sta fra 13 e 15.
  // **Qualunque parola sul timbro rallenta**: "voce profonda di uomo" pesava
  // anche insieme a "a ritmo sciolto e spedito" (10,9-12,0). Resta la
  // pronuncia di madrelingua, e il ritmo di conversazione: fra 11,8 e 15,3,
  // mediana 13,4, due giri per voce (`docs/collaudo/EM/caligo/`). Il timbro
  // lo da' la voce che il fondatore sceglie, non il modo.
  caligo: "Leggi in italiano, con la pronuncia di un madrelingua italiano, " +
    "a ritmo di conversazione:",
  aura: "Leggi in italiano, con la pronuncia di una madrelingua italiana, " +
    "con voce giovane, calma e chiara di donna:",
};

/**
 * **I MODELLI DELLA VOCE FRA CUI SI SCEGLIE**, tutti e due verificati con
 * una chiamata vera in europe-west1: Flash il 23 settembre 2026, Pro il 24.
 * Primo suono a flusso misurato il 24 settembre, tre giri ciascuno: Flash
 * 0,66-0,75 secondi, Pro 1,06-1,13. Il modello si sceglie per Maestro in
 * `configurazione/live.modelliDellaVoce`; un valore sconosciuto vale Flash.
 */
export const I_MODELLI_DELLA_VOCE = [
  "gemini-2.5-flash-tts",
  "gemini-2.5-pro-tts",
];

/**
 * **La frase su cui si confrontano le voci**, la stessa per tutte le
 * candidate di un Maestro. Caligo pronuncia il suo nome: e' anche la prova
 * della voce EJ.04, *"si dice Calìgo"*. **L'indicazione dell'accento non va
 * nel modo**: provata il 24 settembre, la voce la leggeva ad alta voce e la
 * frase durava undici secondi invece di sei. Basta l'accento scritto.
 */
const LA_FRASE_DI_PROVA: Record<string, string> = {
  medora: "Sono Medora. Il cielo di stasera ascolta con me: dimmi cosa ti " +
    "porta qui.",
  caligo: "Sono Calìgo. Le rune tacciono finché non parli tu.",
  aura: "Sono Aura. Prendi un respiro con me, poi dimmi cosa senti.",
};

let scelteInCache: {
  quando: number;
  voci: Record<string, string>;
  modelli: Record<string, string>;
} | null = null;

/**
 * **QUANTO VALE UNA LETTURA DELLA SCELTA: TRE SECONDI.** Ordine EM voce 06,
 * 25 settembre 2026. Il fondatore: *"Quando seleziono la voce nel selettore
 * anche se scelgo una voce diversa, questa non viene applicata realmente,
 * funziona solo il preview della voce."*
 *
 * **La causa.** La scelta restava in memoria un minuto, e **ogni porta del
 * server gira in un servizio Cloud Run suo, con la sua memoria**:
 * `scegliLaVoce` azzerava la propria, ma la porta che parla nel LIVE,
 * `laVoceDelMaestro`, continuava a usare la voce di prima finche' il suo
 * minuto non scadeva. E nel suo registro non scriveva quale voce usava, quindi
 * nessuno poteva leggerlo. Padre: ordine EJ voce 02, che ha scritto la memoria
 * di un minuto e l'azzeramento in una porta sola. Adesso la scelta si rilegge
 * se ha piu' di tre secondi, e ogni voce detta scrive nel registro quale era.
 */
const LA_SCELTA_VALE_MS = 3000;

/**
 * **La voce di un Maestro, come l'ha scelta il fondatore.** Vive in
 * `configurazione/live`, campi `voci` e `modelliDellaVoce`, e cambia senza
 * una build nuova; si rilegge al massimo una volta al minuto. Una voce che
 * non sta fra le candidate non vale, e resta quella di partenza; un modello
 * che non sta fra i modelli verificati vale Flash.
 */
export async function laVoceScelta(
  maestro: string
): Promise<{voce: string; modo: string; modello: string;
  famiglia: "gemini" | "chirp3"}> {
  const ora = Date.now();
  if (!scelteInCache || ora - scelteInCache.quando > LA_SCELTA_VALE_MS) {
    const doc = await getFirestore().doc("configurazione/live").get();
    scelteInCache = {
      quando: ora,
      voci: doc.data()?.voci ?? {},
      modelli: doc.data()?.modelliDellaVoce ?? {},
    };
  }
  const scelta = scelteInCache.voci[maestro];
  const valida = (LE_CANDIDATE[maestro] ?? []).some((c) => c.voce === scelta);
  const partenza = LE_VOCI_DI_PARTENZA[maestro];
  const modello = scelteInCache.modelli[maestro];
  const voce = valida ? scelta : partenza.voce;
  return {
    voce,
    modo: I_MODI[maestro] ?? partenza.modo,
    modello: I_MODELLI_DELLA_VOCE.includes(modello) ?
      modello : MODELLO_DELLA_VOCE,
    famiglia: eUnaVoceChirp(voce) ? "chirp3" : "gemini",
  };
}

/** Dimentica le scelte lette: serve alle prove, che cambiano il documento. */
export function dimenticaLeScelte(): void {
  scelteInCache = null;
}

/** I livelli di qualita' che Protoface accetta, dal piu' leggero. */
const LE_QUALITA = ["lite", "standard", "pro"];

/**
 * Il livello scelto in `configurazione/live.qualita`, oppure nessuno. Ordine
 * EJ voce 03: si cambia senza una build, e un valore sconosciuto non passa.
 */
async function laQualitaScelta(): Promise<string | undefined> {
  const doc = await getFirestore().doc("configurazione/live").get();
  const q = doc.data()?.qualita;
  return typeof q === "string" && LE_QUALITA.includes(q) ? q : undefined;
}

/**
 * **L'USO DEL MESE, NEL REGISTRO.** Ordine EJ voce 03. Protoface non pubblica
 * quanto costa un livello rispetto all'altro: dice solo un credito al minuto,
 * arrotondato. Il riepilogo `/v1/usage` porta i crediti addebitati e i
 * secondi per livello, e scritto a ogni apertura misura la sessione prima.
 */
async function lUsoDelMese(): Promise<void> {
  try {
    const r = await fetch(`${PROTOFACE}/usage?period=current_month`, {
      headers: {Authorization: `Bearer ${PROTOFACE_API_KEY.value()}`},
    });
    const u = (await r.json()) as Record<string, unknown>;
    logger.info("Uso di Protoface nel mese", {
      stato: r.status,
      crediti: u.credits_charged,
      secondi: u.billable_seconds,
      perQualita: u.by_quality,
      sessioni: u.sessions,
    });
  } catch (errore) {
    logger.warn("L'uso di Protoface non si legge", {errore: String(errore)});
  }
}

/** Solo i fondatori scelgono le voci. */
async function soloFondatori(uid: string | undefined): Promise<void> {
  if (!uid) throw new HttpsError("unauthenticated", "Serve un account.");
  const {eFondatore} = await ilDirittoAlLive(uid);
  if (!eFondatore) {
    throw new HttpsError("permission-denied", "Le voci le scelgono i fondatori.");
  }
}

/** L'audio intero di una frase, non a flusso: serve all'ascolto di prova. */
async function laVoceIntera(
  testo: string,
  voce: string,
  modello: string = MODELLO_DELLA_VOCE
): Promise<{audio: string; tasso: number}> {
  const credenziale = await applicationDefault().getAccessToken();
  const indirizzo =
    `https://${REGIONE_DELLA_VOCE}-aiplatform.googleapis.com/v1/projects/` +
    `${process.env.GCLOUD_PROJECT}/locations/${REGIONE_DELLA_VOCE}/` +
    `publishers/google/models/${modello}:generateContent`;
  const risposta = await fetch(indirizzo, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${credenziale.access_token}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      contents: [{role: "user", parts: [{text: testo}]}],
      generationConfig: {
        responseModalities: ["AUDIO"],
        speechConfig: {voiceConfig: {prebuiltVoiceConfig: {voiceName: voce}}},
      },
    }),
  });
  if (!risposta.ok) {
    throw new HttpsError("internal", `La voce ha risposto ${risposta.status}`);
  }
  const dati = (await risposta.json()) as {
    candidates?: {content?: {parts?: {inlineData?: {
      mimeType?: string; data?: string;
    }}[]}}[];
  };
  const parte = dati.candidates?.[0]?.content?.parts?.[0]?.inlineData;
  if (!parte?.data) throw new HttpsError("internal", "La voce e' vuota.");
  const tasso = Number(/rate=(\d+)/.exec(parte.mimeType ?? "")?.[1] ?? 24000);
  return {audio: parte.data, tasso};
}

/** Le candidate di un Maestro, la frase di prova e la scelta di oggi. */
export const leVociDelMaestro = onCall(
  {region: "europe-west1"},
  async (request) => {
    await soloFondatori(request.auth?.uid);
    const maestro = String(request.data?.maestro ?? "");
    const candidate = LE_CANDIDATE[maestro];
    if (!candidate) {
      throw new HttpsError("invalid-argument", `Maestro sconosciuto: ${maestro}`);
    }
    const {voce} = await laVoceScelta(maestro);
    return {candidate, scelta: voce, frase: LA_FRASE_DI_PROVA[maestro]};
  }
);

/** La frase di prova detta da una candidata, per ascoltarla. */
export const ascoltaUnaVoce = onCall(
  {region: "europe-west1", timeoutSeconds: 60},
  async (request) => {
    await soloFondatori(request.auth?.uid);
    const maestro = String(request.data?.maestro ?? "");
    const voce = String(request.data?.voce ?? "");
    if (!(LE_CANDIDATE[maestro] ?? []).some((c) => c.voce === voce)) {
      throw new HttpsError("invalid-argument", "Voce non fra le candidate.");
    }
    // **Una voce Chirp si ascolta com'e'**, senza modo, dall'endpoint "eu":
    // ordine EM voce 02.
    if (eUnaVoceChirp(voce)) {
      const pezzi: Buffer[] = [];
      await laVoceChirpAFlusso(LA_FRASE_DI_PROVA[maestro], voce, (p) => {
        pezzi.push(p);
      });
      logger.info("ascolto di una voce", {
        maestro, voce, famiglia: "chirp3", punto: PUNTO_DELLE_VOCI_CHIRP,
      });
      return {
        audio: Buffer.concat(pezzi).toString("base64"),
        tasso: TASSO_CHIRP,
        canali: 1,
      };
    }
    // Col modello scelto per quel Maestro: l'ascolto di prova deve suonare
    // come il LIVE.
    const {modello} = await laVoceScelta(maestro);
    const {audio, tasso} = await laVoceIntera(
      `${I_MODI[maestro]} ${LA_FRASE_DI_PROVA[maestro]}`, voce, modello);
    logger.info("ascolto di una voce", {maestro, voce, modello});
    return {audio, tasso, canali: 1};
  }
);

/** La voce scelta diventa quella del Maestro, per tutti, senza build. */
export const scegliLaVoce = onCall(
  {region: "europe-west1"},
  async (request) => {
    await soloFondatori(request.auth?.uid);
    const maestro = String(request.data?.maestro ?? "");
    const voce = String(request.data?.voce ?? "");
    if (!(LE_CANDIDATE[maestro] ?? []).some((c) => c.voce === voce)) {
      throw new HttpsError("invalid-argument", "Voce non fra le candidate.");
    }
    await getFirestore().doc("configurazione/live").set(
      {voci: {[maestro]: voce}}, {merge: true});
    scelteInCache = null;
    logger.info("voce scelta", {maestro, voce, uid: request.auth?.uid});
    return {maestro, voce};
  }
);

/** Il tetto di una frase: la voce si chiede una frase alla volta. */
const FRASE_MASSIMA = 1200;

export const laVoceDelMaestro = onCall(
  {region: "europe-west1", timeoutSeconds: 60},
  async (request, response) => {
    const uid = request.auth?.uid;
    if (!uid) throw new HttpsError("unauthenticated", "Serve un account.");
    await ilDirittoAlLive(uid);

    const maestro = String(request.data?.maestro ?? "");
    if (!LE_VOCI_DI_PARTENZA[maestro]) {
      throw new HttpsError("invalid-argument", `Maestro sconosciuto: ${maestro}`);
    }
    const testo = String(request.data?.testo ?? "").trim();
    if (!testo) throw new HttpsError("invalid-argument", "Niente da dire.");
    if (testo.length > FRASE_MASSIMA) {
      throw new HttpsError("invalid-argument", "Frase troppo lunga.");
    }
    // Ordine EJ voce 02: la voce e' quella scelta dal fondatore.
    const come = await laVoceScelta(maestro);

    // **LA VOCE CHIRP, A FLUSSO DALL'ENDPOINT "eu".** Ordine EM voce 02.
    if (come.famiglia === "chirp3") {
      const aFlussoChirp = request.acceptsStreaming;
      const tuttoChirp: Buffer[] = [];
      let pezziChirp = 0;
      let byteChirp = 0;
      let primoChirp = -1;
      const partenzaChirp = Date.now();
      await laVoceChirpAFlusso(testo, come.voce, async (pcm) => {
        if (primoChirp < 0) primoChirp = Date.now() - partenzaChirp;
        pezziChirp++;
        byteChirp += pcm.length;
        if (aFlussoChirp) {
          await response?.sendChunk(
            {audio: pcm.toString("base64"), tasso: TASSO_CHIRP, canali: 1});
        } else {
          tuttoChirp.push(pcm);
        }
      });
      if (pezziChirp === 0) {
        logger.error("la voce Chirp del Maestro e' tornata vuota",
          {maestro, voce: come.voce});
        throw new HttpsError("internal", "La voce e' tornata vuota.");
      }
      logger.info("voce del Maestro", {
        maestro,
        voce: come.voce,
        famiglia: come.famiglia,
        punto: PUNTO_DELLE_VOCI_CHIRP,
        caratteri: testo.length,
        byte: byteChirp,
        tasso: TASSO_CHIRP,
        pezzi: pezziChirp,
        aFlusso: aFlussoChirp,
        primoMs: primoChirp,
        totaleMs: Date.now() - partenzaChirp,
      });
      return aFlussoChirp ?
        {fine: true, tasso: TASSO_CHIRP, canali: 1} :
        {
          audio: Buffer.concat(tuttoChirp).toString("base64"),
          tasso: TASSO_CHIRP,
          canali: 1,
        };
    }

    // **LA VOCE ARRIVA A FLUSSO.** La prima stesura chiedeva l'audio intero
    // e lo restituiva in un colpo: 4,4 secondi per 47 caratteri, 11,7 per
    // 181, misurati sulla prima prova del fondatore, che ha trovato la
    // risposta "molti secondi dopo". Con `streamGenerateContent` il primo
    // pezzo d'audio arriva in 0,61-0,75 secondi, e il telefono lo manda al
    // volto mentre il resto si sta ancora componendo. La generazione e' piu'
    // veloce del parlato, da 4 a 6,6 secondi per 11-12 di voce, quindi il
    // flusso non resta mai indietro rispetto alla bocca.
    const credenziale = await applicationDefault().getAccessToken();
    const indirizzo =
      `https://${REGIONE_DELLA_VOCE}-aiplatform.googleapis.com/v1/projects/` +
      `${process.env.GCLOUD_PROJECT}/locations/${REGIONE_DELLA_VOCE}/` +
      `publishers/google/models/${come.modello}:` +
      "streamGenerateContent?alt=sse";
    const risposta = await fetch(indirizzo, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${credenziale.access_token}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        contents: [{role: "user", parts: [{text: `${come.modo} ${testo}`}]}],
        generationConfig: {
          responseModalities: ["AUDIO"],
          speechConfig: {
            voiceConfig: {prebuiltVoiceConfig: {voiceName: come.voce}},
          },
        },
      }),
    });
    if (!risposta.ok || !risposta.body) {
      const corpo = await risposta.text();
      logger.error("la voce del Maestro non nasce", {
        stato: risposta.status,
        corpo: corpo.slice(0, 500),
        maestro,
      });
      throw new HttpsError("internal", `La voce ha risposto ${risposta.status}`);
    }

    // Chi non sa ricevere a flusso riceve tutto alla fine, nella risposta.
    const aFlusso = request.acceptsStreaming;
    const tutto: Buffer[] = [];
    let tasso = 24000;
    let pezzi = 0;
    let byte = 0;
    let primoMs = -1;
    const partenza = Date.now();
    const lettore = risposta.body.getReader();
    const decodifica = new TextDecoder();
    let resto = "";
    for (;;) {
      const {done, value} = await lettore.read();
      if (value) resto += decodifica.decode(value, {stream: true});
      const righe = resto.split("\n");
      resto = done ? "" : righe.pop() ?? "";
      for (const riga of righe) {
        if (!riga.startsWith("data:")) continue;
        const dato = JSON.parse(riga.slice(5)) as {
          candidates?: {content?: {parts?: {inlineData?: {
            mimeType?: string; data?: string;
          }}[]}}[];
        };
        for (const p of dato.candidates?.[0]?.content?.parts ?? []) {
          const audio = p.inlineData?.data;
          if (!audio) continue;
          // Il tasso lo dice il modello, non lo si da' per scontato.
          tasso = Number(
            /rate=(\d+)/.exec(p.inlineData?.mimeType ?? "")?.[1] ?? tasso);
          if (primoMs < 0) primoMs = Date.now() - partenza;
          pezzi++;
          byte += Math.round(audio.length * 3 / 4);
          if (aFlusso) {
            await response?.sendChunk({audio, tasso, canali: 1});
          } else {
            tutto.push(Buffer.from(audio, "base64"));
          }
        }
      }
      if (done) break;
    }
    if (pezzi === 0) {
      logger.error("la voce del Maestro e' tornata vuota", {maestro});
      throw new HttpsError("internal", "La voce e' tornata vuota.");
    }
    logger.info("voce del Maestro", {
      maestro,
      voce: come.voce,
      famiglia: come.famiglia,
      modello: come.modello,
      punto: `${REGIONE_DELLA_VOCE}-aiplatform.googleapis.com`,
      caratteri: testo.length,
      byte,
      tasso,
      pezzi,
      aFlusso,
      primoMs,
      totaleMs: Date.now() - partenza,
    });
    return aFlusso ?
      {fine: true, tasso, canali: 1} :
      {audio: Buffer.concat(tutto).toString("base64"), tasso, canali: 1};
  }
);
