/**
 * LE LAPIDI VECCHIE, COL SALE VUOTO. Ordine CG voce 15.
 *
 * **Parole del fondatore, 31 agosto 2026:** "cancella la lapide".
 *
 * **IL FATTO, rimisurato sul dato vero il 31 agosto 2026.** Nella collezione
 * `lapidi_del_benvenuto` ci sono TRE lapidi. Due sono SHA-256 nudi
 * dell'indirizzo, cioe' calcolabili da chiunque conosca l'email, e sono
 * `maobatta@gmail.com` del 24 agosto e `cloud@esotericircle.app` del 28. La
 * terza, del 30 agosto, non si riconosce col sale vuoto: e' gia' col pepe, ed
 * e' giusta cosi'.
 *
 * **DUE GESTI DIVERSI SU DUE LAPIDI DIVERSE, e li ha decisi il fondatore.**
 *
 * 1. La lapide di `maobatta@gmail.com` SI CANCELLA e non si ricalcola: e'
 *    l'account con cui prova l'app, e cancellarla gli restituisce la
 *    possibilita' di rifare l'onboarding da capo ricevendo il benvenuto.
 * 2. L'altra lapide col sale vuoto SI RICALCOLA col pepe: finche' resta col
 *    sale vuoto, chiunque conosca quell'indirizzo puo' sapere se ha gia'
 *    incassato il benvenuto, ed e' esattamente la debolezza che il pepe e'
 *    venuto a chiudere.
 *
 * **PERCHE' UN LAVORO A ORARIO E NON UNA CALLABLE, ed e' la decisione presa
 * per delega.** Il pepe non si legge dall'esterno, quindi l'impronta nuova la
 * puo' calcolare solo il server. Una callable che accettasse un indirizzo e
 * riscrivesse una lapide sarebbe **una superficie nuova su un dato antifrode,
 * costruita per essere usata due volte**: chiunque la raggiungesse potrebbe
 * provare indirizzi e leggere dalle risposte chi ha gia' incassato. Qui non
 * entra niente dal di fuori: gli indirizzi da ripesare sono DICHIARATI nel
 * codice, sono due, e non sono segreti (uno e' l'indirizzo di distribuzione
 * del progetto, l'altro l'account di prova del fondatore, tutti e due gia'
 * scritti nel repository).
 *
 * **COME SI CHIUDE DOPO, che l'ordine chiede per nome.** Da sola. Il lavoro e'
 * IDEMPOTENTE: quando la lapide col sale vuoto non c'e' piu', non trova
 * niente e non fa niente. Non serve nessun interruttore da spegnere, e quindi
 * non resta nessun interruttore acceso che qualcuno debba ricordarsi di
 * chiudere. **Un elenco vuoto lo rende inerte per sempre**, e il giorno che
 * l'elenco si svuota la funzione si puo' togliere senza rischi.
 */
import {onSchedule} from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";
import {createHash} from "node:crypto";
import {getFirestore} from "firebase-admin/firestore";

/** Cosa fare con una lapide vecchia. */
export type GestoSullaLapide = "cancella" | "ripesa";

/**
 * GLI INDIRIZZI DA SISTEMARE, e cosa farne.
 *
 * **Non sono segreti**, e per questo possono stare qui: sono gia' scritti nel
 * repository e nessuno dei due e' l'indirizzo di una persona che non sia il
 * fondatore o il progetto stesso.
 *
 * **Quando questo elenco e' vuoto il lavoro e' inerte**, e la funzione si puo'
 * togliere: e' cosi' che la via si chiude senza lasciare un interruttore
 * acceso.
 */
export const LAPIDI_DA_SISTEMARE: {email: string; gesto: GestoSullaLapide}[] = [
  // **SI CANCELLA**, per ordine del fondatore: e' il suo account di prova, e
  // cancellarla gli restituisce il benvenuto quando rifa' l'onboarding.
  {email: "maobatta@gmail.com", gesto: "cancella"},
  // **SI RIPESA**: e' l'indirizzo di distribuzione, e la sua lapide col sale
  // vuoto dice a chiunque conosca l'indirizzo che ha gia' incassato.
  {email: "cloud@esotericircle.app", gesto: "ripesa"},
];

/** L'impronta col sale VUOTO, cioe' come si calcolavano le lapidi vecchie. */
export function improntaSenzaSale(email: string): string {
  return createHash("sha256").update(email).digest("hex");
}

/**
 * L'impronta COL PEPE, la stessa che `statoDelCerchio` calcola.
 *
 * **Il pepe non si legge, non si stampa e non finisce in nessun log**: qui si
 * usa e basta, e quello che esce e' un'impronta.
 */
export function improntaColPepe(email: string): string {
  const sale = process.env.BENVENUTO_PEPPER ?? "";
  return createHash("sha256").update(sale + email).digest("hex");
}

export interface EsitoDelleLapidi {
  cancellate: number;
  ripesate: number;
  giaAPosto: number;
}

/**
 * SISTEMA LE LAPIDI VECCHIE. Idempotente.
 *
 * **Il ripesamento conserva la data**, e non e' un dettaglio: la scadenza
 * delle lapidi si conta da `quando`, e rimetterla a oggi allungherebbe di due
 * anni la vita di un dato antifrode che avrebbe dovuto scadere prima.
 */
export async function sistemaLeLapidiVecchie(): Promise<EsitoDelleLapidi> {
  const db = getFirestore();
  const fatto: EsitoDelleLapidi = {cancellate: 0, ripesate: 0, giaAPosto: 0};

  for (const voce of LAPIDI_DA_SISTEMARE) {
    const vecchia = db
      .collection("lapidi_del_benvenuto")
      .doc(improntaSenzaSale(voce.email));
    const snap = await vecchia.get();
    if (!snap.exists) {
      // **Gia' a posto**: e' il caso normale dopo il primo giro riuscito, ed
      // e' il modo in cui questo lavoro si spegne da solo.
      fatto.giaAPosto++;
      continue;
    }

    if (voce.gesto === "cancella") {
      await vecchia.delete();
      fatto.cancellate++;
      // **Non si scrive quale indirizzo**: un registro che nominasse le email
      // rimetterebbe in chiaro cio' che l'impronta esiste per nascondere.
      logger.info("lapidi: una lapide col sale vuoto e' stata cancellata");
      continue;
    }

    const dati = snap.data() ?? {};
    const nuova = db
      .collection("lapidi_del_benvenuto")
      .doc(improntaColPepe(voce.email));
    // Prima si scrive la nuova e poi si cancella la vecchia: se il giro
    // morisse in mezzo, resterebbe una lapide di troppo e non una di meno,
    // cioe' l'antifrode resterebbe piu' stretto e mai piu' largo.
    await nuova.set({...dati, ripesataIl: new Date()}, {merge: true});
    await vecchia.delete();
    fatto.ripesate++;
    logger.info("lapidi: una lapide col sale vuoto e' stata ripesata");
  }

  logger.info("lapidi: giro finito", fatto);
  return fatto;
}

/**
 * IL LAVORO, una volta al giorno alle tre e cinquanta.
 *
 * Dopo la pulizia delle scadenze delle tre e mezza, cosi' non ripesa una
 * lapide che la pulizia sta per portare via.
 */
export const sistemaLeLapidi = onSchedule(
  {
    schedule: "50 3 * * *",
    timeZone: "Europe/Rome",
    region: "europe-west1",
    timeoutSeconds: 120,
    memory: "256MiB",
    secrets: ["BENVENUTO_PEPPER"],
  },
  async () => {
    const fatto = await sistemaLeLapidiVecchie();
    logger.info("sistemaLeLapidi: giro giornaliero", fatto);
  }
);
