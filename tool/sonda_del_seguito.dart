// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/services/ai/registro_dei_guasti.dart';
import 'package:esoteric_circle/services/ai/voce_sorvegliata.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'la_voce_vera_di_gemini.dart';

/// **LA SONDA DEL SEGUITO.** Ordine EQ, 27 settembre 2026.
///
/// Sul Realme "Vai più a fondo" non faceva niente, tre tocchi su tre. Qui il
/// controller vero chiede il seguito al modello vero, dopo le domande delle
/// catture, e si guarda che cosa ne resta: il grezzo, il pulito, e se la
/// bolla ha davvero il seguito.
///
/// Si lancia con `flutter test tool/sonda_del_seguito.dart -r expanded`; la
/// cartella d'uscita si sceglie con `SONDA_SEGUITO` (predefinita
/// `docs/collaudo/EQ/seguito/sonda_prima`).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Il binding delle prove finge ogni chiamata HTTP con un 400: la sonda
  // parla al modello vero.
  setUpAll(() => HttpOverrides.global = null);
  final cartella = Directory(Platform.environment['SONDA_SEGUITO'] ??
      'docs/collaudo/EQ/seguito/sonda_prima');
  const domande = [
    'Ciao, chi sei? Come puoi aiutarmi?',
    'Beh, vorrei avere una compagna, vorrei andare in Australia e vorrei un '
        'lavoro nuovo. Da dove comincio?',
    'Il mio capo non mi dà mai un riconoscimento. Cosa faccio?',
  ];
  final conto = StringBuffer();

  for (final maestro in Maestro.values) {
    test('il seguito di ${maestro.id}', () async {
      final voce = VoceVeraDiGemini();
      await voce.scaldaIlGettone();
      final registro = RegistroDeiGuasti();
      final controller = MaestroChatController(
        maestro: maestro,
        ai: VoceSorvegliata(voce: voce, registro: registro),
        natal: () => const NatalContext(
          sunSign: 'Cancro',
          ascendant: 'Gemelli',
          lifeNumber: 3,
          lifeNumberTitle: 'il Creativo',
        ),
        memory: InMemoryMaestroMemoryRepository(),
        attesaMinima: Duration.zero,
      );
      await controller.init();
      final righe = StringBuffer('# Il seguito di ${maestro.id}\n\n');
      var arrivati = 0;
      var chiesti = 0;
      for (final d in domande) {
        await controller.send(d);
        if (!controller.puoiChiedereDiApprofondire) {
          final u = controller.messages.last;
          righe.writeln('## $d\n\n(nessun "Vai più a fondo" sotto questa '
              'risposta: maestro ${u.isMaestro}, in attesa ${u.pending}, '
              'responso ${u.portaUnResponso}, tipo ${u.tipo})\n\n${u.text}\n');
          continue;
        }
        chiesti++;
        final quante = voce.grezze.length;
        await controller.approfondisci();
        final grezzo = voce.grezze.length > quante
            ? voce.grezze.last.testo
            : '(nessuna chiamata tornata)';
        final ultima = controller.messages.last;
        final seguito = ultima.seguito ?? '';
        if (seguito.trim().isNotEmpty) arrivati++;
        righe
          ..writeln('## $d\n')
          ..writeln('RISPOSTA:\n${ultima.text}\n')
          ..writeln('SEGUITO GREZZO:\n$grezzo\n')
          ..writeln('SEGUITO MOSTRATO:\n'
              '${seguito.trim().isEmpty ? '(niente: il tocco non fa niente)' : seguito}\n');
      }
      for (final g in registro.guasti) {
        print('GUASTO ${g.riga.replaceAll('\n', ' ')}');
      }
      final riga = 'SEGUITO ${maestro.id}: arrivati $arrivati su $chiesti '
          'tocchi, frasi ripetute tolte ${controller.frasiRipetuteNelSeguito}';
      print(riga);
      conto.writeln(riga);
      cartella.createSync(recursive: true);
      File('${cartella.path}/${maestro.id}.md')
          .writeAsStringSync(righe.toString());
    }, timeout: const Timeout(Duration(minutes: 5)));
  }

  tearDownAll(() {
    cartella.createSync(recursive: true);
    File('${cartella.path}/_conto.txt').writeAsStringSync(conto.toString());
  });
}
