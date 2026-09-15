import '../angels/guardian_angels.dart';
import '../rituals/animal_catalog.dart';
import '../rituals/guide_animal_corpus.dart';
import '../rituals/guide_animal_derivation.dart';

/// LA SCHEDA DELLA SCELTA: cosa dice il riquadro sotto l'animale guida e
/// sotto i tre angeli, e PERCHE' sono stati scelti.
///
/// ORDINE 2163, VOCE 12. Il contenuto nasce QUI, nel generatore, mai nella
/// schermata: le caratteristiche vengono dai corpus con la tradizione
/// nominata (per l'animale la simbologia di Andrews, Farmer, Sams e Carson;
/// per gli angeli la tradizione dello Shemhamphorash gia' documentata nel
/// lore), e la ragione della scelta nomina l'elemento della carta natale che
/// ha eletto. Cio' che scriviamo noi si dichiara come chiave di lettura del
/// Maestro, non come tradizione.
class SchedaDellaScelta {
  const SchedaDellaScelta({
    required this.caratteristiche,
    required this.ragione,
    required this.chiave,
  });

  /// Le righe delle caratteristiche, gia' passate dal filtro. Se e' vuota il
  /// riquadro NON si monta: un riquadro vuoto sarebbe un segnaposto.
  final List<RigaDellaScheda> caratteristiche;

  /// La ragione della scelta, che nomina l'elemento della carta natale.
  /// NULLA quando il dato non c'e': la riga sparisce, non si inventa una
  /// ragione plausibile e non si mostra un segnaposto.
  final String? ragione;

  /// La dichiarazione di curatela: cio' che e' nostro si dice nostro.
  final String chiave;
}

/// Una riga della scheda: un titolo breve facoltativo e il testo.
class RigaDellaScheda {
  const RigaDellaScheda({this.titolo, required this.testo});

  final String? titolo;
  final String testo;
}

/// Il generatore della scheda, con il filtro delle promesse vietate.
class GeneratoreDellaScheda {
  const GeneratoreDellaScheda._();

  /// LE RADICI VIETATE: niente promesse di guarigione, salute, fertilita',
  /// vittoria, ricchezza o protezione. Il filtro vive QUI, nel generatore:
  /// una schermata che filtra e' una schermata che prima o poi non filtra,
  /// perche' la seconda schermata che monta lo stesso dato non lo sa.
  static const List<String> radiciVietate = [
    'guarig', // guarigione, guarigioni
    'guaris', // guarisce, guarisci, guarire declinato
    'salute',
    'fertilit',
    'vittori',
    'ricchezz',
    'protezion',
    'protegg',
  ];

  /// Vero se il testo non contiene nessuna radice vietata.
  static bool ammessa(String testo) {
    final basso = testo.toLowerCase();
    for (final radice in radiciVietate) {
      if (basso.contains(radice)) return false;
    }
    return true;
  }

  /// La scheda per l'animale guida.
  ///
  /// Le caratteristiche vengono dal ritratto del corpus, nell'ordine natura,
  /// dono, lezione: si prendono le prime due che passano il filtro. La
  /// ragione nomina il segno solare che ha eletto l'animale, e la chiave
  /// dichiara che la derivazione e' un ponte di curatela, non tradizione.
  static SchedaDellaScelta perAnimale(GuideAnimal animale) {
    final ritratto = GuideAnimalCorpus.di(animale.name);
    // La PRIMA FRASE di ogni campo, con la stessa regola degli angeli: il
    // riquadro sta sotto un totem alto duecentottanta punti e il campo
    // intero, due frasi, faceva sbordare la colonna di diciotto punti sullo
    // schermo del fondatore, misurato dalla prova del vuoto.
    final candidate = <({String titolo, String? testo})>[
      (titolo: 'La sua natura', testo: _primaFraseAmmessa(ritratto.natura)),
      (titolo: 'Il suo dono', testo: _primaFraseAmmessa(ritratto.dono)),
      (titolo: 'La sua lezione', testo: _primaFraseAmmessa(ritratto.lezione)),
    ];
    final caratteristiche = [
      for (final c in candidate)
        if (c.testo != null) RigaDellaScheda(titolo: c.titolo, testo: c.testo!),
    ].take(2).toList();

    final segno = GuideAnimalDerivation.signOf(animale.name);
    return SchedaDellaScelta(
      caratteristiche: caratteristiche,
      ragione: 'Il tuo Sole in ${segno.italianName} elegge ${animale.name}.',
      chiave: 'Chiave di lettura di Caligo: un ponte di curatela col tuo '
          'cielo, non un responso della tradizione sciamanica.',
    );
  }

  /// La scheda per la triade degli angeli.
  ///
  /// Per ogni angelo noto si prende la prima frase della sua tradizione che
  /// passa il filtro; un angelo senza frase ammessa salta, senza segnaposto.
  /// La ragione nomina solo i dati che ci sono: senza ora di nascita
  /// l'Intelletto non si nomina, e la riga non lo aspetta.
  static SchedaDellaScelta perAngeli(AngelTriad triade) {
    final caratteristiche = <RigaDellaScheda>[];
    final noti = triade.known;
    for (var i = 0; i < noti.length; i++) {
      final angelo = noti[i];
      final lore = angelo.lore;
      if (lore == null) continue;
      final frase = _primaFraseAmmessa(lore.tradition);
      if (frase == null) continue;
      caratteristiche.add(RigaDellaScheda(titolo: angelo.name, testo: frase));
    }

    // I gradi con la virgola, come si scrivono in italiano.
    final gradi = triade.sunLongitude.toStringAsFixed(1).replaceAll('.', ',');
    final pezzi = <String>[
      'Il Fisico dai gradi del tuo Sole ($gradi°)',
      'il Cuore dal tuo giorno dell\'anno (${triade.dayOfYear})',
      if (triade.minuteOfDay != null)
        'l\'Intelletto dall\'ora di nascita (${_ora(triade.minuteOfDay!)})',
    ];
    return SchedaDellaScelta(
      caratteristiche: caratteristiche,
      ragione: '${pezzi.join(', ')}.',
      chiave: 'Dalla tradizione dei settantadue nomi, lo Shemhamphorash.',
    );
  }

  /// La prima frase del testo che passa il filtro, oppure nulla.
  static String? _primaFraseAmmessa(String testo) {
    for (final frase in testo.split('. ')) {
      final pulita = frase.trim();
      if (pulita.isEmpty) continue;
      final chiusa = pulita.endsWith('.') ? pulita : '$pulita.';
      if (ammessa(chiusa)) return chiusa;
    }
    return null;
  }

  static String _ora(int minutiDelGiorno) {
    final ore = (minutiDelGiorno ~/ 60).toString().padLeft(2, '0');
    final minuti = (minutiDelGiorno % 60).toString().padLeft(2, '0');
    return '$ore:$minuti';
  }
}
