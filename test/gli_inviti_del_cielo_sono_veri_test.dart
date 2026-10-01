// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/astro/celestial.dart';
import 'package:esoteric_circle/core/astro/effemeridi.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/maestro/consiglio_finale.dart';
import 'package:flutter_test/flutter_test.dart';

/// **GLI INVITI DEL CIELO SONO VERI.** Ordine EV, voce EV.10. Dalle catture
/// dei fondatori, sotto la risposta di Medora: *"Rivediamoci domani: la Luna
/// entra in Gemelli"*. Sessanta giorni, due ore al giorno, le due forme
/// dell'invito di Medora (l'ingresso e la fase) accanto al cielo cercato al
/// minuto sulle effemeridi dell'app: il segno e la fase devono essere quelli
/// che vengono, e il giorno ("oggi, più tardi", "domani", "fra n giorni")
/// quello in cui accadono. La misura intera, quattro ore al giorno, sta in
/// `docs/collaudo/EV/inviti_del_cielo.txt` (`tool/inviti_del_cielo.dart`).
Zodiac _segno(DateTime t) => Zodiac.values[(Effemeridi.longitudineEclittica(
            CorpoCeleste.luna, Celestial.julianDay(t.toUtc())) ~/
        30) %
    12];

int _quarto(DateTime t) {
  final jd = Celestial.julianDay(t.toUtc());
  return ((Effemeridi.longitudineEclittica(CorpoCeleste.luna, jd) -
              Effemeridi.longitudineEclittica(CorpoCeleste.sole, jd)) %
          360 ~/
          90) %
      4;
}

DateTime _primoCambio(DateTime da, Object Function(DateTime) di) {
  final ora = di(da);
  var t = da;
  while (di(t) == ora) {
    t = t.add(const Duration(minutes: 20));
  }
  var a = t.subtract(const Duration(minutes: 20));
  while (di(a) == ora) {
    a = a.add(const Duration(minutes: 1));
  }
  return a;
}

int _giorni(DateTime da, DateTime a) => DateTime.utc(a.year, a.month, a.day)
    .difference(DateTime.utc(da.year, da.month, da.day))
    .inDays;

void main() {
  test('ORDINE EV VOCE 10: l\'invito della chat parla di adesso', () {
    // Con l'ora della risposta, una chat riaperta il giorno dopo diceva
    // ancora "domani" per un ingresso gia' avvenuto.
    final bolla = File('lib/features/maestri/chat/widgets/chat_bubble.dart')
        .readAsStringSync();
    final i = bolla.indexOf('RigaDelConsiglio(');
    expect(i, greaterThan(0));
    final codice = bolla
        .substring(i, i + 700)
        .split('\n')
        .where((r) => !r.trimLeft().startsWith('//'))
        .join('\n');
    print('ORDINE EV VOCE 10: la chat passa all\'invito '
        '${RegExp(r'quando: ([^,]+),').firstMatch(codice)?.group(1)}');
    expect(codice, contains('quando: DateTime.now()'));
  });

  test('ORDINE EV VOCE 10: gli inviti nominano il cielo vero', () {
    const fasi = [
      'la Luna nuova',
      'il Primo quarto',
      'la Luna piena',
      "l'Ultimo quarto",
    ];
    var inviti = 0;
    final sbagliati = <String>[];
    for (var g = 0; g < 60; g++) {
      for (final h in const [9, 21]) {
        final quando = DateTime(2026, 9, 15 + g, h, 30);
        final ingresso = ProssimoCambioDellaLuna.ingresso(quando);
        final entra = _primoCambio(quando, _segno);
        inviti++;
        if (ingresso.cosa != _segno(entra).italianName ||
            ingresso.fraGiorni != _giorni(quando, entra)) {
          sbagliati.add('$quando: entra in ${ingresso.cosa} fra '
              '${ingresso.fraGiorni}, il cielo dice ${_segno(entra).italianName} '
              'il $entra');
        }
        final fase = ProssimoCambioDellaLuna.fase(quando);
        final esatta = _primoCambio(quando, _quarto);
        inviti++;
        if (fase.cosa != fasi[_quarto(esatta)] ||
            fase.fraGiorni != _giorni(quando, esatta)) {
          sbagliati.add('$quando: ${fase.cosa} fra ${fase.fraGiorni}, il '
              'cielo dice ${fasi[_quarto(esatta)]} il $esatta');
        }
      }
    }
    print('ORDINE EV VOCE 10: inviti col cielo sbagliato ${sbagliati.length} '
        'su $inviti');
    expect(sbagliati, isEmpty, reason: sbagliati.take(8).join('\n'));
  });
}
