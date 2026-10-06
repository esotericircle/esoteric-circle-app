// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LE CARD DEI PIANI DICONO I NUMERI DELLA MATRICE.** Ordine EX Aggiunta 6,
/// 3 ottobre 2026. Il fondatore: *"Si fammi aggiunta ordine con aumento
/// limiti di minuti. Ci saranno da cambiare anche le descrizione degli
/// abbonamenti"*, e poi: *"ogni descrizione dei piani nel menù e nelle altre
/// schermate deve dire i numeri della matrice (domande 3, 12, 18, 22 al
/// giorno; minuti di LIVE 0, 0, 80, 150 al mese)"*.
///
/// La matrice e il server si confrontano gia'
/// (`i_limiti_del_server_sono_quelli_promessi_test.dart`). Le frasi delle
/// card dei piani invece sono testo scritto a mano accanto alla matrice: il
/// giorno che un numero cambia in un posto solo, la card promette una cosa e
/// il Cerchio ne da' un'altra. Qui ogni frase che nomina le domande o i
/// minuti del LIVE deve dire il numero della matrice per quel piano.
void main() {
  const parole = {'una': 1, 'due': 2, 'tre': 3, 'cinque': 5, 'dieci': 10};

  int? numeroIn(String frase) {
    final cifra = RegExp(r'\b(\d+)\b').firstMatch(frase);
    if (cifra != null) return int.parse(cifra.group(1)!);
    for (final p in parole.entries) {
      if (RegExp('\\b${p.key}\\b').hasMatch(frase.toLowerCase())) {
        return p.value;
      }
    }
    return null;
  }

  test('le domande e i minuti di ogni card sono quelli della matrice', () {
    final diverse = <String>[];
    var domande = 0, minuti = 0;
    for (final piano in PlanCatalog.plans) {
      for (final frase in piano.highlights) {
        final basso = frase.toLowerCase();
        if (basso.contains('domand') && basso.contains('al giorno')) {
          domande++;
          final atteso = PlanCatalog.limiteGiornaliero(
              PlanCatalog.rigaDomande, piano.tier);
          if (numeroIn(frase) != atteso) {
            diverse.add('${piano.name}: "$frase" (la matrice dice $atteso)');
          }
        }
        if (basso.contains('minuti') && basso.contains('live')) {
          minuti++;
          final atteso = PlanCatalog.minutiDelLiveAlMese(piano.tier);
          if (numeroIn(frase) != atteso) {
            diverse.add('${piano.name}: "$frase" (la matrice dice $atteso)');
          }
        }
      }
    }
    print('ORDINE EX AGGIUNTA 6: frasi delle card con le domande $domande, '
        'coi minuti del LIVE $minuti; con un numero diverso dalla matrice '
        '${diverse.length}');
    // Quattro piani con le domande, due coi minuti del LIVE.
    cardinaleMinimo(domande, 4, cosa: 'frasi delle card sulle domande');
    cardinaleMinimo(minuti, 2, cosa: 'frasi delle card sui minuti del LIVE');
    expect(diverse, isEmpty, reason: diverse.join('\n'));
  });

  test('ogni piano col LIVE dice i suoi minuti nella sua card', () {
    final senza = [
      for (final piano in PlanCatalog.plans)
        if (PlanCatalog.minutiDelLiveAlMese(piano.tier) > 0 &&
            !piano.highlights.any((f) =>
                f.toLowerCase().contains('minuti') &&
                f.toLowerCase().contains('live')))
          piano.name,
    ];
    expect(senza, isEmpty);
  });

  test('i numeri della matrice sono quelli del fondatore', () {
    const ordine = [Tier.free, Tier.tier1, Tier.tier2, Tier.tier3];
    expect([for (final t in ordine) PlanCatalog.minutiDelLiveAlMese(t)],
        [0, 0, 80, 150]);
    expect([
      for (final t in ordine)
        PlanCatalog.limiteGiornaliero(PlanCatalog.rigaDomande, t)
    ], [
      3,
      12,
      // Ordine FE voce 20, 6 ottobre 2026: 17 e 21, erano 18 e 22 ("Una domanda in meno", il tetto del 30 per cento col filo del consulto).
      17,
      21
    ]);
  });
}
