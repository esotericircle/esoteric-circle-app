// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/astro/effemeridi.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/horoscope/il_cielo_del_segno.dart';
import 'package:esoteric_circle/core/horoscope/il_numero_e_il_colore.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_colors.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **NUMERO FORTUNATO E COLORE DEL GIORNO CON UNA REGOLA.** Ordine ES voce
/// 29, 29 settembre 2026.
///
/// Erano due hash. Adesso il numero e' il giorno personale della numerologia
/// (Hans Decoz) e il colore e' quello di Lilly del pianeta che oggi pesa di
/// piu'. Dieci persone per tre giorni: il valore della scheda deve essere
/// quello che la regola, rifatta qui a mano, da'.
void main() {
  test('l\'esempio di Decoz: nato il 12 aprile, anno personale 3 nel 2021', () {
    // Anno personale: 4 + 12 = 16 -> 7; 7 + 2021 = 2028 -> 3.
    final anno = IlNumeroEIlColore.riduci(IlNumeroEIlColore.riduci(4) +
        IlNumeroEIlColore.riduci(12) +
        IlNumeroEIlColore.riduci(2021));
    expect(anno, 3);
    // I numeri maestri si riducono: 11 -> 2, 22 -> 4.
    expect(IlNumeroEIlColore.riduci(11), 2);
    expect(IlNumeroEIlColore.riduci(22), 4);
  });

  test('dieci persone in tre giorni: numero e colore della regola', () {
    final persone = [
      for (var i = 0; i < 10; i++) DateTime(1960 + i * 5, 1 + i, 3 + i * 2),
    ];
    final giorni = [
      DateTime(2026, 9, 29),
      DateTime(2026, 10, 7),
      DateTime(2026, 10, 19),
    ];
    final senzaRegola = <String>[];
    final righe = <String>[];
    var schede = 0;
    for (final nascita in persone) {
      final segno = Zodiac.values[(nascita.month + 8) % 12];
      for (final oggi in giorni) {
        // In UTC: fra due date locali l'ora legale toglie un'ora e inDays
        // conterebbe un giorno in meno.
        final g = DateTime.utc(oggi.year, oggi.month, oggi.day)
            .difference(DateTime.utc(oggi.year))
            .inDays;
        final carta = Horoscope.cardFor(
            sign: segno,
            dayOfYear: g,
            year: oggi.year,
            domain: HoroscopeDomain.fortuna,
            nascita: nascita);
        schede++;
        final numero = IlNumeroEIlColore.giornoPersonale(nascita, oggi);
        final mezzogiorno =
            DateTime.utc(oggi.year).add(Duration(days: g, hours: 12));
        final luna = IlCieloDelSegno.segnoDi(CorpoCeleste.luna, mezzogiorno);
        final pianeta = IlNumeroEIlColore.signoreDi[luna]!;
        final colore = IlNumeroEIlColore.coloreDi[pianeta]!;
        if (carta.luckyNumber != numero || carta.dayColor != colore) {
          senzaRegola.add('$nascita $oggi: scheda ${carta.luckyNumber} '
              '${carta.dayColor}, regola $numero $colore');
        }
        expect(oroscopoColor(carta.dayColor), isNotNull,
            reason: 'il colore "${carta.dayColor}" non ha una tinta');
        expect(carta.rigaDellaFortuna, isNotNull);
        righe.add('nato ${nascita.day}/${nascita.month}/${nascita.year}, '
            '${oggi.day}/${oggi.month}: numero $numero (giorno personale), '
            'Luna in ${luna.italianName}, signore ${pianeta.nome}, colore '
            '$colore');
      }
    }
    cardinaleMinimo(schede, 30, cosa: 'schede della Fortuna');
    final sintesi = 'ORDINE ES VOCE 29: numeri e colori senza la regola '
        'dietro, ${senzaRegola.length} su $schede (senza carta natale)';
    print(sintesi);
    if (Platform.environment['SCRIVI_LA_PROVA'] == '1') {
      File('docs/collaudo/ES/numero_colore.txt')
        ..createSync(recursive: true)
        ..writeAsStringSync('$sintesi\n\n${righe.join('\n')}\n');
    }
    expect(senzaRegola, isEmpty, reason: senzaRegola.join('\n'));
  });
}
