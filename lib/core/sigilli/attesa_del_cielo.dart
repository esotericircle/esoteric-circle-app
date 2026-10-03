// GENERATO DA tool/genera_corpus_f.py: NON SI SCRIVE A MANO.
// Ordine CP voce 05.
//
// **L'ATTESA TIPICA DI OGNI EVENTO DEL CIELO, in giorni.** Non e' una
// probabilita': e' quanto si aspetta al peggio ragionevole, perche' un
// evento raro vale come traguardo solo se l'attesa e' quella che si
// dichiara. E' il costo in giorni di una FinestraDelCielo, cioe' la
// grandezza su cui poggia tutta la scala dei traguardi.
//
// La tavola vive in tool/corpus_traguardi.py e si rigenera: due tavole
// scritte a mano in due lingue sono due verita' che un giorno divergono.

const Map<String, int> attesaTipicaDelCielo = {
  'eclissi': 90,
  'equinozio': 91,
  'giove_diretto': 240,
  'giove_retrogrado': 120,
  'luna_calante': 2,
  'luna_crescente': 2,
  'luna_nel_segno_opposto': 28,
  'luna_nel_tuo_segno': 28,
  'luna_nuova': 15,
  'luna_nuova_nel_tuo_segno': 365,
  'luna_piena': 15,
  'luna_piena_nel_tuo_segno': 365,
  'marte_diretto': 390,
  'marte_retrogrado': 390,
  'mercurio_diretto': 120,
  'mercurio_retrogrado': 60,
  'primo_quarto': 8,
  'ritorno_solare': 365,
  'saturno_diretto': 240,
  'saturno_retrogrado': 120,
  'sole_nel_tuo_segno': 180,
  'solstizio': 91,
  'transito_su_marte': 60,
  'transito_su_venere': 60,
  'transito_sul_sole': 45,
  'transito_sull_ascendente': 45,
  'transito_sulla_luna': 30,
  'tre_transiti_insieme': 180,
  'ultimo_quarto': 8,
  'venere_diretta': 290,
  'venere_retrograda': 290,
};

// GENERATO DA tool/genera_corpus_f.py: NON SI SCRIVE A MANO.
// Ordine EA voce 05.
//
// **OGNI QUANTO UN EVENTO DEL CIELO TORNA, in giorni.** L'attesa qui sopra
// dice quanto si aspetta la PRIMA volta; questa dice quanto si aspetta ogni
// altra, e serve ai traguardi che la stessa finestra la chiedono piu' volte.
// Il mese sinodico della Luna e' di 29,53 giorni, qui arrotondato a trenta.

const Map<String, int> ritornoDelCielo = {
  'luna_piena': 30,
};
