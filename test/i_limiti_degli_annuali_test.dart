import 'dart:io';

import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:flutter_test/flutter_test.dart';

/// **I LIMITI DELL'ANNUALE. Ordine FE voce 20.**
///
/// Il tetto del 30 per cento sul prezzo tolte IVA e store era stato contato
/// solo sui mensili (ordine EX voce 11): sull'annuale l'Adepto e
/// l'Illuminato stavano al 37 e al 38 per cento. Scelta del fondatore del 6
/// ottobre 2026, *"Domande e minuti insieme"*. Il conto sta in
/// `tool/i_limiti_degli_annuali.py`, e la sua uscita in
/// `docs/costi/i_limiti_degli_annuali.txt`: questa prova pretende che il
/// listino dica, nell'annuale, gli stessi numeri del conto, e che il conto
/// li abbia trovati sotto il tetto.
void main() {
  final strumento = File('tool/i_limiti_degli_annuali.py').readAsStringSync();
  List<int> lista(String nome) {
    final m = RegExp('^$nome = \\[([^\\]]*)\\]', multiLine: true)
        .firstMatch(strumento);
    expect(m, isNotNull, reason: '$nome non c\'e\' piu\' nello strumento');
    return [for (final x in m!.group(1)!.split(',')) int.parse(x.trim())];
  }

  test('FE.20: il listino dell\'annuale dice i numeri del conto', () {
    final domande = lista('DOMANDE_ANNUALE');
    final minuti = lista('MINUTI_ANNUALE');
    const piani = [Tier.tier1, Tier.tier2, Tier.tier3];
    final diversi = <String>[];
    for (final (i, tier) in piani.indexed) {
      final piano = PlanCatalog.plans.firstWhere((p) => p.tier == tier);
      final annuale = piano.highlightsPer(PriceCycle.yearly).join(' | ');
      if (!RegExp('\\b${domande[i]} domande').hasMatch(annuale)) {
        diversi.add('${piano.name}: non dice ${domande[i]} domande');
      }
      if (minuti[i] > 0 && !annuale.contains('${minuti[i]} minuti al mese')) {
        diversi.add('${piano.name}: non dice ${minuti[i]} minuti');
      }
      // Il mensile dice i suoi numeri: dal 6 ottobre 2026 17 e 21 per
      // l'Adepto e l'Illuminato ("Una domanda in meno").
      expect(piano.highlightsPer(PriceCycle.monthly), piano.highlights);
      final mensile = piano.highlightsPer(PriceCycle.monthly).join(' | ');
      final perMese = lista('DOMANDE_MENSILE')[i];
      if (!RegExp('\\b$perMese domande').hasMatch(mensile)) {
        diversi.add('${piano.name}: il mensile non dice $perMese domande');
      }
    }
    // ignore: avoid_print
    print('FE.20 MISURA: piani annuali confrontati col conto ${piani.length}, '
        'diversi ${diversi.length}');
    expect(diversi, isEmpty, reason: diversi.join(' | '));
  });

  test('FE.20: il conto ha trovato ogni ciclo sotto il tetto', () {
    final uscita =
        File('docs/costi/i_limiti_degli_annuali.txt').readAsStringSync();
    expect(uscita, contains('TUTTI I CICLI SOTTO IL TETTO'),
        reason: 'l\'ultima uscita del conto non trova tutti i cicli sotto il '
            'tetto: rilancia python tool/i_limiti_degli_annuali.py');
    for (final d in lista('DOMANDE_ANNUALE')) {
      expect(uscita, contains('annuale: $d domande al giorno'),
          reason: 'l\'uscita del conto non e\' quella dei numeri di oggi');
    }
  });
}
