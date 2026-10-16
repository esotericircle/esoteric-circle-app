// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/chat/il_filo_del_consulto.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/tarot/i_mazzi_dei_tarocchi.dart';
import 'package:esoteric_circle/core/tarot/la_lettura_dal_modello.dart';
import 'package:esoteric_circle/core/tarot/tarot_reading.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread_type.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:flutter_test/flutter_test.dart';

import 'la_voce_vera_di_gemini.dart';

/// **IL TITOLO DAL MODELLO, LETTO DAVVERO.** Ordine FK, aggiunta voci A1 e
/// A2, 11 ottobre 2026.
///
/// Il Protocollo della chiusura: *"dove il risultato lo scrive un modello, la
/// prova e' la risposta vera"*, e i testi generati si misurano su almeno due
/// esecuzioni con dati diversi. Quattro letture vere, quattro domande diverse
/// su quattro estrazioni diverse, per la stessa strada dell'app
/// (`LaLetturaDellaStesa.leggi` e `TarotReading.of`): si stampano il titolo,
/// i tre paragrafi e il "da dove viene", per essere letti a mano.
///
/// ```
/// flutter test tool/collaudo_fk_titolo.dart
/// ```
const List<({TarotTopic argomento, String? scritta, int seme})> letture = [
  (
    argomento: TarotTopic.lavoroTrovare,
    scritta: 'Devo accettare l\'offerta di lavoro a Milano?',
    seme: 11
  ),
  (argomento: TarotTopic.amoreQuadro, scritta: 'Lui tornerà da me?', seme: 23),
  (argomento: TarotTopic.momentoCheVivo, scritta: null, seme: 37),
  (
    argomento: TarotTopic.cambiamento,
    scritta: 'Conviene vendere la casa dei miei genitori?',
    seme: 41
  ),
];

void main() {
  test('FK.A1: quattro titoli veri del modello', () async {
    // La rete vera: flutter test la chiude, e il banco la riapre.
    HttpOverrides.global = null;
    final voce = VoceVeraDiGemini();
    final righe = <String>[
      'IL TITOLO DAL MODELLO, ordine FK aggiunta voci A1 e A2',
      'Modello: ${LaLetturaDellaStesa.modello}, regione europe-west1, '
          '${DateTime.now().toUtc().toIso8601String()}',
      '',
    ];
    var dalModello = 0;
    for (final d in letture) {
      // **Quattro persone, non una**: al primo giro le quattro letture
      // condividevano il filo del consulto, e la quarta ripeteva una frase
      // della prima (docs/collaudo/FK/il_titolo_dal_modello_giro_1.txt).
      IlFiloDelConsulto.dimentica();
      final spread = TarotSpread.draw(seed: d.seme);
      final domanda = d.scritta ?? d.argomento.label;
      final l = await LaLetturaDellaStesa.leggi(
        spread: spread,
        domanda: domanda,
        argomento: d.argomento.label,
        forma: CourtesyForm.neutral,
        chiamata: (istruzione, richiesta, campi) async => (await voce.genera(
          istruzione: istruzione,
          richiesta: richiesta,
          campi: campi.keys.toList(),
          modello: LaLetturaDellaStesa.modello,
        ))
            .testo,
      );
      if (l != null) dalModello++;
      final r = TarotReading.of(spread, d.argomento,
          domandaScritta: d.scritta, dalModello: l);
      righe
        ..add('== DOMANDA: $domanda (seme ${d.seme})')
        ..add('CARTE: ${spread.cards.map((c) => c.displayName).join(', ')}')
        ..add(
            'LETTURA: ${l == null ? 'di casa (${LaLetturaDellaStesa.ultimoScarto})' : 'del modello'}')
        ..add('TITOLO DEL MODELLO: ${l?.titolo ?? '(nessuno)'}')
        ..add('TITOLO A VIDEO: ${r.titolo}')
        ..add('PARAGRAFI: ${r.paragrafi.length}');
      for (var i = 0; i < r.paragrafi.length; i++) {
        righe.add('  ${i + 1}${i == 1 ? ' (nel riquadro)' : ''}. '
            '${r.paragrafi[i]}');
      }
      righe
        ..add(
            'DA DOVE VIENE: ${TarotReading.daDoveViene(spread, mazzo: TarotDeckStyle.riderWaite.label, stesa: TarotSpreadType.treCarte.nome)}')
        ..add('');
    }
    righe.add('LETTURE DEL MODELLO: $dalModello su ${letture.length}');
    final testo = righe.join('\n');
    print(testo);
    File('docs/collaudo/FK/il_titolo_dal_modello.txt')
        .writeAsStringSync('$testo\n');
  }, timeout: const Timeout(Duration(minutes: 10)));
}
