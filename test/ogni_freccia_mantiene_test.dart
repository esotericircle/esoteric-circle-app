import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// OGNI FRECCIA IN GIU' MANTIENE CIO' CHE PROMETTE.
///
/// **La regola, in una riga.** Una freccia in giu' significa "qui sotto c'e'
/// altro testo, te lo mostro" e nient'altro. Se un comando rigenera o naviga
/// non puo' portare quell'icona. Se una freccia non e' toccabile non e' una
/// freccia, e' decorazione, e la decorazione che somiglia a un comando e'
/// peggio di nessun comando.
///
/// **Perche' si ENUMERA invece di provarne una.** Il difetto trovato dal
/// fondatore era su "Vai piu' a fondo", ma non era il solo: nel chip che apre
/// il pannello dei tarocchi la stessa icona apriva un foglio, cioe' navigava.
/// Una prova che guarda un punto trova un punto. Questa scandisce tutto `lib`,
/// e ogni deroga sta scritta qui sotto col suo motivo, in chiaro.
void main() {
  /// LA FAMIGLIA DELLE FRECCE IN GIU', cioe' le icone su cui vale la regola.
  ///
  /// Il triangolo pieno `arrow_drop_down` NON e' in questa lista, ed e' una
  /// scelta dichiarata: e' l'affordance universale del selettore, un'altra
  /// forma e un altro significato, e chi la tocca non si aspetta del testo,
  /// si aspetta delle scelte. Se un giorno si volesse una regola anche su
  /// quella, va scritta qui, non lasciata a intuito.
  const frecceInGiu = [
    'Icons.expand_more',
    'Icons.expand_more_rounded',
    'Icons.arrow_downward',
    'Icons.arrow_downward_rounded',
    'Icons.keyboard_arrow_down',
    'Icons.keyboard_arrow_down_rounded',
    'Icons.expand_circle_down',
    'Icons.expand_circle_down_rounded',
  ];

  /// I PUNTI DOVE UNA FRECCIA IN GIU' STA, e cosa fa quando la si tocca.
  ///
  /// Ogni riga e' un impegno: sta qui perche' qualcuno e' andato a guardare
  /// cosa fa il tocco. Una freccia nuova che non compare in questa mappa fa
  /// cadere la prova, ed e' il punto: la deroga si scrive, non si presume.
  const dichiarate = <String, String>{
    'lib/design_system/components/collasso.dart':
        'la freccetta del Collassabile: gira di mezzo giro e apre il '
            'contenuto che sta sotto, in posto. E\' la freccia in giu\' fatta '
            'bene, ed e\' il modello di tutte le altre.',
    'lib/features/identity/circle_seal_screen.dart':
        '"Cosa significa" nel Sigillo: InkWell con chiave seal_meaning_toggle, '
            'apre il pannello del significato sotto la riga, in posto.',
    'lib/features/maestri/chat/widgets/chat_bubble.dart':
        '"Vai piu\' a fondo": dal 4 agosto 2026 rivela il secondo strato di '
            'una lettura GIA\' SCRITTA. Prima buttava la risposta e ne '
            'chiedeva un\'altra al Maestro, ed e\' il difetto che ha fatto '
            'nascere questa prova.',
    'lib/features/rituals/ritual_gift_card.dart':
        'il dono del rituale: expand_less quando e\' aperto, expand_more '
            'quando e\' chiuso, e apre il testo in posto.',
  };

  test('Ogni freccia in giu\' del progetto e\' dichiarata', () {
    final trovate = <String, List<int>>{};
    for (final voce in Directory('lib').listSync(recursive: true)) {
      if (voce is! File || !voce.path.endsWith('.dart')) continue;
      final percorso = voce.path.replaceAll(Platform.pathSeparator, '/');
      final righe = voce.readAsLinesSync();
      for (var i = 0; i < righe.length; i++) {
        final riga = righe[i];
        // I commenti nominano le icone per spiegarle: non sono frecce a
        // schermo, e contarle vorrebbe dire non poterne piu' parlare.
        if (riga.trimLeft().startsWith('//')) continue;
        if (!frecceInGiu.any(riga.contains)) continue;
        (trovate[percorso] ??= []).add(i + 1);
      }
    }

    final nonDichiarate = trovate.keys
        .where((p) => !dichiarate.containsKey(p))
        .toList(growable: false)
      ..sort();
    expect(nonDichiarate, isEmpty,
        reason: 'c\'e\' una freccia in giu\' che nessuno ha dichiarato:\n'
            '${nonDichiarate.map((p) => '$p righe ${trovate[p]}').join("\n")}\n'
            'Una freccia in giu\' promette "qui sotto c\'e\' altro testo, te '
            'lo mostro". Se questo comando rigenera o naviga, cambia l\'icona; '
            'se non e\' toccabile, toglila; se invece rivela davvero, '
            'aggiungila alla mappa scrivendo cosa fa al tocco.');

    // E NESSUNA DICHIARAZIONE RESTA APPESA A UN PUNTO CHE NON ESISTE PIU'.
    //
    // Senza questa riga la mappa diventerebbe un archivio di deroghe per
    // frecce tolte da mesi, e la prossima freccia sbagliata potrebbe finire
    // in un file gia' scusato.
    final sparite = dichiarate.keys
        .where((p) => !trovate.containsKey(p))
        .toList(growable: false)
      ..sort();
    expect(sparite, isEmpty,
        reason: 'queste deroghe non hanno piu\' una freccia da scusare:\n'
            '${sparite.join("\n")}');
  });

  /// GLI ANTENATI DI UNA RIGA, cioe' i widget che la contengono davvero.
  ///
  /// **Perche' non basta guardarle intorno.** La prima stesura leggeva venti
  /// righe sopra e venti sotto, e una prova del rosso l'ha smentita: togliendo
  /// il `GestureDetector` da "Vai piu' a fondo" la prova restava verde, perche'
  /// sei righe piu' su c'era l'`onTap` di un ALTRO pulsante. Vicinanza non e'
  /// contenimento, e in un `build` denso i comandi si toccano.
  ///
  /// Qui si risale per rientro: da una riga, l'antenato e' la prima riga sopra
  /// con un rientro minore, e cosi' via. E' esattamente l'annidamento che il
  /// Dart formattato mette a schermo.
  List<String> antenatiDi(List<String> righe, int indice) {
    int rientro(String r) => r.length - r.trimLeft().length;
    final catena = <String>[];
    var soglia = rientro(righe[indice]);
    for (var i = indice - 1; i >= 0 && catena.length < 6; i--) {
      final r = righe[i];
      if (r.trim().isEmpty || r.trimLeft().startsWith('//')) continue;
      final q = rientro(r);
      if (q >= soglia) continue;
      catena.add(r);
      soglia = q;
    }
    return catena;
  }

  test('Nessuna freccia in giu\' e\' senza un tocco che la raggiunge', () {
    // **TOCCABILE VUOL DIRE CHE UN GESTO LA CONTIENE**, non che ce ne sia uno
    // li' vicino. Si risale la catena degli antenati e si guarda se uno di
    // loro e' il gesto.
    const gesti = [
      'onTap', 'onPressed', 'GestureDetector', 'InkWell', 'IconButton',
      'onToggle', 'TextButton', 'FilledButton', 'onSelected',
    ];
    // **UN SOLO PUNTO NON PORTA IL SUO TOCCO, e non e' una deroga: e' uno
    // spostamento della regola.** `FreccettaDelCollasso` e' il pezzo condiviso
    // che disegna la freccetta, e il gesto e' di chi la mette in pagina. Qui
    // dentro un `onTap` non ci sarebbe mai. Quindi al posto suo si sorvegliano
    // i suoi TRE punti d'uso, poche righe piu' sotto: la regola copre piu'
    // codice di prima, non meno.
    const pezzoCondiviso = 'lib/design_system/components/collasso.dart';

    /// LE RIGHE COMPOSTE IN UNA VARIABILE, dove il gesto arriva DOPO.
    ///
    /// **Non e' un difetto, e' un limite di chi legge il codice come testo.**
    /// In `maestro_screen` la riga dell'intestazione si compone in una
    /// variabile `riga` e solo piu' sotto viene avvolta in un `InkWell`: il
    /// gesto non e' un antenato per rientro, e' un consumatore. Risalire i
    /// rientri non lo puo' vedere.
    ///
    /// La deroga non e' un permesso: chiede la CHIAVE del gesto che avvolge, e
    /// la prova va a controllare che quella chiave nel file ci sia ancora. Se
    /// qualcuno toglie l'InkWell, la deroga cade con lui.
    const composteInUnaVariabile = <String, String>{
      'FreccettaDelCollasso(aperto: open, color: palette.goldSoft)':
          'art_section_header_',
    };

    final nude = <String>[];
    for (final voce in Directory('lib').listSync(recursive: true)) {
      if (voce is! File || !voce.path.endsWith('.dart')) continue;
      final percorso = voce.path.replaceAll(Platform.pathSeparator, '/');
      if (percorso == pezzoCondiviso) continue;
      final righe = voce.readAsLinesSync();
      for (var i = 0; i < righe.length; i++) {
        if (righe[i].trimLeft().startsWith('//')) continue;
        if (!frecceInGiu.any(righe[i].contains)) continue;
        if (gesti.any(antenatiDi(righe, i).join('\n').contains)) continue;
        if (_scusata(composteInUnaVariabile, righe, i)) continue;
        nude.add('$percorso riga ${i + 1}: ${righe[i].trim()}');
      }
    }
    expect(nude, isEmpty,
        reason: 'queste frecce non sono toccabili, quindi non sono frecce, '
            'sono decorazione:\n${nude.join("\n")}');

    // I PUNTI D'USO DEL PEZZO CONDIVISO, uno per uno.
    final senzaGesto = <String>[];
    var usi = 0;
    for (final voce in Directory('lib').listSync(recursive: true)) {
      if (voce is! File || !voce.path.endsWith('.dart')) continue;
      final percorso = voce.path.replaceAll(Platform.pathSeparator, '/');
      if (percorso == pezzoCondiviso) continue;
      final righe = voce.readAsLinesSync();
      for (var i = 0; i < righe.length; i++) {
        if (righe[i].trimLeft().startsWith('//')) continue;
        if (!righe[i].contains('FreccettaDelCollasso(')) continue;
        usi++;
        if (gesti.any(antenatiDi(righe, i).join('\n').contains)) continue;
        if (_scusata(composteInUnaVariabile, righe, i)) continue;
        senzaGesto.add('$percorso riga ${i + 1}');
      }
    }
    // Senza questa riga, togliendo tutti gli usi la prova resterebbe verde
    // avendo controllato zero cose.
    expect(usi, greaterThan(0),
        reason: 'nessuno usa piu\' la freccetta condivisa: o e\' morta, e va '
            'tolta, oppure questa prova non guarda piu\' niente');
    expect(senzaGesto, isEmpty,
        reason: 'la freccetta condivisa e\' messa in pagina senza un gesto '
            'che la raggiunga:\n${senzaGesto.join("\n")}');
  });
}

/// Vero quando la riga porta un frammento dichiarato, E la chiave del gesto che
/// la avvolge e' ancora nel file. La deroga non e' un permesso, e' un fatto da
/// verificare a ogni giro.
bool _scusata(Map<String, String> deroghe, List<String> righe, int i) {
  // Si guarda anche la riga sopra e sotto: il frammento puo' stare spezzato su
  // piu' righe dal formattatore.
  final da = (i - 1).clamp(0, righe.length - 1);
  final a = (i + 2).clamp(0, righe.length);
  final intorno = righe.sublist(da, a).join(' ').replaceAll(RegExp(r'\s+'), ' ');
  final tutto = righe.join('\n');
  for (final voce in deroghe.entries) {
    if (intorno.contains(voce.key) && tutto.contains(voce.value)) return true;
  }
  return false;
}
