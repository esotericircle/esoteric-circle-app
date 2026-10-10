import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LA PORTA DELLE CONVERSAZIONI E' UNA. Ordine FE voce 22.16**, prova i)
/// dell'aggiunta del fondatore del 6 ottobre 2026.
///
/// Il fatto, nelle catture del fondatore (docs/collaudo/FE/
/// catture_del_fondatore/): il menu' di Medora mostrava conversazioni del
/// 26, 28 e 29 settembre, e il Diario diceva zero a settembre. Il menu'
/// raccoglieva le conversazioni dai messaggi recenti, il Diario dalle sue
/// righe: due porte, due verita'. Adesso l'elenco delle conversazioni nasce
/// in un punto solo, la lettura dell'indice del Diario
/// (`RegistroDeiRicordi.conversazioniDi`), e il menu' della chat la riceve.
///
/// **Cosa fa cadere la guardia.** Una conversazione del menu' costruita
/// fuori da quella lettura, oppure l'elenco del controllore riempito da
/// un'altra fonte che non sia la lettura del Diario.
void main() {
  String senzaCommenti(String testo) =>
      testo.split('\n').where((r) => !r.trimLeft().startsWith('//')).join('\n');

  test('i) le conversazioni del menu\' nascono solo dalla lettura del Diario',
      () {
    final file = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList();
    cardinaleMinimo(file.length, 500, cosa: 'file di lib');

    // 1. Chi costruisce una conversazione del menu'.
    final costruttori = <String>[];
    var dentroLaLettura = 0;
    for (final f in file) {
      final percorso = f.path.replaceAll('\\', '/');
      if (percorso.endsWith('lib/core/chat/le_conversazioni_passate.dart')) {
        continue;
      }
      final testo = senzaCommenti(f.readAsStringSync());
      for (final m in RegExp(r'ConversazionePassata\(').allMatches(testo)) {
        costruttori.add(percorso);
        // La costruzione deve stare dentro la lettura del Diario: fra
        // `leConversazioniDelDiario:` e la costruzione c'e' la chiamata a
        // `conversazioniDi(`, e nient'altro che legga conversazioni.
        final prima = testo.substring(0, m.start);
        final apertura = prima.lastIndexOf('leConversazioniDelDiario:');
        if (apertura >= 0 &&
            m.start - apertura < 800 &&
            prima.substring(apertura).contains('.conversazioniDi(')) {
          dentroLaLettura++;
        }
      }
    }
    // ignore: avoid_print
    print('FE.22.16 MISURA: conversazioni del menu\' costruite in lib '
        '${costruttori.length}, dentro la lettura del Diario '
        '$dentroLaLettura: $costruttori');
    expect(costruttori, isNotEmpty,
        reason: 'nessuno costruisce le conversazioni del menu\': e\' la '
            'guardia a essere cieca, non il codice');
    expect(dentroLaLettura, costruttori.length,
        reason: 'una conversazione del menu\' nasce fuori dalla lettura del '
            'Diario: $costruttori. E\' la seconda porta che le catture del '
            'fondatore hanno mostrato');

    // 2. Da dove il controllore riempie l'elenco.
    final controllore = senzaCommenti(
        File('lib/features/maestri/chat/maestro_chat_controller.dart')
            .readAsStringSync());
    final passate = RegExp(r'\b_passate\s*=([^;]*);').allMatches(controllore);
    final dalDiario =
        RegExp(r'\b_dalDiario\s*=([^;]*);').allMatches(controllore);
    final fuori = <String>[
      for (final m in passate)
        if (!m.group(1)!.contains('_dalDiario') &&
            m.group(1)!.trim() != 'const []')
          '_passate =${m.group(1)}',
      for (final m in dalDiario)
        if (!m.group(1)!.contains('await leggi()') &&
            !m.group(1)!.contains('_dalDiario') &&
            m.group(1)!.trim() != 'const []')
          '_dalDiario =${m.group(1)}',
    ];
    // ignore: avoid_print
    print('FE.22.16 MISURA: assegnazioni dell\'elenco nel controllore '
        '${passate.length + dalDiario.length}, da un\'altra fonte '
        '${fuori.length}');
    expect(passate.length + dalDiario.length, greaterThanOrEqualTo(3),
        reason: 'il controllore non riempie piu\' l\'elenco come la guardia '
            'si aspetta: va riletta');
    expect(fuori, isEmpty,
        reason: 'l\'elenco del menu\' si riempie da un\'altra fonte: $fuori');
    expect(controllore.contains('LeConversazioniPassate.raccogli'), isFalse,
        reason: 'la raccolta dai messaggi recenti e\' tornata');
  });
}
