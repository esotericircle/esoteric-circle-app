// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/chat/il_filo_del_consulto.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/tarot/la_lettura_dal_modello.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread_type.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:flutter_test/flutter_test.dart';

import 'la_voce_vera_di_gemini.dart';

/// **LA CROCE CELTICA ALLA PROFONDITA' LUNGA, COL MODELLO VERO.** Ordine FS,
/// 13 ottobre 2026.
///
/// Il fondatore, sulla build 2308: la profondita' Lunga non porta i due
/// paragrafi arancioni. La lettura ha una pazienza fissa
/// (`LaLetturaDellaStesa.pazienza`): se il modello non risponde entro quel
/// tempo, parla la lettura di casa, che i due paragrafi non li ha. Qui si
/// misura quanto ci mette il modello su dieci carte, con lo stesso tetto di
/// gettoni dell'app, e se i due paragrafi arrivano.
///
/// ```
/// flutter test -r expanded tool/collaudo_croce_celtica_lunga.dart
/// ```
const letture = [
  (
    argomento: TarotTopic.momentoCheVivo,
    scritta: 'Quando diventerò padre?',
    seme: 501
  ),
  (
    argomento: TarotTopic.momentoCheVivo,
    scritta: 'Devo cambiare lavoro quest\'anno?',
    seme: 502
  ),
];

void main() {
  test('FS: la Croce Celtica alla Lunga dal modello vero', () async {
    HttpOverrides.global = null;
    final voce = VoceVeraDiGemini();
    final righe = <String>[
      'LA CROCE CELTICA ALLA PROFONDITA\' LUNGA, ordine FS',
      'Modello: ${LaLetturaDellaStesa.modello}, regione europe-west1, '
          '${DateTime.now().toUtc().toIso8601String()}',
      'Pazienza dell\'app: ${LaLetturaDellaStesa.pazienza.inSeconds} s',
      '',
    ];
    for (final d in letture) {
      for (final profonda in const [false, true]) {
        IlFiloDelConsulto.dimentica();
        final spread = TarotSpread.draw(
            seed: d.seme, posizioni: TarotSpreadType.dieciCarte.posizioni);
        final campi = LaLetturaDellaStesa.campiPer(spread, profonda: profonda);
        final tetto =
            LaLetturaDellaStesa.tettoDeiGettoni(campi, profonda: profonda);
        final tempi = <int>[];
        final orologio = Stopwatch()..start();
        final l = await LaLetturaDellaStesa.leggi(
          spread: spread,
          domanda: d.scritta,
          argomento: d.argomento.label,
          forma: CourtesyForm.neutral,
          profonda: profonda,
          chiamata: (istruzione, richiesta, c) async {
            final s = Stopwatch()..start();
            final esito = await voce.genera(
              istruzione: istruzione,
              richiesta: richiesta,
              campi: c.keys.toList(),
              modello: LaLetturaDellaStesa.modello,
              tetto: tetto,
            );
            tempi.add(s.elapsedMilliseconds);
            return esito.testo;
          },
        );
        final totale = orologio.elapsedMilliseconds;
        righe
          ..add('== seme ${d.seme}, ${profonda ? 'LUNGA' : 'BREVE'}, '
              'tetto $tetto gettoni')
          ..add('  chiamate al modello: ${tempi.length}, tempi ms $tempi, '
              'totale ms $totale')
          ..add(
              '  esito: ${l == null ? 'LETTURA DI CASA (${LaLetturaDellaStesa.ultimiScarti.join(' | ')})' : 'dal modello'}');
        if (l != null && profonda) {
          // Ordine GA: un approfondimento solo, misurato in parole.
          righe.add('  approfondimento (${l.approfondimento.split(' ').length} '
              'parole): ${l.approfondimento}');
        }
        righe.add('');
      }
    }
    final testo = righe.join('\n');
    print(testo);
    Directory('docs/collaudo/FS').createSync(recursive: true);
    File('docs/collaudo/FS/la_croce_celtica_lunga.txt')
        .writeAsStringSync('$testo\n');
  }, timeout: const Timeout(Duration(minutes: 10)));
}
