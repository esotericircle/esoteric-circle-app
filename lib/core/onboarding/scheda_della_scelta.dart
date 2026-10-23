import '../angels/guardian_angels.dart';
import '../rituals/animal_catalog.dart';
import '../rituals/guide_animal_corpus.dart';
import '../l10n/numero_del_cerchio.dart';

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
  /// dono, lezione: si prendono le prime due che passano il filtro.
  ///
  /// **LA RAGIONE NON NOMINA PIU' UN SEGNO, ordine FZ voce 01 e 02, 17
  /// ottobre 2026.** Qui c'era *"Il tuo Sole in [segno] elegge [animale]"*,
  /// letta da `GuideAnimalDerivation.signOf`: era vera finche' l'animale
  /// nasceva dal segno solare. Non lo e' piu': l'animale si rivela seguendo
  /// le ombre nel Viaggio dello Sciamano, non da nessun elemento della carta
  /// natale, e questo generatore esiste apposta per nominare "l'elemento
  /// della carta natale che ha eletto" (vedi la nota di classe). Per
  /// l'animale quell'elemento non c'e' piu': [ragione] torna nulla, e la
  /// riga sparisce com'e' previsto per i dati assenti, invece di dire una
  /// cosa falsa. **Nota per chi tiene lo stato**: questo metodo non e'
  /// agganciato da nessuna schermata vera oggi (`trionfi_screen.dart` chiama
  /// solo `perAngeli`); il controllo l'ha fatto questo stesso ordine.
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

    return SchedaDellaScelta(
      caratteristiche: caratteristiche,
      ragione: null,
      // **LA CHIAVE, DOPO FZ: NON PIU' UN PONTE COL CIELO.** Qui c'era *"un
      // ponte di curatela col tuo cielo, non un responso della tradizione
      // sciamanica"*: era l'onesta' dovuta a una derivazione dal segno che
      // la tradizione di Harner non prevede. Dall'ordine FZ la regola e'
      // quella vera di Harner (le quattro apparizioni), e dirle "non tua
      // tradizione" sarebbe adesso il disclaimer sbagliato.
      chiave: 'Chiave di lettura di Caligo: la regola delle quattro '
          'apparizioni di Michael Harner, messa in scena dal Viaggio dello '
          'Sciamano.',
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

    // I gradi col separatore della lingua che si sta leggendo. Ordine
    // DM voce 03: qui c'era una virgola messa a mano, giusta in
    // italiano e sbagliata in ogni altra lingua.
    final gradi = NumeroDelCerchio.conCifre(triade.sunLongitude, 1);
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
