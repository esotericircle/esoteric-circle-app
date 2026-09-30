// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/horoscope/cielo_di_oggi.dart';
import 'package:esoteric_circle/core/horoscope/il_livello_del_cielo.dart';
import 'package:esoteric_circle/core/horoscope/la_settimana_del_cielo.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **IL SETTIMANALE VIENE DAL CIELO.** Ordine ES voce 02, 29 settembre 2026.
///
/// - Le fasi della Luna dell'app contro l'almanacco del JPL DE440s
///   (skyfield), da settembre 2026 a febbraio 2027, entro due minuti.
/// - Tre carte natali diverse dello stesso segno non danno la stessa
///   settimana.
/// - Ogni riga di ogni giorno ha dietro un fatto del cielo di quel giorno.
void main() {
  test('le fasi della Luna contro il JPL, sei mesi', () {
    final righe = File('docs/collaudo/ES/fasi_lunari.csv')
        .readAsLinesSync()
        .skip(1)
        .where((r) => r.trim().isNotEmpty)
        .toList();
    cardinaleMinimo(righe.length, 24, cosa: 'fasi lunari di riferimento');
    final app = LaSettimanaDelCielo.fasi(
        DateTime.utc(2026, 9, 1), DateTime.utc(2027, 3, 1));
    var peggiore = 0.0;
    final mancanti = <String>[];
    for (final r in righe) {
      final c = r.split(',');
      final t = DateTime.parse(c[0]);
      final k = int.parse(c[1]);
      final vicine = app
          .where((f) => f.$2 == k)
          .map((f) => f.$1.difference(t).inSeconds.abs() / 60.0);
      final m = vicine.isEmpty ? 1e9 : vicine.reduce((a, b) => a < b ? a : b);
      if (m > 2) mancanti.add('$t fase $k: scarto $m minuti');
      if (m < 1e9 && m > peggiore) peggiore = m;
    }
    print('ORDINE ES VOCE 02: fasi della Luna ${righe.length} contro il JPL, '
        'scarto massimo ${peggiore.toStringAsFixed(2)} minuti, oltre i due '
        'minuti ${mancanti.length}; fasi dell\'app ${app.length}');
    expect(mancanti, isEmpty, reason: mancanti.join('\n'));
    expect(app.length, righe.length);
  });

  test('tre carte dello stesso segno, tre settimane, ogni riga dal cielo', () {
    NatalChart carta(double luna, double venere, double marte, double asc) =>
        NatalChart(
          sunSign: Zodiac.leo,
          planets: [
            const PlanetPosition(
                id: 'sun',
                name: 'Sole',
                glyph: '☉',
                longitude: 130.0,
                sign: Zodiac.leo),
            for (final (id, nome, l) in [
              ('moon', 'Luna', luna),
              ('venus', 'Venere', venere),
              ('mars', 'Marte', marte),
              ('jupiter', 'Giove', (luna + 90) % 360),
            ])
              PlanetPosition(
                  id: id,
                  name: nome,
                  glyph: '',
                  longitude: l,
                  sign: Zodiac.values[(l ~/ 30) % 12]),
          ],
          ascendantLongitude: asc,
          midheavenLongitude: (asc + 270) % 360,
          houses: [
            for (var n = 1; n <= 12; n++)
              HouseCusp(number: n, longitude: (asc + (n - 1) * 30.0) % 360.0),
          ],
          hasTime: true,
        );
    final oggi = DateTime(2026, 10, 5);
    final carte = [
      carta(10, 100, 200, 15),
      carta(140, 250, 40, 200),
      carta(300, 20, 310, 95),
    ];
    final settimane = <String>[];
    final testo = StringBuffer();
    var righe = 0;
    final senzaFatto = <String>[];
    // **OGNI RIGA E' QUELLA DEL SUO GIORNO.** Regola B del 30 settembre 2026:
    // con le sette righe lette tutte dal cielo del primo giorno questa prova
    // restava verde, perche' ogni riga aveva comunque un fatto del cielo
    // dietro. Due misure: la riga e' quella che il cielo di quel giorno da',
    // e senza carta natale, dove la riga viene dalla Luna, in sette giorni
    // la Luna cambia segno almeno due volte.
    final nonDelSuoGiorno = <String>[];
    var lunePiuStrette = 99;
    for (final c in [...carte, null]) {
      final p =
          LaSettimanaDelCielo.per(segno: Zodiac.leo, carta: c, oggi: oggi);
      expect(p.dallaCarta, c != null);
      testo.writeln(c == null
          ? '\n=== LEONE SENZA CARTA NATALE (segno e case solari) ==='
          : '\n=== CARTA DEL LEONE, Luna natale a ${c.planets[1].longitude} '
              'gradi, Ascendente a ${c.ascendantLongitude} ===');
      testo.writeln('Eventi:');
      for (final e in p.eventi) {
        testo.writeln('  ${e.testo}');
      }
      final firma = StringBuffer();
      for (final d in p.domini) {
        testo.writeln('${d.dominio.label}: giorno migliore '
            '${LaSettimanaDelCielo.data(d.migliore.giorno)} (livello '
            '${d.migliore.livello}); momento chiave ${d.momentoChiave}');
        if (c == null) {
          final diverse = d.giorni.map((g) => g.motivo).toSet().length;
          if (diverse < lunePiuStrette) lunePiuStrette = diverse;
        }
        for (final g in d.giorni) {
          righe++;
          if (!g.motivo.startsWith('Dal')) {
            senzaFatto.add('${d.dominio.name} ${g.giorno}: "${g.motivo}"');
          }
          final mezzogiorno =
              DateTime(g.giorno.year, g.giorno.month, g.giorno.day, 12).toUtc();
          final (livello, motivo) = IlLivelloDelCielo.per(
              dominio: d.dominio,
              segno: Zodiac.leo,
              cielo: CieloDiOggi.perIlGiorno(adesso: mezzogiorno, carta: c),
              quando: mezzogiorno,
              oggi: false);
          if (livello != g.livello || motivo != g.motivo) {
            nonDelSuoGiorno.add('${d.dominio.name} ${g.giorno}: "${g.motivo}"');
          }
          firma.write('${g.livello}${g.motivo}|');
          testo.writeln('  ${LaSettimanaDelCielo.data(g.giorno)}: livello '
              '${g.livello}. ${g.motivo}');
        }
      }
      if (c != null) settimane.add(firma.toString());
    }
    cardinaleMinimo(righe, 7 * 4 * 4, cosa: 'righe delle settimane');
    final identiche = settimane.length - settimane.toSet().length;
    final sintesi = 'ORDINE ES VOCE 02: righe della settimana senza un fatto '
        'del cielo dietro ${senzaFatto.length} su $righe; settimane identiche '
        'per due carte diverse dello stesso segno $identiche su 3';
    print(sintesi);
    if (Platform.environment['SCRIVI_LA_PROVA'] == '1') {
      File('docs/collaudo/ES/settimana.txt')
        ..createSync(recursive: true)
        ..writeAsStringSync('$sintesi\nSettimana dal 5 ottobre 2026.\n$testo');
    }
    print('ORDINE ES VOCE 02: righe che non sono quelle del cielo del loro '
        'giorno ${nonDelSuoGiorno.length} su $righe; senza carta, righe '
        'diverse nei sette giorni di un dominio, almeno $lunePiuStrette');
    expect(senzaFatto, isEmpty, reason: senzaFatto.take(5).join('\n'));
    expect(identiche, 0);
    expect(nonDelSuoGiorno, isEmpty,
        reason: nonDelSuoGiorno.take(5).join('\n'));
    expect(lunePiuStrette, greaterThanOrEqualTo(3),
        reason: 'senza carta la riga viene dalla Luna del giorno: in sette '
            'giorni deve cambiare almeno due volte');
  });

  test('il mese: trenta giorni, ogni riga dal cielo, con le eclissi', () {
    final testo = StringBuffer();
    var righe = 0;
    final senzaFatto = <String>[];
    // Febbraio 2027: c'e' un'eclissi (l'anulare del 6 febbraio 2027) e il
    // mese prova anche gli eventi rari.
    final oggi = DateTime(2027, 1, 25);
    final p = LaSettimanaDelCielo.per(
        segno: Zodiac.leo, carta: null, oggi: oggi, giorni: 30);
    for (final e in p.eventi) {
      testo.writeln('  ${e.testo}');
    }
    for (final d in p.domini) {
      testo.writeln('${d.dominio.label}: giorno migliore '
          '${LaSettimanaDelCielo.data(d.migliore.giorno)}; momento chiave '
          '${d.momentoChiave}');
      for (final g in d.giorni) {
        righe++;
        if (!g.motivo.startsWith('Dal')) senzaFatto.add('${g.giorno}');
      }
    }
    cardinaleMinimo(righe, 30 * 4, cosa: 'righe del mese');
    final eclissi = p.eventi.where((e) => e.testo.contains('eclissi')).length;
    final lune = p.eventi
        .where((e) =>
            e.testo.contains('Luna nuova') || e.testo.contains('Luna piena'))
        .length;
    final sintesi = 'ORDINE ES VOCE 03: righe del mese senza un fatto del '
        'cielo dietro ${senzaFatto.length} su $righe; lune nuove e piene $lune, '
        'eclissi $eclissi (dal 25 gennaio 2027, Leone senza carta)';
    print(sintesi);
    if (Platform.environment['SCRIVI_LA_PROVA'] == '1') {
      File('docs/collaudo/ES/mese.txt')
        ..createSync(recursive: true)
        ..writeAsStringSync('$sintesi\n\nEventi:\n$testo');
    }
    expect(senzaFatto, isEmpty);
    expect(lune, greaterThanOrEqualTo(2));
    expect(eclissi, greaterThanOrEqualTo(1));
  });
}
