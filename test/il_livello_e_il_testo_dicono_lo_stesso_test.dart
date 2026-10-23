// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/horoscope/i_testi_eu.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'oroscopo_eu_comune.dart';

/// **IL LIVELLO E IL TESTO DICONO LA STESSA COSA.** Ordine EU voce 17, 1
/// ottobre 2026.
///
/// Il fatto, nelle catture del fondatore: il Giorno Generale segnava "5 su
/// 5", apriva con "oggi il tuo cielo si accende" e poi diceva "riduci gli
/// impegni dove puoi". Il corpus dell'Architetto da' a ogni voce la sua
/// fascia (Favorevole per 4 e 5, In equilibrio per 3, In salita per 2 e
/// sotto): qui, per ogni scheda composta, si cerca nel corpus la voce da cui
/// viene e si pretende che la sua fascia sia quella del livello della scheda
/// (il livello del periodo nella Settimana e nel Mese).
///
/// Tre persone in trenta giorni, nelle tre tradizioni, nel Giorno, nella
/// Settimana, nel Mese e nell'Anno; il livello e la fascia dichiarata delle
/// schede scelte si scrivono in `docs/collaudo/EU/livello_e_testo.txt`.
void main() {
  test('ogni scheda viene da una voce della fascia del suo livello', () {
    final fuori = <String>[];
    final righe = <String>[
      'ORDINE EU VOCE 17, IL LIVELLO E IL TESTO, 1 ottobre 2026.',
      'Per ogni scheda: il livello, la fascia che il livello chiede, la '
          'fascia della voce del corpus da cui viene il testo.',
      '',
    ];
    var schede = 0;
    for (final persona in dodiciPersone.take(3)) {
      for (var k = 0; k < 30; k++) {
        final oggi = DateTime(2026, 10, 1 + k);
        for (final t in TradizioneEu.values) {
          if (!persona.legge(t)) continue;
          void guarda(String periodo, PeriodoEu p, HoroscopeDomain d,
              int livello, String titolo, String testo) {
            schede++;
            final attesa = FasciaEu.di(livello);
            final trovata = voceDellaScheda(t, p, d, titolo, testo);
            final riga = '${persona.nome} ${oggi.day}/${oggi.month} '
                '${t.name} $periodo ${d.label}: livello $livello, fascia '
                '${attesa.name}, voce ${trovata == null ? 'NON TROVATA' : '${trovata.$1.name} ${trovata.$2 + 1}'}';
            if (k < 7 || trovata?.$1 != attesa) righe.add(riga);
            if (trovata == null || trovata.$1 != attesa) fuori.add(riga);
          }

          for (final c in persona.giorno(t, oggi)) {
            guarda('Giorno', PeriodoEu.giorno, c.domain, c.indicator, c.title,
                c.text);
          }
          if (k % 7 == 0) {
            for (final mese in [false, true]) {
              for (final d in persona.periodo(t, oggi, mese: mese).domini) {
                guarda(
                    mese ? 'Mese' : 'Settimana',
                    mese ? PeriodoEu.mese : PeriodoEu.settimana,
                    d.dominio,
                    d.livello,
                    d.voce.titolo,
                    d.voce.testo(lunga: true));
              }
            }
          }
          if (k == 0) {
            for (final c in persona.anno(t, oggi)) {
              guarda('Anno', PeriodoEu.anno, c.domain, c.indicator, c.title,
                  c.text);
            }
          }
        }
      }
    }
    cardinaleMinimo(schede, 3 * 30 * 2 * 4, cosa: 'schede guardate');
    final sintesi = 'ORDINE EU VOCE 17: schede con un paragrafo di una fascia '
        'diversa dal livello ${fuori.length} su $schede';
    print(sintesi);
    File('docs/collaudo/EU/livello_e_testo.txt')
        .writeAsStringSync('${[sintesi, ...righe].join('\n')}\n');
    expect(fuori, isEmpty, reason: fuori.take(8).join('\n'));
  });
}
