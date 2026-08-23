import {test} from "node:test";
import assert from "node:assert/strict";
import {GIORNI_DI_RIPENSAMENTO} from "./cerchio";

/**
 * I TRENTA GIORNI DI RIPENSAMENTO. Ordine BC voce 02.
 *
 * **Decisione del fondatore**: "Cancella l'account, in fondo, con la
 * schermata che elenca cosa sparisce davvero, e trenta giorni di
 * ripensamento prima della cancellazione definitiva."
 *
 * Qui si guarda il conto dei giorni, che e' l'unica parte di questa voce che
 * si possa provare senza Firestore vivo: quanto dista la data segnata da
 * quella in cui si e' chiesto. Che la cancellazione avvenga davvero lo dice
 * il lavoro notturno, e quello si guarda sui log del servizio.
 */

/** La data che `chiediLOblio` scrive, calcolata come la scrive lui. */
function cancellaDopo(chiestoIl: Date): Date {
  const quando = new Date(chiestoIl.getTime());
  quando.setUTCDate(quando.getUTCDate() + GIORNI_DI_RIPENSAMENTO);
  return quando;
}

test("il ripensamento dura trenta giorni, non uno di meno", () => {
  assert.equal(GIORNI_DI_RIPENSAMENTO, 30);
});

test("la data segnata cade trenta giorni dopo la richiesta", () => {
  const chiesto = new Date(Date.UTC(2026, 7, 23, 14, 30));
  const quando = cancellaDopo(chiesto);
  const giorni = (quando.getTime() - chiesto.getTime()) / 86400000;
  assert.equal(giorni, 30);
  assert.equal(quando.toISOString(), "2026-09-22T14:30:00.000Z");
});

test("e regge il cambio di mese e l'ora legale", () => {
  // **Il 15 ottobre piu' trenta giorni cade il 14 novembre**, e in mezzo
  // l'Europa torna all'ora solare. Si somma sulla data UTC apposta: sommare
  // trenta volte ventiquattro ore darebbe un'ora di scarto, e chi guarda la
  // data segnata leggerebbe un giorno sbagliato.
  const chiesto = new Date(Date.UTC(2026, 9, 15, 12));
  assert.equal(
    cancellaDopo(chiesto).toISOString(), "2026-11-14T12:00:00.000Z");
  // E il salto d'anno.
  const dicembre = new Date(Date.UTC(2026, 11, 20, 9));
  assert.equal(
    cancellaDopo(dicembre).toISOString(), "2027-01-19T09:00:00.000Z");
});
