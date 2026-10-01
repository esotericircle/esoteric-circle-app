// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/effemeridi.dart';
import 'package:esoteric_circle/core/horoscope/cielo_di_oggi.dart';
import 'package:esoteric_circle/core/horoscope/i_testi_eu.dart';
import 'package:esoteric_circle/core/horoscope/la_lettura_vedica.dart';
import 'package:esoteric_circle/core/horoscope/la_settimana_del_cielo.dart';
import 'package:esoteric_circle/core/horoscope/oroscopo_vedico_data.dart';
import 'package:esoteric_circle/features/horoscope/il_periodo_view.dart';
import 'package:esoteric_circle/features/horoscope/la_ruota_del_passaggio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'oroscopo_eu_comune.dart';

/// **LE RIFINITURE DEI "DA DOVE VIENE".** Ordine EV, voce EV.09, coi testi
/// della sezione "Le altre decisioni" del file dell'Architetto
/// (`docs/corpus/eu/verifica_affermazioni_architetto.md`).
void main() {
  test('ORDINE EV VOCE 09: il venerdì vedico è screziato, nei due posti', () {
    final venerdi = LaLetturaVedica.pianetiDelGiorno[5];
    print('ORDINE EV VOCE 09: colore del venerdì nella Fortuna "${venerdi.$2}"');
    expect(venerdi.$1, 'Venere');
    expect(venerdi.$2, 'screziato');
    expect(OroscopoVedicoData.righeDelGiorno.join(' '),
        contains('Il suo colore è lo screziato'));
  });

  test('ORDINE EV VOCE 09: il Rahu Kalam in corso dice sempre l\'ora', () {
    const inCorso = OroscopoVedicoData.rahuInCorso;
    cardinaleMinimo(inCorso.length, 3, cosa: 'varianti del Rahu in corso');
    final senzaOra = [
      for (final v in inCorso)
        if (!v.split(' || ').last.contains('{fine}')) v,
    ];
    print('ORDINE EV VOCE 09: varianti del Rahu in corso senza l\'ora '
        '${senzaOra.length} su ${inCorso.length}');
    expect(senzaOra, isEmpty);
    expect(inCorso.join('\n'),
        contains('Siamo dentro il Rahu Kalam di oggi, dalle {inizio} alle {fine}.'));
  });

  test('ORDINE EV VOCE 09: la riga della ruota non ripete il passaggio', () {
    const v = VoceDelCielo(
      transito: CorpoCeleste.sole,
      bersaglio: 'Urano',
      idBersaglio: 'uranus',
      aspetto: AspectType.square,
      orbe: 1.2,
      applicativo: true,
      casa: 3,
      retrogrado: false,
      giorniDiIncertezza: 0.01,
    );
    final riga = LaRigaDelPassaggio.riga(v);
    print('ORDINE EV VOCE 09: riga della ruota "$riga"');
    expect(riga, 'Guardalo sulla tua carta, nella tua terza casa.');
    expect(riga.contains('Urano'), isFalse);
  });

  test('ORDINE EV VOCE 09: due giorni migliori di fila non ripetono la riga',
      () {
    GiornoDelPeriodo g(int giorno, String motivo) => GiornoDelPeriodo(
        giorno: DateTime(2026, 10, giorno),
        livello: 4,
        motivo: motivo,
        titolo: 'Un titolo');
    const stesso = 'Dalla Luna del giorno in Gemelli, nella tua terza casa '
        'solare; Venere è in Bilancia, nella tua quinta.';
    final migliori = [g(1, stesso), g(2, stesso), g(5, 'Altra riga.')];
    final righe = [
      for (var i = 0; i < 3; i++) IlPeriodoView.daDoveDelGiorno(migliori, i)
    ];
    print('ORDINE EV VOCE 09: ${righe.join(' | ')}');
    expect(righe[1],
        'Da dove viene: lo stesso passaggio di ${LaSettimanaDelCielo.data(DateTime(2026, 10, 1)).toLowerCase()}.');
    expect(righe[0], isNot(righe[1]));
  });

  test('ORDINE EV VOCE 09: sotto la data di un altro giorno niente "oggi"',
      () {
    final oggiParola = RegExp(r'\boggi\b', caseSensitive: false);
    var righe = 0;
    final conOggi = <String>[];
    final esempi = <String>{};
    for (final p in dodiciPersone.take(6)) {
      for (final t in [TradizioneEu.vedica, TradizioneEu.cinese]) {
        if (!p.legge(t)) continue;
        for (final inizio in [DateTime(2026, 10, 1), DateTime(2026, 11, 9)]) {
          final periodo = p.periodo(t, inizio, mese: false);
          for (final d in periodo.domini) {
            for (final r in d.giorni) {
              if (r.giorno == inizio) continue;
              righe++;
              if (oggiParola.hasMatch(r.motivo)) {
                conOggi.add('${t.name} ${r.giorno}: ${r.motivo}');
              }
              if (esempi.length < 40 && r.motivo != r.motivo.toLowerCase()) esempi.add('${t.name}: ${r.motivo}');
            }
          }
        }
      }
    }
    cardinaleMinimo(righe, 100, cosa: 'righe di altri giorni');
    print('ORDINE EV VOCE 09: righe di altri giorni $righe, con "oggi" '
        '${conOggi.length}\n${esempi.join('\n')}');
    expect(conOggi, isEmpty, reason: conOggi.take(6).join('\n'));
  });
}
