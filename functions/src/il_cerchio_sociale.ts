import {onCall, HttpsError, CallableRequest} from "firebase-functions/v2/https";
import {SpazioDellaPresenza, spazioDi} from "./i_collaudi";
import * as logger from "firebase-functions/logger";
import {
  DocumentSnapshot,
  getFirestore,
  FieldValue,
  Firestore,
  Timestamp,
  Transaction,
} from "firebase-admin/firestore";
import {getMessaging} from "firebase-admin/messaging";
import {chiaveDelGiorno} from "./giorno";
import {Piano, pianoValido} from "./budget";
import {confineDellaPresenza} from "./presenza";
import {
  DatiDellaPersona,
  Indizio,
  INDIZI_MASSIMI,
  costoDellIndizio,
  indizioDellaPartita,
  puntiDellaRisposta,
} from "./gli_indizi";
import {
  DURATA_DELLA_SFIDA_MS,
  Domanda,
  INDOVINELLI_AL_GIORNO,
  PREZZO_DEL_SEGNO,
  PUNTI_DELLA_SCOMMESSA,
  SCOMMESSE_AL_GIORNO,
  Volto,
  chiaveDellaDomanda,
  esclusiPerLaDomanda,
  esitoDellaSfida,
  figuraDi,
  ilRitornoDi,
  laClassifica,
  laDomanda,
  lunaValida,
  metaDelPellegrinaggio,
  piuVicini,
  punteggioDi,
  puoComparire,
  quattroVolti,
  rispostaDellIndovinello,
  ritrattoValido,
  scommessaAmmessa,
  sfidaGiaAperta,
  sfidaPerIlPiano,
} from "./gli_enigmi";
import {
  RIGHE_DEL_RIFIUTO,
  formeDiConfronto,
  verdettoDelNome,
} from "./il_nome_del_cerchio";
import {
  ArteDellaPresenza,
  DURATE_DEL_CODICE,
  FRAMMENTI_DELLA_PRESENZA,
  EOS_DEL_POSTO_IN_PIU,
  Istantanea,
  OGNI_QUANTO_SI_RIFA_L_ISTANTANEA_MS,
  POSTI_DEL_LEGAME,
  RIGA_DEI_QUATTORDICI,
  PREZZI_DEI_DONI,
  Presenza,
  SchedaCompatta,
  RISPOSTE_PER_SEGNO,
  SEGNI_AL_GIORNO,
  StatoDelLegame,
  TETTI_DELLE_PORTE,
  TipoDelCodice,
  VISIBILITA_PREDEFINITA,
  Visibilita,
  codiceScritto,
  costruisciLIstantanea,
  coppia,
  decidiIlGift,
  decidiIlSegno,
  decidiIlTetto,
  decidiLInvito,
  donoPerIlPiano,
  donoValido,
  fineDelRifiuto,
  fineDellaQuarantena,
  frammentoDi,
  gradinoValido,
  quattordiciDichiarati,
  iconaDelSegno,
  iconaValida,
  istantaneaVecchia,
  maestroValido,
  quandoSiRiapreIlNome,
  reazioneValida,
  registraLoScambio,
  rigaDelTetto,
  scadenzaDelNomeLasciato,
  scompatta,
  segnoValido,
  semaforoPer,
  sogliaDellEtaPassata,
  sigilloScritto,
  soloIlPubblico,
  somiglianti,
  unCodice,
  unSigillo,
  visibilitaEffettiva,
  visibilitaValida,
} from "./sociale";

/**
 * LE PORTE DEL MOTORE SOCIALE DEL CERCHIO, ordine EY.
 *
 * **Il server e' sovrano.** Il telefono propone, queste porte verificano e
 * scrivono. Il telefono non scrive mai il proprio profilo pubblico, ne' i
 * legami, ne' i segni: le regole di Firestore chiudono al client tutto cio'
 * che sta fuori dal suo ramo, e il suo ramo si legge soltanto.
 *
 * **Ogni porta ha il suo tetto** per identita' e per finestra di tempo
 * (`TETTI_DELLE_PORTE` in `sociale.ts`, EY.16), e il rifiuto dice quanto
 * manca. Una prova enumera le porte di questo file e cade se una nasce senza.
 *
 * **App Check resta spento**, come su tutte le callable del Cerchio (premessa
 * P9 dell'ordine): l'uid arriva dal token e mai dal corpo della richiesta.
 *
 * **Nessuna chiamata al modello** in tutto il file (regola R11): il motore
 * sociale e' deterministico.
 *
 * DOVE STANNO I DATI
 * - `profili/{uid}`: il profilo pubblico, solo i sette campi di
 *   `CAMPI_DEL_PROFILO_PUBBLICO`. Leggibile dagli altri SOLO attraverso queste
 *   porte: le regole di Firestore lo chiudono a ogni lettura diretta.
 * - `sigilli/{sigillo}`: chi porta quel sigillo, oppure la quarantena.
 * - `nomi_lasciati/{forma}`: un nome lasciato, di chi era e fino a quando.
 * - `legami/{coppia}`: il legame fra due account, con lo stato, chi ha
 *   invitato, lo scambio del giorno e i giorni accesi del glifo.
 * - `codici_invito/{codice}`: il codice opaco, di chi e' e quando scade.
 * - `cerchio_adesso/istantanea`: l'istantanea dei presenti, rifatta al
 *   massimo ogni trenta secondi.
 * - sotto `users/{uid}`, che se ne va con l'account: `stato/identita`,
 *   `stato/legami`, `stato/blocchi`, `stato/sociale_oggi`,
 *   `stato/tetti_sociali`, `segni/{id}`, `doni/{id}`.
 */

/** Le impostazioni comuni, le stesse delle altre callable del Cerchio. */
const OPZIONI_SOCIALI = {
  region: "europe-west1",
  enforceAppCheck: false,
  timeoutSeconds: 30,
  memory: "256MiB" as const,
};

/** Preso pigro: l'app la inizializza `cerchio.ts`, e le prove non la vogliono. */
const db = (): Firestore => getFirestore();
const utente = (uid: string) => db().collection("users").doc(uid);
const statoDi = (uid: string, nome: string) =>
  utente(uid).collection("stato").doc(nome);
const profiloDi = (uid: string) => db().collection("profili").doc(uid);
const legameDi = (a: string, b: string) =>
  db().collection("legami").doc(coppia(a, b));
// Lo spazio della presenza, ordine FD voce 05: i collaudi hanno il proprio.
const ISTANTANEA = (spazio: SpazioDellaPresenza) =>
  db().collection(`${spazio}cerchio_adesso`).doc("istantanea");

function uidDi(request: CallableRequest): string {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated",
      "Serve un account, anche anonimo, per parlare col Cerchio.");
  }
  return uid;
}

/**
 * IL TETTO DELLA PORTA, EY.16: si conta in transazione sul ramo di chi
 * chiama, prima di ogni altra cosa. Il rifiuto dice quanto manca.
 */
async function tettoDellaPorta(uid: string, porta: string): Promise<void> {
  const doc = statoDi(uid, "tetti_sociali");
  const esito = await db().runTransaction(async (tx) => {
    const snap = await tx.get(doc);
    // **LA SOGLIA DEI QUATTORDICI ANNI, ordine EZ voce 04**, nello stesso
    // documento del tetto: nessuna lettura in piu' per gesto.
    if (!sogliaDellEtaPassata(porta, snap.data()?.quattordici)) {
      return {concesso: false as const, sottoLaSoglia: true, mancaMs: 0};
    }
    const dati = (snap.data()?.[porta] ?? {}) as Record<string, unknown>;
    const decisione = decidiIlTetto({
      porta,
      inizio: typeof dati.inizio === "number" ? dati.inizio : null,
      quante: typeof dati.quante === "number" ? dati.quante : 0,
      adessoMs: Date.now(),
    });
    if (decisione.concesso) {
      tx.set(doc, {[porta]: {inizio: decisione.inizio, quante: decisione.quante}},
        {merge: true});
    }
    return decisione;
  });
  if ("sottoLaSoglia" in esito) {
    throw new HttpsError("permission-denied", RIGA_DEI_QUATTORDICI);
  }
  if (!esito.concesso) {
    throw new HttpsError("resource-exhausted", rigaDelTetto(esito.mancaMs));
  }
}

async function pianoDi(uid: string): Promise<Piano> {
  const snap = await statoDi(uid, "abbonamento").get();
  return pianoValido(snap.data()?.piano);
}

function elenco(valore: unknown): string[] {
  return Array.isArray(valore) ?
    valore.filter((v): v is string => typeof v === "string") :
    [];
}

interface Identita {
  sigillo: string | null;
  nome: string;
  cambiNome: number;
  ultimoCambio: number | null;
  visibilita: Visibilita;
  chiPuoInvitare: "tutti" | "sigillo";
  maggiorenne: boolean;
  quattordici: boolean;
  icona: string;
  segno: string | null;
  maestro: string | null;
  gradino: number;
  postiComprati: number;
}

function identitaDa(dati: Record<string, unknown> | undefined): Identita {
  const d = dati ?? {};
  return {
    sigillo: typeof d.sigillo === "string" ? d.sigillo : null,
    nome: typeof d.nome === "string" ? d.nome : "",
    cambiNome: typeof d.cambiNome === "number" ? d.cambiNome : 0,
    ultimoCambio: typeof d.ultimoCambio === "number" ? d.ultimoCambio : null,
    visibilita: visibilitaValida(d.visibilita) ?? VISIBILITA_PREDEFINITA,
    chiPuoInvitare: d.chiPuoInvitare === "sigillo" ? "sigillo" : "tutti",
    // **Finche' il telefono non lo dice, nessuno e' maggiorenne**: la
    // presenza pubblica resta chiusa invece di aprirsi per un dato mancante.
    maggiorenne: d.maggiorenne === true,
    quattordici: quattordiciDichiarati(d),
    icona: iconaValida(d.icona) ?? iconaDelSegno(d.segno),
    segno: segnoValido(d.segno),
    maestro: maestroValido(d.maestro),
    gradino: gradinoValido(d.gradino) ?? 0,
    postiComprati: typeof d.postiComprati === "number" ? d.postiComprati : 0,
  };
}

async function leggiIdentita(uid: string): Promise<Identita> {
  const snap = await statoDi(uid, "identita").get();
  return identitaDa(snap.data());
}

/** La scheda che la presenza porta con se', per l'istantanea. */
function schedaDellaPresenza(i: Identita): SchedaCompatta {
  return {
    n: i.nome.length > 0 ? i.nome : null,
    s: i.sigillo,
    i: i.icona,
    z: i.segno,
    m: i.maestro,
    g: i.gradino,
    v: visibilitaEffettiva(i.visibilita, i.maggiorenne),
    M: i.maggiorenne,
    c: i.chiPuoInvitare,
  };
}

/**
 * IL SIGILLO SI ASSEGNA IN TRANSAZIONE, MAI DAL CLIENT. Si prova un
 * candidato a caso; se il posto e' preso (o in quarantena) se ne prova un
 * altro, fino a otto letture, poi si scrive. Con un milione di sigilli
 * possibili e pochi presi, il secondo tentativo e' gia' raro.
 */
async function assicuraIlSigillo(uid: string): Promise<string> {
  for (let giro = 0; giro < 3; giro++) {
    const preso = await db().runTransaction(async (tx) => {
      const io = await tx.get(statoDi(uid, "identita"));
      const gia = identitaDa(io.data()).sigillo;
      if (gia !== null) return gia;
      for (let i = 0; i < 8; i++) {
        const candidato = unSigillo();
        const posto = db().collection("sigilli").doc(candidato);
        const snap = await tx.get(posto);
        if (snap.exists) continue;
        tx.set(posto, {uid, dal: Date.now()});
        tx.set(statoDi(uid, "identita"), {sigillo: candidato}, {merge: true});
        return candidato;
      }
      return null;
    });
    if (preso !== null) return preso;
  }
  throw new HttpsError("unavailable", "Il Cerchio non trova un sigillo libero: riprova.");
}

/** Le persone fra cui c'e' un blocco, in un verso o nell'altro. */
async function blocchiDi(uid: string): Promise<Set<string>> {
  const snap = await statoDi(uid, "blocchi").get();
  const d = snap.data() ?? {};
  return new Set([...elenco(d.bloccati), ...elenco(d.bloccatoDa)]);
}

interface Legame {
  stato: StatoDelLegame;
  da: string;
  fino: number | null;
  giorniAccesi: string[];
  scambio: {giorno: string; chi: string[]} | null;
  nonRicambiati: Record<string, number>;
}

function legameDa(dati: Record<string, unknown> | undefined): Legame | null {
  if (!dati || typeof dati.stato !== "string") return null;
  const scambio = dati.scambio as {giorno?: unknown; chi?: unknown} | undefined;
  return {
    stato: dati.stato as StatoDelLegame,
    da: String(dati.da ?? ""),
    fino: typeof dati.fino === "number" ? dati.fino : null,
    giorniAccesi: elenco(dati.giorniAccesi),
    scambio: scambio && typeof scambio.giorno === "string" ?
      {giorno: scambio.giorno, chi: elenco(scambio.chi)} :
      null,
    nonRicambiati: (dati.nonRicambiati ?? {}) as Record<string, number>,
  };
}

/**
 * L'ELENCO DEI LEGAMI DI UNA PERSONA, sul suo ramo: gli amici, gli inviti
 * mandati e quelli ricevuti. Lo scrive solo questo file, nella stessa
 * transazione che scrive il legame, cosi' i due non discordano mai.
 */
function aggiornaGliElenchi(
  tx: Transaction,
  uid: string,
  altro: string,
  dove: "amici" | "inviati" | "ricevuti" | null
): void {
  const togli = FieldValue.arrayRemove(altro);
  const campi: Record<string, unknown> = {
    amici: togli,
    inviati: togli,
    ricevuti: togli,
  };
  if (dove !== null) campi[dove] = FieldValue.arrayUnion(altro);
  tx.set(statoDi(uid, "legami"), campi, {merge: true});
  // LAPIDE, ordine FB voce 01: qui l'ordine FA scriveva gli amici anche
  // nella presenza, per trovarli con una domanda chiusa a sei. Adesso la
  // tendina li incrocia in memoria con l'istantanea, e questa scrittura in
  // piu' non serve.
}

/** Il contatore sociale di oggi: inviti, segni, segni per persona, regali. */
interface Oggi {
  giorno: string;
  inviti: number;
  segni: number;
  perPersona: Record<string, number>;
  regalati: number;
}

function oggiDa(dati: Record<string, unknown> | undefined, giorno: string): Oggi {
  if (!dati || dati.giorno !== giorno) {
    return {giorno, inviti: 0, segni: 0, perPersona: {}, regalati: 0};
  }
  return {
    giorno,
    inviti: typeof dati.inviti === "number" ? dati.inviti : 0,
    segni: typeof dati.segni === "number" ? dati.segni : 0,
    perPersona: (dati.perPersona ?? {}) as Record<string, number>,
    regalati: typeof dati.regalati === "number" ? dati.regalati : 0,
  };
}

/**
 * LA NOTIFICA AL CERCHIO, sul canale che esiste gia': Firebase Messaging,
 * con i recapiti che il telefono ha gia' dato per i Doni (`push_dei_doni`) e
 * quello che da' al Cerchio (`stato/dispositivo`). La notifica NOMINA LA
 * COSA, "Lunaria ti ha mandato un segno", mai "apri l'app".
 *
 * Su Android arriva come dato e la mostra l'app (come la push dei Doni); su
 * iPhone arriva gia' composta, perche' una push di soli dati con l'app chiusa
 * iOS non la garantisce. Un errore non ferma il gesto: il segno e' gia'
 * scritto e la persona lo trova aprendo il Cerchio.
 */
async function avvisa(uid: string, testo: string, tipo: string): Promise<void> {
  try {
    const recapiti = new Set<string>();
    const mio = await statoDi(uid, "dispositivo").get();
    const t = mio.data()?.token;
    if (typeof t === "string" && t.length >= 20) recapiti.add(t);
    const doni = await db().collection("push_dei_doni").where("uid", "==", uid).get();
    for (const d of doni.docs) {
      const token = d.data().token;
      if (typeof token === "string" && token.length >= 20) recapiti.add(token);
    }
    for (const token of recapiti) {
      try {
        await getMessaging().send({
          token,
          data: {tipo: "cerchio", sottotipo: tipo, titolo: "Il Cerchio", testo},
          android: {priority: "high"},
          apns: {payload: {aps: {alert: {title: "Il Cerchio", body: testo}}}},
        });
      } catch (errore) {
        logger.warn("Cerchio: un recapito non risponde", {errore: String(errore)});
      }
    }
  } catch (errore) {
    logger.warn("Cerchio: l'avviso non parte", {errore: String(errore)});
  }
}

// ---------------------------------------------------------------------------
// PARTE A, L'IDENTITA'
// ---------------------------------------------------------------------------

/**
 * IL MIO PROFILO NEL CERCHIO, EY.01, EY.02 ed EY.03.
 *
 * Restituisce cio' che il menu' del profilo mostra, assegna il sigillo la
 * prima volta (lo assegna il server, in transazione) e accetta dal telefono
 * gli aggiornamenti che solo il telefono conosce: il segno (calcolato dalla
 * data di nascita sul telefono e mandato come SEGNO, mai come data), il
 * Maestro, il gradino del Cammino e se la persona e' maggiorenne.
 */
export const ilMioProfiloNelCerchio = onCall(OPZIONI_SOCIALI, async (request) => {
  const uid = uidDi(request);
  await tettoDellaPorta(uid, "ilMioProfiloNelCerchio");
  const corpo = (request.data ?? {}) as Record<string, unknown>;
  // **I QUATTORDICI ANNI, ordine EZ voce 04**: si scrivono nel documento del
  // tetto, dove tutte le altre porte li trovano senza una lettura in piu'.
  const quattordici = quattordiciDichiarati(corpo);
  await Promise.all([
    statoDi(uid, "tetti_sociali").set({quattordici}, {merge: true}),
    statoDi(uid, "identita").set({quattordici}, {merge: true}),
  ]);
  if (!quattordici) {
    // Nessun profilo pubblico e nessuna presenza: se c'erano, se ne vanno.
    // Dall'ordine FB voce 01 la presenza sta nel suo frammento: la voce si
    // toglie da li'; il documento di prima si cancella ancora, perche' chi
    // aveva una presenza prima della pubblicazione puo' averlo.
    await Promise.all([
      db().collection("profili").doc(uid).delete(),
      scriviLaPresenza(uid, null),
      utente(uid).collection("presenza").doc("adesso").delete(),
    ]);
    return {chiuso: true, riga: RIGA_DEI_QUATTORDICI};
  }
  const sigillo = await assicuraIlSigillo(uid);
  const aggiornamenti: Record<string, unknown> = {};
  if (corpo.segno !== undefined) aggiornamenti.segno = segnoValido(corpo.segno);
  if (corpo.maestro !== undefined) aggiornamenti.maestro = maestroValido(corpo.maestro);
  if (corpo.gradino !== undefined && gradinoValido(corpo.gradino) !== null) {
    aggiornamenti.gradino = gradinoValido(corpo.gradino);
  }
  if (typeof corpo.maggiorenne === "boolean") {
    aggiornamenti.maggiorenne = corpo.maggiorenne;
  }
  if (Object.keys(aggiornamenti).length > 0) {
    await statoDi(uid, "identita").set(aggiornamenti, {merge: true});
  }
  const io = await leggiIdentita(uid);
  if (io.nome.length > 0) await scriviIlPubblico(uid, io);
  await aggiornaLaSchedaDellaPresenza(uid, io);
  return vistaDelProfilo(uid, io, sigillo);
});

function vistaDelProfilo(uid: string, io: Identita, sigillo: string) {
  return {
    uid,
    sigillo,
    nome: io.nome,
    icona: io.icona,
    visibilita: io.visibilita,
    visibilitaEffettiva: visibilitaEffettiva(io.visibilita, io.maggiorenne),
    chiPuoInvitare: io.chiPuoInvitare,
    nomeSiRiapre: quandoSiRiapreIlNome(io.cambiNome, io.ultimoCambio, Date.now()),
    primoNomeLibero: io.cambiNome < 1,
  };
}

/** Scrive il profilo pubblico, e SOLO i suoi sette campi. */
async function scriviIlPubblico(uid: string, io: Identita): Promise<void> {
  if (io.sigillo === null || io.nome.length === 0) return;
  const pubblico = soloIlPubblico({
    nome: io.nome,
    sigillo: io.sigillo,
    icona: io.icona,
    segno: io.segno,
    gradino: io.gradino,
    maestro: io.maestro,
    ultimaPresenza: Date.now(),
  });
  await profiloDi(uid).set(pubblico);
}

/**
 * SCEGLI IL NOME, EY.01. Il telefono propone, questa porta decide: la forma,
 * i nomi riservati, le parole offensive, il nome lasciato da un altro da meno
 * di novanta giorni, la cadenza del cambio. **Il nome visibile non e' unico**:
 * due persone possono chiamarsi uguale, e a distinguerle e' il sigillo.
 */
export const scegliIlNome = onCall(OPZIONI_SOCIALI, async (request) => {
  const uid = uidDi(request);
  await tettoDellaPorta(uid, "scegliIlNome");
  const verdetto = verdettoDelNome(request.data?.nome);
  if (!verdetto.ok || verdetto.perche !== null) {
    const perche = verdetto.perche ?? "caratteri";
    return {ok: false, perche, riga: RIGHE_DEL_RIFIUTO[perche]};
  }
  const sigillo = await assicuraIlSigillo(uid);
  const adesso = Date.now();
  const forma = formeDiConfronto(verdetto.nome)[0];
  const esito = await db().runTransaction(async (tx) => {
    const ioSnap = await tx.get(statoDi(uid, "identita"));
    const io = identitaDa(ioSnap.data());
    const lasciato = await tx.get(db().collection("nomi_lasciati").doc(forma));
    const dl = lasciato.data();
    if (dl && dl.uid !== uid && typeof dl.fino === "number" && adesso < dl.fino) {
      return {ok: false, perche: "lasciato",
        riga: "Questo nome è stato lasciato da poco: torna libero fra qualche settimana."};
    }
    if (io.nome === verdetto.nome) return {ok: true, perche: null, riga: null};
    const primo = io.nome.length === 0;
    if (!primo) {
      const riapre = quandoSiRiapreIlNome(io.cambiNome, io.ultimoCambio, adesso);
      if (riapre !== null) {
        return {ok: false, perche: "cadenza", riapre,
          riga: "Il nome si cambia una volta ogni trenta giorni."};
      }
      // Il nome lasciato resta di chi lo lascia per novanta giorni.
      const vecchia = formeDiConfronto(io.nome)[0];
      tx.set(db().collection("nomi_lasciati").doc(vecchia),
        {uid, fino: scadenzaDelNomeLasciato(adesso)});
    }
    tx.set(statoDi(uid, "identita"), {
      nome: verdetto.nome,
      cambiNome: primo ? 0 : io.cambiNome + 1,
      ultimoCambio: primo ? null : adesso,
      ...(primo ? {primoNomeIl: adesso} : {}),
    }, {merge: true});
    return {ok: true, perche: null, riga: null};
  });
  if (!esito.ok) return esito;
  const io = await leggiIdentita(uid);
  await scriviIlPubblico(uid, io);
  await aggiornaLaSchedaDellaPresenza(uid, io);
  return {...esito, profilo: vistaDelProfilo(uid, io, sigillo)};
});

/**
 * AGGIORNA IL PROFILO, EY.03 ed EY.09: l'icona, la visibilita' e chi puo'
 * invitarti. L'invisibilita' e' gratuita per tutti i piani: questa porta non
 * guarda il piano.
 */
export const aggiornaIlProfiloNelCerchio = onCall(OPZIONI_SOCIALI, async (request) => {
  const uid = uidDi(request);
  await tettoDellaPorta(uid, "aggiornaIlProfiloNelCerchio");
  const corpo = (request.data ?? {}) as Record<string, unknown>;
  const campi: Record<string, unknown> = {};
  if (corpo.icona !== undefined) {
    const icona = iconaValida(corpo.icona);
    if (icona === null) throw new HttpsError("invalid-argument", "Icona sconosciuta.");
    campi.icona = icona;
  }
  if (corpo.visibilita !== undefined) {
    const v = visibilitaValida(corpo.visibilita);
    if (v === null) throw new HttpsError("invalid-argument", "Visibilità sconosciuta.");
    campi.visibilita = v;
  }
  if (corpo.chiPuoInvitare !== undefined) {
    campi.chiPuoInvitare = corpo.chiPuoInvitare === "sigillo" ? "sigillo" : "tutti";
  }
  const sigillo = await assicuraIlSigillo(uid);
  if (Object.keys(campi).length > 0) {
    await statoDi(uid, "identita").set(campi, {merge: true});
  }
  const io = await leggiIdentita(uid);
  await scriviIlPubblico(uid, io);
  await aggiornaLaSchedaDellaPresenza(uid, io);
  return vistaDelProfilo(uid, io, sigillo);
});

// ---------------------------------------------------------------------------
// PARTE B, IL LEGAME
// ---------------------------------------------------------------------------

/**
 * IL CODICE DELL'INVITO, EY.17 ed EY.04. Un meccanismo solo, due durate: il
 * codice del link (trenta giorni, rinnovabile, revocabile dal profilo) e il
 * codice da inquadrare (cinque minuti). Lo genera il server, lo lega a chi
 * invita, e nel codice non c'e' nessun dato della persona.
 */
export const ilCodiceDellInvito = onCall(OPZIONI_SOCIALI, async (request) => {
  const uid = uidDi(request);
  await tettoDellaPorta(uid, "ilCodiceDellInvito");
  const tipo: TipoDelCodice = request.data?.tipo === "vicino" ? "vicino" : "link";
  const rinnova = request.data?.rinnova === true;
  const revoca = request.data?.revoca === true;
  const adesso = Date.now();
  const mio = statoDi(uid, "codici");
  return db().runTransaction(async (tx) => {
    // Prima tutte le letture, poi le scritture: e' la regola delle
    // transazioni di Firestore.
    const snap = await tx.get(mio);
    const d = snap.data() ?? {};
    const attuale = typeof d[tipo] === "string" ? (d[tipo] as string) : null;
    let valido: {codice: string; scade: number} | null = null;
    if (attuale !== null) {
      const c = await tx.get(db().collection("codici_invito").doc(attuale));
      const scade = c.data()?.scade;
      if (c.exists && c.data()?.uid === uid && typeof scade === "number" && scade > adesso) {
        valido = {codice: attuale, scade};
      }
    }
    let nuovo = unCodice(tipo);
    for (let i = 0; i < 5; i++) {
      const c = await tx.get(db().collection("codici_invito").doc(nuovo));
      if (!c.exists) break;
      nuovo = unCodice(tipo);
    }
    if (revoca) {
      if (attuale !== null) tx.delete(db().collection("codici_invito").doc(attuale));
      tx.set(mio, {[tipo]: null}, {merge: true});
      return {codice: null, scade: null};
    }
    // Il codice da inquadrare e' sempre nuovo: vale cinque minuti e una sua
    // fotografia non deve servire a niente dopo.
    if (valido !== null && !rinnova && tipo === "link") return valido;
    if (attuale !== null) tx.delete(db().collection("codici_invito").doc(attuale));
    const scade = adesso + DURATE_DEL_CODICE[tipo];
    tx.set(db().collection("codici_invito").doc(nuovo), {uid, tipo, scade});
    tx.set(mio, {[tipo]: nuovo}, {merge: true});
    return {codice: nuovo, scade};
  });
});

/** Il proprietario di un codice valido, oppure null. */
async function chiPortaIlCodice(codice: string): Promise<string | null> {
  const c = await db().collection("codici_invito").doc(codice).get();
  const d = c.data();
  if (!d || typeof d.uid !== "string") return null;
  if (typeof d.scade !== "number" || d.scade <= Date.now()) return null;
  return d.uid;
}

/** Cio' che di una persona si vede in un elenco: mai il sigillo. */
async function schedaPubblica(uid: string) {
  const snap = await profiloDi(uid).get();
  if (!snap.exists) return null;
  const p = soloIlPubblico(snap.data() ?? {});
  return {uid, nome: p.nome, icona: p.icona, segno: p.segno, maestro: p.maestro,
    gradino: p.gradino, sigillo: p.sigillo};
}

/**
 * LEGGI IL CODICE, EY.04: chi apre un link o inquadra un codice vede chi lo
 * chiama prima di decidere. Nessun legame nasce da questa porta.
 */
export const leggiIlCodice = onCall(OPZIONI_SOCIALI, async (request) => {
  const uid = uidDi(request);
  await tettoDellaPorta(uid, "leggiIlCodice");
  const codice = codiceScritto(request.data?.codice);
  if (codice === null) return {valido: false};
  const di = await chiPortaIlCodice(codice);
  if (di === null || di === uid) return {valido: false, tuo: di === uid};
  if ((await blocchiDi(uid)).has(di)) return {valido: false};
  const chi = await schedaPubblica(di);
  if (chi === null) return {valido: false};
  const l = legameDa((await legameDi(uid, di).get()).data());
  // Il sigillo non viaggia: chi legge un codice vede il nome e l'icona.
  return {valido: true, chi: {uid: chi.uid, nome: chi.nome, icona: chi.icona,
    segno: chi.segno, maestro: chi.maestro}, semaforo: semaforoPer(uid, l)};
});

/**
 * IL LEGAME FRA DUE ACCOUNT, scritto da UNA funzione sola per tutte le porte
 * che lo fanno nascere (il codice, il sigillo, la tendina e il riscatto
 * dell'invito). Restituisce l'esito; non controlla i tetti di chi chiama,
 * che controlla la porta.
 */
async function apriIlLegame(args: {
  da: string;
  a: string;
  /** "amici" quando tutti e due hanno gia' detto si'. */
  comeAmici: boolean;
  conIlSigillo: boolean;
  contaLInvito: boolean;
}): Promise<{ok: boolean; perche: string | null; semaforo?: string}> {
  const {da, a} = args;
  const pianoDa = await pianoDi(da);
  const pianoA = await pianoDi(a);
  const giorno = chiaveDelGiorno();
  const adesso = Date.now();
  return db().runTransaction(async (tx) => {
    const legame = legameDi(da, a);
    const lSnap = await tx.get(legame);
    const bloccoDa = await tx.get(statoDi(da, "blocchi"));
    const identA = await tx.get(statoDi(a, "identita"));
    const legamiDa = await tx.get(statoDi(da, "legami"));
    const legamiA = await tx.get(statoDi(a, "legami"));
    const oggiSnap = await tx.get(statoDi(da, "sociale_oggi"));
    const identDa = await tx.get(statoDi(da, "identita"));
    const b = bloccoDa.data() ?? {};
    const bloccati = elenco(b.bloccati).includes(a) || elenco(b.bloccatoDa).includes(a);
    const l = legameDa(lSnap.data());
    const ia = identitaDa(identA.data());
    const id = identitaDa(identDa.data());
    const amiciDa = elenco(legamiDa.data()?.amici);
    const amiciA = elenco(legamiA.data()?.amici);
    const oggi = oggiDa(oggiSnap.data(), giorno);
    const postiDa = POSTI_DEL_LEGAME[pianoDa] + id.postiComprati;
    const postiA = POSTI_DEL_LEGAME[pianoA] + ia.postiComprati;

    if (args.comeAmici) {
      // Tutti e due hanno detto si': chi ha dato il codice dandolo, chi lo
      // usa usandolo. Contano i posti di entrambi.
      if (da === a) return {ok: false, perche: "teStesso"};
      if (bloccati) return {ok: false, perche: "nonRaggiungibile"};
      if (l?.stato === "amici") return {ok: true, perche: "giaAmici", semaforo: "verde"};
      if (amiciDa.length >= postiDa) return {ok: false, perche: "postiFiniti"};
      if (amiciA.length >= postiA) return {ok: false, perche: "postiFinitiDellAltro"};
      tx.set(legame, {
        membri: [da, a].sort(),
        stato: "amici",
        da: a,
        quando: adesso,
        giorniAccesi: l?.giorniAccesi ?? [],
        nonRicambiati: {},
      }, {merge: true});
      aggiornaGliElenchi(tx, da, a, "amici");
      aggiornaGliElenchi(tx, a, da, "amici");
      return {ok: true, perche: null, semaforo: "verde"};
    }

    const decisione = decidiLInvito({
      da,
      a,
      bloccati,
      legame: l,
      conIlSigillo: args.conIlSigillo,
      soloColSigillo: ia.chiPuoInvitare === "sigillo",
      invitiOggi: args.contaLInvito ? oggi.inviti : 0,
      amiciDiChiInvita: amiciDa.length,
      postiDiChiInvita: postiDa,
      adessoMs: adesso,
    });
    if (!decisione.concesso) return {ok: false, perche: decisione.perche};
    tx.set(legame, {
      membri: [da, a].sort(),
      stato: "invito",
      da,
      quando: adesso,
      fino: null,
      giorniAccesi: l?.giorniAccesi ?? [],
      nonRicambiati: {},
    }, {merge: true});
    aggiornaGliElenchi(tx, da, a, "inviati");
    aggiornaGliElenchi(tx, a, da, "ricevuti");
    if (args.contaLInvito) {
      tx.set(statoDi(da, "sociale_oggi"), {...oggi, inviti: oggi.inviti + 1});
    }
    return {ok: true, perche: null, semaforo: "arancioneChiaro"};
  });
}

/** Le righe dei rifiuti del legame, in italiano, una per motivo. */
const RIGHE_DEL_LEGAME: Record<string, string> = {
  teStesso: "Questo è il tuo stesso invito.",
  giaAmici: "Siete già amici nel Cerchio.",
  giaInvitato: "Ti ha già invitato: trovi l’invito fra le persone che ti cercano.",
  aspettaRisposta: "L’hai già invitato: aspetta la sua risposta.",
  rifiutatoDiRecente: "Per ora questo invito non si può rimandare.",
  nonRaggiungibile: "Questa persona non si può invitare.",
  postiFiniti: "I tuoi posti nel Cerchio sono pieni.",
  postiFinitiDellAltro: "I suoi posti nel Cerchio sono pieni.",
  invitiFiniti: "Per oggi hai mandato tutti gli inviti: venti al giorno.",
  soloColSigillo: "Questa persona si invita solo col suo sigillo.",
  // Ordine FD voce 06.8, alla lettera: il codice da inquadrare (sei
  // caratteri) e il link d'invito (otto) dicono ciascuno la sua scadenza.
  codice: "Questo codice non vale più. Fatelo mostrare di nuovo.",
  link: "Questo invito è scaduto. Chiedi alla persona che te lo ha mandato di rifarlo.",
  assente: "Questa persona non è nel Cerchio adesso.",
};

/**
 * CHIEDI IL LEGAME, EY.04: tre vie, una porta.
 * - `codice`: il codice del link o quello inquadrato. Chi lo ha dato ha gia'
 *   detto si', chi lo usa dice si' adesso: nasce l'amicizia.
 * - `sigillo`: chi conosce il tuo sigillo ti invita, e tu decidi.
 * - `uid`: dalla tendina, solo verso chi e' presente, visibile a tutti e
 *   accetta inviti da tutti. Il server lo verifica sull'istantanea: non si
 *   invita un uid inventato.
 */
export const chiediIlLegame = onCall(OPZIONI_SOCIALI, async (request) => {
  const uid = uidDi(request);
  await tettoDellaPorta(uid, "chiediIlLegame");
  const corpo = (request.data ?? {}) as Record<string, unknown>;
  let esito: {ok: boolean; perche: string | null; semaforo?: string};
  if (corpo.codice !== undefined) {
    const codice = codiceScritto(corpo.codice);
    const di = codice === null ? null : await chiPortaIlCodice(codice);
    if (di === null) {
      esito = {ok: false,
        perche: codice !== null && codice.length !== 6 ? "link" : "codice"};
    } else {
      esito = await apriIlLegame({da: uid, a: di, comeAmici: true,
        conIlSigillo: true, contaLInvito: false});
      // Il codice da inquadrare vale una volta: usato, si spegne.
      if (esito.ok && codice !== null && codice.length === 6) {
        await db().collection("codici_invito").doc(codice).delete();
      }
    }
  } else if (corpo.sigillo !== undefined) {
    const sigillo = sigilloScritto(corpo.sigillo);
    const posto = sigillo === null ? null :
      await db().collection("sigilli").doc(sigillo).get();
    const di = posto?.data()?.uid;
    if (typeof di !== "string") {
      esito = {ok: false, perche: "nonRaggiungibile"};
    } else {
      esito = await apriIlLegame({da: uid, a: di, comeAmici: false,
        conIlSigillo: true, contaLInvito: true});
      if (esito.ok) await avvisaDellInvito(uid, di);
    }
  } else {
    const di = String(corpo.uid ?? "");
    const presente = di.length === 0 ? undefined : await presenzaDi(di, uid);
    if (presente === undefined || presente.visibilita !== "tutti" ||
      !presente.maggiorenne) {
      esito = {ok: false, perche: "assente"};
    } else {
      esito = await apriIlLegame({da: uid, a: di, comeAmici: false,
        conIlSigillo: false, contaLInvito: true});
      if (esito.ok) await avvisaDellInvito(uid, di);
    }
  }
  return {...esito, riga: esito.perche === null ? null :
    (RIGHE_DEL_LEGAME[esito.perche] ?? null)};
});

async function avvisaDellInvito(da: string, a: string): Promise<void> {
  const chi = await schedaPubblica(da);
  if (chi === null) return;
  await avvisa(a, `${chi.nome} ti invita nel suo Cerchio`, "invito");
}

/**
 * RISPONDI AL LEGAME, EY.05: accetta, rifiuta, oppure togli (un amico, o un
 * invito mandato che non aspetti piu').
 *
 * **IL RIFIUTO NON E' UN BLOCCO**: non dice niente a chi ha invitato (per lui
 * l'invito resta in attesa) e impedisce un secondo invito dalla stessa
 * persona per trenta giorni.
 */
export const rispondiAlLegame = onCall(OPZIONI_SOCIALI, async (request) => {
  const uid = uidDi(request);
  await tettoDellaPorta(uid, "rispondiAlLegame");
  const altro = String(request.data?.uid ?? "");
  const azione = String(request.data?.azione ?? "");
  if (altro.length === 0 || altro === uid) {
    throw new HttpsError("invalid-argument", "Persona sconosciuta.");
  }
  if (azione === "accetta") {
    const l = legameDa((await legameDi(uid, altro).get()).data());
    if (l === null || l.stato !== "invito" || l.da !== altro) {
      return {ok: false, riga: "Questo invito non c’è più."};
    }
    const esito = await apriIlLegame({da: uid, a: altro, comeAmici: true,
      conIlSigillo: true, contaLInvito: false});
    if (esito.ok) {
      const io = await schedaPubblica(uid);
      if (io !== null) await avvisa(altro, `${io.nome} è nel tuo Cerchio`, "accolto");
    }
    return {...esito, riga: esito.perche === null ? null :
      (RIGHE_DEL_LEGAME[esito.perche] ?? null)};
  }
  if (azione === "rifiuta" || azione === "togli") {
    await db().runTransaction(async (tx) => {
      const legame = legameDi(uid, altro);
      const l = legameDa((await tx.get(legame)).data());
      if (l === null) return;
      if (azione === "rifiuta" && l.stato === "invito" && l.da === altro) {
        tx.set(legame, {stato: "rifiutato", fino: fineDelRifiuto(Date.now())},
          {merge: true});
        aggiornaGliElenchi(tx, uid, altro, null);
        // Per chi ha invitato l'invito resta "mandato": il rifiuto non si
        // annuncia.
        return;
      }
      if (azione === "togli") {
        tx.delete(legame);
        aggiornaGliElenchi(tx, uid, altro, null);
        aggiornaGliElenchi(tx, altro, uid, null);
      }
    });
    return {ok: true, riga: null};
  }
  throw new HttpsError("invalid-argument", "Azione sconosciuta.");
});

/**
 * BLOCCA UNA PERSONA, EY.05. **IL BLOCCO AGISCE SULL'IDENTIFICATIVO, mai sul
 * nome**: cambiare nome non lo evade. Chi e' bloccato non compare fra i
 * presenti, non ti vede, non puo' invitarti, non puo' mandarti niente, e NON
 * viene informato: dire a una persona che e' stata bloccata produce il
 * ritorno con un altro account, e un account oggi costa zero.
 */
export const bloccaUnaPersona = onCall(OPZIONI_SOCIALI, async (request) => {
  const uid = uidDi(request);
  await tettoDellaPorta(uid, "bloccaUnaPersona");
  const altro = String(request.data?.uid ?? "");
  const sblocca = request.data?.sblocca === true;
  if (altro.length === 0 || altro === uid) {
    throw new HttpsError("invalid-argument", "Persona sconosciuta.");
  }
  await db().runTransaction(async (tx) => {
    const legame = legameDi(uid, altro);
    await tx.get(legame);
    if (sblocca) {
      tx.set(statoDi(uid, "blocchi"), {bloccati: FieldValue.arrayRemove(altro)},
        {merge: true});
      tx.set(statoDi(altro, "blocchi"), {bloccatoDa: FieldValue.arrayRemove(uid)},
        {merge: true});
      return;
    }
    tx.set(statoDi(uid, "blocchi"), {bloccati: FieldValue.arrayUnion(altro)},
      {merge: true});
    tx.set(statoDi(altro, "blocchi"), {bloccatoDa: FieldValue.arrayUnion(uid)},
      {merge: true});
    // Il blocco scioglie il legame e ogni invito, in silenzio.
    tx.delete(legame);
    aggiornaGliElenchi(tx, uid, altro, null);
    aggiornaGliElenchi(tx, altro, uid, null);
  });
  return {ok: true};
});

/**
 * IL MIO CERCHIO, EY.03 ed EY.05: gli amici col semaforo verde, gli inviti
 * ricevuti (arancione pieno) e mandati (arancione chiaro), e l'elenco delle
 * persone bloccate, che e' l'unico posto dove vive il rosso.
 */
export const ilMioCerchio = onCall(OPZIONI_SOCIALI, async (request) => {
  const uid = uidDi(request);
  await tettoDellaPorta(uid, "ilMioCerchio");
  const [legamiSnap, blocchiSnap, io, piano] = await Promise.all([
    statoDi(uid, "legami").get(),
    statoDi(uid, "blocchi").get(),
    leggiIdentita(uid),
    pianoDi(uid),
  ]);
  const amici = elenco(legamiSnap.data()?.amici);
  const inviati = elenco(legamiSnap.data()?.inviati);
  const ricevuti = elenco(legamiSnap.data()?.ricevuti);
  const bloccati = elenco(blocchiSnap.data()?.bloccati);
  const tutti = [...new Set([...amici, ...inviati, ...ricevuti, ...bloccati])];
  const profili = tutti.length === 0 ? [] :
    await db().getAll(...tutti.map((u) => profiloDi(u)));
  const perUid = new Map<string, ReturnType<typeof soloIlPubblico>>();
  for (const p of profili) if (p.exists) perUid.set(p.id, soloIlPubblico(p.data() ?? {}));
  const legami = amici.length === 0 ? [] :
    await db().getAll(...amici.map((u) => legameDi(uid, u)));
  const accesi = new Map<string, number>();
  for (const l of legami) {
    const d = legameDa(l.data());
    const altro = (l.data()?.membri as string[] | undefined)?.find((m) => m !== uid);
    if (d !== null && altro) accesi.set(altro, d.giorniAccesi.length);
  }
  const persona = (u: string, semaforo: string) => {
    const p = perUid.get(u);
    return p === undefined ? null : {
      uid: u, nome: p.nome, icona: p.icona, segno: p.segno, maestro: p.maestro,
      gradino: p.gradino, sigillo: p.sigillo, semaforo,
      tratti: accesi.get(u) ?? 0,
    };
  };
  const oggi = oggiDa((await statoDi(uid, "sociale_oggi").get()).data(),
    chiaveDelGiorno());
  // I segni e i doni recenti viaggiano con il Cerchio: il telefono legge
  // tutto da questa porta, senza una seconda strada sullo stesso dato.
  const [segniSnap, doniSnap] = await Promise.all([
    utente(uid).collection("segni").orderBy("quando", "desc").limit(40).get(),
    utente(uid).collection("doni").orderBy("quando", "desc").limit(40).get(),
  ]);
  const nomeDi = (u: string) => perUid.get(u)?.nome ?? null;
  const iconaDi = (u: string) => perUid.get(u)?.icona ?? null;
  const maestroDi = (u: string) => perUid.get(u)?.maestro ?? null;
  return {
    segni: segniSnap.docs.map((d) => {
      const s = d.data();
      const con = String(s.con ?? "");
      return {id: d.id, segno: s.segno ?? null, verso: s.verso ?? null, con,
        nomeCon: nomeDi(con), iconaCon: iconaDi(con), maestroCon: maestroDi(con),
        quando: s.quando ?? null,
        risposta: typeof s.risposta === "number" ? s.risposta : null,
        reazione: typeof s.reazione === "string" ? s.reazione : null};
    }),
    doni: doniSnap.docs.map((d) => {
      const s = d.data();
      const da = String(s.da ?? "");
      return {id: d.id, dono: s.dono ?? null, da, nomeDa: nomeDi(da),
        quando: s.quando ?? null};
    }),
    amici: amici.map((u) => persona(u, "verde")).filter((x) => x !== null),
    ricevuti: ricevuti.map((u) => persona(u, "arancionePieno")).filter((x) => x !== null),
    inviati: inviati.map((u) => persona(u, "arancioneChiaro")).filter((x) => x !== null),
    bloccati: bloccati.map((u) => {
      const p = perUid.get(u);
      return {uid: u, nome: p?.nome ?? "Una persona del Cerchio", sigillo: p?.sigillo ?? ""};
    }),
    posti: POSTI_DEL_LEGAME[piano] + io.postiComprati,
    segniOggi: oggi.segni,
    segniAlGiorno: SEGNI_AL_GIORNO[piano],
    regalatiOggi: oggi.regalati,
  };
});

/**
 * UN POSTO IN PIU' NEL CERCHIO, EY.07: costa 100 Eos, la voce `amicoInPiu`
 * che esiste gia' nel listino. Nessun secondo prezzo. Si paga sull'esito, e
 * l'identificativo del movimento rende innocuo il doppio tocco.
 */
export const compraUnPostoNelCerchio = onCall(OPZIONI_SOCIALI, async (request) => {
  const uid = uidDi(request);
  await tettoDellaPorta(uid, "compraUnPostoNelCerchio");
  const id = String(request.data?.idMovimento ?? "").trim();
  if (id.length < 8 || id.length > 200) {
    throw new HttpsError("invalid-argument", "Ogni movimento porta il suo identificativo.");
  }
  return db().runTransaction(async (tx) => {
    const movimento = utente(uid).collection("movimenti").doc(id);
    const gia = await tx.get(movimento);
    const borsa = await tx.get(statoDi(uid, "borsellino"));
    const io = identitaDa((await tx.get(statoDi(uid, "identita"))).data());
    const saldo = (borsa.data()?.saldo as number) ?? 0;
    if (gia.exists) return {ok: true, saldo, gia: true};
    if (saldo < EOS_DEL_POSTO_IN_PIU) {
      return {ok: false, saldo, manca: EOS_DEL_POSTO_IN_PIU - saldo};
    }
    tx.set(movimento, {causale: "spesa", motivo: "amico_in_piu",
      importo: -EOS_DEL_POSTO_IN_PIU, saldoDopo: saldo - EOS_DEL_POSTO_IN_PIU,
      quando: FieldValue.serverTimestamp()});
    tx.set(statoDi(uid, "borsellino"), {saldo: saldo - EOS_DEL_POSTO_IN_PIU,
      aggiornato: FieldValue.serverTimestamp()}, {merge: true});
    tx.set(statoDi(uid, "identita"), {postiComprati: io.postiComprati + 1},
      {merge: true});
    return {ok: true, saldo: saldo - EOS_DEL_POSTO_IN_PIU, gia: false};
  });
});

// ---------------------------------------------------------------------------
// PARTE C, LA PRESENZA
// ---------------------------------------------------------------------------

const FRAMMENTO = (k: number, spazio: SpazioDellaPresenza) =>
  db().collection(`${spazio}cerchio_presenze`).doc(String(k));
const TURNO = (spazio: SpazioDellaPresenza) =>
  db().collection(`${spazio}cerchio_adesso`).doc("turno");

/**
 * **SCRIVE LA PRESENZA NEL SUO FRAMMENTO, ordine FB voce 01**: la voce della
 * persona dentro `cerchio_presenze/{k}`. Nulla la toglie (chi esce, chi ha
 * meno di quattordici anni, chi cancella il Cerchio). Una scrittura, come
 * prima la scrittura del documento della persona.
 */
export async function scriviLaPresenza(uid: string,
  campi: SchedaCompatta | null): Promise<void> {
  const doc = FRAMMENTO(frammentoDi(uid), spazioDi(uid));
  if (campi === null) {
    try {
      await doc.update({[`p.${uid}`]: FieldValue.delete()});
    } catch (senzaFrammento) {
      logger.debug("La presenza da togliere non c'era.", {uid});
    }
    return;
  }
  await doc.set({p: {[uid]: campi}}, {merge: true});
}

/**
 * **L'ULTIMO SEGNO DI CHI VA SULLO SFONDO, ordine FF voce 01.** Rinnova solo
 * l'ora della voce della persona, e lascia la scheda com'e'. Chi non ha una
 * voce con la scheda (sotto i quattordici anni, o mai passato) riceve una
 * voce con la sola ora, che il conto salta perche' senza visibilita'
 * (`costruisciLIstantanea`) e la ricostruzione toglie dopo un'ora. Una
 * scrittura, come la cancellazione che prendeva il suo posto.
 */
export async function scriviLUscita(uid: string,
  adesso: number): Promise<void> {
  const doc = FRAMMENTO(frammentoDi(uid), spazioDi(uid));
  try {
    await doc.update({[`p.${uid}.u`]: adesso});
  } catch (senzaFrammento) {
    logger.debug("L'uscita non ha un frammento da rinnovare.", {uid});
  }
}

/**
 * **L'ISTANTANEA IN MEMORIA, ordine EZ voce 03.** Ogni istanza del server
 * tiene l'ultima istantanea letta per trenta secondi: le aperture che
 * arrivano nello stesso mezzo minuto non la rileggono. `letta` e' quando
 * l'istanza l'ha letta, che non e' quando e' stata fatta.
 */
//
// **Una per spazio**, ordine FD voce 05: i collaudi non leggono la memoria
// degli utenti, e gli utenti non leggono la loro.
const istantaneaInMemoria = new Map<SpazioDellaPresenza,
  {ist: Istantanea; letta: number}>();

function istantaneaVuota(adesso: number): Istantanea {
  return {quando: adesso, totale: 0, perArte: {}, presenti: {}, nascosti: [],
    troncata: false};
}

/**
 * **L'ISTANTANEA COI PRESENTI, ordine FB voce 01.** Si rifa' al massimo una
 * volta ogni trenta secondi PER TUTTO IL CERCHIO: chi la trova vecchia prende
 * il turno in transazione (`cerchio_adesso/turno`), e solo chi l'ha preso la
 * ricostruisce; gli altri servono quella che c'e'. La ricostruzione legge il
 * turno e i novantasei frammenti, qualunque sia il numero dei presenti, e
 * toglie dai frammenti le voci scadute da piu' di un'ora.
 *
 * **LA RICOSTRUISCE SOLO IL PASSO DELLA PRESENZA** (`ricostruisci: true`, la
 * chiama `chiEOnline`), mai la tendina ne' i gesti. Nella prima stesura di
 * questa voce l'apertura della tendina che trovava l'istantanea vecchia la
 * rifaceva, e quell'apertura leggeva centodue documenti invece di cinque:
 * una ogni trenta secondi, ma sopra la soglia delle dieci. Adesso la tendina
 * legge l'istantanea com'e': chi la apre e' presente e il suo passo la tiene
 * fresca, al massimo un minuto.
 */
export async function istantanea(
  {ricostruisci, spazio}: {ricostruisci: boolean; spazio: SpazioDellaPresenza}):
  Promise<Istantanea> {
  const adesso = Date.now();
  const inMemoria = istantaneaInMemoria.get(spazio);
  if (inMemoria && !istantaneaVecchia(inMemoria.letta, adesso) &&
    (!ricostruisci || !istantaneaVecchia(inMemoria.ist.quando, adesso))) {
    return inMemoria.ist;
  }
  const snap = await ISTANTANEA(spazio).get();
  const d = snap.data() as Istantanea | undefined;
  const valida = d !== undefined && typeof d.presenti === "object" &&
    d.presenti !== null;
  if (valida && (!ricostruisci || !istantaneaVecchia(d.quando, adesso))) {
    istantaneaInMemoria.set(spazio, {ist: d, letta: adesso});
    return d;
  }
  if (!ricostruisci) return istantaneaVuota(adesso);
  const mioIlTurno = await db().runTransaction(async (tx) => {
    const turno = await tx.get(TURNO(spazio));
    const fino = (turno.data()?.fino as number | undefined) ?? 0;
    if (fino > adesso) return false;
    tx.set(TURNO(spazio), {fino: adesso + OGNI_QUANTO_SI_RIFA_L_ISTANTANEA_MS});
    return true;
  });
  if (!mioIlTurno) return valida ? d : istantaneaVuota(adesso);
  // Solo i frammenti che esistono: con un presente solo, uno (ordine FB voce
  // 01, i vuoti si cancellano qui sotto).
  const esistenti = await db().collection(`${spazio}cerchio_presenze`).get();
  const frammenti = new Array<Record<string, SchedaCompatta> | undefined>(
    FRAMMENTI_DELLA_PRESENZA).fill(undefined);
  const istanti = new Map<number, Timestamp>();
  for (const f of esistenti.docs) {
    const k = Number(f.id);
    if (!Number.isInteger(k) || k < 0 || k >= FRAMMENTI_DELLA_PRESENZA) continue;
    frammenti[k] = (f.data()?.p ?? {}) as Record<string, SchedaCompatta>;
    istanti.set(k, f.updateTime);
  }
  const {istantanea: nuova, scadute, vuoti} = costruisciLIstantanea({
    frammenti,
    adessoMs: adesso,
    confineMs: confineDellaPresenza(adesso),
  });
  await ISTANTANEA(spazio).set(nuova);
  if (scadute.length > 0 || vuoti.length > 0) {
    // La pulizia vale solo se il frammento e' ancora quello letto: un passo
    // arrivato nel frattempo cambia l'ora del documento, la precondizione
    // fa cadere il lotto e la voce fresca resta. Si riprova alla prossima.
    const perFrammento = new Map<number, Record<string, unknown>>();
    for (const {frammento, uid} of scadute) {
      const campi = perFrammento.get(frammento) ?? {};
      campi[`p.${uid}`] = FieldValue.delete();
      perFrammento.set(frammento, campi);
    }
    const batch = db().batch();
    for (const k of vuoti) {
      batch.delete(FRAMMENTO(k, spazio), {lastUpdateTime: istanti.get(k)!});
      perFrammento.delete(k);
    }
    for (const [k, campi] of perFrammento) {
      batch.update(FRAMMENTO(k, spazio), campi, {lastUpdateTime: istanti.get(k)!});
    }
    try {
      await batch.commit();
    } catch (cambiatoNelFrattempo) {
      logger.debug("La pulizia dei frammenti si rifa' alla prossima.",
        {errore: String(cambiatoNelFrattempo)});
    }
  }
  istantaneaInMemoria.set(spazio, {ist: nuova, letta: adesso});
  return nuova;
}

/**
 * LA PRESENZA DI UNA PERSONA SOLA, per i gesti verso chi non e' amico:
 * dall'istantanea, senza una lettura in piu' (ordine FB voce 01).
 */
async function presenzaDi(uid: string, chiGuarda: string):
  Promise<Presenza | undefined> {
  const ist = await istantanea({ricostruisci: false, spazio: spazioDi(chiGuarda)});
  return scompatta(uid, ist.presenti?.[uid]) ?? undefined;
}

/** L'affinita' alta fra due segni: lo stesso elemento, cioe' il trigono. */
function affinitaAltaFraSegni(a: string, b: string): boolean {
  const i = SEGNI_ORDINATI.indexOf(a);
  const j = SEGNI_ORDINATI.indexOf(b);
  return i >= 0 && j >= 0 && i !== j && (i % 4) === (j % 4);
}
const SEGNI_ORDINATI = ["aries", "taurus", "gemini", "cancer", "leo", "virgo",
  "libra", "scorpio", "sagittarius", "capricorn", "aquarius", "pisces"];

/**
 * LA TENDINA DELL'INDICATORE ONLINE, EY.08 ed EY.09: i tuoi amici presenti,
 * il Cerchio adesso per arte, e al massimo dodici persone che ti somigliano,
 * col criterio dichiarato. **Nessun elenco completo dei presenti**: non
 * esiste una via per scorrerli tutti. E' la porta col tetto piu' stretto.
 */
export const laTendinaDelCerchio = onCall(OPZIONI_SOCIALI, async (request) => {
  const uid = uidDi(request);
  await tettoDellaPorta(uid, "laTendinaDelCerchio");
  const [ist, legamiSnap, blocchi, io] = await Promise.all([
    istantanea({ricostruisci: false, spazio: spazioDi(uid)}),
    statoDi(uid, "legami").get(),
    blocchiDi(uid),
    leggiIdentita(uid),
  ]);
  const amici = new Set(elenco(legamiSnap.data()?.amici));
  const inviati = new Set(elenco(legamiSnap.data()?.inviati));
  const ricevuti = new Set(elenco(legamiSnap.data()?.ricevuti));
  // **TUTTI GLI AMICI PRESENTI, ordine FB voce 01**: incrociati IN MEMORIA
  // fra l'istantanea e i legami gia' letti. Nessuna lettura per amico: sei
  // amici presenti o centocinquanta costano le stesse letture.
  const amiciPresenti = [...amici]
    .filter((a) => !blocchi.has(a))
    .flatMap((a) => {
      const p = scompatta(a, ist.presenti?.[a]);
      return p ? [p] : [];
    })
    .map((p) => ({uid: p.uid, nome: p.nome, icona: p.icona, segno: p.segno,
      maestro: p.maestro, arte: p.arte, sigillo: p.sigillo, semaforo: "verde"}));
  const esclusi = new Set<string>([...amici, ...blocchi]);
  // **Un minorenne non vede sconosciuti e non e' visto da loro**: la tendina
  // gli mostra gli amici e il Cerchio per arte, non le persone che somigliano.
  const simili = !io.maggiorenne ? [] : somiglianti({
    istantanea: ist,
    chiGuarda: uid,
    giorno: chiaveDelGiorno(),
    mioSegno: io.segno,
    mioMaestro: io.maestro,
    mioGradino: io.gradino,
    esclusi,
    affinitaAlta: affinitaAltaFraSegni,
  }).map(({persona, criterio}) => ({
    uid: persona.uid, nome: persona.nome, icona: persona.icona,
    segno: persona.segno, maestro: persona.maestro, gradino: persona.gradino,
    sigillo: persona.sigillo, criterio,
    semaforo: inviati.has(persona.uid) ? "arancioneChiaro" :
      ricevuti.has(persona.uid) ? "arancionePieno" : "spento",
    invitabile: persona.chiPuoInvitare === "tutti",
  }));
  return {
    amiciPresenti,
    perArte: ist.perArte,
    somiglianti: simili,
    io: {visibilita: visibilitaEffettiva(io.visibilita, io.maggiorenne)},
    quando: ist.quando,
  };
});

/**
 * LA SCHEDA SEGUE IL PROFILO, ordine EZ voce 03: il passo della presenza non
 * rilegge piu' l'identita' a ogni minuto, quindi quando il profilo cambia la
 * scheda si aggiorna qui, con l'identita' gia' letta dalla porta. Se la
 * persona non e' presente adesso il documento non c'e', e la scheda si
 * scrivera' al suo primo passo.
 */
async function aggiornaLaSchedaDellaPresenza(uid: string, io: Identita):
  Promise<void> {
  // Una voce senza passo (`u`) non conta, e la ricostruzione la toglie: chi
  // non e' presente adesso non diventa presente per un cambio di profilo.
  await scriviLaPresenza(uid, io.quattordici ? schedaDellaPresenza(io) : null);
}

/** Scrive la scheda della presenza; la chiama `chiEOnline` al primo passo. */
export async function rinnovaLaScheda(uid: string, arte: ArteDellaPresenza):
  Promise<SchedaCompatta | null> {
  const io = await leggiIdentita(uid);
  // Sotto i quattordici anni nessuna presenza (ordine EZ voce 04).
  if (!io.quattordici) return null;
  return {...schedaDellaPresenza(io), a: arte};
}

// ---------------------------------------------------------------------------
// PARTE D, I GESTI
// ---------------------------------------------------------------------------

/**
 * MANDA UN SEGNO, EY.10. Solo agli amici, solo segni dell'elenco chiuso:
 * **zero testo libero** in tutto il motore sociale. Il segno arriva come
 * notifica che nomina la cosa. I segni non si comprano e non fanno guadagnare
 * Eos.
 */
export const mandaUnSegno = onCall(OPZIONI_SOCIALI, async (request) => {
  const uid = uidDi(request);
  await tettoDellaPorta(uid, "mandaUnSegno");
  const a = String(request.data?.a ?? "");
  const segno = String(request.data?.segno ?? "");
  if (RISPOSTE_PER_SEGNO[segno] === undefined) {
    throw new HttpsError("invalid-argument", "Segno sconosciuto.");
  }
  const piano = await pianoDi(uid);
  const giorno = chiaveDelGiorno();
  const esito = await scriviUnGesto({uid, a, piano, giorno,
    contenuto: {segno}, conta: true});
  if (esito.ok) {
    const io = await schedaPubblica(uid);
    if (io !== null) await avvisa(a, `${io.nome} ti ha mandato un segno`, "segno");
  }
  return esito;
});

const RIGHE_DEL_SEGNO: Record<string, string> = {
  segniFiniti: "Per oggi hai mandato tutti i tuoi segni.",
  troppiAllaStessaPersona: "Oggi le hai già mandato tre segni.",
  aspettaCheRisponda: "Aspetta che risponda ai tuoi segni.",
  nonAmici: "I segni si mandano agli amici del Cerchio.",
};

/**
 * Scrive un segno, una risposta o una reazione sui rami dei due, conta i
 * tetti e accende lo scambio del giorno per il glifo.
 */
async function scriviUnGesto(args: {
  uid: string;
  a: string;
  piano: Piano;
  giorno: string;
  contenuto: Record<string, unknown>;
  conta: boolean;
  rispondeA?: string;
}): Promise<{ok: boolean; perche: string | null; riga: string | null; id?: string}> {
  const {uid, a, piano, giorno} = args;
  return db().runTransaction(async (tx) => {
    const legame = legameDi(uid, a);
    const l = legameDa((await tx.get(legame)).data());
    const oggiSnap = await tx.get(statoDi(uid, "sociale_oggi"));
    const blocchi = (await tx.get(statoDi(uid, "blocchi"))).data() ?? {};
    const oggi = oggiDa(oggiSnap.data(), giorno);
    const bloccati = elenco(blocchi.bloccati).includes(a) ||
      elenco(blocchi.bloccatoDa).includes(a);
    const amici = l !== null && l.stato === "amici" && !bloccati;
    const decisione = decidiIlSegno({
      piano,
      mandatiOggi: oggi.segni,
      allaStessaOggi: oggi.perPersona[a] ?? 0,
      // Chi risponde non insiste: la risposta non guarda i non ricambiati.
      nonRicambiati: args.rispondeA !== undefined ? 0 : (l?.nonRicambiati[uid] ?? 0),
      amici,
    });
    if (!decisione.concesso) {
      return {ok: false, perche: decisione.perche,
        riga: RIGHE_DEL_SEGNO[decisione.perche ?? ""] ?? null};
    }
    const scambio = registraLoScambio({giorno, chiManda: uid,
      scambio: l?.scambio ?? null, giorniAccesi: l?.giorniAccesi ?? []});
    const nonRicambiati = {...(l?.nonRicambiati ?? {})};
    // Chi manda qualcosa ricambia: i segni non ricambiati dell'altro verso di
    // lui tornano a zero, i suoi crescono finche' l'altro non risponde.
    nonRicambiati[a] = 0;
    nonRicambiati[uid] = args.rispondeA !== undefined ? 0 : (nonRicambiati[uid] ?? 0) + 1;
    tx.set(legame, {scambio: scambio.scambio, giorniAccesi: scambio.giorniAccesi,
      nonRicambiati}, {merge: true});
    if (args.conta) {
      tx.set(statoDi(uid, "sociale_oggi"), {...oggi, segni: oggi.segni + 1,
        perPersona: {...oggi.perPersona, [a]: (oggi.perPersona[a] ?? 0) + 1}});
    }
    if (args.rispondeA !== undefined) {
      // La risposta sta sul segno a cui risponde, nei due rami.
      tx.set(utente(uid).collection("segni").doc(args.rispondeA),
        {...args.contenuto, rispostoIl: Date.now()}, {merge: true});
      tx.set(utente(a).collection("segni").doc(args.rispondeA),
        {...args.contenuto, rispostoIl: Date.now()}, {merge: true});
      return {ok: true, perche: null, riga: null, id: args.rispondeA};
    }
    const id = utente(uid).collection("segni").doc().id;
    const quando = Date.now();
    tx.set(utente(uid).collection("segni").doc(id),
      {...args.contenuto, con: a, verso: "mandato", quando});
    tx.set(utente(a).collection("segni").doc(id),
      {...args.contenuto, con: uid, verso: "ricevuto", quando});
    return {ok: true, perche: null, riga: null, id};
  });
}

/**
 * RISPONDI A UN SEGNO, EY.10 ed EY.11: una delle risposte dichiarate,
 * oppure una reazione. **UNA REAZIONE RISPONDE A UN SEGNO RICEVUTO, un gesto
 * PARTE da zero**: questa e' l'unica porta delle reazioni e pretende un segno
 * ricevuto, quindi il verso negativo non si manda mai da solo. Le reazioni
 * negative restano private fra i due: nessun contatore, nessuna somma sul
 * profilo, nessuna classifica.
 */
export const rispondiAlSegno = onCall(OPZIONI_SOCIALI, async (request) => {
  const uid = uidDi(request);
  await tettoDellaPorta(uid, "rispondiAlSegno");
  const id = String(request.data?.id ?? "");
  if (id.length === 0) throw new HttpsError("invalid-argument", "Segno sconosciuto.");
  const ricevuto = await utente(uid).collection("segni").doc(id).get();
  const d = ricevuto.data();
  if (!d || d.verso !== "ricevuto" || typeof d.con !== "string") {
    return {ok: false, perche: "nessunSegno",
      riga: "Una reazione risponde a un segno ricevuto."};
  }
  if (d.risposta !== undefined || d.reazione !== undefined) {
    return {ok: false, perche: "giaRisposto", riga: "Hai già risposto a questo segno."};
  }
  const contenuto: Record<string, unknown> = {};
  if (request.data?.reazione !== undefined) {
    const reazione = reazioneValida(request.data?.reazione);
    if (reazione === null) throw new HttpsError("invalid-argument", "Reazione sconosciuta.");
    contenuto.reazione = reazione;
  } else {
    const n = Number(request.data?.risposta);
    const quante = RISPOSTE_PER_SEGNO[String(d.segno)] ?? 0;
    if (!Number.isInteger(n) || n < 0 || n >= quante) {
      throw new HttpsError("invalid-argument", "Risposta sconosciuta.");
    }
    contenuto.risposta = n;
  }
  const piano = await pianoDi(uid);
  const esito = await scriviUnGesto({uid, a: d.con, piano, giorno: chiaveDelGiorno(),
    contenuto, conta: true, rispondeA: id});
  if (esito.ok) {
    const io = await schedaPubblica(uid);
    if (io !== null) await avvisa(d.con, `${io.nome} ha risposto al tuo segno`, "risposta");
  }
  return esito;
});

/**
 * MANDA UN DONO, EY.12: il cenno gratuito, la scintilla a 30 Eos, il sigillo
 * a 80. Il prezzo si paga sull'esito, nella stessa transazione che consegna
 * il dono; l'identificativo del movimento rende innocuo il doppio tocco.
 * **Il dono non conia Eos a chi lo riceve**: riceve l'oggetto.
 *
 * Doni e reazioni arrivano solo agli amici, con UNA eccezione dichiarata: il
 * cenno gratuito si puo' mandare una volta sola a una persona presente che
 * non e' amica, e vale come saluto. Mai a un minorenne che non e' amico.
 */
export const mandaUnDono = onCall(OPZIONI_SOCIALI, async (request) => {
  const uid = uidDi(request);
  await tettoDellaPorta(uid, "mandaUnDono");
  const a = String(request.data?.a ?? "");
  const dono = donoValido(request.data?.dono);
  const id = String(request.data?.idMovimento ?? "").trim();
  if (dono === null) throw new HttpsError("invalid-argument", "Dono sconosciuto.");
  if (id.length < 8 || id.length > 200) {
    throw new HttpsError("invalid-argument", "Ogni dono porta il suo identificativo.");
  }
  if (a.length === 0 || a === uid) throw new HttpsError("invalid-argument", "Persona sconosciuta.");
  const piano = await pianoDi(uid);
  if (!donoPerIlPiano(dono, piano)) {
    return {ok: false, perche: "piano",
      riga: "Scintilla e Sigillo si donano dall’Adepto in su."};
  }
  const prezzo = PREZZI_DEI_DONI[dono];
  // Il cenno a chi non e' amico guarda la sua presenza sola (ordine EZ
  // voce 03), non l'elenco dei presenti che l'istantanea non porta piu'.
  const presenzaDiA = dono === "cenno" ? await presenzaDi(a, uid) : undefined;
  const esito = await db().runTransaction(async (tx) => {
    const movimento = utente(uid).collection("movimenti").doc(`dono-${id}`);
    const gia = await tx.get(movimento);
    const legame = legameDa((await tx.get(legameDi(uid, a))).data());
    const blocchi = (await tx.get(statoDi(uid, "blocchi"))).data() ?? {};
    const borsa = await tx.get(statoDi(uid, "borsellino"));
    const cenni = await tx.get(statoDi(uid, "cenni"));
    const saldo = (borsa.data()?.saldo as number) ?? 0;
    if (gia.exists) return {ok: true, perche: null, riga: null, gia: true};
    const bloccati = elenco(blocchi.bloccati).includes(a) ||
      elenco(blocchi.bloccatoDa).includes(a);
    if (bloccati) return {ok: false, perche: "nonRaggiungibile", riga: null};
    const amici = legame?.stato === "amici";
    if (!amici) {
      const presente = presenzaDiA;
      const giaSalutato = cenni.data()?.[a] === true;
      if (dono !== "cenno" || presente === undefined ||
        presente.visibilita !== "tutti" || !presente.maggiorenne || giaSalutato) {
        return {ok: false, perche: "nonAmici",
          riga: dono === "cenno" ? "Il cenno a chi non è amico si manda una volta sola." :
            "I doni si mandano agli amici del Cerchio."};
      }
      tx.set(statoDi(uid, "cenni"), {[a]: true}, {merge: true});
    }
    if (prezzo > saldo) {
      return {ok: false, perche: "eos", riga: null, manca: prezzo - saldo};
    }
    if (prezzo > 0) {
      tx.set(statoDi(uid, "borsellino"), {saldo: saldo - prezzo,
        aggiornato: FieldValue.serverTimestamp()}, {merge: true});
    }
    tx.set(movimento, {causale: "spesa", motivo: `dono_${dono}`, importo: -prezzo,
      saldoDopo: saldo - prezzo, quando: FieldValue.serverTimestamp()});
    tx.set(utente(a).collection("doni").doc(`${uid}-${id}`),
      {da: uid, dono, quando: Date.now()});
    return {ok: true, perche: null, riga: null, gia: false};
  });
  if (esito.ok && !esito.gia) {
    const io = await schedaPubblica(uid);
    const nomi: Record<string, string> = {cenno: "un cenno", scintilla: "una scintilla",
      sigillo: "un sigillo"};
    if (io !== null) await avvisa(a, `${io.nome} ti ha mandato ${nomi[dono]}`, "dono");
  }
  return esito;
});

/**
 * REGALA GLI EOS, EY.12 punto 5: da cento a cinquecento al giorno, solo agli
 * amici e SOLO a valere su Eos comprati o sulla dote del piano
 * (`borsellino.regalabili`), mai su quelli guadagnati gratis. Altrimenti si
 * creano account per raccogliere Eos gratuiti e travasarli su uno solo.
 *
 * **Oggi i regalabili valgono zero per tutti**: ne' l'acquisto ne' la dote
 * hanno una porta che li accredita (`borsellino.ts`). La porta lo dice invece
 * di inventarsi una fonte. Gli Eos ricevuti in regalo non si regalano a loro
 * volta.
 */
export const regalaGliEos = onCall(OPZIONI_SOCIALI, async (request) => {
  const uid = uidDi(request);
  await tettoDellaPorta(uid, "regalaGliEos");
  const a = String(request.data?.a ?? "");
  const quanti = Number(request.data?.quanti);
  const id = String(request.data?.idMovimento ?? "").trim();
  if (id.length < 8 || id.length > 200) {
    throw new HttpsError("invalid-argument", "Ogni regalo porta il suo identificativo.");
  }
  if (a.length === 0 || a === uid) throw new HttpsError("invalid-argument", "Persona sconosciuta.");
  const giorno = chiaveDelGiorno();
  return db().runTransaction(async (tx) => {
    const movimento = utente(uid).collection("movimenti").doc(`regalo-${id}`);
    const gia = await tx.get(movimento);
    const legame = legameDa((await tx.get(legameDi(uid, a))).data());
    const mia = await tx.get(statoDi(uid, "borsellino"));
    const sua = await tx.get(statoDi(a, "borsellino"));
    const oggiSnap = await tx.get(statoDi(uid, "sociale_oggi"));
    if (gia.exists) return {ok: true, gia: true};
    if (legame?.stato !== "amici") {
      return {ok: false, perche: "nonAmici", riga: "Gli Eos si regalano agli amici del Cerchio."};
    }
    const saldo = (mia.data()?.saldo as number) ?? 0;
    const regalabili = (mia.data()?.regalabili as number) ?? 0;
    const oggi = oggiDa(oggiSnap.data(), giorno);
    const decisione = decidiIlGift({quanti, regalatiOggi: oggi.regalati, regalabili, saldo});
    if (!decisione.concesso) {
      const righe: Record<string, string> = {
        importo: "Si regalano almeno cento Eos.",
        tetto: "Al giorno si regalano al massimo cinquecento Eos.",
        nonRegalabili: "Si regalano solo Eos comprati o della dote del piano.",
      };
      return {ok: false, perche: decisione.perche, riga: righe[decisione.perche ?? ""],
        regalabili};
    }
    const suoSaldo = (sua.data()?.saldo as number) ?? 0;
    tx.set(statoDi(uid, "borsellino"), {saldo: saldo - quanti,
      regalabili: regalabili - quanti, aggiornato: FieldValue.serverTimestamp()},
    {merge: true});
    tx.set(statoDi(a, "borsellino"), {saldo: suoSaldo + quanti,
      aggiornato: FieldValue.serverTimestamp()}, {merge: true});
    tx.set(movimento, {causale: "rettifica", motivo: "regalo_mandato", importo: -quanti,
      saldoDopo: saldo - quanti, a, quando: FieldValue.serverTimestamp()});
    tx.set(utente(a).collection("movimenti").doc(`regalo-${uid}-${id}`), {
      causale: "rettifica", motivo: "regalo_ricevuto", importo: quanti,
      saldoDopo: suoSaldo + quanti, da: uid, quando: FieldValue.serverTimestamp()});
    tx.set(statoDi(uid, "sociale_oggi"), {...oggi, regalati: oggi.regalati + quanti});
    return {ok: true, gia: false, saldo: saldo - quanti};
  });
});

/**
 * IL RECAPITO DEL CERCHIO: il telefono lo da' quando ha gia' il permesso
 * delle notifiche. Serve ai segni anche a chi non ha acceso i Doni.
 */
export const scriviIlTokenDelCerchio = onCall(OPZIONI_SOCIALI, async (request) => {
  const uid = uidDi(request);
  await tettoDellaPorta(uid, "scriviIlTokenDelCerchio");
  const token = String(request.data?.token ?? "");
  if (token.length < 20 || token.length > 500) {
    throw new HttpsError("invalid-argument", "Recapito non valido.");
  }
  await statoDi(uid, "dispositivo").set({token, aggiornato: Date.now()});
  return {ok: true};
});

// ---------------------------------------------------------------------------
// LA CANCELLAZIONE, EY.02 punto 5
// ---------------------------------------------------------------------------

/**
 * CHI CANCELLA IL PROPRIO ACCOUNT perde anche il profilo pubblico, i legami e
 * i codici; il sigillo resta in quarantena novanta giorni senza il resto.
 * La chiamano `cancellaIlCerchio` e `azzeraIDatiDelCerchio` prima di
 * cancellare il ramo `users/{uid}`, che porta via tutto il resto.
 */
export async function cancellaIlSociale(uid: string): Promise<void> {
  const io = await leggiIdentita(uid);
  const legami = await statoDi(uid, "legami").get();
  const blocchi = await statoDi(uid, "blocchi").get();
  const altri = new Set([
    ...elenco(legami.data()?.amici),
    ...elenco(legami.data()?.inviati),
    ...elenco(legami.data()?.ricevuti),
  ]);
  await scriviLaPresenza(uid, null);
  const batch = db().batch();
  batch.delete(profiloDi(uid));
  if (io.sigillo !== null) {
    batch.set(db().collection("sigilli").doc(io.sigillo),
      {uid: null, quarantenaFino: fineDellaQuarantena(Date.now())});
  }
  for (const altro of altri) {
    batch.delete(legameDi(uid, altro));
    batch.set(statoDi(altro, "legami"), {
      amici: FieldValue.arrayRemove(uid),
      inviati: FieldValue.arrayRemove(uid),
      ricevuti: FieldValue.arrayRemove(uid),
    }, {merge: true});
  }
  for (const altro of elenco(blocchi.data()?.bloccati)) {
    batch.set(statoDi(altro, "blocchi"), {bloccatoDa: FieldValue.arrayRemove(uid)},
      {merge: true});
  }
  const codici = await statoDi(uid, "codici").get();
  for (const c of [codici.data()?.link, codici.data()?.vicino]) {
    if (typeof c === "string") batch.delete(db().collection("codici_invito").doc(c));
  }
  await batch.commit();
  // **GLI ENIGMI FUORI DAL RAMO, ordine FF**: le partite di chi se ne va, le
  // scommesse fatte e ricevute, le sfide nei due versi.
  const fuori = await Promise.all([
    PARTITE().where("di", "==", uid).get(),
    SCOMMESSE().where("da", "==", uid).get(),
    SCOMMESSE().where("amico", "==", uid).get(),
    SFIDE().where("da", "==", uid).get(),
    SFIDE().where("a", "==", uid).get(),
  ]);
  for (const q of fuori) {
    for (const d of q.docs) await d.ref.delete();
  }
}

/**
 * IL LEGAME DALL'INVITO RISCATTATO, ordine EY Aggiunta 1 punto 2. **Chi entra
 * col tuo invito NON diventa tuo amico da solo**: trova l'invito al legame
 * gia' in arrivo, arancione pieno, e lo accetta con un tocco. Il legame nasce
 * dall'accettazione: un'amicizia creata di nascosto da un riscatto sarebbe un
 * consenso che nessuno ha dato. Lo scrive la stessa funzione di tutti gli
 * altri legami; `invitatoDa` resta scritto dalla sola porta che lo scrive
 * oggi, `riscattaLInvito`.
 */
export async function invitoDalRiscatto(chiInvita: string, chiArriva: string):
  Promise<void> {
  // Chi ha dichiarato meno di quattordici anni non riceve (ordine EZ voce
  // 04). Chi non l'ha ancora dichiarato riceve l'invito, ma non lo vede
  // finche' le porte del suo Cerchio non si aprono.
  const tetti = await statoDi(chiArriva, "tetti_sociali").get();
  if (tetti.data()?.quattordici === false) return;
  try {
    await apriIlLegame({da: chiInvita, a: chiArriva, comeAmici: false,
      conIlSigillo: true, contaLInvito: false});
  } catch (errore) {
    logger.warn("Cerchio: l'invito al legame dal riscatto non parte",
      {errore: String(errore)});
  }
}

// ---------------------------------------------------------------------------
// PARTE E, GLI ENIGMI DEL CERCHIO, ordine FF (8 ottobre 2026)
// ---------------------------------------------------------------------------

/**
 * **DOVE STANNO I DATI DEI GIOCHI, e perche' fuori dal ramo.** Il Ritratto
 * della persona sta in `users/{uid}/stato/ritratto` e le sue scelte sui giochi
 * (l'interruttore, l'archetipo e l'animale pubblicati) in
 * `users/{uid}/stato/giochi`: li legge il suo telefono. Le partite, le
 * scommesse e le sfide stanno invece in collezioni chiuse al telefono
 * (`enigmi_partite`, `enigmi_scommesse`, `enigmi_sfide`): una partita porta
 * la fotografia del Ritratto di un'ALTRA persona, che chi gioca non deve poter
 * leggere intera, e una scommessa porta chi ha scommesso, che la persona
 * indovinata non deve sapere. Le toglie `cancellaIlSociale`.
 */
const PARTITE = () => db().collection("enigmi_partite");
const SCOMMESSE = () => db().collection("enigmi_scommesse");
const SFIDE = () => db().collection("enigmi_sfide");
const SETTIMANA = (s: string) => db().collection("enigmi_settimane").doc(s);
const PROVA = (uid: string, s: string) =>
  utente(uid).collection("prove").doc(s);

function idDelGesto(valore: unknown): string | null {
  const s = String(valore ?? "").trim();
  return /^[A-Za-z0-9_-]{8,120}$/.test(s) ? s : null;
}

/** Un archetipo o un animale pubblicato: un identificativo, mai testo. */
function voceDelCatalogo(valore: unknown): string | null {
  const s = String(valore ?? "");
  return /^[a-z_]{2,32}$/.test(s) ? s : null;
}

/** Il lunedi' della settimana di oggi, nel fuso di Roma. */
function lunediDiOggi(): string {
  const oggi = chiaveDelGiorno();
  const d = new Date(`${oggi}T12:00:00Z`);
  const dal = (d.getUTCDay() + 6) % 7;
  return new Date(d.getTime() - dal * 864e5).toISOString().slice(0, 10);
}

/** I contatori dei giochi di oggi, azzerati quando il giorno cambia. */
function contatoriDeiGiochi(dati: Record<string, unknown> | undefined,
  oggi: string) {
  const d = dati ?? {};
  const stessoGiorno = d.giorno === oggi;
  return {
    giorno: oggi,
    indovinelli: stessoGiorno ? Number(d.indovinelli ?? 0) : 0,
    scommesse: stessoGiorno ? Number(d.scommesse ?? 0) : 0,
    indovinati: Number(d.indovinati ?? 0),
    punti: Number(d.punti ?? 0),
    sfideVinte: Number(d.sfideVinte ?? 0),
  };
}

/** Gli amici, tolti i blocchi nei due versi. */
async function amiciNeiGiochi(uid: string): Promise<string[]> {
  const [legami, blocchi] = await Promise.all([
    statoDi(uid, "legami").get(), statoDi(uid, "blocchi").get()]);
  const fuori = new Set([...elenco(blocchi.data()?.bloccati),
    ...elenco(blocchi.data()?.bloccatoDa)]);
  return elenco(legami.data()?.amici).filter((a) => !fuori.has(a));
}

/**
 * **UN VOLTO DEI GIOCHI**, nullo per chi non puo' comparire: senza Ritratto,
 * con l'interruttore spento, sotto i quattordici anni.
 */
async function voltoDi(uid: string): Promise<Volto | null> {
  const [r, g, i] = await Promise.all([statoDi(uid, "ritratto").get(),
    statoDi(uid, "giochi").get(), statoDi(uid, "identita").get()]);
  const io = identitaDa(i.data());
  if (!puoComparire({ritratto: r.data()?.tratti,
    fuoriDaiGiochi: g.data()?.fuoriDaiGiochi, quattordici: io.quattordici})) {
    return null;
  }
  const tratti = ritrattoValido(r.data()?.tratti) as number[];
  return {
    uid,
    ritratto: tratti.map(String),
    segno: io.segno,
    animale: voceDelCatalogo(g.data()?.animale),
    archetipo: voceDelCatalogo(g.data()?.archetipo),
    archetipoSecondario: null,
  };
}

/**
 * Il volto come arriva a chi gioca: il nome e l'icona scelta. **L'icona del
 * segno non viaggia**: direbbe l'elemento a chi deve indovinarlo.
 */
async function voltoPubblico(uid: string) {
  const s = await schedaPubblica(uid);
  const icona = s?.icona ?? null;
  return {uid, nome: s?.nome ?? "", sigillo: s?.sigillo ?? null,
    icona: icona !== null && icona.startsWith("segno") ? null : icona};
}

/**
 * **IL RITRATTO E LE SCELTE DEI GIOCHI**, voci FF.02 e FF.04.4. Senza corpo
 * restituisce il proprio Ritratto (solo a chi lo possiede: nessuna porta lo
 * restituisce ad altri); coi campi lo scrive. Il Ritratto si scrive solo
 * intero, venti caratteristiche del corpus.
 */
export const ilMioRitratto = onCall(OPZIONI_SOCIALI, async (request) => {
  const uid = uidDi(request);
  await tettoDellaPorta(uid, "ilMioRitratto");
  const corpo = (request.data ?? {}) as Record<string, unknown>;
  if (corpo.tratti !== undefined) {
    const tratti = ritrattoValido(corpo.tratti);
    if (tratti === null) {
      throw new HttpsError("invalid-argument",
        "Il Ritratto vuole venti caratteristiche diverse.");
    }
    await statoDi(uid, "ritratto").set({tratti, quando: Date.now()});
  }
  const giochi: Record<string, unknown> = {};
  if (typeof corpo.fuoriDaiGiochi === "boolean") {
    giochi.fuoriDaiGiochi = corpo.fuoriDaiGiochi;
  }
  if (corpo.archetipo !== undefined) {
    giochi.archetipo = voceDelCatalogo(corpo.archetipo);
  }
  if (corpo.animale !== undefined) giochi.animale = voceDelCatalogo(corpo.animale);
  if (Object.keys(giochi).length > 0) {
    await statoDi(uid, "giochi").set(giochi, {merge: true});
  }
  const [r, g] = await Promise.all([statoDi(uid, "ritratto").get(),
    statoDi(uid, "giochi").get()]);
  return {
    tratti: ritrattoValido(r.data()?.tratti) ?? [],
    fuoriDaiGiochi: g.data()?.fuoriDaiGiochi === true,
    archetipo: voceDelCatalogo(g.data()?.archetipo),
    animale: voceDelCatalogo(g.data()?.animale),
  };
});

/** Chiude le sfide scadute di una persona: il punto va a chi ha giocato. */
async function chiudiLeSfideScadute(uid: string, adesso: number) {
  const [mie, altrui] = await Promise.all([
    SFIDE().where("da", "==", uid).where("chiusa", "==", false).get(),
    SFIDE().where("a", "==", uid).where("chiusa", "==", false).get()]);
  const aperte: Record<string, unknown>[] = [];
  for (const doc of [...mie.docs, ...altrui.docs]) {
    const s = doc.data();
    const esito = esitoDellaSfida({
      da: String(s.da), a: String(s.a), scade: Number(s.scade),
      punteggioDa: s.punteggioDa ?? null, punteggioA: s.punteggioA ?? null,
      stimaDa: s.stimaDa ?? null, stimaA: s.stimaA ?? null,
    }, adesso);
    if (esito === null) {
      aperte.push({id: doc.id, da: s.da, a: s.a, scade: s.scade,
        tua: s.da === uid, haiStimato: s.da === uid ? true : s.stimaA != null});
      continue;
    }
    await chiudiLaSfida(doc.id, esito.vincitori, esito.perche);
  }
  return aperte;
}

async function chiudiLaSfida(id: string, vincitori: string[], perche: string) {
  await db().runTransaction(async (tx) => {
    const ref = SFIDE().doc(id);
    const snap = await tx.get(ref);
    if (!snap.exists || snap.data()?.chiusa === true) return;
    const oggi = chiaveDelGiorno();
    const stati = await Promise.all(vincitori.map((v) =>
      tx.get(statoDi(v, "enigmi"))));
    tx.set(ref, {chiusa: true, vincitori, perche}, {merge: true});
    vincitori.forEach((v, i) => {
      const c = contatoriDeiGiochi(stati[i].data(), oggi);
      tx.set(statoDi(v, "enigmi"), {...c, sfideVinte: c.sfideVinte + 1},
        {merge: true});
    });
  });
}

/**
 * **GLI ENIGMI, la vista d'insieme**: il proprio Ritratto e' compilato?
 * Quanti indovinelli e scommesse restano oggi, chi ti ha indovinato (il
 * numero e i segni scoperti, mai un nome), la Prova della settimana coi suoi
 * amici, le sfide aperte col tempo che resta, il Pellegrinaggio con la parte
 * di ciascuno, la classifica di chi conosce il Cerchio. Le sfide scadute si
 * chiudono qui, alla lettura: nessun gioco aspetta che qualcuno apra l'app.
 */
export const gliEnigmi = onCall(OPZIONI_SOCIALI, async (request) => {
  const uid = uidDi(request);
  await tettoDellaPorta(uid, "gliEnigmi");
  const corpo = (request.data ?? {}) as Record<string, unknown>;
  const oggi = chiaveDelGiorno();
  const adesso = Date.now();
  const settimana = lunediDiOggi();
  const luna = lunaValida(corpo.luna, oggi);
  const [ritratto, enigmi, indovinato, piano, amici, settimanaDoc, miaProva] =
    await Promise.all([
      statoDi(uid, "ritratto").get(), statoDi(uid, "enigmi").get(),
      statoDi(uid, "indovinato").get(), pianoDi(uid), amiciNeiGiochi(uid),
      SETTIMANA(settimana).get(), PROVA(uid, settimana).get()]);
  const c = contatoriDeiGiochi(enigmi.data(), oggi);
  const persone = [uid, ...amici];
  const [stati, pellegrinaggi, prove, volti, mieScommesse, sfide] =
    await Promise.all([
      db().getAll(...persone.map((p) => statoDi(p, "enigmi"))),
      db().getAll(...persone.map((p) => statoDi(p, "pellegrinaggio"))),
      amici.length > 0 ?
        db().getAll(...amici.map((a) => PROVA(a, settimana))) :
        Promise.resolve([]),
      Promise.all(persone.map(voltoPubblico)),
      SCOMMESSE().where("da", "==", uid).where("settimana", "==", settimana)
        .get(),
      chiudiLeSfideScadute(uid, adesso)]);
  const nomi = Object.fromEntries(volti.map((v) => [v.uid, v]));
  const scommesse = Object.fromEntries(mieScommesse.docs.map((d) =>
    [String(d.data().amico), {valore: d.data().valore,
      vinta: d.data().vinta ?? null}]));
  const classifica = laClassifica(persone.map((p, i) => ({
    uid: p, nome: nomi[p]?.nome ?? "", tu: p === uid,
    indovinati: contatoriDeiGiochi(stati[i].data(), oggi).indovinati,
  })));
  const passi = persone.map((p, i) => {
    const d = pellegrinaggi[i].data();
    return {uid: p, nome: nomi[p]?.nome ?? "", tu: p === uid,
      passi: luna !== null && d?.luna === luna ? elenco(d?.giorni).length : 0};
  });
  const totale = passi.reduce((a, p) => a + p.passi, 0);
  const meta = metaDelPellegrinaggio(persone.length);
  const prova = miaProva.data();
  return {
    ritrattoCompilato: ritrattoValido(ritratto.data()?.tratti) !== null,
    piano,
    oggi: {
      indovinelli: c.indovinelli, indovinelliAlGiorno: INDOVINELLI_AL_GIORNO[piano],
      scommesse: c.scommesse, scommesseAlGiorno: SCOMMESSE_AL_GIORNO[piano],
    },
    ritorno: ilRitornoDi(indovinato.data()),
    prova: {
      settimana,
      tema: settimanaDoc.data()?.tema ?? null,
      fatta: prova !== undefined,
      punteggio: prova?.punteggio ?? null,
      figura: prova ? figuraDi(Number(prova.tema), Number(prova.punteggio)) : null,
      amici: amici.map((a, i) => {
        const p = (prove[i] as DocumentSnapshot).data();
        return {uid: a, nome: nomi[a]?.nome ?? "",
          fatta: p !== undefined,
          // Il punteggio si vede solo dopo che la persona ha fatto la Prova.
          punteggio: p?.punteggio ?? null,
          scommessa: scommesse[a] ?? null};
      }),
    },
    sfide: {aperte: sfide, puoiSfidare: sfidaPerIlPiano(piano)},
    pellegrinaggio: luna === null ? null :
      {luna, meta, totale, arrivato: totale >= meta, passi},
    classifica,
  };
});

/**
 * **CHI DEL CERCHIO**, voce FF.04: si apre, si chiedono gli indizi, si
 * risponde. Il gioco non aspetta nessuno: si gioca contro i dati e il
 * risultato arriva subito.
 */
export const unIndovinello = onCall(OPZIONI_SOCIALI, async (request) => {
  const uid = uidDi(request);
  await tettoDellaPorta(uid, "unIndovinello");
  const corpo = (request.data ?? {}) as Record<string, unknown>;
  const id = idDelGesto(corpo.partita);
  if (id === null) throw new HttpsError("invalid-argument", "Partita sconosciuta.");
  const azione = String(corpo.azione ?? "");
  const oggi = chiaveDelGiorno();
  if (azione === "apri") {
    const gia = await PARTITE().doc(id).get();
    if (gia.exists) {
      if (gia.data()?.di !== uid) {
        throw new HttpsError("permission-denied", "Partita di un altro.");
      }
      return vistaDellaPartita(id, gia.data() ?? {});
    }
    const [piano, enigmi, mio] = await Promise.all([pianoDi(uid),
      statoDi(uid, "enigmi").get(), statoDi(uid, "ritratto").get()]);
    if (ritrattoValido(mio.data()?.tratti) === null) {
      return {ok: false, perche: "ritratto"};
    }
    const c = contatoriDeiGiochi(enigmi.data(), oggi);
    if (c.indovinelli >= INDOVINELLI_AL_GIORNO[piano]) {
      return {ok: false, perche: "limite", limite: INDOVINELLI_AL_GIORNO[piano]};
    }
    // I candidati si leggono nell'ordine del seme, finche' se ne trovano
    // quattro: nessuna lettura di troppo con un Cerchio grande.
    const ordinati = quattroVolti(
      (await amiciNeiGiochi(uid)).map((a) => ({uid: a})), id, Infinity)
      .map((a) => a.uid);
    const volti: Volto[] = [];
    for (const a of ordinati) {
      const v = await voltoDi(a);
      if (v !== null) volti.push(v);
      if (volti.length === 4) break;
    }
    if (volti.length < 4) return {ok: false, perche: "pochi", quanti: volti.length};
    const scelta = laDomanda(volti, id);
    if (scelta === null) return {ok: false, perche: "nessunaDomanda"};
    const persona = volti.find((v) => v.uid === scelta.giusta) as Volto;
    const partita = {
      di: uid, quando: Date.now(), facce: volti.map((v) => v.uid),
      giusta: scelta.giusta, domanda: scelta.domanda,
      // La fotografia del Ritratto di quando la partita comincia (voce
      // FF.02.5): chi sta per essere indovinato non cambia le caselle a meta'.
      dati: {ritratto: persona.ritratto, segno: persona.segno ?? null,
        animale: persona.animale ?? null, archetipoSecondario: null},
      esclusi: esclusiPerLaDomanda(scelta.domanda),
      indizi: [] as Indizio[], chiusa: false,
    };
    await PARTITE().doc(id).set(partita);
    return vistaDellaPartita(id, partita);
  }
  if (azione === "indizio") {
    const esito = await db().runTransaction(async (tx) => {
      const ref = PARTITE().doc(id);
      const snap = await tx.get(ref);
      const borsa = await tx.get(statoDi(uid, "borsellino"));
      const p = snap.data();
      if (!snap.exists || p?.di !== uid) return {ok: false, perche: "partita"};
      if (p?.chiusa === true) return {ok: false, perche: "chiusa"};
      const indizi = (p?.indizi ?? []) as Indizio[];
      const n = indizi.length + 1;
      if (n > INDIZI_MASSIMI) return {ok: false, perche: "finiti"};
      const costo = costoDellIndizio(n);
      const saldo = Number(borsa.data()?.saldo ?? 0);
      if (costo > saldo) return {ok: false, perche: "eos", manca: costo - saldo};
      const indizio = indizioDellaPartita(p?.dati as DatiDellaPersona, id, n,
        (p?.esclusi ?? []) as string[]);
      if (indizio === null) return {ok: false, perche: "finiti"};
      tx.set(ref, {indizi: [...indizi, indizio]}, {merge: true});
      if (costo > 0) {
        tx.set(statoDi(uid, "borsellino"), {saldo: saldo - costo,
          aggiornato: FieldValue.serverTimestamp()}, {merge: true});
        tx.set(utente(uid).collection("movimenti").doc(`indizio-${id}-${n}`),
          {causale: "spesa", motivo: "indizio_del_cerchio", importo: -costo,
            saldoDopo: saldo - costo, quando: FieldValue.serverTimestamp()});
      }
      return {ok: true, indizio, n, costo, saldo: saldo - costo,
        costoProssimo: n < INDIZI_MASSIMI ? costoDellIndizio(n + 1) : null};
    });
    return esito;
  }
  if (azione === "rispondi") {
    const scelta = String(corpo.scelta ?? "");
    const io = await leggiIdentita(uid);
    const piano = await pianoDi(uid);
    const esito = await db().runTransaction(async (tx) => {
      const ref = PARTITE().doc(id);
      const snap = await tx.get(ref);
      const p = snap.data();
      if (!snap.exists || p?.di !== uid) return {ok: false, perche: "partita"};
      const stato = await tx.get(statoDi(uid, "enigmi"));
      const giustaUid = String(p?.giusta);
      const indovinato = await tx.get(statoDi(giustaUid, "indovinato"));
      if (p?.chiusa === true) {
        return {ok: true, ...rispostaDellIndovinello({giusta: p?.risposta === giustaUid,
          punti: Number(p?.punti ?? 0), uidGiusto: giustaUid})};
      }
      const c = contatoriDeiGiochi(stato.data(), oggi);
      if (c.indovinelli >= INDOVINELLI_AL_GIORNO[piano]) {
        return {ok: false, perche: "limite", limite: INDOVINELLI_AL_GIORNO[piano]};
      }
      if (!(p?.facce as string[]).includes(scelta)) {
        return {ok: false, perche: "scelta"};
      }
      const giusta = scelta === giustaUid;
      const punti = puntiDellaRisposta(((p?.indizi ?? []) as unknown[]).length,
        giusta);
      tx.set(ref, {chiusa: true, risposta: scelta, punti}, {merge: true});
      tx.set(statoDi(uid, "enigmi"), {...c, indovinelli: c.indovinelli + 1,
        indovinati: c.indovinati + (giusta ? 1 : 0), punti: c.punti + punti},
      {merge: true});
      if (giusta) {
        // **CHI VIENE INDOVINATO LO SA**, voce FF.04.3: il numero e il segno
        // di chi ha indovinato, da scoprire uno alla volta. Il nome no.
        const chiave = chiaveDellaDomanda(p?.domanda as Domanda);
        const per = (indovinato.data()?.perDomanda ?? {}) as Record<string,
          {quanti?: number; segni?: string[]; rivelati?: number}>;
        const voce = per[chiave] ?? {};
        tx.set(statoDi(giustaUid, "indovinato"), {perDomanda: {[chiave]: {
          quanti: Number(voce.quanti ?? 0) + 1,
          segni: [...(voce.segni ?? []), io.segno ?? "sconosciuto"],
          rivelati: Number(voce.rivelati ?? 0),
        }}}, {merge: true});
      }
      return {ok: true, ...rispostaDellIndovinello({giusta, punti,
        uidGiusto: giustaUid}), nuovo: true};
    });
    if (esito.ok && "nuovo" in esito && esito.giusta) {
      await avvisa(String(esito.era),
        "Qualcuno del tuo Cerchio ti ha riconosciuto in un indovinello.",
        "indovinato");
    }
    if ("nuovo" in esito) delete (esito as {nuovo?: boolean}).nuovo;
    return esito;
  }
  throw new HttpsError("invalid-argument", "Gesto sconosciuto.");
});

/** La partita come la vede chi gioca: mai la risposta giusta prima del tempo. */
function vistaDellaPartita(id: string, p: Record<string, unknown>) {
  return Promise.all(((p.facce ?? []) as string[]).map(voltoPubblico))
    .then((facce) => {
      const indizi = (p.indizi ?? []) as Indizio[];
      return {
        ok: true, partita: id, facce, domanda: p.domanda, indizi,
        costoProssimo: indizi.length < INDIZI_MASSIMI ?
          costoDellIndizio(indizi.length + 1) : null,
        chiusa: p.chiusa === true,
        ...(p.chiusa === true ? {era: p.giusta, punti: p.punti ?? 0} : {}),
      };
    });
}

/**
 * **IL SEGNO DI CHI TI HA INDOVINATO**, venti Eos, uno alla volta. Il segno
 * si', il nome mai: il nome non e' mai stato scritto qui.
 */
export const scopriUnSegno = onCall(OPZIONI_SOCIALI, async (request) => {
  const uid = uidDi(request);
  await tettoDellaPorta(uid, "scopriUnSegno");
  const chiave = String(request.data?.chiave ?? "");
  const id = idDelGesto(request.data?.idMovimento);
  if (id === null) {
    throw new HttpsError("invalid-argument", "Ogni spesa porta il suo identificativo.");
  }
  return db().runTransaction(async (tx) => {
    const doc = statoDi(uid, "indovinato");
    const movimento = utente(uid).collection("movimenti").doc(`segno-${id}`);
    const [snap, borsa, gia] = await Promise.all([tx.get(doc),
      tx.get(statoDi(uid, "borsellino")), tx.get(movimento)]);
    if (gia.exists) return {ok: true, gia: true, ritorno: ilRitornoDi(snap.data())};
    const per = (snap.data()?.perDomanda ?? {}) as Record<string,
      {quanti?: number; segni?: string[]; rivelati?: number}>;
    const voce = per[chiave];
    const segni = voce?.segni ?? [];
    const rivelati = Number(voce?.rivelati ?? 0);
    if (voce === undefined || rivelati >= segni.length) {
      return {ok: false, perche: "nessuno"};
    }
    const saldo = Number(borsa.data()?.saldo ?? 0);
    if (PREZZO_DEL_SEGNO > saldo) {
      return {ok: false, perche: "eos", manca: PREZZO_DEL_SEGNO - saldo};
    }
    tx.set(doc, {perDomanda: {[chiave]: {...voce, rivelati: rivelati + 1}}},
      {merge: true});
    tx.set(statoDi(uid, "borsellino"), {saldo: saldo - PREZZO_DEL_SEGNO,
      aggiornato: FieldValue.serverTimestamp()}, {merge: true});
    tx.set(movimento, {causale: "spesa", motivo: "segno_di_chi_indovina",
      importo: -PREZZO_DEL_SEGNO, saldoDopo: saldo - PREZZO_DEL_SEGNO,
      quando: FieldValue.serverTimestamp()});
    const dopo = {...per, [chiave]: {...voce, rivelati: rivelati + 1}};
    return {ok: true, gia: false, saldo: saldo - PREZZO_DEL_SEGNO,
      ritorno: ilRitornoDi({perDomanda: dopo})};
  });
});

/** Chiude le scommesse fatte su chi ha appena consegnato la Prova. */
async function chiudiLeScommesse(amico: string, settimana: string,
  punteggio: number) {
  const aperte = await SCOMMESSE().where("amico", "==", amico)
    .where("settimana", "==", settimana).get();
  const stime = aperte.docs.filter((d) => d.data().vinta == null)
    .map((d) => ({chi: String(d.data().da), valore: Number(d.data().valore),
      ref: d.ref}));
  const vincitori = new Set(piuVicini(stime, punteggio));
  const oggi = chiaveDelGiorno();
  for (const s of stime) {
    await db().runTransaction(async (tx) => {
      const st = await tx.get(statoDi(s.chi, "enigmi"));
      const c = contatoriDeiGiochi(st.data(), oggi);
      const vinta = vincitori.has(s.chi);
      tx.set(s.ref, {vinta, punteggio}, {merge: true});
      if (vinta) {
        tx.set(statoDi(s.chi, "enigmi"),
          {...c, punti: c.punti + PUNTI_DELLA_SCOMMESSA}, {merge: true});
      }
    });
  }
}

/** Dopo la Prova di una persona, le sue sfide della settimana si aggiornano. */
async function aggiornaLeSfide(uid: string, settimana: string,
  punteggio: number) {
  const comeA = await SFIDE().where("a", "==", uid)
    .where("settimana", "==", settimana).get();
  for (const d of comeA.docs) {
    if (d.data().chiusa === true) continue;
    await d.ref.set({punteggioA: punteggio}, {merge: true});
    const s = d.data();
    const esito = esitoDellaSfida({da: String(s.da), a: String(s.a),
      scade: Number(s.scade), punteggioDa: s.punteggioDa ?? null,
      punteggioA: punteggio, stimaDa: s.stimaDa ?? null,
      stimaA: s.stimaA ?? null}, Date.now());
    if (esito !== null) await chiudiLaSfida(d.id, esito.vincitori, esito.perche);
  }
}

/**
 * **LA PROVA DELLA SETTIMANA**, voci FF.05 e FF.06.4: si consegna, si
 * scommette sul punteggio di un amico finche' non l'ha fatta, si sfida un
 * amico. Il punteggio lo calcola il server dai pesi del corpus.
 */
export const laProva = onCall(OPZIONI_SOCIALI, async (request) => {
  const uid = uidDi(request);
  await tettoDellaPorta(uid, "laProva");
  const corpo = (request.data ?? {}) as Record<string, unknown>;
  const azione = String(corpo.azione ?? "");
  const settimana = lunediDiOggi();
  const oggi = chiaveDelGiorno();
  if (azione === "consegna") {
    const tema = Number(corpo.tema);
    const punteggio = punteggioDi(tema, settimana, corpo.scelte);
    if (punteggio === null) {
      throw new HttpsError("invalid-argument", "La Prova vuole dieci risposte.");
    }
    const esito = await db().runTransaction(async (tx) => {
      const [sett, gia] = await Promise.all([tx.get(SETTIMANA(settimana)),
        tx.get(PROVA(uid, settimana))]);
      // **LA STESSA PER TUTTI**: il primo telefono della settimana fissa il
      // tema, e un telefono con l'orologio sbagliato non ne apre un altro.
      if (sett.exists && Number(sett.data()?.tema) !== tema) {
        return {ok: false, perche: "tema", tema: sett.data()?.tema};
      }
      if (gia.exists) {
        return {ok: true, gia: true, punteggio: gia.data()?.punteggio,
          figura: figuraDi(tema, Number(gia.data()?.punteggio))};
      }
      if (!sett.exists) tx.set(SETTIMANA(settimana), {tema});
      tx.set(PROVA(uid, settimana), {tema, scelte: corpo.scelte, punteggio,
        quando: Date.now()});
      return {ok: true, gia: false, punteggio, figura: figuraDi(tema, punteggio)};
    });
    if (esito.ok && esito.gia === false) {
      await chiudiLeScommesse(uid, settimana, punteggio);
      await aggiornaLeSfide(uid, settimana, punteggio);
    }
    return esito;
  }
  const amico = String(corpo.amico ?? "");
  if (!(await amiciNeiGiochi(uid)).includes(amico)) {
    return {ok: false, perche: "amico"};
  }
  const valore = Number(corpo.valore);
  if (!Number.isInteger(valore) || valore < 0 || valore > 100) {
    throw new HttpsError("invalid-argument", "Un punteggio va da 0 a 100.");
  }
  if (azione === "scommetti") {
    const piano = await pianoDi(uid);
    return db().runTransaction(async (tx) => {
      const ref = SCOMMESSE().doc(`${settimana}_${amico}_${uid}`);
      const [suaProva, gia, stato] = await Promise.all([
        tx.get(PROVA(amico, settimana)), tx.get(ref),
        tx.get(statoDi(uid, "enigmi"))]);
      // Dopo e' tardi: il punteggio si vede, e la scommessa non si piazza.
      const c = contatoriDeiGiochi(stato.data(), oggi);
      const ammessa = scommessaAmmessa({provaDellAmico: suaProva.exists,
        gia: gia.exists, usateOggi: c.scommesse,
        limite: SCOMMESSE_AL_GIORNO[piano]});
      if (ammessa !== "ok") {
        return {ok: false, perche: ammessa, limite: SCOMMESSE_AL_GIORNO[piano]};
      }
      tx.set(ref, {da: uid, amico, settimana, valore, quando: Date.now(),
        vinta: null});
      tx.set(statoDi(uid, "enigmi"), {...c, scommesse: c.scommesse + 1},
        {merge: true});
      return {ok: true};
    });
  }
  if (azione === "sfida") {
    if (!sfidaPerIlPiano(await pianoDi(uid))) {
      return {ok: false, perche: "piano"};
    }
    const mia = await PROVA(uid, settimana).get();
    if (!mia.exists) return {ok: false, perche: "prova"};
    const id = idDelGesto(corpo.sfida);
    if (id === null) throw new HttpsError("invalid-argument", "Sfida sconosciuta.");
    const adesso = Date.now();
    const ref = SFIDE().doc(id);
    if ((await ref.get()).exists) return {ok: true, gia: true};
    const [mie, sue] = await Promise.all([
      SFIDE().where("da", "==", uid).where("a", "==", amico).get(),
      SFIDE().where("da", "==", amico).where("a", "==", uid).get(),
    ]);
    if (sfidaGiaAperta([...mie.docs, ...sue.docs].map((d) => d.data()),
      adesso)) {
      return {ok: false, perche: "sfidaAperta"};
    }
    await ref.set({da: uid, a: amico, settimana, quando: adesso,
      scade: adesso + DURATA_DELLA_SFIDA_MS, punteggioDa: mia.data()?.punteggio,
      stimaDa: valore, punteggioA: null, stimaA: null, chiusa: false});
    const io = await schedaPubblica(uid);
    if (io !== null) {
      await avvisa(amico, `${io.nome} ti sfida sulla Prova della settimana`,
        "sfida");
    }
    return {ok: true, gia: false, scade: adesso + DURATA_DELLA_SFIDA_MS};
  }
  if (azione === "rispondiAllaSfida") {
    const id = idDelGesto(corpo.sfida);
    if (id === null) throw new HttpsError("invalid-argument", "Sfida sconosciuta.");
    const ref = SFIDE().doc(id);
    const snap = await ref.get();
    const s = snap.data();
    if (!snap.exists || s?.a !== uid || s?.da !== amico) {
      return {ok: false, perche: "sfida"};
    }
    if (s?.chiusa === true || Date.now() >= Number(s?.scade)) {
      return {ok: false, perche: "scaduta"};
    }
    const suaProva = await PROVA(uid, settimana).get();
    await ref.set({stimaA: valore,
      punteggioA: suaProva.data()?.punteggio ?? null}, {merge: true});
    const esito = esitoDellaSfida({da: String(s?.da), a: uid,
      scade: Number(s?.scade), punteggioDa: s?.punteggioDa ?? null,
      punteggioA: suaProva.data()?.punteggio ?? null, stimaDa: s?.stimaDa ?? null,
      stimaA: valore}, Date.now());
    if (esito !== null) await chiudiLaSfida(id, esito.vincitori, esito.perche);
    return {ok: true, esito};
  }
  throw new HttpsError("invalid-argument", "Gesto sconosciuto.");
});

/**
 * **UN PASSO DEL PELLEGRINAGGIO**, voce FF.06.2: un rito compiuto nella
 * settimana che porta alla luna piena porta il Cerchio avanti di un passo,
 * uno al giorno per persona. Aperto a ogni piano.
 */
export const unPassoDelPellegrinaggio = onCall(OPZIONI_SOCIALI, async (request) => {
  const uid = uidDi(request);
  await tettoDellaPorta(uid, "unPassoDelPellegrinaggio");
  const oggi = chiaveDelGiorno();
  const luna = lunaValida(request.data?.luna, oggi);
  if (luna === null) return {ok: false, perche: "luna"};
  return db().runTransaction(async (tx) => {
    const doc = statoDi(uid, "pellegrinaggio");
    const snap = await tx.get(doc);
    const giorni = snap.data()?.luna === luna ? elenco(snap.data()?.giorni) : [];
    if (giorni.includes(oggi)) return {ok: true, passi: giorni.length, gia: true};
    const dopo = [...giorni, oggi];
    tx.set(doc, {luna, giorni: dopo});
    return {ok: true, passi: dopo.length, gia: false};
  });
});

/** Per le prove: le porte di questo file e i loro tetti si contano insieme. */
export const PORTE_SOCIALI = Object.keys(TETTI_DELLE_PORTE);
