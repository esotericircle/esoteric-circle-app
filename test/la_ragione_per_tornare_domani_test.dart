// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/astro/effemeridi.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/horoscope/corrente_del_cielo.dart';
import 'package:esoteric_circle/core/horoscope/il_cielo_del_segno.dart';
import 'package:esoteric_circle/core/horoscope/il_domani.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LA RAGIONE PER TORNARE DOMANI DICE IL VERO SUL GIORNO DOPO.** Ordine ES
/// voce 34, 29 settembre 2026.
///
/// Trenta giorni per l'Occidentale senza carta: l'anticipazione di ogni
/// giorno deve nominare la casa solare in cui la Luna sta davvero il giorno
/// dopo, rifatta dal motore delle effemeridi. (Cinese e Vedica avranno le
/// loro anticipazioni con le voci ES.08 ed ES.09.)
void main() {
  test('trenta giorni di anticipazioni confrontati col giorno dopo', () {
    const segno = Zodiac.leo;
    final diverse = <String>[];
    final righe = <String>[];
    var giorni = 0;
    for (var g = 0; g < 30; g++) {
      final oggi = DateTime(2026, 10, 1).add(Duration(days: g));
      final riga = IlDomani.riga(segno, null, oggi);
      final domani = DateTime.utc(oggi.year, oggi.month, oggi.day, 12)
          .add(const Duration(days: 1));
      final casa = IlCieloDelSegno.casaSolare(
          segno, IlCieloDelSegno.segnoDi(CorpoCeleste.luna, domani));
      final atteso = CorrenteDelCielo.ordinaliDelleCase[casa - 1];
      giorni++;
      if (!riga.contains('tua $atteso casa solare')) {
        diverse.add('$oggi: "$riga", ma domani la Luna e\' nella $atteso');
      }
      righe.add('${oggi.toIso8601String().substring(0, 10)}: $riga');
    }
    cardinaleMinimo(giorni, 30, cosa: 'giorni di anticipazione');
    final sintesi = 'ORDINE ES VOCE 34: anticipazioni che non corrispondono '
        'al giorno dopo, ${diverse.length} su $giorni (Leone, ottobre 2026)';
    print(sintesi);
    if (Platform.environment['SCRIVI_LA_PROVA'] == '1') {
      File('docs/collaudo/ES/domani.txt')
        ..createSync(recursive: true)
        ..writeAsStringSync('$sintesi\n\n${righe.join('\n')}\n');
    }
    expect(diverse, isEmpty, reason: diverse.join('\n'));
  });
}
