import 'dart:io';

import 'package:esoteric_circle/features/rituals/dream_rite_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LA STELLA NON FINISCE SOTTO IL TESTO.** Ordine CQ voce 1.07,
/// 3 settembre 2026.
///
/// **Il fatto, parole del fondatore:** *"l'area di tocco della stella e'
/// coperta dall'etichetta sopra di essa."*
///
/// **La causa, misurata e non dedotta.** La costellazione vive in una fascia
/// di cielo alta il 46 per cento dello schermo, e il blocco del testo comincia
/// esattamente li'. Le stelle senza spostamento stanno fra il 13 e il 43 per
/// cento, cioe' dentro. **Lo spostamento della parallasse le portava via**:
/// l'inclinazione moltiplicata per trecentoventi, di cui alla costellazione
/// arriva il cinquantacinque per cento, fa fino a centosettantasei punti su
/// uno schermo di ottocentoquaranta. Una stella al 43 per cento finiva al 64,
/// cioe' sotto il testo, che sta piu' in alto nella pila e mangia il tocco su
/// tutta la sua area: **il dito arrivava sulla riga "Tocca la stella che
/// pulsa" invece che sulla stella.**
///
/// **PROVENIENZA IGNOTA.** La mappa della stella e il blocco del testo sono
/// nati in ordini diversi e nessuno dei due ha mai nominato l'altro: non c'e'
/// una voce a cui attribuire l'incontro fra la fascia e il testo. E' un
/// difetto entrato senza lasciare traccia, e questa riga lo dice.
///
/// **PERCHE' LA GUARDIA NON MONTA LA SCHERMATA.** Dentro una prova il
/// giroscopio non c'e' e l'inclinazione vale zero: montando il rito si
/// vedrebbero le stelle sempre a riposo, cioe' esattamente il caso che non
/// falliva mai. Il caso del fondatore e' il telefono inclinato in mano, e si
/// misura interrogando la mappa con lo spostamento che l'inclinazione produce.
void main() {
  test('a qualunque inclinazione la stella resta nella fascia di cielo', () {
    const larghezza = 390.0;
    const altezza = 844.0;
    // Lo spostamento massimo che la scena puo' produrre: l'inclinazione
    // satura vale 1, per 320, per il 55 per cento del piano della
    // costellazione, piu' i 46 punti del trascinamento a dito.
    const estremo = (320.0 + 46.0) * 0.55;
    final fuori = <String>[];
    var guardate = 0;
    for (var i = -10; i <= 10; i++) {
      final off = Offset(0, estremo * i / 10);
      for (var y = 0; y <= 10; y++) {
        for (var x = 0; x <= 2; x++) {
          guardate++;
          final dove = doveVaLaStella(Offset(x / 2, y / 10),
              larghezza: larghezza, altezza: altezza, off: off);
          if (dove.dy >= altezza * fasciaCielo) {
            fuori.add('con spostamento ${off.dy.round()} la stella '
                '${(y / 10).toStringAsFixed(1)} va a ${dove.dy.round()}');
          }
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 1.07: posizioni guardate $guardate, sotto il '
        'testo ${fuori.length}${fuori.isEmpty ? "" : " ${fuori.first}"}');
    cardinaleMinimo(guardate, 100,
        cosa: 'posizioni di stella provate a inclinazioni diverse',
        perche: 'Con pochi campioni la prova non attraverserebbe il bordo '
            'della fascia, e sarebbe verde per non averlo mai toccato.');
    expect(fuori, isEmpty,
        reason: 'la stella finisce dentro l area del testo, dove il tocco lo '
            'prende il testo e non lei: ${fuori.take(3).join(" | ")}');
  });

  test('la stella si muove ancora: non e stata inchiodata', () {
    // **UNA GUARDIA CHE PRETENDE UN LIMITE INVITA A SPEGNERE LA COSA.** Il
    // modo piu' rapido di far passare la prova qui sopra sarebbe togliere la
    // parallasse alla costellazione, e sarebbe un rimedio peggiore del male:
    // il cielo di questo rito si muove col telefono, ed e' la sua idea.
    const altezza = 844.0;
    final quote = <double>{};
    for (var i = -10; i <= 10; i++) {
      quote.add(doveVaLaStella(const Offset(0.5, 0.5),
              larghezza: 390, altezza: altezza, off: Offset(0, 20.0 * i))
          .dy);
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 1.07: quote diverse assunte dalla stella di mezzo '
        '${quote.length}, da ${quote.reduce((a, b) => a < b ? a : b).round()} '
        'a ${quote.reduce((a, b) => a > b ? a : b).round()}');
    expect(quote.length, greaterThan(10),
        reason: 'la stella assume poche quote diverse: la parallasse e stata '
            'spenta per far passare la prova qui sopra');
  });

  test('il testo comincia dove finisce la fascia, e la fascia e una sola', () {
    // **LE DUE MISURE DEVONO RESTARE LA STESSA.** Se domani il blocco del
    // testo cominciasse piu' in alto senza che la fascia si stringa, il
    // difetto tornerebbe identico e la prova qui sopra resterebbe verde,
    // perche' guarda la fascia e non il testo.
    final schermata =
        File('lib/features/rituals/dream_rite_screen.dart').readAsStringSync();
    final quante = 'fasciaCielo'.allMatches(schermata).length;
    // ignore: avoid_print
    print('ORDINE CQ VOCE 1.07: la fascia di cielo e nominata $quante volte');
    expect(schermata, contains('top: h * fasciaCielo,'),
        reason: 'il blocco del testo non comincia piu dalla fascia di cielo: '
            'adesso il suo bordo e un numero suo, e i due possono scostarsi '
            'senza che nessuno se ne accorga');
    expect(quante, greaterThanOrEqualTo(3),
        reason: 'la fascia di cielo e nominata meno di tre volte: la mappa '
            'della stella, il limite e il bordo del testo devono leggerla '
            'tutte e tre dallo stesso posto');
  });
}
