/// **LE DOMANDE DELICATE.** Ordine FU voce FU.04, 15 ottobre 2026. Il
/// fondatore, "Ok" sulle cinque correzioni dell'Architetto: se la domanda
/// parla di una crisi, del farsi del male o di un pericolo per se' o per
/// altri, non si estraggono carte e non si fa oracolo. Medora risponde con
/// cura, in poche righe, e indica dove trovare un aiuto vero.
///
/// **Il riconoscimento avviene prima sul telefono**, con l'elenco qui sotto,
/// e poi nell'istruzione al modello (`LaLetturaDellOracolo.istruzione`). Il
/// telefono sbaglia per prudenza: una domanda che parla di morire per amore
/// in senso figurato riceve la risposta di cura invece dell'oracolo, ed e'
/// il prezzo giusto. Una domanda normale non deve mai cadere qui: la prova
/// `test/l_oracolo_risponde_con_cura_test.dart` lo misura con dieci domande
/// delicate e dieci normali.
///
/// **L'app non ha ancora un percorso di aiuto coi suoi contatti** (cercato
/// sul ramo il 15 ottobre 2026: nessun numero, nessuna schermata). Intanto
/// la risposta invita a rivolgersi ai servizi di emergenza, il 112 in tutta
/// l'Unione Europea; i contatti da aggiungere, con la fonte di ciascuno,
/// sono proposti nel rapporto dell'ordine FU.
abstract final class LaDomandaDelicata {
  /// Le frasi e le radici che riconoscono una domanda delicata, in
  /// minuscolo. Una frase intera vale piu' di una parola sola: "farla
  /// finita", non "finita".
  static const List<String> segnali = [
    'suicid',
    'uccidermi',
    'ammazzarmi',
    'togliermi la vita',
    'farla finita',
    'farmi del male',
    'farmi male da sol',
    'mi taglio',
    'tagliarmi',
    'autolesion',
    'non voglio più vivere',
    'non voglio piu vivere',
    'voglio morire',
    'vorrei morire',
    'morire stanotte',
    'non ce la faccio più a vivere',
    'non ce la faccio piu a vivere',
    'farla pagare',
    'fargli del male',
    'farle del male',
    'uccidere',
    'ammazzare',
    'mi picchia',
    'mi ha picchiat',
    'ho paura che mi uccida',
    'mi minaccia di morte',
    'violenza in casa',
    'abusi',
    'abusa di me',
    'overdose',
  ];

  /// Vero se la domanda va accolta con cura invece che con l'oracolo.
  static bool e(String domanda) {
    final d = domanda.toLowerCase().replaceAll('’', '\'');
    return segnali.any(d.contains);
  }

  /// **LA RISPOSTA DI CURA**, nella voce di Medora: poche righe, nessuna
  /// carta, l'aiuto vero detto per primo.
  static const String titolo = 'Adesso conta avere qualcuno accanto';

  static const List<String> paragrafi = [
    'Quello che mi scrivi è importante e merita una voce vera accanto a te, '
        'adesso. Gli angeli possono aspettare: tu no.',
    'Se senti di essere in pericolo, o che qualcuno lo sia, chiama subito '
        'il 112, il numero di emergenza in tutta Europa. Parlane anche con '
        'una persona di cui ti fidi.',
    'Quando vorrai, io sono qui. Torna a trovarmi.',
  ];
}
