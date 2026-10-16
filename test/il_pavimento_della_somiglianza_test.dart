// ignore_for_file: avoid_print
import 'dart:math';

import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/rituals/rune_presage.dart';
import 'package:esoteric_circle/core/tarot/tarot_reading.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:flutter_test/flutter_test.dart';

import 'motore_della_ripetizione.dart';

/// **IL PAVIMENTO DELLA SOMIGLIANZA, cioe' quanto l'italiano somiglia a se'
/// stesso.** Ordine DF voce 02, 11 settembre 2026.
///
/// **PERCHE' QUESTA PROVA ESISTE.** Nel referto dell'ordine DF ho scritto che
/// la misura C guarda **sequenze di cinque parole** e non coppie, e ho dato una
/// ragione con dei numeri: *"fra due testi presi da due arti diverse di questa
/// app la somiglianza a due parole sta fra il quindici e il venticinque per
/// cento, e a cinque parole e' zero"*.
///
/// **Quei numeri non si credono, si misurano.** Questa prova li misura e li
/// stampa, cosi' la riga del referto ha un comando dietro invece di una
/// memoria. E' la stessa legge che il progetto applica a ogni altro numero
/// scritto in un documento.
///
/// **E se un giorno il pavimento salisse**, per esempio perche' due arti
/// cominciano a usare le stesse formule, questa prova lo direbbe **prima** che
/// la misura C smetta di distinguere qualcosa.
void main() {
  test('FRA DUE ARTI DIVERSE: a due parole c e un pavimento, a cinque no', () {
    final caso = Random(9);

    // Dieci Stese e dieci gettate di rune, con ingressi diversi fra loro.
    final stese = <String>[];
    for (var i = 0; i < 10; i++) {
      final s = TarotSpread.draw(seed: caso.nextInt(1 << 31));
      stese.add(TarotReading.of(s, TarotTopic.values[i % TarotTopic.values.length])
          .consiglio);
    }
    final gettate = <String>[];
    for (var i = 0; i < 10; i++) {
      final e =
          RuneCast.getta(gettataNorne, random: Random(caso.nextInt(1 << 31)));
      final r = RunePresagio.componiIlResponso(e, domanda: '');
      gettate.add([r.risposta, r.cosaPuoiFare, r.daDoveViene].join('\n\n'));
    }

    // **La somiglianza a cinque parole, che e' quella che il motore usa.**
    var peggioreCinque = 0.0;
    var somma = 0.0;
    var quante = 0;
    for (final a in stese) {
      for (final b in gettate) {
        final s = MotoreDellaRipetizione.somiglianza(a, b);
        somma += s;
        quante++;
        if (s > peggioreCinque) peggioreCinque = s;
      }
    }
    final media = somma / quante;

    print('ORDINE DF VOCE 02: fra ${stese.length} Stese e ${gettate.length} '
        'gettate di rune, cioe $quante coppie di ARTI DIVERSE, la somiglianza '
        'a ${MotoreDellaRipetizione.quantoELungaUnaSequenza} parole ha media '
        '${(media * 100).toStringAsFixed(2)} per cento e massimo '
        '${(peggioreCinque * 100).toStringAsFixed(2)}');

    expect(quante, 100,
        reason: 'la prova ha confrontato $quante coppie invece di cento');
    expect(peggioreCinque, lessThan(0.05),
        reason: 'due testi di arti diverse si somigliano al '
            '${(peggioreCinque * 100).toStringAsFixed(1)} per cento anche a '
            'cinque parole: il pavimento non e zero, e la soglia della misura '
            'C sta misurando la lingua invece del compositore');

    // **E LO STESSO CONFRONTO A DUE PAROLE**, che e' la grandezza scartata:
    // serve a dimostrare che la scelta delle cinque non e' un vezzo.
    double aDueParole(String x, String y) {
      List<String> parole(String t) => t
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-zà-ÿ0-9\s]'), ' ')
          .split(RegExp(r'\s+'))
          .where((p) => p.isNotEmpty)
          .toList();
      final pa = parole(x);
      final pb = parole(y);
      if (pa.length < 2 || pb.length < 2) return 0;
      Map<String, int> coppie(List<String> p) {
        final m = <String, int>{};
        for (var i = 0; i < p.length - 1; i++) {
          final c = '${p[i]} ${p[i + 1]}';
          m[c] = (m[c] ?? 0) + 1;
        }
        return m;
      }

      final ca = coppie(pa);
      final cb = coppie(pb);
      var comuni = 0;
      for (final e in ca.entries) {
        comuni += min(e.value, cb[e.key] ?? 0);
      }
      return 2 * comuni / ((pa.length - 1) + (pb.length - 1));
    }

    var peggioreDue = 0.0;
    var sommaDue = 0.0;
    for (final a in stese) {
      for (final b in gettate) {
        final s = aDueParole(a, b);
        sommaDue += s;
        if (s > peggioreDue) peggioreDue = s;
      }
    }
    final mediaDue = sommaDue / quante;
    print('ORDINE DF VOCE 02: le stesse cento coppie, misurate a DUE parole: '
        'media ${(mediaDue * 100).toStringAsFixed(2)} per cento, massimo '
        '${(peggioreDue * 100).toStringAsFixed(2)}');

    expect(mediaDue, greaterThan(media * 3),
        reason: 'a due parole il pavimento e '
            '${(mediaDue * 100).toStringAsFixed(2)} per cento e a cinque e '
            '${(media * 100).toStringAsFixed(2)}: i due numeri sono troppo '
            'vicini perche la scelta delle cinque parole abbia senso, e la '
            'riga del referto che la motiva diventa falsa');
  });
}
