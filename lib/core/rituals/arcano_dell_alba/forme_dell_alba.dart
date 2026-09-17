import 'attribuzioni_degli_arcani.dart';

/// **LE FORME CON CUI SI DICE LA CARTA, E IL FILO CON IERI.** Ordine DT voci
/// 08 e 10, 17 settembre 2026.
///
/// **Il primo movimento ha un compito solo**: nominare la carta, il verso e
/// l'attribuzione. Niente consiglio, niente immagine: quelli sono del dono e di
/// Medora. Si compone da un'apertura e da una clausola, e le aperture sono
/// **piu' dei giorni di un ciclo**, perche' il registro delle aperture non ne
/// lasci ripetere nessuna dentro i quarantaquattro giorni.
///
/// **Ogni apertura regge la carta come oggetto o come predicato**, mai dietro
/// una preposizione: *"a il Matto"* e *"su la Torre"* non si scrivono, e *"Gli
/// Amanti esce"* nemmeno.
abstract final class FormeDellAlba {
  static const List<String> aperture = [
    'Stamattina il mazzo ti consegna',
    'Sotto la tua mano scopri',
    'Dietro il dorso toccato trovi',
    'La carta voltata per te è',
    'L\'alba di oggi ti porta',
    'Fra le carte coperte hai trovato',
    'Il tuo gesto del mattino scopre',
    'Sotto il dorso scopri',
    'Il mazzo ti risponde con',
    'Per questa giornata il mazzo sceglie',
    'Col mattino ancora giovane saluti',
    'Hai scoperto la carta e incontri',
    'La giornata si apre con',
    'Il nome di stamattina è',
    'Con le tue dita scopri',
    'Questo mattino ti presenta',
    'Per oggi il mazzo ti assegna',
    'Dal mazzo intero hai tirato fuori',
    'Fino a sera porti con te',
    'Oggi hai scoperto',
    'Il primo sguardo della giornata incontra',
    'Voltando la carta incontri',
    'A sorpresa ricevi',
    'Il mattino ti affida',
    'Fra i ventidue arcani maggiori oggi peschi',
    'Sotto le dita ritrovi',
    'Stamani hai rivelato',
    'Da sotto il dorso tiri fuori',
    'Al tuo risveglio il mazzo mostra',
    'Ora hai in mano',
    'L\'arcano del tuo mattino è',
    'Hai davanti a te',
    'Questa mattina accogli',
    'Per aprire la giornata hai preso',
    'Nel mazzo coperto hai incontrato',
    'La tua mano ha voltato',
    'Oggi il caso ti regala',
    'Il gesto è fatto e hai davanti',
    'Oggi la carta è',
    'Vedi venire verso di te',
    'Tra le dita adesso stringi',
    'Il giorno comincia con',
    'In tasca per oggi porti',
    'Nel primo mattino giri',
    'Appena voltata la carta trovi',
    'Per le prossime ore tieni con te',
    'Il risveglio ti porge',
    'Ha parlato il mazzo e dice',
  ];

  /// Le clausole dell'attribuzione, per famiglia. `{di}` e' l'attribuzione con
  /// la sua preposizione: *"dell'Aria"*, *"di Marte"*, *"dei Pesci"*.
  static const Map<FamigliaDellArcano, List<String>> clausole = {
    FamigliaDellArcano.elementale: [
      'carta {di}',
      'lettera madre {di}',
      'arcano {di}',
      'nell\'elemento {di}',
    ],
    FamigliaDellArcano.planetaria: [
      'carta {di}',
      'lettera doppia {di}',
      'arcano {di}',
      'sotto il governo {di}',
    ],
    FamigliaDellArcano.zodiacale: [
      'carta {di}',
      'lettera semplice {di}',
      'arcano {di}',
      'nel segno {di}',
    ],
  };

  /// **IL FILO CON IERI**, per relazione. `{ieri}` e' la carta di ieri col suo
  /// verso. Sta **in fondo** alla chiusura di Medora, che e' il solo posto dove
  /// l'ordine lo ammette, e mai in apertura: l'apertura di Medora appartiene
  /// alla lettura e al suo registro.
  static const Map<RelazioneFraArcani, List<String>> filo = {
    RelazioneFraArcani.governo: [
      'Ieri avevi {ieri}: fra le due carte c\'è un governo, un pianeta '
          'che regge il segno dell\'altra.',
      'Con {ieri}, ieri, questa mattina è legata da un governo: un pianeta '
          'regge il segno dell\'altra carta.',
    ],
    RelazioneFraArcani.opposizione: [
      'Ieri avevi {ieri}: il suo segno sta di fronte a quello di oggi, '
          'come due rive dello stesso fiume.',
      'Fra ieri e oggi il cielo si specchia: ieri avevi {ieri}, '
          'nel segno opposto.',
    ],
    RelazioneFraArcani.quadratura: [
      'Ieri avevi {ieri}: i due segni stanno ad angolo retto, un attrito '
          'che mette in moto.',
      'Fra {ieri} di ieri e la carta di oggi corre una quadratura: una '
          'tensione utile.',
    ],
    RelazioneFraArcani.stessoElemento: [
      'Ieri avevi {ieri}: lo stesso elemento attraversa le due mattine.',
      'Con {ieri}, ieri, questa carta condivide l\'elemento: il filo continua.',
    ],
    RelazioneFraArcani.stessaFamiglia: [
      'Ieri avevi {ieri}, della stessa famiglia di arcani: stessa forma, '
          'contenuto nuovo.',
      'Anche ieri, con {ieri}, il dono aveva questa forma: il senso però è '
          'nuovo.',
    ],
  };

  /// **L'ORDINE IN CUI SI GUARDANO LE RELAZIONI**: dalla piu' stretta alla
  /// piu' larga. Due carte possono averne piu' d'una, e il filo ne dice una.
  static const List<RelazioneFraArcani> precedenza = [
    RelazioneFraArcani.governo,
    RelazioneFraArcani.opposizione,
    RelazioneFraArcani.quadratura,
    RelazioneFraArcani.stessoElemento,
    RelazioneFraArcani.stessaFamiglia,
  ];

  /// L'attribuzione con la sua preposizione articolata.
  static String diAttribuzione(AttribuzioneDellArcano a) => switch (a.nome) {
        'Aria' => 'dell\'Aria',
        'Acqua' => 'dell\'Acqua',
        'Fuoco' => 'del Fuoco',
        'Luna' => 'della Luna',
        'Sole' => 'del Sole',
        'Ariete' => 'dell\'Ariete',
        'Toro' => 'del Toro',
        'Gemelli' => 'dei Gemelli',
        'Cancro' => 'del Cancro',
        'Leone' => 'del Leone',
        'Vergine' => 'della Vergine',
        'Bilancia' => 'della Bilancia',
        'Scorpione' => 'dello Scorpione',
        'Sagittario' => 'del Sagittario',
        'Capricorno' => 'del Capricorno',
        'Acquario' => 'dell\'Acquario',
        'Pesci' => 'dei Pesci',
        final pianeta => 'di $pianeta',
      };

  /// Il nome della carta dentro una frase: l'articolo in minuscolo.
  static String nomeInFrase(String nome) {
    for (final articolo in const ['Il ', 'La ', 'Gli ', 'Lo ', 'I ', 'Le ']) {
      if (nome.startsWith(articolo)) {
        return articolo.toLowerCase() + nome.substring(articolo.length);
      }
    }
    if (nome.startsWith('L\'')) return 'l\'${nome.substring(2)}';
    return nome;
  }

  /// La parola del verso accordata alla carta, da quella del rovescio che il
  /// catalogo del mazzo gia' accorda: *"rovesciata"* diventa *"dritta"*.
  static String verso(String parolaDelRovescio, {required bool rovescio}) =>
      rovescio
          ? parolaDelRovescio
          : parolaDelRovescio.replaceFirst('rovesciat', 'dritt');
}
