import 'dart:io';

import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL BENVENUTO, L'ACCREDITO DEL GIORNO E LA DOTE. Ordine AN voce 07.
///
/// Il benvenuto e l'accredito del giorno vivono sul SERVER, dentro
/// `statoDelCerchio`, che e' cio' che il client chiede a ogni apertura: le
/// loro prove stanno in `functions/src/cerchio.test.ts` e girano con
/// `npm test`. Qui si sorveglia la parte che vive nel client: la dote dei
/// piani, che la pagina mostra come valore del piano.
void main() {
  test('la dote cresce col piano, e il gratuito non ne ha', () {
    expect(PlanCatalog.doteDellaSottoscrizione[Tier.free], 0);
    expect(PlanCatalog.doteDellaSottoscrizione[Tier.tier1], 500);
    expect(PlanCatalog.doteDellaSottoscrizione[Tier.tier2], 1500);
    expect(PlanCatalog.doteDellaSottoscrizione[Tier.tier3], 3000);
  });

  test('la dote si scrive come si legge', () {
    expect(PlanCatalog.doteScritta(Tier.tier1), '500 Eos');
    expect(PlanCatalog.doteScritta(Tier.tier2), '1.500 Eos');
    expect(PlanCatalog.doteScritta(Tier.tier3), '3.000 Eos');
    expect(PlanCatalog.doteScritta(Tier.free), isNull,
        reason: 'il piano gratuito non ha una dote, e non si finge che ce '
            'l\'abbia');
    // ignore: avoid_print
    print('ORDINE AN VOCE 07: doti ${[
      for (final t in Tier.values) PlanCatalog.doteScritta(t)
    ]}');
  });

  test('la dote sta nella pagina dei Piani, come valore del piano', () {
    final riga = PlanCatalog.matrix
        .where((r) => r.label.contains('dono alla sottoscrizione'));
    expect(riga, isNotEmpty,
        reason: 'la dote non compare nella matrice dei Piani: il valore del '
            'piano resterebbe invisibile a chi lo sta valutando');
    expect(riga.first.values, ['No', '500', '1.500', '3.000'],
        reason: 'i numeri della pagina non sono quelli della dote');
  });

  test('le azioni premiate non esistono nel client', () {
    // Decisione di Mauro del 18 agosto: login, oracolo, soffio, mood,
    // meditazione e video NON premiano, e non si predispone niente per
    // loro. Questa prova enumera i sorgenti e cade se qualcuno le
    // reintroduce da una porta laterale.
    final colpevoli = <String>[];
    final sospetti = RegExp(
        r'''(premio|bonus)_(login|oracolo|soffio|mood|meditazione|video)''');
    var osservati = 0;
    for (final voce in Directory('lib').listSync(recursive: true)) {
      if (voce is! File || !voce.path.endsWith('.dart')) continue;
      osservati++;
      final trovato = sospetti.firstMatch(voce.readAsStringSync());
      if (trovato != null) {
        colpevoli.add('${voce.path}: ${trovato.group(0)}');
      }
    }
    // ignore: avoid_print
    print('ORDINE AN VOCE 07: sorgenti osservati $osservati');
    expect(osservati, greaterThan(100));
    expect(colpevoli, isEmpty,
        reason: 'le azioni premiate sono tornate:\n${colpevoli.join("\n")}');
  });
}
