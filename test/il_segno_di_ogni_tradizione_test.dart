// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/horoscope/astro_tradition.dart';
import 'package:esoteric_circle/core/horoscope/i_segni_delle_tradizioni.dart';
import 'package:esoteric_circle/core/horoscope/il_capodanno_lunare.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **IL SEGNO DI OGNI TRADIZIONE E' QUELLO DELLE FONTI.** Ordine ES voci 07 e
/// 11, 29 settembre 2026.
///
/// Dieci nascite di controllo, con data, ora e citta', calcolate FUORI
/// dall'app: la Luna e il Sole con l'effemeride JPL (skyfield, DE421 e
/// DE440s) e con la Swiss Ephemeris, il Maya coi convertitori di Fourmilab e
/// dello Smithsonian, il Capodanno lunare con l'Osservatorio di Hong Kong. I
/// file di quel calcolo stanno in `docs/collaudo/ES/` (`dieci_date.csv`,
/// `cinese_vedica_dieci_date.csv`, `capodanno_lunare_1900_2100.csv`). Qui
/// l'app deve dare gli stessi segni: sei tradizioni per dieci nascite.
void main() {
  // (data e ora locali, fuso, maya, albero, decano, dimora 1-28, animale,
  // rashi)
  final nascite =
      <(DateTime, String, String, String, String, int, String, String)>[
    (
      DateTime(1990, 3, 15, 8, 30),
      'Europe/Rome',
      '7 Akʼbʼal',
      'Frassino',
      'Ptibiou, terzo decano dei Pesci',
      17,
      'Cavallo',
      'Tula'
    ),
    (
      DateTime(1985, 7, 4, 22, 10),
      'Europe/Rome',
      '8 Lamat',
      'Quercia',
      'Sit, secondo decano del Cancro',
      25,
      'Bue',
      'Makara'
    ),
    (
      DateTime(2000, 1, 1, 0, 5),
      'Europe/Rome',
      '11 Ikʼ',
      'Betulla',
      'Smat, primo decano del Capricorno',
      17,
      'Coniglio',
      'Tula'
    ),
    (
      DateTime(1972, 11, 23, 14, 0),
      'Europe/Rome',
      '4 Ikʼ',
      'Canna',
      'Reouo, primo decano del Sagittario',
      8,
      'Topo',
      'Mithuna'
    ),
    (
      DateTime(1995, 12, 24, 6, 45),
      'Europe/Rome',
      '11 Bʼen',
      'Betulla',
      'Smat, primo decano del Capricorno',
      24,
      'Maiale',
      'Makara'
    ),
    (
      DateTime(1968, 6, 21, 12, 0),
      'Europe/Rome',
      '13 Kimi',
      'Quercia',
      'Sothis, primo decano del Cancro',
      4,
      'Scimmia',
      'Mesha'
    ),
    (
      DateTime(2004, 2, 29, 18, 20),
      'Europe/Rome',
      '10 Ikʼ',
      'Frassino',
      'Chontare, secondo decano dei Pesci',
      7,
      'Scimmia',
      'Mithuna'
    ),
    (
      DateTime(1979, 9, 9, 3, 15),
      'Europe/Rome',
      '2 Akʼbʼal',
      'Vite',
      'Ouestebkoti, secondo decano della Vergine',
      2,
      'Capra',
      'Mina'
    ),
    (
      DateTime(1999, 8, 11, 11, 0),
      'Europe/Rome',
      '11 Kawak',
      'Nocciolo',
      'Epe, secondo decano del Leone',
      11,
      'Coniglio',
      'Karka'
    ),
    (
      DateTime(1958, 4, 30, 20, 30),
      'Europe/Rome',
      '13 Imix',
      'Salice',
      'Choou, primo decano del Toro',
      15,
      'Cane',
      'Kanya'
    ),
  ];

  test('dieci nascite: sei tradizioni danno il segno delle fonti', () {
    cardinaleMinimo(nascite.length, 10, cosa: 'nascite di controllo');
    final diversi = <String>[];
    final righe = <String>[];
    for (final (quando, fuso, maya, albero, decano, dimora, animale, rashi)
        in nascite) {
      final n = NascitaDeiSegni(locale: quando, oraNota: true, fuso: fuso);
      final s = {
        for (final t in AstroTradition.values)
          t: ISegniDelleTradizioni.per(t, n),
      };
      final attesi = {
        AstroTradition.maya: maya,
        AstroTradition.celtica: albero,
        // Dall'ordine ES, vista sul Realme, il nome in grande e' il solo
        // decano; il resto sta nella frase.
        AstroTradition.egizia: decano.split(',').first,
        AstroTradition.araba: '${ISegniDelleTradizioni.dimore[dimora - 1].$1}, '
            '${ISegniDelleTradizioni.dimore[dimora - 1].$2}',
        AstroTradition.cinese: animale,
      };
      attesi.forEach((t, atteso) {
        if (s[t]!.nome != atteso) {
          diversi.add('$quando ${t.name}: app "${s[t]!.nome}", fonte '
              '"$atteso"');
        }
      });
      if (!s[AstroTradition.vedica]!.nome.startsWith('$rashi ')) {
        diversi.add('$quando vedica: app "${s[AstroTradition.vedica]!.nome}", '
            'fonte "$rashi"');
      }
      righe.add('$quando | ${s[AstroTradition.cinese]!.nome} | '
          '${s[AstroTradition.vedica]!.nome} | ${s[AstroTradition.maya]!.nome}'
          ' | ${s[AstroTradition.celtica]!.nome} | '
          '${s[AstroTradition.egizia]!.nome} | ${s[AstroTradition.araba]!.nome}');
    }
    final sintesi = 'ORDINE ES VOCI 07 E 11: nascite 10, segni confrontati '
        '${nascite.length * 6}, diversi dalla fonte ${diversi.length}';
    print(sintesi);
    for (final r in righe) {
      print(r);
    }
    if (Platform.environment['SCRIVI_LA_PROVA'] == '1') {
      File('docs/collaudo/ES/segni_dieci_nascite.txt')
        ..createSync(recursive: true)
        ..writeAsStringSync('$sintesi\n\nnascita | cinese | vedica | maya | '
            'celtica | egizia | araba\n${righe.join('\n')}\n');
    }
    expect(diversi, isEmpty, reason: diversi.join('\n'));
  });

  test('il Capodanno lunare e\' quello della tabella verificata, 201 anni', () {
    final righe = File('docs/collaudo/ES/capodanno_lunare_1900_2100.csv')
        .readAsLinesSync()
        .skip(1)
        .where((r) => r.trim().isNotEmpty)
        .toList();
    cardinaleMinimo(righe.length, 201, cosa: 'anni del Capodanno lunare');
    final diversi = <String>[];
    for (final r in righe) {
      final c = r.split(',');
      final anno = int.parse(c[0]);
      final data = DateTime.parse(c[1]);
      final app = IlCapodannoLunare.di(anno);
      if (app != data) diversi.add('$anno: app $app, tabella $data');
      final animale = ISegniDelleTradizioni.cinese(NascitaDeiSegni(
              locale: DateTime(anno, data.month, data.day), oraNota: false))
          .nome;
      if (animale != c[2]) {
        diversi.add('$anno: animale $animale, tabella ${c[2]}');
      }
      // Il giorno prima del Capodanno e' ancora l'anno di prima.
      if (anno > 1900) {
        final prima = data.subtract(const Duration(days: 1));
        final vigilia = ISegniDelleTradizioni.cinese(
                NascitaDeiSegni(locale: prima, oraNota: false))
            .nome;
        if (vigilia != c[3]) {
          diversi.add('$anno: la vigilia da\' $vigilia, tabella ${c[3]}');
        }
      }
    }
    print('ORDINE ES VOCE 07: anni del Capodanno confrontati ${righe.length}, '
        'diversi ${diversi.length}');
    expect(diversi, isEmpty, reason: diversi.take(10).join('\n'));
  });

  test('i casi limite delle fonti', () {
    DateTime g(int a, int m, int d) => DateTime(a, m, d, 12);
    String maya(DateTime d) =>
        ISegniDelleTradizioni.maya(NascitaDeiSegni(locale: d, oraNota: false))
            .nome;
    String albero(DateTime d) => ISegniDelleTradizioni.celtica(
            NascitaDeiSegni(locale: d, oraNota: false))
        .nome;
    // La data era del Lungo Computo, 13.0.0.0.0: 4 Ajaw con la GMT 584283.
    expect(maya(g(2012, 12, 21)), '4 Ajaw');
    expect(ISegniDelleTradizioni.giornoGiulianoCivile(2000, 1, 1), 2451545);
    // Graves: la Betulla dal 24 dicembre al 20 gennaio, il 23 dicembre
    // fuori dai mesi, il 29 febbraio nel Frassino.
    expect(albero(g(2001, 12, 24)), 'Betulla');
    expect(albero(g(2001, 1, 20)), 'Betulla');
    expect(albero(g(2001, 1, 21)), 'Sorbo');
    expect(albero(g(2001, 12, 22)), 'Sambuco');
    expect(albero(g(2001, 12, 23)), 'Il giorno senza albero');
    expect(albero(g(2004, 2, 29)), 'Frassino');
    // Il 1 gennaio 2000 e' ancora Coniglio, non Drago.
    expect(
        ISegniDelleTradizioni.cinese(
                NascitaDeiSegni(locale: g(2000, 1, 1), oraNota: false))
            .nome,
        'Coniglio');
    // Senza l'ora la dimora araba non si dice.
    final senzaOra = ISegniDelleTradizioni.araba(
        NascitaDeiSegni(locale: g(1990, 3, 15), oraNota: false));
    expect(senzaOra.certo, isFalse);
    expect(senzaOra.nota, isNotNull);
    // Il 23 novembre 1972 la Luna ha cambiato segno siderale: senza ora
    // il segno vedico si dice incerto, con la nota.
    final incerto = ISegniDelleTradizioni.vedica(NascitaDeiSegni(
        locale: g(1972, 11, 23), oraNota: false, fuso: 'Europe/Rome'));
    print('ORDINE ES VOCE 07: vedica senza ora il 23/11/1972: '
        '${incerto.nome}, certo ${incerto.certo}');
    // Un segno incerto dice i due possibili, non uno come se fosse certo.
    if (!incerto.certo) {
      expect(incerto.nome, contains(' o '));
      expect(incerto.nota, isNotNull);
    }
  });
}
