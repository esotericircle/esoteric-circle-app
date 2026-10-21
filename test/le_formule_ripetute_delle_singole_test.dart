// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/tarot/le_carte_nella_posizione.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LE SINGOLE NON SI CHIUDONO TUTTE CON LA STESSA FORMULA.** Ordine GA voce
/// GA.06, terzo giro, 21 ottobre 2026.
///
/// Il lettore cieco indipendente ha contato, sulle cinquantadue singole di
/// nove stese, *"tutte le 52 risposte chiuse con 'Nella vita / Nel lavoro o
/// in un progetto / In amore la carta parla...'"*, *"27 su 52 Cosa fare con
/// 'Questa carta parla di...'"*, *"32 su 52 con 'oggi'"*.
///
/// **LA GRANDEZZA MISURATA**, sul corpus che l'app legge (il Dart generato):
/// - la quota dei registri che cominciano con le stesse tre parole, per
///   gruppo. Prima della cura: 76 per cento in amore, 97 in lavoro, 85 nella
///   vita. Dopo: il massimo e' il 30 per cento. Soglia al 45.
/// - la quota dei "Cosa fare" che spiegano con "La carta/Questa carta" e un
///   verbo (parla, indica, mostra, segnala) a inizio frase. Prima: 27 per
///   cento. Dopo: 16,5. Soglia al 20.
/// - la quota dei "Cosa fare" che portano "oggi". Prima: 63 per cento. Dopo:
///   37. Soglia al 50.
///
/// PADRE: ordine FI voce 20 (i registri) e ordine GA voce 07 (i "Cosa fare"
/// delle carte), scritti con la stessa apertura per ogni carta.
void main() {
  DrawnCard carta(TarotCard c, bool capovolta) => DrawnCard(
      card: c, position: SpreadPosition.presente, reversed: capovolta);

  test('le aperture dei registri non sono sempre le stesse', () {
    var quanti = 0;
    final guasti = <String>[];
    for (final gruppo in TarotTopicGroup.values) {
      final aperture = <String, int>{};
      var totale = 0;
      for (final c in TarotDeck.cards) {
        for (final capovolta in [false, true]) {
          final r =
              LeCarteNellaPosizione.registroDi(carta(c, capovolta), gruppo);
          if (r == null) continue;
          totale++;
          final a = r.toLowerCase().split(' ').take(3).join(' ');
          aperture[a] = (aperture[a] ?? 0) + 1;
        }
      }
      quanti += totale;
      final top = aperture.entries.reduce((a, b) => a.value >= b.value ? a : b);
      final quota = top.value / totale;
      print('ORDINE GA VOCE 06: registri ${gruppo.name} $totale, apertura '
          'piu ripetuta "${top.key}" ${(quota * 100).toStringAsFixed(0)} per '
          'cento');
      if (quota > 0.45) {
        guasti.add('${gruppo.name}: "${top.key}" apre il '
            '${(quota * 100).toStringAsFixed(0)} per cento dei registri');
      }
    }
    cardinaleMinimo(quanti, 468, cosa: 'registri guardati');
    expect(guasti, isEmpty, reason: guasti.join('\n'));
  });

  test(
      'il cosa fare non spiega sempre con "la carta parla" e non dice '
      'sempre "oggi"', () {
    var quanti = 0;
    var formula = 0;
    var oggi = 0;
    final spiega =
        RegExp(r'(^|[.:;] )(Questa|La) carta (parla|indica|mostra|segnala) ');
    for (final gruppo in TarotTopicGroup.values) {
      for (final c in TarotDeck.cards) {
        for (final capovolta in [false, true]) {
          for (final t in LeCarteNellaPosizione.cosaFareVariantiDi(
              carta(c, capovolta), gruppo)) {
            quanti++;
            if (spiega.hasMatch(t)) formula++;
            if (RegExp(r'\boggi\b').hasMatch(t)) oggi++;
          }
        }
      }
    }
    print('ORDINE GA VOCE 06: cosa fare delle carte $quanti, con la formula '
        '${(formula * 100 / quanti).toStringAsFixed(1)} per cento, con "oggi" '
        '${(oggi * 100 / quanti).toStringAsFixed(1)} per cento');
    cardinaleMinimo(quanti, 1404, cosa: 'cosa fare delle carte guardati');
    expect(formula / quanti, lessThan(0.2),
        reason: 'troppi cosa fare spiegano con la stessa formula');
    expect(oggi / quanti, lessThan(0.5),
        reason: 'troppi cosa fare dicono "oggi"');
  });
}
