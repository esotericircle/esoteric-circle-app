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

  test('Il corredo e\' l\'unica porta verso docs/preview', () {
    // Chiunque scriva un\'anteprima fuori da qui crea una seconda porta, e la
    // sua immagine non vedra\' mai la misura reale.
    final fuori = <String>[];
    for (final f in Directory('test').listSync()) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
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
