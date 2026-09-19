/**
 * LA PULIZIA DEI DOPPIONI, da lanciare a mano. Ordine DV.
 *
 * **Non e' una funzione distribuita**: e' un comando che si lancia una volta
 * dal PC con le credenziali di progetto, e per default NON cancella niente.
 * Scorre tutte le cronologie, conta i doppioni con la stessa regola del
 * telefono, e stampa il conto. Solo con `--davvero` cancella.
 *
 * Uso, dalla cartella functions:
 *
 *   npm run build
 *   node lib/pulisci_doppioni.js            # conta e basta
 *   node lib/pulisci_doppioni.js --davvero  # cancella i doppioni
 *
 * Serve una sessione con i permessi sul progetto (`gcloud auth
 * application-default login`). Il conto va letto prima di cancellare.
 */
import {initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";

import {doppioniDa, MessaggioSalvato} from "./doppioni";

async function principale(): Promise<void> {
  const davvero = process.argv.includes("--davvero");
  initializeApp({projectId: "esoteric-circle"});
  const db = getFirestore();

  let cronologie = 0;
  let messaggi = 0;
  let doppioni = 0;
  const utenti = await db.collection("users").listDocuments();
  for (const utente of utenti) {
    const maestri = await utente.collection("maestri").listDocuments();
    for (const maestro of maestri) {
      const snap = await maestro
        .collection("messages")
        .orderBy("createdAt")
        .get();
      if (snap.empty) continue;
      cronologie++;
      messaggi += snap.size;
      const lista: MessaggioSalvato[] = snap.docs.map((d) => ({
        id: d.id,
        role: String(d.get("role") ?? ""),
        text: String(d.get("text") ?? ""),
        conversazione: (d.get("conversazione") as string | undefined) ?? null,
      }));
      const daTogliere = doppioniDa(lista);
      doppioni += daTogliere.length;
      if (davvero && daTogliere.length > 0) {
        // A lotti da cinquecento, il tetto di una scrittura in blocco.
        for (let i = 0; i < daTogliere.length; i += 500) {
          const lotto = db.batch();
          for (const id of daTogliere.slice(i, i + 500)) {
            lotto.delete(maestro.collection("messages").doc(id));
          }
          await lotto.commit();
        }
      }
    }
  }
  console.log(
    `cronologie ${cronologie}, messaggi ${messaggi}, doppioni ${doppioni}` +
      (davvero ? ", cancellati" : ", niente cancellato: rilancia con --davvero"),
  );
}

principale().catch((errore) => {
  console.error(errore);
  process.exit(1);
});
