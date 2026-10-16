// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'giudici_ej.dart';
import 'la_voce_vera_di_gemini.dart';

/// **L'ITALIANO PRIMA E DOPO, CON LO STESSO GIUDICE.** Ordine EJ voce 08, 24
/// settembre 2026.
///
/// Il giudice severo della grammatica e' nato dopo il primo giro del
/// collaudo, quindi le trascrizioni del prima non erano mai passate da lui.
/// Qui le si rilegge tutte, fase per fase, con lo stesso giudice e la stessa
/// taratura, e si scrive `docs/collaudo/EJ/risposte/_grammatica.txt`.
///
/// ```
/// flutter test tool/grammatica_ej.dart
/// ```
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final voce = VoceVeraDiGemini();
  final uscita = StringBuffer();

  setUpAll(() => HttpOverrides.global = null);

  final radice = Directory('docs/collaudo/EJ/risposte');
  for (final cartella in radice.listSync().whereType<Directory>().toList()
    ..sort((a, b) => a.path.compareTo(b.path))) {
    final fase = cartella.uri.pathSegments.where((s) => s.isNotEmpty).last;
    test('grammatica della fase $fase', () async {
      for (final f in cartella.listSync().whereType<File>().toList()
        ..sort((a, b) => a.path.compareTo(b.path))) {
        if (!f.path.endsWith('.md')) continue;
        final scambi = scambiDa(f);
        final errori = <String>[];
        for (final s in scambi) {
          errori.addAll(await erroriDiGrammatica(voce, s.letta.intera));
        }
        final maestro = f.uri.pathSegments.last.replaceAll('.md', '');
        final riga = 'GRAMMATICA $fase $maestro: risposte ${scambi.length}, '
            'errori ${errori.length} ${errori.join(' | ')}';
        print(riga);
        uscita.writeln(riga);
        expect(scambi, hasLength(6),
            reason: 'la trascrizione $f non ha sei scambi');
      }
    }, timeout: const Timeout(Duration(minutes: 10)));
  }

  tearDownAll(() {
    uscita.writeln('Domande al giudice: ${voce.giudizi}.');
    File('docs/collaudo/EJ/risposte/_grammatica.txt')
        .writeAsStringSync(uscita.toString());
  });
}
