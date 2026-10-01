// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/horoscope/cielo_di_oggi.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/horoscope/la_settimana_del_cielo.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LA SETTIMANA E IL GIORNO DICONO LO STESSO.** Ordine ES, 30 settembre
/// 2026, parole del fondatore: *"l'utente che chiede l'oroscopo settimanale
/// riceve un responso per ogni giorno della settimana che, controlla, dovrà
/// essere coerente con quello giornaliero, nel caso lo chiederà."*
///
/// Si pretende che la riga di ogni giorno della Settimana e del Mese, in
/// ogni campo, dica **la stessa lettura** e **lo stesso livello** della
/// scheda del Giorno che la persona trovera' quel giorno: la scheda si compone
/// qui come la compone l'Oroscopo, con `Horoscope.cardFor` e il cielo del
/// giorno letto alle nove di mattina (l'ora a cui la persona apre l'app non
/// deve cambiare niente). Dodici segni, tre carte natali e nessuna, due
/// settimane e un mese.
///
/// Il difetto che la prova ha preso nascendo: la riga misurava il livello a
/// mezzogiorno locale e la scheda alle 12 UTC; senza carta il livello guarda
/// la Luna, e vicino a un confine di casa i pallini della Settimana e quelli
/// del Giorno non coincidevano.
void main() {
  NatalChart carta(
          Zodiac segno, double luna, double venere, double marte, double asc) =>
      NatalChart(
        sunSign: segno,
        planets: [
          PlanetPosition(
              id: 'sun',
              name: 'Sole',
              glyph: '☉',
              longitude: segno.index * 30.0 + 10,
              sign: segno),
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

  test('ogni giorno della Settimana e del Mese e\' il Giorno di quel giorno',
      () {
    var righe = 0;
    final letturaDiversa = <String>[];
    final livelloDiverso = <String>[];
    for (final segno in Zodiac.values) {
      final carte = <NatalChart?>[
        null,
        carta(segno, 10, 100, 200, 15),
        carta(segno, 140, 250, 40, 200),
        carta(segno, 300, 20, 310, 95),
      ];
      for (final c in carte) {
        for (final (inizio, giorni) in [
          (DateTime(2026, 9, 30), 7),
          (DateTime(2027, 2, 14), 7),
          if (c == null || c == carte[1]) (DateTime(2026, 10, 20), 30),
          // **UN ANNO INTERO SENZA CARTA, per il Leone**: senza carta il
          // livello guarda il segno della Luna all'istante esatto, e la Luna
          // cambia segno a un'ora qualunque. Solo su tanti giorni capita che
          // cambi fra il mezzogiorno di Roma e le 12 UTC, cioe' dove una riga
          // misurata a un'altra ora si separerebbe dal Giorno.
          if (c == null && segno == Zodiac.leo)
            for (var mese = 0; mese < 12; mese++)
              (DateTime(2026, 10 + mese, 1), 30),
        ]) {
          final p = LaSettimanaDelCielo.per(
              segno: segno, carta: c, oggi: inizio, giorni: giorni);
          for (final d in p.domini) {
            for (final g in d.giorni) {
              righe++;
              final mattina =
                  DateTime(g.giorno.year, g.giorno.month, g.giorno.day, 9);
              final scheda = Horoscope.cardFor(
                  sign: segno,
                  dayOfYear: Horoscope.dayOfYear(mattina),
                  year: mattina.year,
                  domain: d.dominio,
                  cielo: CieloDiOggi.perIlGiorno(adesso: mattina, carta: c));
              final chi =
                  '${segno.name} ${c == null ? 'senza carta' : 'carta'} '
                  '${d.dominio.name} ${g.giorno.toIso8601String().substring(0, 10)}';
              // LAPIDE, EU Aggiunta, 1 ottobre 2026: qui si confrontava la
              // lettura della riga con la prima parte della scheda. Adesso la
              // riga porta il titolo della scheda del Giorno di quella data
              // (il testo si legge quel giorno): si confronta il titolo.
              if (g.titolo != scheda.title) {
                letturaDiversa.add('$chi: "${g.titolo}", Giorno '
                    '"${scheda.title}"');
              }
              if (g.livello != scheda.indicator) {
                livelloDiverso
                    .add('$chi: riga ${g.livello}, Giorno ${scheda.indicator}');
              }
            }
          }
        }
      }
    }
    cardinaleMinimo(righe, 6900, cosa: 'righe dei periodi confrontate');
    print('LA SETTIMANA E IL GIORNO: righe confrontate $righe; con una lettura '
        'diversa dal Giorno ${letturaDiversa.length}; con un livello diverso '
        '${livelloDiverso.length}');
    expect(letturaDiversa, isEmpty, reason: letturaDiversa.take(4).join('\n'));
    expect(livelloDiverso, isEmpty, reason: livelloDiverso.take(4).join('\n'));
  });
}
