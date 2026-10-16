import 'dart:io';

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/maestri/live/stato_della_schermata_live.dart';
import 'package:esoteric_circle/services/live/porta_del_live.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA VOCE CHE NON PARTE: SI CONTINUA PER ISCRITTO. Ordine FE voce 07.**
///
/// Quando il LIVE si apre ma la voce non riesce a partire, la persona legge
/// *"La voce non riesce a raggiungerti. Continuo a scriverti."* e il tempo
/// senza voce non si scala dai minuti. La schermata parla con LiveKit e
/// Protoface, che al banco non ci sono: qui si prova la forma del codice nei
/// tre punti dove la voce puo' mancare, e la frase. Il conto senza voce lo
/// prova il server (`functions/src/live.test.ts`, FE.07).
void main() {
  final schermata = File('lib/features/maestri/live/schermata_live.dart')
      .readAsStringSync()
      .replaceAll('\r\n', '\n');

  test('la frase della voce che non parte è quella dell\'ordine', () {
    expect(
      const QuadroDelLive(
        momento: MomentoDelLive.nonSiApre,
        maestro: Maestro.medora,
        perche: PerchePerILiveNonSiApre.vocePerduta,
      ).laFraseDelRifiuto(),
      'La voce non riesce a raggiungerti. Continuo a scriverti.',
    );
  });

  test('il volto che non arriva chiude senza scalare i minuti', () {
    final i = schermata.indexOf("StateError('nessun \${s.lavoratore} in 20 "
        "secondi')");
    expect(i, greaterThan(0));
    final dopo = schermata.substring(i, i + 200);
    expect(dopo, contains('await _laVoceNonParte(senzaVoce: true);'));
  });

  test('il saluto che non si sente chiude senza scalare i minuti', () {
    expect(
        schermata,
        contains('if (!sentito) {\n'
            '        await _laVoceNonParte(senzaVoce: true);'));
  });

  test('a meta\' consulto la voce persa porta alla forma scritta', () {
    expect(schermata,
        contains('if (!await _dillo(risposta.text, conAttesa: true)) {'));
    expect(schermata, contains('await _laVoceNonParte(senzaVoce: false);'));
  });

  test('la chiusura senza voce porta il segno al server', () {
    expect(schermata,
        contains('unawaited(PortaDelLive.chiudi(id, senzaVoce: senzaVoce));'));
    final porta =
        File('lib/services/live/porta_del_live.dart').readAsStringSync();
    expect(porta, contains("if (senzaVoce) 'senzaVoce': true,"));
    expect(schermata, contains('return primoSuono != null;'));
  });
}
