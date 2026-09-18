/**
 * I DOPPIONI DELLA CRONOLOGIA. Ordine DV, 18 settembre 2026.
 *
 * **Da dove vengono.** Dall'11 agosto 2026 (commit 7797f63c, ordine N) ogni
 * scrittura della memoria arriva qui dal telefono attraverso una coda, e la
 * coda si svuotava in due corse insieme: la domanda arrivava due volte, e
 * `scriviLaMemoria` la scriveva due volte, perche' `messaggio` aggiunge sempre
 * un documento nuovo. La coda sul telefono adesso corre una volta sola, ma i
 * doppioni gia' scritti restano nelle cronologie di chi ha usato l'app.
 *
 * **La regola e' la stessa del telefono**, `CronologiaSenzaDoppioni.doppione`
 * in `lib/core/chat/cronologia_senza_doppioni.dart`: due domande della
 * persona una dietro l'altra, con lo stesso testo e nella stessa
 * conversazione. Una cronologia sana non le puo' avere, perche' dopo ogni
 * domanda c'e' sempre un turno del Maestro; una domanda ripetuta davvero ha
 * la sua risposta in mezzo, e resta.
 *
 * **Il telefono li nasconde gia' in lettura**, quindi la pulizia dei dati non
 * e' urgente per chi guarda la chat. Serve perche' i doppioni sono dati falsi
 * su una persona: finiscono nelle sintesi settimanali della memoria e nei
 * Ricordi del Cerchio.
 */

/** Un messaggio come sta nella collezione `messages`, in ordine di tempo. */
export interface MessaggioSalvato {
  id: string;
  role: string;
  text: string;
  conversazione?: string | null;
}

/**
 * Gli identificativi dei doppioni in [messaggi], gia' in ordine di tempo.
 * Il primo di una serie resta, gli altri si tolgono.
 */
export function doppioniDa(messaggi: MessaggioSalvato[]): string[] {
  const daTogliere: string[] = [];
  let precedente: MessaggioSalvato | null = null;
  for (const m of messaggi) {
    if (precedente !== null && eDoppione(precedente, m)) {
      daTogliere.push(m.id);
      // Il precedente resta quello tenuto: tre copie di fila ne lasciano una.
      continue;
    }
    precedente = m;
  }
  return daTogliere;
}

/** Vero se [dopo] ripete [prima]: due domande uguali, una dietro l'altra. */
export function eDoppione(
  prima: MessaggioSalvato,
  dopo: MessaggioSalvato,
): boolean {
  return (
    prima.role === "user" &&
    dopo.role === "user" &&
    prima.text.trim() === dopo.text.trim() &&
    (prima.conversazione ?? null) === (dopo.conversazione ?? null)
  );
}
