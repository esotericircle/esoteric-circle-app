/**
 * IL CONFINE DEL GIORNO LO DECIDE IL SERVER, e questa e' l'unica definizione.
 *
 * **Perche' non l'orologio del telefono.** Fino all'ordine N i contatori
 * giornalieri nascevano da `DateTime.now()` sul dispositivo: spostando l'ora
 * avanti di un giorno tutti e quattro i budget tornavano interi, verificato
 * eseguendo e non ragionando. Un limite che il telefono puo' riscrivere non e'
 * un limite, quindi il giorno viene da qui e il client lo riceve gia' deciso.
 *
 * **Il fuso e' Europe/Rome, ed e' una scelta dichiarata.** Il giorno di una
 * persona deve essere quello del suo calendario, e il Cerchio nasce in
 * italiano: finche' non c'e' un fuso per persona (che andra' scritto nel suo
 * documento, non mandato a ogni chiamata, altrimenti lo sceglie il client e
 * siamo daccapo) il confine e' quello di Roma per tutti. Chi cambia questa
 * riga sposta il mezzanotte di tutti.
 *
 * **Perche' una stringa e non una data.** Serve solo a dire "e' lo stesso
 * giorno oppure no": due stringhe si confrontano senza fusi, ore legali ne'
 * millisecondi di scarto da interpretare. E' la stessa ragione scritta accanto
 * a `ConfineDelGiorno` nel client, che resta per il confine RITUALE e per cio'
 * che e' solo locale.
 */
export const FUSO_DEL_CERCHIO = "Europe/Rome";

/**
 * La chiave del giorno d'uso per un istante, nel fuso del Cerchio.
 *
 * Il formato e' `AAAA-MM-GG` e per il client e' OPACO: non lo ricalcola, lo
 * conserva e lo confronta. Cosi' nessuno puo' fabbricarne uno.
 */
export function chiaveDelGiorno(istante: Date = new Date()): string {
  // `en-CA` produce proprio `AAAA-MM-GG`, ed e' il modo di ottenere la data
  // civile in un fuso senza tirarsi dentro una libreria di fusi orari: la
  // tabella dei fusi e' quella del sistema, che Node aggiorna per conto suo.
  return new Intl.DateTimeFormat("en-CA", {
    timeZone: FUSO_DEL_CERCHIO,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).format(istante);
}

/** Vero se la chiave e' quella del giorno in cui cade l'istante. */
export function eOggi(chiave: string, istante: Date = new Date()): boolean {
  return chiave === chiaveDelGiorno(istante);
}
