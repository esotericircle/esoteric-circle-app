/// **LA FORMA DEI RESPONSI INTERPRETATIVI, IN UN PUNTO SOLO.** Ordine GA,
/// voci GA.03, GA.04 e GA.05, 20 ottobre 2026. Sta accanto alla regola del
/// titolo (`il_titolo_del_responso.dart`): il titolo resta il primo pezzo,
/// questa e' la forma di cio' che lo segue nelle quattro arti che
/// interpretano un simbolo uscito.
///
/// **LE PAROLE DEL FONDATORE, per intero**, perche' sono la regola e non un
/// suo riassunto: vedi [paroleDelFondatore].
///
/// **LA FORMA.** Il responso breve: il titolo, il paragrafo della risposta e
/// il riquadro "Cosa fare adesso". Il responso lungo aggiunge il paragrafo che
/// approfondisce e il riquadro del rito propiziatorio, col titolo dell'arte
/// ([titoloDelRito]). Sotto, sempre, il "Da dove viene" in corsivo, fuori dal
/// conto delle parole. Ogni paragrafo ha da [minimo] a [massimo] parole,
/// contate come le conta chi legge ([parole]).
///
/// **DOVE SI DISEGNA.** In `IlResponsoInterpretato`
/// (`lib/design_system/components/il_responso_interpretato.dart`), che passa
/// dal titolo comune: nessuna arte ricompone i riquadri a mano. La guardia
/// `la_forma_del_responso_test.dart` cade col nome dell'arte e del testo.
library;

/// Le arti della forma nuova. L'Oroscopo ne vale tre perche' il titolo del
/// rito segue la tradizione scelta.
enum ArteInterpretata {
  oroscopoOccidentale,
  oroscopoVedico,
  oroscopoCinese,
  tarocchi,
  oracolo,
  rune,
}

abstract final class LaFormaDelResponso {
  /// Le parole del fondatore, con la loro data e ora.
  static const Map<String, String> paroleDelFondatore = {
    '19 ottobre 2026 alle 23:08': 'bisogna cambiare le regole per i responsi '
        'delle funzionalità oroscopo, tarocchi, arcano angelo, estrazione '
        'rune: tutte le risposte composte da paragrafi ognuno con tra 40 a 50 '
        'parole ognuno. Per le risposte brevi 2 paragrafi di cui il secondo '
        'messo in evidenza in un riquadro e questo riquadro deve intitolarsi '
        '"cosa fare adesso" e di conseguenza adattare il testo. Per le '
        'risposte lunghe aggiungi 2 paragrafi sempre con il primo in '
        'riquadro. Sotto sempre il paragrafo in corsivo "da dove viene". '
        'Restano all\'inizio i titoli, anche per le singola carte o le '
        'singole rune.',
    '20 ottobre 2026 alle 00:10': 'Il secondo riquadro della risposta lunga, '
        'quindi il quarto paragrafo con riquadro',
  };

  /// Le parole di un paragrafo, il primo e l'ultimo numero ammessi.
  static const int minimo = 40;
  static const int massimo = 50;

  /// Il titolo del riquadro del secondo paragrafo, uguale in ogni arte.
  static const String titoloDelConsiglio = 'Cosa fare adesso';

  /// L'etichetta del paragrafo in corsivo in fondo.
  static const String etichettaDellaFonte = 'Da dove viene';

  /// **IL TITOLO DEL RIQUADRO DEL RITO**, voce GA.04: il fondatore, 20
  /// ottobre 2026 alle 00:16, *"Per le rune 'il galdr propiziatorio', per
  /// l'arcano 'il versetto o salmo propiziatorio' scegli tu, per i tarocchi
  /// scegli tu, scegli tu. Anzi scegli tu su tutto"*.
  static String titoloDelRito(ArteInterpretata arte) => switch (arte) {
        ArteInterpretata.rune => 'Il galdr propiziatorio',
        ArteInterpretata.oracolo => 'Il salmo propiziatorio',
        ArteInterpretata.tarocchi => 'La contemplazione propiziatoria',
        ArteInterpretata.oroscopoOccidentale => 'L\'inno propiziatorio',
        ArteInterpretata.oroscopoVedico => 'Il mantra propiziatorio',
        ArteInterpretata.oroscopoCinese => 'Il gesto propiziatorio',
      };

  /// Il nome dell'arte come lo legge chi guarda una prova rossa.
  static String nome(ArteInterpretata arte) => switch (arte) {
        ArteInterpretata.oroscopoOccidentale => 'Oroscopo occidentale',
        ArteInterpretata.oroscopoVedico => 'Oroscopo vedico',
        ArteInterpretata.oroscopoCinese => 'Oroscopo cinese',
        ArteInterpretata.tarocchi => 'Stesa di Tarocchi',
        ArteInterpretata.oracolo => 'Oracolo degli Angeli',
        ArteInterpretata.rune => 'Rune di Caligo',
      };

  /// **LE PAROLE DI UN PARAGRAFO, come le conta chi legge**: separate da uno
  /// spazio (voce GA.03).
  static int parole(String testo) =>
      testo.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).length;

  /// Se un paragrafo sta nella misura.
  static bool aMisura(String testo) {
    final n = parole(testo);
    return n >= minimo && n <= massimo;
  }

  /// **LA FORMA E LA RISPOSTA DIRETTA, PER IL MODELLO, IN UN PUNTO SOLO.**
  /// Ordine GA voci GA.03, GA.06 e GA.07, 20 ottobre 2026: "dove un testo
  /// lo scrive il modello, l'istruzione a Gemini si riscrive con la forma di
  /// GA.03 e la regola di GA.06, una volta sola, in un punto solo". La parte
  /// che vale per ogni arte che interpreta: i paragrafi da [minimo] a
  /// [massimo] parole, la prima frase che risponde, il riquadro "Cosa fare
  /// adesso" scritto per il titolo, ogni affermazione sui simboli usciti e
  /// sulla domanda, niente futuro certo, salute, denaro, questioni legali.
  /// Ogni istruzione la legge da qui, come legge il confine del responso
  /// (`ConfineDelResponso.perIlModello`); la sua prova conta che compaia una
  /// volta sola. Il fondatore, 19 ottobre 2026: *"risposte dirette
  /// immediatamente, l'utente deve avere subito e sempre risposte senza
  /// fronzoli o criptiche o includenti o sibilline"*.
  ///
  /// Il rito propiziatorio della Lunga non lo scrive il modello: viene dalle
  /// raccolte dei riti con la sua fonte (GA.04, "nessuna formula
  /// inventata"), e la riga lo dice.
  static String perIlModello({
    required ArteInterpretata arte,
    required bool lunga,
  }) =>
      'LA FORMA DEL RESPONSO E LA RISPOSTA DIRETTA (${nome(arte)}):\n'
      '- Il titolo è già la risposta, in una frase sola.\n'
      '- Ogni paragrafo ha da $minimo a $massimo parole, contate separate '
      'da uno spazio: mai meno di $minimo, mai più di $massimo.\n'
      '- Il primo paragrafo è la risposta: la sua prima frase risponde alla '
      'domanda (dove non c\'è una domanda, dice com\'è il giorno o il '
      'periodo), subito, senza preamboli e senza immagini al posto della '
      'risposta.\n'
      '- Il secondo paragrafo sta nel riquadro "$titoloDelConsiglio": è '
      'scritto per il titolo e dice che cosa fare o non fare adesso, con '
      'verbi all\'imperativo.\n'
      '${lunga ? '- Il terzo paragrafo approfondisce la risposta sugli '
          'stessi simboli. Il quarto, "${titoloDelRito(arte)}", lo aggiunge '
          'l\'app dalla sua fonte: non scriverlo e non inventare formule.\n' : ''}'
      '- Ogni affermazione poggia sui simboli usciti, sul loro significato e '
      'sulla domanda: un testo che starebbe bene sotto qualunque simbolo o '
      'qualunque domanda è sbagliato.\n'
      '- Niente fronzoli, niente frasi criptiche o sibilline: chi legge '
      'deve sapere che cosa fare o non fare.\n'
      '- Nessun futuro dato per certo; nessun consiglio su salute, denaro o '
      'questioni legali.';
}

/// **UN RESPONSO INTERPRETATO**, i pezzi della forma di GA.03 senza il
/// disegno. Breve quando [approfondimento] e [rito] mancano; una singola
/// carta o una singola runa e' breve e senza [daDoveViene] (voce GA.05: il
/// "Da dove viene" chiude la consultazione una volta sola, in fondo).
class ResponsoInterpretato {
  const ResponsoInterpretato({
    required this.arte,
    required this.titolo,
    required this.risposta,
    required this.cosaFare,
    this.approfondimento,
    this.rito,
    this.daDoveViene,
  });

  final ArteInterpretata arte;
  final String titolo;

  /// Il paragrafo 1: la risposta. La prima frase risponde (voce GA.06).
  final String risposta;

  /// Il paragrafo 2, nel riquadro "Cosa fare adesso".
  final String cosaFare;

  /// Il paragrafo 3 della Lunga: approfondisce la risposta.
  final String? approfondimento;

  /// Il paragrafo 4 della Lunga, nel riquadro del rito propiziatorio.
  final String? rito;

  /// Il paragrafo breve in corsivo in fondo, fuori dal conto.
  final String? daDoveViene;

  bool get lungo => approfondimento != null || rito != null;

  /// I paragrafi che si contano, nell'ordine in cui si leggono.
  List<String> get paragrafi => [
        risposta,
        cosaFare,
        if (approfondimento != null) approfondimento!,
        if (rito != null) rito!,
      ];

  /// **I DIFETTI DELLA FORMA**, ognuno col nome dell'arte e l'inizio del
  /// testo: un paragrafo fuori misura, un pezzo che manca. [conLaFonte] dice
  /// se questo responso deve chiudere col "Da dove viene" (il responso
  /// principale si', la singola carta no).
  List<String> difetti({bool conLaFonte = true}) {
    final chi = '${LaFormaDelResponso.nome(arte)}, «$titolo»';
    final fuori = <String>[];
    if (titolo.trim().isEmpty) fuori.add('$chi: manca il titolo');
    void misura(String nome, String? testo) {
      if (testo == null || testo.trim().isEmpty) {
        fuori.add('$chi: manca $nome');
        return;
      }
      final n = LaFormaDelResponso.parole(testo);
      if (!LaFormaDelResponso.aMisura(testo)) {
        final inizio =
            testo.length > 40 ? '${testo.substring(0, 40)}...' : testo;
        fuori.add('$chi: $nome ha $n parole, «$inizio»');
      }
    }

    misura('la risposta', risposta);
    misura('il riquadro "${LaFormaDelResponso.titoloDelConsiglio}"', cosaFare);
    if (lungo) {
      misura('l\'approfondimento', approfondimento);
      misura('il riquadro "${LaFormaDelResponso.titoloDelRito(arte)}"', rito);
    }
    if (conLaFonte && (daDoveViene == null || daDoveViene!.trim().isEmpty)) {
      fuori.add('$chi: manca il "${LaFormaDelResponso.etichettaDellaFonte}"');
    }
    return fuori;
  }
}
