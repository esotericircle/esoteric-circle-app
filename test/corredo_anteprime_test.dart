import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// IL CORREDO DELLE ANTEPRIME HA UNA PORTA SOLA, E QUELLA PORTA MISURA 360.
///
/// **Cosa e' successo.** In un giro precedente ho dichiarato "cinquantanove
/// anteprime rigenerate" alla misura reale. Dodici avevano impronta identica a
/// prima, quindi non erano passate dalla misura nuova. Fra queste
/// `le-tue-arti.png`, che misurava ancora 390 per 844.
///
/// **Le tre cause, tutte diverse.**
///
/// 1. Una SECONDA PORTA: `mano_anteprima_test.dart` scriveva dritto in
///    `docs/preview` senza passare dal corredo, quindi la sua anteprima non
///    aveva mai visto la misura reale.
/// 2. Tre anteprime ORFANE, nate da prove temporanee poi cancellate: nessuno le
///    rigenerava piu' e restavano ferme all'ultima volta.
/// 3. Due catture ROTTE che nessuno guardava: da quando il lettore audio reale
///    e' il default, aprire la Meditazione tentava di riprodurre e in prova il
///    plugin non c'e'. La cattura cadeva e la sua anteprima smetteva di
///    aggiornarsi in silenzio.
///
/// E' la settima volta che incontro la stessa forma: **una regola messa in una
/// porta quando le porte sono due non e' una regola**. Per questo la regola sta
/// qui, nel dato, e non in un controllo a mano.
/// Il rapporto che ogni anteprima deve dichiarare.
const double rapportoDichiarato = 3.0;

void main() {
  final corredo = File('test/screenshot_capture_test.dart').readAsStringSync();

  test('La misura reale e\' dichiarata, ed e\' la prima', () {
    expect(corredo.contains('schermoReale = Size(360, 797)'), isTrue,
        reason: 'il corredo non dichiara piu\' la misura del telefono su cui '
            'l\'app viene guardata');
    // Le catture che non dicono altro partono da li'.
    expect(corredo.contains('schermo ?? schermoReale'), isTrue,
        reason: 'le catture non partono piu\' dalla misura reale');
  });

  test('Nessuna cattura resta alla larghezza vecchia', () {
    // La larghezza sbagliata era 390. Se ricompare in una cattura, quella
    // anteprima torna a mentire.
    final colpevoli = <String>[];
    final righe = corredo.split('\n');
    for (var i = 0; i < righe.length; i++) {
      final r = righe[i];
      if (r.trimLeft().startsWith('//')) continue;
      // schermoAlto resta come SECONDA misura del corredo, dichiarata.
      if (r.contains('schermoAlto = Size(390')) continue;
      if (r.contains('Size(390')) colpevoli.add('riga ${i + 1}: ${r.trim()}');
    }
    expect(colpevoli, isEmpty,
        reason: 'queste catture usano ancora la larghezza vecchia, quindi le '
            'loro anteprime non mostrano cio\' che si vede sul telefono:\n'
            '${colpevoli.join("\n")}');
  });

  // IL RAPPORTO DI PIXEL E' UN DATO DICHIARATO, MAI IMPLICITO.
  //
  // **Il dato che ha fatto nascere questa prova.** Il corredo impaginava a
  // rapporto UNO e poi ingrandiva l'immagine tre volte in scrittura: il file
  // usciva della misura giusta, ma dipinto come su un telefono che non esiste.
  // A rapporti diversi cambiano la rasterizzazione dei glifi, i tratti sottili
  // e la diffusione delle ombre, quindi un'anteprima a rapporto piu' basso puo'
  // NASCONDERE esattamente i difetti che il corredo esiste per prendere.
  //
  // E c'era di peggio: dentro il corredo TRENTAQUATTRO punti impostavano la
  // misura dello schermo a mano, molti senza dichiarare nessun rapporto, cioe'
  // prendendosi quello lasciato dall'ultima cattura. Portarne tre a rapporto
  // tre e lasciare gli altri ha prodotto subito un overflow di centoquattro
  // pixel, perche' la misura fisica scritta a mano diventava un terzo di
  // schermo. Il rapporto implicito non e' una pedanteria.
  const eccezioniDelRapporto = <String, String>{
    // L'icona dell'app non e' una schermata: si guarda ingrandita per
    // controllare il tratto, non per giudicare come si legge su un telefono.
    'icona_cerchio_capture_test.dart':
        'e\' l\'icona dell\'app, non una schermata, e si cattura a sei per '
            'vedere il tratto da vicino',
  };

  test('Nessuna cattura ha un rapporto di pixel implicito', () {
    final colpe = <String>[];
    for (final f in Directory('test').listSync()) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final nome =
          f.path.replaceAll(Platform.pathSeparator, '/').split('/').last;
      if (nome == 'corredo_anteprime_test.dart') continue;
      final sorgente = f.readAsStringSync();
      // Solo chi SCRIVE un'anteprima: chi usa toImage per contare pixel non
      // produce un'immagine che qualcuno guardera'.
      if (!sorgente.contains('writeAsBytes')) continue;
      if (eccezioniDelRapporto.containsKey(nome)) continue;

      final rapporti = RegExp(r'devicePixelRatio = ([0-9.]+)')
          .allMatches(sorgente)
          .map((m) => m.group(1)!)
          .toSet();
      if (rapporti.isEmpty) {
        // Un rapporto puo' essere dichiarato anche con una COSTANTE. In quel
        // caso e' dichiarato meglio che con un numero scritto: il corredo fa
        // cosi', e la prova qui sotto verifica che quella costante valga tre.
        // Cercare i soli letterali avrebbe bocciato proprio il file che la
        // regola l'ha applicata per primo.
        if (sorgente.contains('rapportoDelCorredo = ')) continue;
        colpe.add('$nome non dichiara nessun rapporto di pixel');
        continue;
      }
      for (final r in rapporti) {
        if (double.parse(r) != rapportoDichiarato) {
          colpe.add('$nome cattura a rapporto $r invece di '
              '$rapportoDichiarato, senza una riga di eccezione');
        }
      }
      // OGNI MISURA HA IL SUO RAPPORTO ACCANTO, non una per file.
      //
      // Guardando il solo INSIEME dei rapporti dichiarati, un file con cinque
      // catture di cui una sola dichiarava il rapporto passava: le altre
      // quattro si prendevano quello lasciato dall'ultima. La prova del rosso
      // lo ha mostrato togliendo un rapporto da un file che ne aveva due, e
      // restando verde. Qui si contano: tante misure, tanti rapporti.
      final misure =
          RegExp(r'tester\.view\.physicalSize = ').allMatches(sorgente).length;
      final dichiarazioni =
          RegExp(r'tester\.view\.devicePixelRatio = ').allMatches(sorgente).length;
      if (misure != dichiarazioni) {
        colpe.add('$nome imposta $misure misure di schermo ma dichiara '
            '$dichiarazioni rapporti: quelle senza si prendono il rapporto '
            'lasciato dalla cattura precedente');
      }
    }
    expect(
      colpe,
      isEmpty,
      reason: 'il rapporto e\' un dato che sta accanto alla misura: se una '
          'cattura non puo\' stare a tre per una ragione tecnica, non si '
          'abbassa in silenzio, si dichiara qui con la ragione accanto.\n'
          '${colpe.join('\n')}',
    );
  });

  test('Il corredo dichiara il rapporto tre, e in un punto solo', () {
    final corredo =
        File('test/screenshot_capture_test.dart').readAsStringSync();
    expect(corredo.contains('const double rapportoDelCorredo = 3.0;'), isTrue,
        reason: 'il rapporto del corredo non e\' piu\' dichiarato');
    // UNA porta sola: se qualcuno rimette un devicePixelRatio a mano, e' un
    // secondo rapporto che puo' divergere dal primo.
    expect(RegExp(r'devicePixelRatio = ').allMatches(corredo).length, 1,
        reason: 'il rapporto si imposta in un punto solo, `montaLoSchermo`');
  });

  test('Il corredo e\' l\'unica porta verso docs/preview', () {
    // Chiunque scriva un\'anteprima fuori da qui crea una seconda porta, e la
    // sua immagine non vedra\' mai la misura reale.
    // UNA SOLA ECCEZIONE, dichiarata: le catture PRIMA e DOPO. Non sono
    // anteprime del corredo, sono la prova visiva di una singola correzione:
    // vivono in `docs/preview/prima_dopo/`, si generano due volte sullo stesso
    // stato con il codice riportato indietro, e non descrivono l'app di oggi.
    // Farle passare dal corredo vorrebbe dire rigenerarle a ogni giro, e la
    // "prima" sparirebbe al primo aggiornamento.
    const eccezioni = {
      'prima_dopo_capture_test.dart',
      // Stessa natura: e' il prima e dopo dell'icona del Cerchio, non
      // un'anteprima dell'app, e la "prima" mostra un'icona che non esiste
      // piu'. Rigenerarla dal corredo la cancellerebbe.
      'icona_cerchio_capture_test.dart',
      // Stessa natura: sono le immagini che l'ordine E ha chiesto per far
      // vedere le sue correzioni, e restano fuori dal corredo perche' mostrano
      // uno stato passato, non l'app di oggi.
      //
      // Qui c'era scritta una DIVERGENZA, ed e' chiusa dal 3 agosto 2026: le
      // catture dell'ordine chiedevano 360 per 797 a rapporto 3, il corredo
      // impaginava a rapporto 1 e ingrandiva in scrittura. Adesso il rapporto
      // e' 3 da entrambe le parti, ed e' lo stesso numero, non due numeri
      // uguali per caso.
      'anteprime_ordine_e_test.dart',
    };
    final fuori = <String>[];
    for (final f in Directory('test').listSync()) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      if (eccezioni.any((e) => f.path.endsWith(e))) continue;
      final nome = f.path.replaceAll(Platform.pathSeparator, '/');
      if (nome.endsWith('screenshot_capture_test.dart')) continue;
      if (nome.endsWith('preview_integrity_test.dart')) continue;
      if (nome.endsWith('corredo_anteprime_test.dart')) continue;
      final t = f.readAsLinesSync()
          .where((r) => !r.trimLeft().startsWith('//'))
          .join('\n');
      if (t.contains("docs/preview")) fuori.add(nome);
    }
    expect(fuori, isEmpty,
        reason: 'questi file scrivono anteprime fuori dal corredo: '
            '${fuori.join(", ")}');
  });

  test('Ogni anteprima del repo ha un generatore', () {
    // Un\'anteprima orfana resta ferma all\'ultima volta che qualcuno l\'ha
    // prodotta, e nessuno se ne accorge finche\' non la guarda.
    final orfane = <String>[];
    for (final f in Directory('docs/preview').listSync()) {
      if (f is! File || !f.path.endsWith('.png')) continue;
      final nome = f.uri.pathSegments.last;
      if (corredo.contains(nome)) continue;
      // Diverse catture compongono il nome a runtime: il Maestro davanti, la
      // variante di altezza in coda. Si riconosce la radice.
      final radice = nome
          .replaceFirst(RegExp(r'^(medora|aura|caligo)-'), '')
          .replaceFirst(RegExp(r'-(medora|aura|caligo)'), '')
          .replaceFirst(RegExp(r'-\d{4}\.png$'), '.png')
          .replaceFirst('.png', '');
      if (corredo.contains(radice)) continue;
      orfane.add(nome);
    }
    expect(orfane, isEmpty,
        reason: 'queste anteprime non le rigenera nessuno, quindi mostrano uno '
            'stato vecchio: ${orfane.join(", ")}');
  });
}
