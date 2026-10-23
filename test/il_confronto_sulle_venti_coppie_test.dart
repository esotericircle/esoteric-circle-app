import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/cerchio/il_confronto_del_cielo.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL CONFRONTO SULLE VENTI COPPIE. Ordine FD voce 02.3 e 02.4 d.
///
/// Venti coppie di segni, ciascuna in un giorno suo, sparse sul decennio: il
/// confronto e' simmetrico (A con B vale B con A) e deterministico (due
/// calcoli dello stesso caso danno lo stesso numero). La prova stampa i
/// valori: il rapporto dell'ordine FD li mette accanto a quelli misurati col
/// motore di prima, in `docs/collaudo/FD/il_confronto_prima_e_dopo.txt`.
final venti = <(Zodiac, Zodiac, DateTime)>[
  for (var i = 0; i < 20; i++)
    (
      Zodiac.values[(i * 5) % 12],
      Zodiac.values[(i * 7 + 3) % 12],
      DateTime.utc(2021 + (i * 3) % 9, 1 + (i * 5) % 12, 1 + (i * 11) % 28),
    ),
];

void main() {
  test('simmetrico e deterministico sulle venti coppie', () {
    expect(venti, hasLength(20));
    for (final (a, b, giorno) in venti) {
      final ab = IlConfrontoDelCielo.fra(a, b, giorno);
      final ba = IlConfrontoDelCielo.fra(b, a, giorno);
      final ancora = IlConfrontoDelCielo.fra(a, b, giorno);
      expect(ab.affinita, ba.affinita, reason: '$a e $b il $giorno');
      expect(ab.cieloDiOggi, ba.cieloDiOggi);
      expect(ab.affinita, ancora.affinita);
      expect(ab.cieloDiOggi, ancora.cieloDiOggi);
      expect(ab.lunaDiOggi, ancora.lunaDiOggi);
      // ignore: avoid_print
      print('CONFRONTO ${a.name} ${b.name} '
          '${giorno.toIso8601String().substring(0, 10)} '
          'affinita ${ab.affinita} cielo ${ab.cieloDiOggi} '
          'luna ${ab.lunaDiOggi.name}');
    }
  });
}
