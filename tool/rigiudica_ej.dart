// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'controlli_ej.dart';
import 'giudici_ej.dart';
import 'la_voce_vera_di_gemini.dart';

/// **IL PRIMA E IL DOPO CON LO STESSO METRO.** Ordine EJ voci 05 e 06, 24
/// settembre 2026.
///
/// I giudici della risposta diretta e del passo sono stati rifatti dopo il
/// primo giro, perche' oscillavano. Le trascrizioni di ogni fase sono salvate
/// in `docs/collaudo/EJ/risposte/<fase>/`, e qui si rigiudicano tutte con
/// gli stessi giudici: il confronto fra prima e dopo e' onesto solo se lo
/// strumento e' lo stesso.
///
/// ```
/// flutter test tool/rigiudica_ej.dart
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
    test('rigiudizio della fase $fase', () async {
      for (final f in cartella.listSync().whereType<File>().toList()
        ..sort((a, b) => a.path.compareTo(b.path))) {
        if (!f.path.endsWith('.md')) continue;
        final scambi = scambiDa(f);
        var indirette = 0;
        var senzaPasso = 0;
        for (final s in scambi) {
          if (!await giudicaDiretta(voce, s.domanda, s.letta.intera)) {
            indirette++;
          }
          if (!await giudicaPasso(voce, s.letta.intera)) senzaPasso++;
        }
        final nome = f.uri.pathSegments.last.replaceAll('.md', '');
        final lette = [for (final s in scambi) s.letta];
        final vietate =
            lette.fold<int>(0, (a, l) => a + frasiVietate(l).length);
        final anticipate =
            lette.fold<int>(0, (a, l) => a + anticipazioni(l).length);
        final regole =
            lette.fold<int>(0, (a, l) => a + erroriDiRegola(l).length);
        final riga = 'RIGIUDIZIO $fase $nome: risposte ${scambi.length}, '
            'chiusure ripetute ${chiusureRipetute(lette)}, frasi vietate '
            '$vietate, dati ripetuti ${datiRipetuti(lette, datiDellaPersona)}, '
            'anticipazioni $anticipate, errori di regola $regole, '
            'non dirette $indirette, senza passo concreto $senzaPasso';
        print(riga);
        uscita.writeln(riga);
      }
    }, timeout: const Timeout(Duration(minutes: 10)));
  }

  tearDownAll(() {
    uscita.writeln('Domande al giudice: ${voce.giudizi}, ragionamento '
        '$ragionamentoDelGiudice gettoni ciascuna.');
    File('${radice.path}/_rigiudizio.txt').writeAsStringSync(uscita.toString());
  });
}
