/// **QUANDO DAVANTI ALL'OBIETTIVO C'E' DAVVERO UN VOLTO.**
/// Ordine CR voce 01, seconda stesura, 6 settembre 2026.
///
/// **Parole del fondatore, dopo aver provato la prima stesura**: *"ho fatto la
/// foto al muro e mi e' uscito ugualmente il responso con la foto del muro"*, e
/// *"ci sono milioni di app che hanno un riconoscimento serio e professionale,
/// pensa a tutti i servizi finanziari o anche casino online"*.
///
/// **PERCHE' IL MURO PASSAVA ANCHE COL CANCELLO CHIUSO, e la causa e' scritta
/// nel pacchetto.** La catena di MediaPipe nasce con l'INSEGUIMENTO acceso:
/// dopo che ha agganciato un volto, nei fotogrammi successivi **il rilevatore
/// non gira piu'** e la mesh continua a produrre punti dentro la regione che
/// stava seguendo. La documentazione del pacchetto lo dice con parole sue:
/// *"Null when the frame was served by landmark tracking, in which case the
/// detector did not run"*, e *"hasFace: False on landmark-tracked frames even
/// though a face is being followed"*.
///
/// Chi completava la scansione col proprio viso e poi inquadrava una parete
/// riceveva quindi ancora dei punti, perche' nessuno stava piu' cercando un
/// volto: si stava soltanto seguendo il ricordo di dove il volto era. Il
/// cancello guardava una lista di punti non vuota e la trovava piena.
///
/// **COSA CAMBIA ADESSO, e come lo fanno le app serie.** Il rilevatore gira a
/// OGNI fotogramma, e non basta che trovi qualcosa: deve trovarlo con un
/// punteggio di confidenza sopra una soglia dichiarata. Un volto vero davanti
/// a una fotocamera frontale sta comodamente sopra; una parete no.
class SoglieDelRilevamento {
  const SoglieDelRilevamento._();

  /// **LA CONFIDENZA MINIMA DEL RILEVATORE.**
  ///
  /// Il modello a corto raggio di MediaPipe nasce con `0.5`. Qui si sale a
  /// **0.75**, e la ragione e' che le due soglie servono a cose diverse: la
  /// soglia del pacchetto decide *cosa vale la pena di analizzare*, la nostra
  /// decide *a chi diamo un responso sul suo volto*. La seconda ha il diritto
  /// di essere piu' severa della prima.
  static const double confidenzaDelRilevatore = 0.75;

  /// **LA CONFIDENZA MINIMA DELLA MESH.**
  ///
  /// Il rilevatore dice che li' c'e' una faccia; la mesh dice quanto bene i
  /// suoi 478 punti si sono posati sopra. Sono due giudizi diversi e si
  /// pretendono tutti e due: un rilevamento sicuro con una mesh incerta e' un
  /// volto troppo storto, troppo lontano o troppo al buio per essere misurato,
  /// e misurarlo lo stesso vorrebbe dire dare numeri a caso.
  static const double confidenzaDellaMesh = 0.60;

  /// **QUANTO PUO' ESSERE VECCHIA LA LETTURA NELL'ISTANTE DELLO SCATTO.**
  ///
  /// Il cancello guardava l'ULTIMA lettura, senza chiedersi di quando fosse.
  /// Fra l'ultimo fotogramma con un volto e il dito che tocca lo scatto
  /// possono passare secondi, e in quei secondi la fotocamera puo' essere
  /// finita su tutt'altro. **Una lettura vecchia non e' una lettura**: e' un
  /// ricordo, ed e' esattamente cio' che ha lasciato passare il muro.
  ///
  /// Quattro decimi di secondo sono larghi per una catena che gira a piu'
  /// fotogrammi al secondo e stretti per un movimento umano.
  static const Duration letturaAncoraFresca = Duration(milliseconds: 400);
}
