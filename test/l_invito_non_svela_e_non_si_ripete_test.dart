import 'package:esoteric_circle/core/chat/la_risposta_ripulita.dart';
import 'package:esoteric_circle/core/maestro/chakra_del_giorno.dart';
import 'package:esoteric_circle/core/maestro/consiglio_finale.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/rituals/runes.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **L'INVITO A TORNARE NON SVELA I DONI E NON SI RIPETE.** Ordine EJ voci
/// 05, 07 e 08, 24 settembre 2026.
///
/// Il fondatore ha letto, nella 2278, *"Torna domani sera: la runa che scende
/// e' Fehu"*, *"Torna domani: si apre la gola"*, e *"Ripassa fra 2 giorni,
/// per la Luna piena."* in fondo a cinque risposte di fila. Queste righe le
/// compone l'app, non Gemini: qui si provano per un anno intero.
void main() {
  test('IN UN ANNO NESSUN INVITO NOMINA LA RUNA O IL CENTRO DI DOMANI', () {
    final nomi = <String>[
      for (final r in kElderFuthark) r.name,
      for (final c in ChakraDelGiorno.tutti) ...[c.nome, c.italiano],
    ];
    cardinaleMinimo(nomi.length, 24 + 14,
        cosa: 'nomi di rune e di centri',
        perche: 'Ventiquattro rune e sette centri col loro nome italiano.');
    final svelati = <String>[];
    var inviti = 0;
    for (final m in Maestro.values) {
      for (var g = 0; g < 366; g++) {
        final giorno = DateTime(2026, 1, 1).add(Duration(days: g, hours: 20));
        final invito = ConsiglioFinale.invitoDelRitorno(m,
            quando: giorno, identita: 'prova');
        inviti++;
        for (final n in nomi) {
          if (RegExp('\\b${RegExp.escape(n)}\\b', caseSensitive: false)
              .hasMatch(invito)) {
            svelati.add('${m.id} $giorno: "$invito" nomina $n');
          }
        }
      }
    }
    cardinaleMinimo(inviti, 1000,
        cosa: 'inviti composti', perche: 'Tre Maestri per un anno.');
    expect(svelati, isEmpty,
        reason: 'un invito svela il dono prima del suo momento:\n'
            '${svelati.take(5).join('\n')}');
  });

  test('L\'INVITO STA SOLO SOTTO L\'ULTIMA RISPOSTA DEL MAESTRO', () {
    expect(
        ConsiglioFinale.invitoSotto(posizione: 9, ultimaDelMaestro: 9), isTrue);
    for (final p in [1, 3, 5, 7]) {
      expect(ConsiglioFinale.invitoSotto(posizione: p, ultimaDelMaestro: 9),
          isFalse,
          reason: 'la risposta $p non e\' l\'ultima e porta l\'invito');
    }
    final senza = ConsiglioFinale.componi(Maestro.medora,
        testo: 'Corpo.\n✦ Scrivi le tre cose che vuoi dirgli.',
        quando: DateTime(2026, 9, 24, 20),
        identita: 'prova',
        conInvito: false);
    expect(senza, 'Scrivi le tre cose che vuoi dirgli.');
  });

  test('LE FRASI VIETATE SI TOLGONO, E LE REGOLE DI LINGUA SI APPLICANO', () {
    final pulito = LaRispostaRipulita.applica(
        'Comprendo la tua inquietudine. Il tuo Cancro solare chiede riparo, '
        'e domani parla — con calma — col tuo capo.\n'
        '✦ Stasera scrivi le tre cose che vuoi dirgli.');
    expect(pulito, isNot(contains('Comprendo')));
    expect(pulito, isNot(contains('—')));
    expect(pulito, isNot(contains(', e ')));
    expect(pulito, startsWith('Il tuo Cancro solare chiede riparo e domani'));
    expect(pulito, endsWith('✦ Stasera scrivi le tre cose che vuoi dirgli.'));
    // Una risposta fatta solo di una frase vietata non si svuota.
    expect(LaRispostaRipulita.applica('Capisco.'), 'Capisco.');
  });
}
