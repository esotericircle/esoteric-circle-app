// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/astro/celestial.dart';
import 'package:esoteric_circle/core/astro/effemeridi.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/maestro/consiglio_finale.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:flutter_test/flutter_test.dart';

/// **GLI INVITI DEL CIELO, ORDINE EV VOCE EV.10.** 1 ottobre 2026.
///
/// Sessanta giorni, quattro ore al giorno: l'invito di Medora
/// (`ConsiglioFinale.invitoDelRitorno`) accanto al cielo vero, cioe' il
/// segno della Luna e il suo prossimo ingresso cercati minuto per minuto
/// sulle effemeridi dell'app in tempo universale. Un invito e' sbagliato se
/// nomina un ingresso nel segno in cui la Luna gia' si trova, o se il giorno
/// che dice ("oggi, piu' tardi", "domani", "fra n giorni") non e' quello in
/// cui l'ingresso accade, nell'ora italiana.
///
///     flutter test tool/inviti_del_cielo.dart
///
/// Scrive `docs/collaudo/EV/inviti_del_cielo.txt`.
Zodiac _segno(DateTime utc) {
  final l = Effemeridi.longitudineEclittica(
      CorpoCeleste.luna, Celestial.julianDay(utc));
  return Zodiac.values[(l ~/ 30) % 12];
}

/// Il prossimo ingresso della Luna dopo [daUtc], al minuto.
(Zodiac, DateTime) _ingresso(DateTime daUtc) {
  final ora = _segno(daUtc);
  var t = daUtc;
  while (_segno(t) == ora) {
    t = t.add(const Duration(minutes: 30));
  }
  var a = t.subtract(const Duration(minutes: 30));
  while (_segno(a) == ora) {
    a = a.add(const Duration(minutes: 1));
  }
  return (_segno(a), a);
}

/// La prossima fase principale dopo [daUtc], al minuto, col suo articolo.
(String, DateTime) _fase(DateTime daUtc) {
  double elongazione(DateTime t) {
    final jd = Celestial.julianDay(t);
    return (Effemeridi.longitudineEclittica(CorpoCeleste.luna, jd) -
            Effemeridi.longitudineEclittica(CorpoCeleste.sole, jd)) %
        360;
  }

  int quarto(DateTime t) => (elongazione(t) ~/ 90) % 4;
  final ora = quarto(daUtc);
  var t = daUtc;
  while (quarto(t) == ora) {
    t = t.add(const Duration(minutes: 30));
  }
  var a = t.subtract(const Duration(minutes: 30));
  while (quarto(a) == ora) {
    a = a.add(const Duration(minutes: 1));
  }
  const nomi = [
    'la Luna nuova',
    'il Primo quarto',
    'la Luna piena',
    "l'Ultimo quarto",
  ];
  return (nomi[quarto(a)], a);
}

int _giorniDiCalendario(DateTime da, DateTime a) =>
    DateTime.utc(a.year, a.month, a.day)
        .difference(DateTime.utc(da.year, da.month, da.day))
        .inDays;

void main() {
  test('gli inviti del cielo in sessanta giorni', () {
    final righe = <String>[
      'ORDINE EV VOCE EV.10, GLI INVITI DEL CIELO: sessanta giorni dal 15 '
          'settembre 2026, alle 07:30, 12:00, 18:00 e 23:30 (ora del telefono, '
          '${DateTime(2026, 10, 1).timeZoneName}).',
      'Per ogni istante: l\'invito di Medora (la forma col prossimo '
          'ingresso: "Rivediamoci ... la Luna entra in ..."), il segno della '
          'Luna in quel momento e il suo prossimo ingresso dalle effemeridi.',
      '',
    ];
    var inviti = 0;
    var sbagliati = 0;
    final errori = <String>[];
    for (var g = 0; g < 60; g++) {
      for (final (h, m) in const [(7, 30), (12, 0), (18, 0), (23, 30)]) {
        final quando = DateTime(2026, 9, 15 + g, h, m);
        // La forma con l'ingresso: l'invito la usa nei giorni pari del giro.
        final cambio = ProssimoCambioDellaLuna.ingresso(quando);
        final dopo = switch (cambio.fraGiorni) {
          0 => 'oggi, più tardi',
          1 => 'domani',
          final n => 'fra $n giorni',
        };
        final invito = 'Rivediamoci $dopo: la Luna entra in ${cambio.cosa}.';
        final adesso = _segno(quando.toUtc());
        final (verso, alle) = _ingresso(quando.toUtc());
        final giusto = cambio.cosa == verso.italianName &&
            cambio.fraGiorni == _giorniDiCalendario(quando, alle.toLocal());
        inviti++;
        if (!giusto) {
          sbagliati++;
          errori.add('$quando: "$invito" ma la Luna e\' in '
              '${adesso.italianName} ed entra in ${verso.italianName} il '
              '${alle.toLocal()}');
        }
        righe.add('${quando.toString().substring(0, 16)}  '
            '${giusto ? 'GIUSTO ' : 'SBAGLIATO'}  "$invito"  Luna in '
            '${adesso.italianName}, entra in ${verso.italianName} il '
            '${alle.toLocal().toString().substring(0, 16)}');
      }
    }
    // **LA SECONDA FORMA, la fase.** "Ripassa ..., per la Luna piena": la
    // fase vera e' l'istante in cui l'elongazione della Luna dal Sole passa
    // per 0, 90, 180 o 270 gradi, cercato al minuto sulle effemeridi.
    righe
      ..add('')
      ..add('LA FORMA CON LA FASE ("Ripassa ..., per ..."):');
    for (var g = 0; g < 60; g++) {
      for (final (h, m) in const [(7, 30), (12, 0), (18, 0), (23, 30)]) {
        final quando = DateTime(2026, 9, 15 + g, h, m);
        final cambio = ProssimoCambioDellaLuna.fase(quando);
        final dopo = switch (cambio.fraGiorni) {
          0 => 'oggi, più tardi',
          1 => 'domani',
          final n => 'fra $n giorni',
        };
        final invito = 'Ripassa $dopo, per ${cambio.cosa}.';
        final (nome, alle) = _fase(quando.toUtc());
        final giusto = cambio.cosa == nome &&
            cambio.fraGiorni == _giorniDiCalendario(quando, alle.toLocal());
        inviti++;
        if (!giusto) {
          sbagliati++;
          errori.add('$quando: "$invito" ma $nome e\' il '
              '${alle.toLocal()}');
        }
        righe.add('${quando.toString().substring(0, 16)}  '
            '${giusto ? 'GIUSTO ' : 'SBAGLIATO'}  "$invito"  $nome il '
            '${alle.toLocal().toString().substring(0, 16)}');
      }
    }
    // L'invito vero, per Medora, alle 07:31 del 30 settembre e del 1 ottobre.
    for (final q in [
      DateTime(2026, 9, 30, 7, 31),
      DateTime(2026, 10, 1, 7, 31)
    ]) {
      for (var id = 0; id < 2; id++) {
        righe.add('INVITO DELL\'APP $q (identita $id): '
            '${ConsiglioFinale.invitoDelRitorno(Maestro.medora, quando: q, identita: '$id')}');
      }
    }
    righe
      ..add('')
      ..add('MISURA: inviti col cielo sbagliato $sbagliati su $inviti.')
      ..addAll(errori);
    File('docs/collaudo/EV/inviti_del_cielo.txt')
        .writeAsStringSync('${righe.join('\n')}\n');
    print('ORDINE EV VOCE 10: inviti col cielo sbagliato $sbagliati su '
        '$inviti\n${errori.take(10).join('\n')}');
    print(righe.where((r) => r.startsWith('INVITO')).join('\n'));
  });
}
