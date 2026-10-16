// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/chat/il_filo_del_consulto.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/tarot/la_lettura_dal_modello.dart';
import 'package:esoteric_circle/core/tarot/tarot_reading.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread_type.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:flutter_test/flutter_test.dart';

import 'la_voce_vera_di_gemini.dart';

/// **LE STESE NUOVE, LETTE DAL MODELLO VERO.** Ordine FK, aggiunta 2 voci A9
/// e A12, 12 ottobre 2026.
///
/// Il Protocollo della chiusura: dove il risultato lo scrive un modello, la
/// prova e' la risposta vera, su almeno due esecuzioni con dati diversi. Due
/// stese a una carta e due a croce, quattro domande e quattro estrazioni,
/// per la stessa strada dell'app (`LaLetturaDellaStesa.leggi` e
/// `TarotReading.of`), ognuna come una persona diversa (il filo del consulto
/// azzerato). Si stampa tutto per essere letto a mano.
///
/// ```
/// flutter test tool/collaudo_fk_stese.dart
/// ```
const letture = [
  (
    tipo: TarotSpreadType.unaCarta,
    argomento: TarotTopic.lavoroTrovare,
    scritta: 'Devo accettare l\'offerta di lavoro a Milano?',
    seme: 101
  ),
  (
    tipo: TarotSpreadType.unaCarta,
    argomento: TarotTopic.momentoCheVivo,
    scritta: null,
    seme: 202
  ),
  (
    tipo: TarotSpreadType.croceQuattro,
    argomento: TarotTopic.amoreQuadro,
    scritta: 'Questa relazione ha un futuro?',
    seme: 303
  ),
  (
    tipo: TarotSpreadType.croceQuattro,
    argomento: TarotTopic.cambiamento,
    scritta: 'Conviene trasferirmi in un\'altra città quest\'anno?',
    seme: 404
  ),
];

void main() {
  test('FK aggiunta 2: le stese nuove lette dal modello vero', () async {
    HttpOverrides.global = null;
    final voce = VoceVeraDiGemini();
    final righe = <String>[
      'LE STESE NUOVE DAL MODELLO, ordine FK aggiunta 2 voci A9 e A12',
      'Modello: ${LaLetturaDellaStesa.modello}, regione europe-west1, '
          '${DateTime.now().toUtc().toIso8601String()}',
      '',
    ];
    var dalModello = 0;
    for (final d in letture) {
      IlFiloDelConsulto.dimentica();
      final spread =
          TarotSpread.draw(seed: d.seme, posizioni: d.tipo.posizioni);
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
        ..add('== ${d.tipo.nome}, DOMANDA: $domanda (seme ${d.seme})')
        ..add(
            'LETTURA: ${l == null ? 'di casa (${LaLetturaDellaStesa.ultimiScarti.join(' | ')})' : 'del modello'}')
        ..add('TITOLO: ${r.titolo}');
      for (var i = 0; i < r.paragrafi.length; i++) {
        righe.add('  ${i + 1}${i == 1 ? ' (nel riquadro)' : ''}. '
            '${r.paragrafi[i]}');
      }
      for (final p in r.posizioni) {
        righe.add('  CARTA, ${p.drawn.position.etichetta}, '
            '${p.drawn.displayName}: ${p.testo}');
      }
      righe.add('');
    }
    righe.add('LETTURE DEL MODELLO: $dalModello su ${letture.length}');
    final testo = righe.join('\n');
    print(testo);
    File('docs/collaudo/FK/le_stese_dal_modello.txt')
        .writeAsStringSync('$testo\n');
  }, timeout: const Timeout(Duration(minutes: 10)));
}
