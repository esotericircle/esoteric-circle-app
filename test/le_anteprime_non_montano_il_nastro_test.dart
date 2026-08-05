import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// NESSUNA ANTEPRIMA MOSTRA IL NASTRO DI DEBUG.
///
/// **Come e' sfuggito.** Il 6 agosto 2026 l'anteprima della chat di Aura e'
/// uscita col nastro rosso in alto a destra, e ci e' voluto l'occhio del
/// fondatore per vederlo. L'app vera lo spegne una volta sola, in
/// `lib/app.dart`, quindi ogni cattura che monta l'app non lo mostra mai; ma
/// una cattura che si costruisce un `MaterialApp` per conto suo se lo riprende,
/// perche' quello e' il comportamento predefinito di Flutter.
///
/// **Non era un caso isolato.** Cercandolo, il nastro era acceso in **cinque**
/// altre catture gia' nel repo, tutte quelle che costruiscono la scena a mano.
/// Chi le guardava vedeva un fotogramma che l'app non produce, e nessuno lo
/// aveva notato.
///
/// **Perche' una prova strutturale e non una sui pixel.** Il nastro si dipinge
/// solo in debug e in un punto che dipende dalla direzione del testo: cercarlo
/// nei pixel sarebbe fragile. Qui si guarda la causa invece dell'effetto, cioe'
/// il `MaterialApp` che non lo spegne, e la causa e' una sola.
void main() {
  /// I file che generano il corredo di anteprime.
  const generatori = [
    'test/screenshot_capture_test.dart',
    'test/prima_dopo_capture_test.dart',
  ];

  /// Il corpo bilanciato di una costruzione, dalla parentesi aperta alla sua.
  String corpoDi(String sorgente, int daQui) {
    var profondita = 1;
    var i = daQui;
    while (i < sorgente.length && profondita > 0) {
      final c = sorgente[i];
      if (c == '(') profondita++;
      if (c == ')') profondita--;
      i++;
    }
    return sorgente.substring(daQui, i);
  }

  test('nessuna cattura del corredo monta un MaterialApp col nastro acceso',
      () {
    final colpevoli = <String>[];

    for (final percorso in generatori) {
      final file = File(percorso);
      if (!file.existsSync()) continue;
      final sorgente = file.readAsStringSync();

      for (final m in RegExp(r'MaterialApp\(').allMatches(sorgente)) {
        final corpo = corpoDi(sorgente, m.end);
        if (corpo.contains('debugShowCheckedModeBanner: false')) continue;
        final riga = '\n'.allMatches(sorgente.substring(0, m.start)).length + 1;
        colpevoli.add('$percorso riga $riga');
      }
    }

    expect(colpevoli, isEmpty,
        reason: 'queste catture montano un MaterialApp che non spegne il '
            'nastro di debug, quindi producono un\'anteprima che l\'app non '
            'produce: $colpevoli');
  });

  test('l\'app vera lo spegne, e lo spegne in un punto solo', () {
    // Se un giorno sparisse di li', tutte le catture che montano l'app
    // tornerebbero a mostrarlo insieme, e questa prova non se ne accorgerebbe
    // guardando solo il corredo.
    final app = File('lib/app.dart').readAsStringSync();
    expect(app, contains('debugShowCheckedModeBanner: false'),
        reason: 'l\'app vera ha smesso di spegnere il nastro');

    final quanti =
        RegExp('debugShowCheckedModeBanner').allMatches(app).length;
    expect(quanti, 1,
        reason: 'l\'app dichiara il nastro in piu\' di un punto: $quanti');
  });
}
