// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/horoscope/i_termini_solari.dart';
import 'package:esoteric_circle/core/horoscope/l_almanacco_cinese.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **L'ALMANACCO CINESE E' QUELLO PUBBLICATO.** Ordine ES voce 08, 29
/// settembre 2026.
///
/// I trenta giorni dal 1 ottobre 2026 e le dieci nascite di
/// `docs/collaudo/ES/cinese_verifica.csv`, calcolati fuori dall'app con due
/// librerie cinesi (`lunar_python`, `cnlunar`) e riscontrati per cinque
/// giorni su due siti di almanacco (huangli999.com, huangli888.com); la
/// tabella dei jie contro `docs/collaudo/ES/jie_1900_2100_pechino.csv`; la
/// matrice dei rapporti e quella dei Dieci Dei delle specifiche
/// (`docs/collaudo/ES/cinese.txt`).
void main() {
  const tronchi = '甲乙丙丁戊己庚辛壬癸';
  const rami = '子丑寅卯辰巳午未申酉戌亥';
  const guardiani = '建除满平定执破危成收开闭';

  final righe = File('docs/collaudo/ES/cinese_verifica.csv').readAsLinesSync();

  test('trenta giorni: pilastro e guardiano dell\'almanacco', () {
    final giorni = righe
        .skip(1)
        .takeWhile((r) => r.trim().isNotEmpty)
        .map((r) => r.split(','))
        .toList();
    cardinaleMinimo(giorni.length, 30, cosa: 'giorni dell\'almanacco');
    final diversi = <String>[];
    for (final c in giorni) {
      final g = DateTime.parse(c[0]);
      final pilastro =
          '${tronchi[LAlmanaccoCinese.tronco(g)]}${rami[LAlmanaccoCinese.ramo(g)]}';
      final guardiano = guardiani[LAlmanaccoCinese.guardiano(g)!];
      if (pilastro != c[9]) {
        diversi.add('${c[0]} pilastro $pilastro, fonte ${c[9]}');
      }
      if (guardiano != c[10]) {
        diversi.add('${c[0]} guardiano $guardiano, fonte ${c[10]}');
      }
    }
    print('ORDINE ES VOCE 08: giorni con animale o guardiano diverso dalla '
        'fonte ${diversi.length} su ${giorni.length}');
    expect(diversi, isEmpty, reason: diversi.join('\n'));
  });

  test('dieci nascite: il signore del giorno', () {
    final i = righe.indexWhere((r) => r.startsWith('data_di_nascita'));
    final nascite = righe
        .skip(i + 1)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => r.split(','))
        .toList();
    cardinaleMinimo(nascite.length, 10, cosa: 'nascite');
    final diversi = <String>[];
    for (final c in nascite) {
      final g = DateTime.parse(c[0]);
      final pilastro =
          '${tronchi[LAlmanaccoCinese.tronco(g)]}${rami[LAlmanaccoCinese.ramo(g)]}';
      if (pilastro != c[6]) diversi.add('${c[0]}: $pilastro, fonte ${c[6]}');
    }
    print('ORDINE ES VOCE 08: signori del giorno diversi dalla fonte '
        '${diversi.length} su ${nascite.length}');
    expect(diversi, isEmpty, reason: diversi.join('\n'));
  });

  test('i jie dell\'app sono quelli della tabella, 2.412', () {
    final jie = File('docs/collaudo/ES/jie_1900_2100_pechino.csv')
        .readAsLinesSync()
        .skip(1)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => r.split(','))
        .toList();
    cardinaleMinimo(jie.length, 2412, cosa: 'jie');
    var diversi = 0;
    for (var k = 0; k < jie.length; k++) {
      final c = jie[k];
      final data =
          int.parse(c[0]) * 10000 + int.parse(c[1]) * 100 + int.parse(c[2]);
      if (ITerminiSolari.date[k] != data) diversi++;
      if ((ITerminiSolari.ramoDelPrimo + k) % 12 != rami.indexOf(c[5])) {
        diversi++;
      }
    }
    expect(diversi, 0);
  });

  test('i rapporti fra animali e i Dieci Dei delle tabelle classiche', () {
    // Riscontri puntuali delle matrici (specifiche, paragrafi 3 e 4).
    expect(LAlmanaccoCinese.rapporto(0, 6), RapportoFraAnimali.scontro);
    expect(LAlmanaccoCinese.rapporto(0, 3), RapportoFraAnimali.punizione);
    expect(LAlmanaccoCinese.rapporto(0, 7), RapportoFraAnimali.danno);
    expect(LAlmanaccoCinese.rapporto(0, 1), RapportoFraAnimali.armonia);
    expect(LAlmanaccoCinese.rapporto(0, 4), RapportoFraAnimali.triplaArmonia);
    expect(LAlmanaccoCinese.rapporto(0, 0), RapportoFraAnimali.stessoAnimale);
    expect(LAlmanaccoCinese.rapporto(4, 4), RapportoFraAnimali.punizione);
    expect(LAlmanaccoCinese.rapporto(1, 7), RapportoFraAnimali.scontro);
    expect(LAlmanaccoCinese.rapporto(2, 5), RapportoFraAnimali.punizione);
    expect(
        LAlmanaccoCinese.rapporto(5, 8), RapportoFraAnimali.armoniaChePunisce);
    // Il conto delle 144 celle: nessuno 66, tripla 24, punizione 14 (piu' le
    // due dell'armonia che punisce), scontro 12, armonia 10 (meno due),
    // danno 10, stesso animale 8.
    final conto = <RapportoFraAnimali, int>{};
    for (var a = 0; a < 12; a++) {
      for (var b = 0; b < 12; b++) {
        final r = LAlmanaccoCinese.rapporto(a, b);
        conto[r] = (conto[r] ?? 0) + 1;
      }
    }
    print('ORDINE ES VOCE 08: rapporti sulle 144 celle $conto');
    expect(conto[RapportoFraAnimali.nessuno], 66);
    expect(conto[RapportoFraAnimali.scontro], 12);
    expect(conto[RapportoFraAnimali.danno], 10);
    expect(conto[RapportoFraAnimali.triplaArmonia], 24);
    expect(conto[RapportoFraAnimali.stessoAnimale], 8);
    expect(conto[RapportoFraAnimali.armoniaChePunisce], 2);
    // I Dieci Dei: la prima riga della matrice (signore Jia).
    const jia = [
      DioDelGiorno.compagno,
      DioDelGiorno.rivale,
      DioDelGiorno.nutrimento,
      DioDelGiorno.ufficialeFerito,
      DioDelGiorno.ricchezzaIndiretta,
      DioDelGiorno.ricchezzaDiretta,
      DioDelGiorno.setteUccisioni,
      DioDelGiorno.ufficialeDiretto,
      DioDelGiorno.sigilloIndiretto,
      DioDelGiorno.sigilloDiretto,
    ];
    for (var t = 0; t < 10; t++) {
      expect(LAlmanaccoCinese.dio(0, t), jia[t], reason: 'Jia e ${tronchi[t]}');
    }
    // E una riga yin (signore Yi): Jia e' il Rivale, Bing l'Ufficiale Ferito.
    expect(LAlmanaccoCinese.dio(1, 0), DioDelGiorno.rivale);
    expect(LAlmanaccoCinese.dio(1, 2), DioDelGiorno.ufficialeFerito);
    expect(LAlmanaccoCinese.dio(1, 4), DioDelGiorno.ricchezzaDiretta);
    expect(LAlmanaccoCinese.dio(1, 6), DioDelGiorno.ufficialeDiretto);
    expect(LAlmanaccoCinese.dio(1, 8), DioDelGiorno.sigilloDiretto);
  });
}
